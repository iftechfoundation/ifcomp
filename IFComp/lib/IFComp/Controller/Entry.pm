package IFComp::Controller::Entry;
use Moose;
use namespace::autoclean;
use String::Random;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Entry - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

use IFComp::Form::Entry;
use IFComp::Form::WithdrawEntry;
use IFComp::Form::Coauthorship;

use MIME::Types;
use Imager;
use DateTime;

use Readonly;
Readonly my $MAX_ENTRIES => 3;

has 'form' => (
    is         => 'ro',
    isa        => 'IFComp::Form::Entry',
    lazy_build => 1,
);

has 'withdrawal_form' => (
    is         => 'ro',
    isa        => 'IFComp::Form::WithdrawEntry',
    lazy_build => 1,
);

has 'coauthorship_form' => (
    is         => 'ro',
    isa        => 'IFComp::Form::Coauthorship',
    lazy_build => 1,
);

has 'entry' => (
    is  => 'rw',
    isa => 'Maybe[IFComp::Schema::Result::Entry]',
);

sub root : Chained('/') : PathPart('entry') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user ) {
        $c->res->redirect('/auth/login');
        return;
    }

    my @entries = $c->user->get_object->current_comp_entries;
    my @collabs = $c->model('IFCompDB::EntryCoauthor')->search({ coauthor => $c->user });

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;

    $c->stash(
        form         => $self->form,
        entries      => \@entries,
        collabs      => \@collabs,
        current_comp => $current_comp,
    );

}

sub fetch_entry : Chained('root') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $entry = $c->model('IFCompDB::Entry')->find($id);
    if ( $entry && $entry->author->id eq $c->user->get_object->id ) {
        $c->stash->{entry} = $entry;
        $self->entry($entry);
    }
    else {
        $c->res->redirect('/');
    }
}

sub list : Chained('root') : PathPart('') : Args(0) {
    my ( $self, $c ) = @_;
}

sub preview : Chained('root') : PathPart('preview') : Args(0) {
    my ( $self, $c ) = @_;
}

sub create : Chained('root') : PathPart('create') : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->stash->{current_comp}->status eq 'accepting_intents' ) {
        $c->res->redirect( $c->uri_for_action('/entry/list') );
    }

    my $gen = String::Random->new;
    $gen->{'I'} = [ 'A'..'Z', 'a'..'z', '0'..'9', '_' ];
    my $code = $gen->randpattern('I' x 20);

    my %new_result_args = (
        comp   => $c->stash->{current_comp},
        author => $c->user->get_object->id,
        code   => $code,
    );

    $c->stash( entry =>
            $c->model('IFCompDB::Entry')->new_result( \%new_result_args ) );
    if ( $self->_process_form($c) ) {
        $c->res->redirect( $c->uri_for_action('/entry/list') );
    }
}

sub update : Chained('fetch_entry') : PathPart('update') : Args(0) {
    my ( $self, $c ) = @_;

    my $status = $c->stash->{current_comp}->status;
    unless ( ( $status eq 'accepting_intents' )
        || ( $status eq 'closed_to_intents' )
        || ( $status eq 'open_for_judging' ) )
    {
        $c->res->redirect( $c->uri_for_action('/entry/list') );
    }

    $self->_process_form($c);

    $self->_process_withdrawal_form($c);
}

