package IFComp::Form::WithdrawEntry;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name' => ( default => 'withdrawal' );
has '+html_prefix' => ( default => 1 );

has '+widget_wrapper' => (
    default => 'Bootstrap3',
);

has_field 'confirm' => (
    type => 'Checkbox',
    label => "Yes, I'm sure I want to do this.",
    required => 1,
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Withdraw this entry',
    element_attr => {
        class => 'btn btn-danger',
    },
);

1;
