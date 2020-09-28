package IFComp::Controller::Play;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON;

__PACKAGE__->meta->make_immutable;

sub root : Chained('/') : PathPart('play') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;

    $c->stash( current_comp => $current_comp, );

}

sub fetch_entry : Chained('root') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $entry = $c->model('IFCompDB::Entry')->find($id);

    if ($entry) {
        $c->stash->{entry} = $entry;
        if ( $entry->comp->id eq $c->stash->{current_comp}->id ) {
            unless (
                   ( $c->stash->{current_comp}->status eq 'open_for_judging' )
                || ( $c->stash->{current_comp}->status eq 'processing_votes' )
                || ( $c->stash->{current_comp}->status eq 'over' )
                || ( $c->user && ( $entry->author->id eq $c->user->id ) )
                || ( $c->check_user_roles('curator') ) )
            {
                $c->res->redirect( $c->uri_for_action('/comp/comp') );
            }
        }
        else {
            $c->res->redirect(
                'http://ifdb.tads.org/viewgame?id=' . $entry->ifdb_id );
        }
    }
    else {
        $c->detach('/error_404');
    }
}

sub play_online : Chained('fetch_entry') : Args(0) {
    my ( $self, $c ) = @_;

    my $entry              = $c->stash->{entry};
    my $entry_id           = $entry->id;
    my $redirection_target = '';
    $redirection_target = $entry->play_file->stringify;

    my $redirection_path = "/$entry_id/content/$redirection_target";
    $c->res->redirect( $c->uri_for($redirection_path) );
}

# download: If the main file is a single HTML file, serve it ourselves with a proper
#           content-disposition header. Else, redirect it so that the webserver handles
#           this as a static file.
sub download : Chained('fetch_entry') : Args(0) {
    my ( $self, $c ) = @_;

    my $entry    = $c->stash->{entry};
    my $filename = $entry->main_file->basename;
    if ( $filename =~ /\.html?$/i ) {
        my $body = $entry->main_file->slurp( iomode => '<:encoding(UTF-8)' );

        $c->res->header(
            'Content-Disposition' => qq{attachment; filename="$filename"} );
        $c->res->content_type('text/html; charset=utf-8');
        $c->res->code(200);
        $c->res->body($body);
    }
    else {
        $c->res->redirect(
            $c->uri_for( '/' . $entry->id . "/main/$filename" ) );
    }
}

sub transcribe : Chained('fetch_entry') : Args(0) {
    my ( $self, $c ) = @_;

    my $entry = $c->stash->{entry};

    my $data_list_ref = $self->_normalize_transcript_data($c);

    my $now = DateTime->now( time_zone => 'UTC' );
    for my $transcript (@$data_list_ref) {
        $c->model('IFCompDB::Transcript')->create(
            {   session     => $transcript->{session},
                inputcount  => $transcript->{log}->{inputcount},
                outputcount => $transcript->{log}->{outputcount},
                window      => $transcript->{log}->{window},
                input       => $transcript->{log}->{input},
                output      => $transcript->{log}->{output},
                styles      => $transcript->{log}->{styles},

                entry     => $entry->id,
                timestamp => $now,
            }
        );
    }

    $c->res->code(200);
    $c->res->body('OK');

}

sub cover : Chained('fetch_entry') : PathPart('cover') : Args(0) {
    my ( $self, $c ) = @_;

    return $self->_cover( $c, 'web_cover_file' );
}

sub full_cover : Chained('fetch_entry') : PathPart('full_cover') : Args(0) {
    my ( $self, $c ) = @_;

    return $self->_cover( $c, 'cover_file' );
}

sub _cover {
    my ( $self, $c, $method ) = @_;

    my $file = $c->stash->{entry}->$method;
    if ( -e $file ) {
        my $image_data = $file->slurp;
        $c->res->headers->header( 'Cache-Control' => 'max-age=86400' );
        if ( $file->basename =~ /png$/ ) {
            $c->res->content_type('image/png');
        }
        else {
            $c->res->content_type('image/jpeg');
        }
        $c->res->body($image_data);
    }
    else {
        $c->detach('/error_404');
    }

}

sub updates : Chained('fetch_entry') : PathPart('updates') : Args(0) {
    my ( $self, $c ) = @_;

    my @updates = $c->stash->{entry}
        ->entry_updates->search( {}, { order_by => 'time asc', }, )->all;

    $c->stash(
        template => 'ballot/updates.tt',
        updates  => \@updates,
    );
}

sub _normalize_transcript_data {
    my ( $self, $c ) = @_;

    # Quixe (natively) and Parchment (via if-recorder) report transcription
    # data in entirely different formats.
    # We 'normalize' them to look like Parchment's, because it came first.
    my $data_list_ref;
    if ( $c->req->body_data->{data} ) {
        $data_list_ref = $self->_normalize_parchment_transcript_data($c);
    }
    else {
        $data_list_ref = $self->_normalize_quixe_transcript_data($c);
    }

    return $data_list_ref;
}

sub _normalize_parchment_transcript_data {
    my ( $self, $c ) = @_;

    my $data_ref = $c->req->body_data->{data};

    unless ( ref $data_ref ) {
        $data_ref = from_json($data_ref);
    }

    my $data_list_ref;
    if ( ref $data_ref eq 'ARRAY' ) {
        $data_list_ref = $data_ref;
    }
    else {
        $data_list_ref = [$data_ref];
    }

    return $data_list_ref;
}

sub _normalize_quixe_transcript_data {
    my ( $self, $c ) = @_;

    my $quixe_data = $c->req->body_data;

    my $normalized_data = {};
    $normalized_data->{session}       = $quixe_data->{sessionId};
    $normalized_data->{log}->{input}  = $quixe_data->{input};
    $normalized_data->{log}->{output} = $quixe_data->{output};
    $normalized_data->{log}->{window} = 0;

    $normalized_data->{log}->{output} =~ s/^$quixe_data->{input}//g;

    my $input_count = $c->model('IFCompDB::Transcript')->search(
        {   entry   => $c->stash->{entry}->id,
            session => $quixe_data->{sessionId},
        },
    )->get_column('inputcount')->max;

    my $output_count = ++$input_count;

    $normalized_data->{log}->{outputcount} = $output_count;
    $normalized_data->{log}->{inputcount}  = $input_count;

    return [$normalized_data];

}

1;