sub cover : Chained('fetch_entry') : PathPart('cover') : Args(0) {
    my ( $self, $c ) = @_;

    my $file = $c->stash->{entry}->cover_file;
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

sub current_comp_test : Chained('fetch_entry') : PathPart('test') : Args(0) {
    my ( $self, $c ) = @_;
}

sub transcript_list : Chained('fetch_entry') : PathPart('transcript') :
    Args(0) {
    my ( $self, $c ) = @_;

    my $session_rs = $c->model('IFCompDB::Transcript')->search(
        { entry => $c->stash->{entry}->id, },
        {   select => [
                'session',
                { max => 'inputcount', -as => 'command_count' },
                { min => 'timestamp',  -as => 'start_time' },
            ],
            as       => [qw( session_id command_count start_time )],
            group_by => 'session',
            order_by => 'start_time',
        },
    );

    $c->stash->{session_rs} = $session_rs;

}

sub transcript : Chained('fetch_entry') : PathPart('transcript') : Args(1) {
    my ( $self, $c, $session_id ) = @_;

    my @inputs;
    my @output_sets;

    my $transcript_rs = $c->model('IFCompDB::Transcript')->search(
        {   session => $session_id,
            entry   => $c->stash->{entry}->id,
            window  => 0,
        },
        { order_by => 'timestamp', },
    );

    my $current_input_count = 0;
    @output_sets = ( [] );
    while ( my $transcript = $transcript_rs->next ) {
        if ( $current_input_count != $transcript->inputcount ) {
            $current_input_count = $transcript->inputcount;
            push @inputs,      $transcript->input;
            push @output_sets, [];
        }
        push @{ $output_sets[-1] }, $transcript->output;
    }

    $c->stash(
        inputs      => \@inputs,
        output_sets => \@output_sets,
    );

}

sub feedback : Chained('root') : PathPart('feedback') : Args(0) {
    my ( $self, $c ) = @_;

    my $author_id = $c->user->get_object->id;

    # Fetch a resultset of feedback for all the current user's entries,
    # limited to competitions that have closed,
    # ordered by comp-year (descending) and entry title.
    my $dtf         = $c->model('IFCompDB')->storage->datetime_parser;
    my $feedback_rs = $c->model('IFCompDB::Feedback')->search(
        {   author      => $author_id,
            comp_closes => { '<',  $dtf->format_datetime( DateTime->now ) },
            text        => { '!=', undef },
        },
        {   join     => { entry => 'comp' },
            order_by => [ 'comp.year desc', 'entry.title' ],
        }
    );

    $c->stash( feedback_rs => $feedback_rs );
}

sub _build_form {
    return IFComp::Form::Entry->new;
}

sub _build_withdrawal_form {
    return IFComp::Form::WithdrawEntry->new;
}

sub _build_coauthorship_form {
    return IFComp::Form::Coauthorship->new;
}

sub _process_form {
    my ( $self, $c ) = @_;

    $c->stash(
        form     => $self->form,
        template => 'entry/update.tt',
    );

    my $params_ref = $c->req->parameters;
    foreach (qw( main_upload walkthrough_upload cover_upload )) {
        my $param = "entry.$_";
        if ( $params_ref->{$param} ) {
            $params_ref->{$param} = $c->req->upload($param);
        }
    }

    my $entry = $c->stash->{entry};
    if ( $self->form->process( item => $entry, params => $params_ref, ) ) {

        # Handle files
        for my $upload_type (qw( main walkthrough cover )) {
            my $deletion_param = "entry.${upload_type}_delete";
            if ( $params_ref->{$deletion_param} ) {
                my $method = "${upload_type}_file";
                if ( my $file = $entry->$method ) {
                    $entry->$method->remove;
                    my $clearer = "clear_${upload_type}_file";
                    $entry->$clearer;
                }
                if ( $upload_type eq 'cover' ) {

                    # If clearing cover art, also clear the web-cover.
                    $entry->web_cover_file->remove;
                    $entry->clear_web_cover_file;
                }
            }

            my $upload_param = "entry.${upload_type}_upload";
            if ( my $upload = $params_ref->{$upload_param} ) {
                my $file_method = "${upload_type}_file";
                if ( my $file = $entry->$file_method ) {
                    $file->remove;
                }
                my $directory_method = "${upload_type}_directory";
                my $result =
                    $upload->copy_to(
                    $entry->$directory_method->file( $upload->basename ) );
                unless ($result) {
                    die "Failed to write the $upload_type file from "
                        . $upload->tempname . " to "
                        . $entry->$directory_method->file( $upload->basename )
                        . ": $!";
                }
                my $clearer = "clear_${upload_type}_file";
                $entry->$clearer;

                # Now do extra work specific to uploaded file types.
                if ( $upload_type eq 'main' ) {

                    # This is the main game file! Process it into the entry's
                    # content directory.
                    $entry->update_content_directory;
                    if ( my $note = $self->form->field('note')->value ) {
                        $entry->add_to_entry_updates(
                            {   note => $note,
                                time => DateTime->now( time_zone => 'UTC' ),
                            }
                        );
                    }
                }
                elsif ( $upload_type eq 'cover' ) {

                    # Cover art! Preserve as-is, but also make a possibly
                    # scaled-down web copy.
                    $entry->create_web_cover_file;
                }
            }
        }

        $c->flash->{entry_updated} = 1;
        return 1;
    }
    else {
        return 0;
    }
}

sub _process_withdrawal_form {
    my ( $self, $c ) = @_;

    if ( $self->withdrawal_form->process( params => $c->req->parameters, ) ) {
        $c->stash->{entry}->delete;
        $c->flash->{entry_withdrawn} = $c->stash->{entry}->title;
        $c->res->redirect( $c->uri_for_action('/entry/list') );
    }

    $c->stash->{withdrawal_form} = $self->withdrawal_form;

}

sub _process_coauthorship_form {
    # TODO
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
