package IFComp::Controller::Play;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON;

__PACKAGE__->meta->make_immutable;

sub root :Chained('/') :PathPart('play') :CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $current_comp = $c->model( 'IFCompDB::Comp' )->current_comp;

    $c->stash(
        current_comp => $current_comp,
    );

}

sub fetch_entry :Chained('root') :PathPart('') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $entry = $c->model( 'IFCompDB::Entry' )->search(
        {
            id => $id,
            comp => $c->stash->{ current_comp }->id,
        }
    )->single;

    if ( $entry ) {
        $c->stash->{ entry } = $entry;
        unless (
            ( $c->stash->{ current_comp }->status eq 'open_for_judging' )
            || ( $c->stash->{ current_comp }->status eq 'processing_votes' )
            || ( $c->stash->{ current_comp }->status eq 'over' )
            || ( $c->user && ( $entry->author->id eq $c->user->id ) )
        ) {
            $c->res->redirect( $c->uri_for_action( '/comp/comp' ) );
        }
    }
    else {
        $c->res->code( 404 );
        $c->res->body( "No valid entry with ID $id" );
        $c->detach;
    }
}

sub play_online :Chained('fetch_entry') :Args(0) {
    my ( $self, $c ) = @_;

    my $entry = $c->stash->{ entry };
    my $entry_id = $entry->id;
    my $redirection_target = '';
    if ( $entry->platform eq 'html' ) {
        $redirection_target = $entry->main_file->basename;
    }
    else {
        $redirection_target = 'index.html';
    }

    my $redirection_path = "/$entry_id/content/$redirection_target";
    $c->res->redirect( $c->uri_for( $redirection_path ) );
}

# download: If the main file is a single HTML file, serve it ourselves with a proper
#           content-disposition header. Else, redirect it so that the webserver handles
#           this as a static file.
sub download :Chained('fetch_entry') :Args(0) {
    my ( $self, $c ) = @_;

    my $entry = $c->stash->{ entry };
    my $filename = $entry->main_file->basename;
    if ( $entry->platform eq 'html' ) {
        my $body = $entry->main_file->slurp;
        $c->res->header( 'Content-Disposition' => "attachment; filename=$filename" );
        $c->res->content_type( 'text/html' );
        $c->res->code( 200 );
        $c->res->body( $body );
    }
    else {
        $c->res->redirect(
            $c->uri_for( '/' . $entry->id . "/main/$filename" )
        );
    }
}

sub transcribe :Chained('fetch_entry') :Args(0) {
    my ( $self, $c ) = @_;

    my $entry = $c->stash->{ entry };


    my $data_ref = $c->req->body_data->{ data };
    unless ( ref $data_ref ) {
        $data_ref = decode_json( $data_ref );
    }

    my $data_list_ref;
    if ( ref $data_ref eq 'ARRAY' ) {
        $data_list_ref = $data_ref;
    }
    else {
        $data_list_ref = [ $data_ref ];
    }

    my $now = DateTime->now( time_zone => 'UTC' );
    for my $transcript ( @$data_list_ref ) {
        $c->model( 'IFCompDB::Transcript' )->create( {
            session => $transcript->{ session },
            inputcount => $transcript->{ log }->{ inputcount },
            outputcount => $transcript->{ log }->{ outputcount },
            window => $transcript->{ log }->{ window },
            input => $transcript->{ log }->{ input },
            output => $transcript->{ log }->{ output },
            styles => $transcript->{ log }->{ styles },

            entry => $entry->id,
            timestamp => $now,
        } );
    }

    $c->res->code( 200 );
    $c->res->body( 'OK' );

}

sub cover :Chained('fetch_entry') :PathPart('cover') :Args(0) {
    my ( $self, $c ) = @_;

    my $file = $c->stash->{ entry }->cover_file;
    if ( -e $file ) {
        my $image_data = $file->slurp;
        if ( $file->basename =~ /png$/ ) {
            $c->res->content_type( 'image/png' );
        }
        else {
            $c->res->content_type( 'image/jpeg' );
        }
        $c->res->body( $image_data );
    }
    else {
        $c->res->code( 404 );
        $c->res->body( '' );
    }
}

sub updates :Chained('fetch_entry') :PathPart('updates') :Args(0) {
    my ( $self, $c ) = @_;

    my @updates = $c->stash->{ entry }->entry_updates->search(
        {},
        { order_by => 'time asc', },
    )->all;

    $c->stash(
        template => 'ballot/updates.tt',
        updates  => \@updates,
    );
}

1;
