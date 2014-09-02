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
    }
    else {
        $c->res->code( 404 );
        $c->res->body( "No valid entry with ID $id" );
    }
}

sub download :Chained('fetch_entry') :Args(0) {
    my ( $self, $c ) = @_;

    $self->_serve_file( $c, 'main_file' );
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

sub walkthrough :Chained('fetch_entry') :Args(0) {
    my ( $self, $c ) = @_;

    $self->_serve_file( $c, 'walkthrough_file' );
}

sub transcribe :Chained('fetch_entry') :Args(0) {
    my ( $self, $c ) = @_;

    my $entry = $c->stash->{ entry };

    my $data_ref = decode_json( $c->req->body_data->{ data } );
    my $now = DateTime->now( time_zone => 'UTC' );
    for my $transcript ( @$data_ref ) {
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

sub _serve_file {
    my ( $self, $c, $method ) = @_;

    my $file = $c->stash->{ entry }->$method;

    my $mime_type = MIME::Types->mimeTypeOf( $file );

    $c->res->content_type( $mime_type->type );
    $c->res->body( $file->open );

}


1;
