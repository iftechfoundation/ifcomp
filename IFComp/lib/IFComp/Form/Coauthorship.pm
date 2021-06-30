package IFComp::Form::Coauthorship;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name'        => ( default => 'coauthorship' );
has '+html_prefix' => ( default => 1 );

has '+widget_wrapper' => ( default => 'Bootstrap3', );

has_field 'add_coauthor_code' => (
    type      => 'Text',
    label     => 'Code given by primary author',
    minlength => 20,
    maxlength => 20,
    required  => 1,
    messages  => {
        text_minlength => 'Code must be exactly 20 characters',
        text_maxlength => 'Code must be exactly 20 characters',
    }
);

has_field 'pseudonym' => (
    type      => 'Text',
    label     => 'Displayed name',
    maxlength => 128,
);

has_field 'reveal_pseudonym' => (
    type  => 'Checkbox',
    label => 'Reveal pseudonym'
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Add Co-authorship',
);

1;
