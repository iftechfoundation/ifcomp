package IFComp::Form::Entry;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+enctype' => ( default => 'multipart/form-data');
has '+widget_wrapper' => (
    default => 'Bootstrap3',
);

has '+name' => ( default => 'entry' );
has '+html_prefix' => ( default => 1 );

use Readonly;
Readonly my $MAX_FILE_SIZE => 10485760;
Readonly my $MAX_GAME_SIZE => 26214400;

has_field 'title' => (
    required => 1,
    type => 'Text',
);

has_field 'subtitle' => (
    type => 'Text',
);

has_field 'blurb' => (
    type => 'TextArea',
);

has_field 'pseudonym' => (
    type => 'Text',
    label => 'Your pseudonym (if using one for this entry)',
);

has_field 'reveal_pseudonym' => (
    default => 1,
    label => 'Reveal your identity after the comp ends (if using a pseuodym)?',
    type => 'Checkbox',
);

has_field 'email' => (
    type => 'Email',
    label => 'Contact email to display for this game',
);

has_field 'main_upload' => (
    type => 'Upload',
    label => 'Upload a new main game file',
    max_size => $MAX_GAME_SIZE,
);

has_field 'cover_upload' => (
    type => 'Upload',
    label => 'Upload new cover art',
    max_size => $MAX_FILE_SIZE,
);

has_field 'walkthrough_upload' => (
    type => 'Upload',
    label => 'Upload a new main walkthrough or hint file',
    max_size => $MAX_FILE_SIZE,
);

has_field 'online_play_upload' => (
    type => 'Upload',
    label => 'Uplaod a new online-play file',
    max_size => $MAX_FILE_SIZE,
);

has_field 'main_delete' => (
    type => 'Checkbox',
    label => 'Delete main game file',
);

has_field 'online_play_delete' => (
    type => 'Checkbox',
    label => 'Delete online-play file',
);

has_field 'walkthrough_delete' => (
    type => 'Checkbox',
    label => 'Delete walkthrough file',
);

has_field 'cover_delete' => (
    type => 'Checkbox',
    label => 'Delete cover art file',
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Submit game information',
    element_attr => {
        class => 'btn btn-success',
    },
);

sub validate_reveal_pseudonym {
    my $self = shift;
    my ( $field ) = @_;

    if ( $field->value && not $self->field( 'pseudonym' )->value ) {
        $field->add_error( "This setting makes sense only if you're setting "
                           . "a pseudonym." );
    }
}

sub validate_cover_upload {
    my $self = shift;
    my ( $field ) = @_;

    if ( $field->value && not $field->value->filename =~ /\.(pn|jpe?)g$/ ) {
        $field->add_error( "This doesn't appear to be a PNG or JPEG file.");
    }
}

1;
