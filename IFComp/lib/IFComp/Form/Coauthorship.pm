package IFComp::Form::Coauthorship;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name'        => ( default => 'coauthorship' );
has '+html_prefix' => ( default => 1 );

has '+widget_wrapper' => ( default => 'Bootstrap3', );

has_field 'add_code' => (
    type    => 'Text',
    label   => 'Code given by primary author',
);

has_field 'confirm' => (
    type     => 'Checkbox',
    label    => "Remove myself from this game",
);

has_field 'submit' => (
    type         => 'Submit',
    value        => 'Update',
    element_attr => { class => 'btn btn-danger', },
);

1;
