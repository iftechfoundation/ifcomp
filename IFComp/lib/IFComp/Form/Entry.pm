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

has_field 'playtime' => (
    type => 'Select',
    label => 'Estimated play time',
    empty_select => '',
    id => 'playtime',
    options => [[
        '15 minutes or less',
        'half an hour',
        'one hour',
        'an hour and a half',
        'two hours',
        'longer than two hours',
    ]],
);

has_field 'warning' => (
    type => 'Text',
);

has_field 'author_pseudonym' => (
    type => 'Text',
    label => 'Displayed pseudonym or author-list (if different from your registered name)',
);

has_field 'reveal_pseudonym' => (
    default => 1,
    label => 'Reveal your identity after the comp ends (if using a pseudonym)',
    type => 'Checkbox',
);

has_field 'email' => (
    type => 'Email',
    label => 'Contact email to display for this game',
);

has_field 'main_upload' => (
    type => 'Upload',
    label => 'Upload a new game file',
    max_size => $MAX_GAME_SIZE,
);

has_field 'cover_upload' => (
    type => 'Upload',
    label => 'Upload new cover art',
    max_size => $MAX_FILE_SIZE,
);

has_field 'walkthrough_upload' => (
    type => 'Upload',
    label => 'Upload a new walkthrough or hint file',
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

has_field 'note' => (
    type => 'TextArea',
    label => 'Reason for this update (Will be player-visible; avoid spoilers)',
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Submit game information',
    element_attr => {
        class => 'btn btn-success',
    },
);

before 'validate_form' => sub {
    my $self = shift;

    if (
        $self->item
        && $self->item->id
        && (
            ( $self->item->comp->status eq 'closed_to_entries' )
            || ( $self->item->comp->status eq 'open_for_judging' )
        )
    ) {
        $self->field( 'title' )->inactive( 1 );
        $self->field( 'title' )->required( 0 );
    }
};

sub validate_reveal_pseudonym {
    my $self = shift;
    my ( $field ) = @_;

    if ( $field->value && not $self->field( 'author_pseudonym' )->value ) {
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

sub validate_main_upload {
    my $self = shift;
    my ( $field ) = @_;

    if (
        $self->item
        && $self->item->id
        && (
            ( $self->item->comp->status eq 'closed_to_entries' )
            || ( $self->item->comp->status eq 'open_for_judging' )
        )
        && not $self->field( 'note' )->input
    ) {
        $field->add_error( "You must provide a reason for this update." );
    }
}

1;
