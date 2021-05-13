package IFComp::Form::Entry;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

use Imager;

has '+enctype'        => ( default => 'multipart/form-data' );
has '+widget_wrapper' => ( default => 'Bootstrap3', );

has '+name'        => ( default => 'entry' );
has '+html_prefix' => ( default => 1 );

use Readonly;
Readonly my $MAX_FILE_SIZE => 10485760;
Readonly my $MAX_GAME_SIZE => 262144000;
Readonly my $MAX_ENTRIES   => 3;

has_field 'title' => (
    required  => 1,
    type      => 'Text',
    maxlength => 128,
);

has_field 'subtitle' => (
    type      => 'Text',
    maxlength => 128,
);

has_field 'platform' => (
    type    => 'Select',
    id      => 'platform',
    label   => 'Gameplay platform',
    options => [
        {   value => 'website',
            label => 'Browser-based JavaScript (including Twine)',
        },
        {   value => 'inform',
            label => 'Glulx or Z-code, not packaged with a website',
        },
        {   value => 'quixe',
            label =>
                q{Glulx, using Inform's "Release with a website" feature},
        },
        {   value => 'parchment',
            label =>
                q{Z-code, using Inform's "Release with a website" feature},
        },
        {   value => 'inform-website',
            label => 'Glulx or Z-code, presented within a custom website',
        },
        {   value => 'quest',
            label => 'Quest (download-only)',
        },
        {   value => 'quest-online',
            label => 'Quest (online play available)',
        },
        {   value => 'tads',
            label => 'TADS (regular UI)',
        },
        {   value => 'tads-web-ui',
            label => 'TADS 3.1 Web UI',
        },
        {   value => 'windows',
            label => 'A Windows executable',
        },
        {   value => 'alan',
            label => 'Alan',
        },
        {   value => 'hugo',
            label => 'Hugo',
        },
        {   value => 'adrift',
            label => 'ADRIFT (download-only)',
        },
        {   value => 'adrift-online',
            label => 'ADRIFT (online play available)',
        },
        {   value => 'other',
            label => 'Other',
        },
    ],
);

has_field 'genre' => (
    type      => 'Text',
    maxlength => 48,
);

has_field 'blurb' => ( type => 'TextArea', );

has_field 'playtime' => (
    type         => 'Select',
    label        => 'Estimated play time',
    empty_select => '( No estimate )',
    id           => 'playtime',
    options      => [
        [   '15 minutes or less',
            'half an hour',
            'one hour',
            'an hour and a half',
            'two hours',
            'longer than two hours',
        ]
    ],
);

has_field 'warning' => ( type => 'Text', maxlength => 250 );

has_field 'style' => (
    type         => 'Select',
    label        => 'Interaction style',
    empty_select => '-- Please choose an option --',
    id           => 'style',
    options      => [
        {   value => 'parser',
            label => 'Primarily parser-based',
        },
        { value => 'choice', label => 'Primarily choice-based', },
        { value => 'other',  label => 'Neither (or both!) of the above', },
    ],
);

has_field 'author_pseudonym' => (
    type => 'Text',
    label =>
        'Displayed pseudonym or author-list (if different from your registered name)',
    maxlength => 64,
);

has_field 'reveal_pseudonym' => (
    default => 1,
    label =>
        'Reveal your identity after the comp ends (if using a pseudonym)',
    type => 'Checkbox',
);

has_field 'collaborator_delete' => {
    type  => 'Checkbox',
    label => 'Remove co-author',
};

has_field 'email' => (
    type      => 'Email',
    label     => 'Contact email to display for this game',
    maxlength => 64,
);

has_field 'main_upload' => (
    type     => 'Upload',
    label    => 'Upload a new game file',
    max_size => $MAX_GAME_SIZE,
);

has_field 'cover_upload' => (
    type     => 'Upload',
    label    => 'Upload new cover art',
    max_size => $MAX_FILE_SIZE,
);

has_field 'walkthrough_upload' => (
    type     => 'Upload',
    label    => 'Upload a new walkthrough or hint file',
    max_size => $MAX_FILE_SIZE,
);

has_field 'online_play_upload' => (
    type     => 'Upload',
    label    => 'Uplaod a new online-play file',
    max_size => $MAX_FILE_SIZE,
);

has_field 'main_delete' => (
    type  => 'Checkbox',
    label => 'Delete main game file',
);

has_field 'online_play_delete' => (
    type  => 'Checkbox',
    label => 'Delete online-play file',
);

has_field 'walkthrough_delete' => (
    type  => 'Checkbox',
    label => 'Delete walkthrough file',
);

has_field 'cover_delete' => (
    type  => 'Checkbox',
    label => 'Delete cover art file',
);

has_field 'note' => (
    type => 'TextArea',
    label =>
        'Reason for this update (Will be player-visible; avoid spoilers)',
);

has_field 'submit' => (
    type         => 'Submit',
    value        => 'Submit game information',
    element_attr => { class => 'btn btn-success', },
);

before 'validate_form' => sub {
    my $self = shift;

    if (   $self->item
        && $self->item->id
        && (   ( $self->item->comp->status eq 'closed_to_entries' )
            || ( $self->item->comp->status eq 'open_for_judging' ) )
        )
    {
        $self->field('title')->inactive(1);
        $self->field('title')->required(0);
    }
};

sub validate_reveal_pseudonym {
    my $self = shift;
    my ($field) = @_;

    if ( $field->value && not $self->field('author_pseudonym')->value ) {
        $field->add_error( "This setting makes sense only if you're setting "
                . "a pseudonym." );
    }
}

sub validate_cover_upload {
    my $self = shift;
    my ($field) = @_;

    if ( $field->value ) {
        my $image = Imager->new( file => $field->value->tempname );
        unless ($image) {
            $field->add_error(
                "This doesn't appear to be a valid PNG or JPEG file.");
        }
    }
}

sub validate_main_upload {
    my $self = shift;
    my ($field) = @_;

    if (   $self->item
        && $self->item->id
        && (   ( $self->item->comp->status eq 'closed_to_entries' )
            || ( $self->item->comp->status eq 'open_for_judging' ) )
        && not $self->field('note')->input
        )
    {
        $field->add_error("You must provide a reason for this update.");
    }
}

sub validate {
    my $self = shift;

    my $entry_count = $self->schema->resultset('Entry')->search(
        {   author => $self->item->author->id,
            comp   => $self->item->comp->id,
        }
    )->count;

    if ( $entry_count >= $MAX_ENTRIES && !$self->item->id ) {
        $self->add_form_error("INVALID_ENTRY_COUNT");
    }
}

1;
