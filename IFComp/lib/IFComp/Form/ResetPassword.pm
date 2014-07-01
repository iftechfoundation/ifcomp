package IFComp::Form::ResetPassword;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'IFComp::Form::PasswordFields';


has 'schema' => (
    required => 1,
    is => 'ro',
    isa => 'IFComp::Schema',
);


has_field 'submit' => (
    type => 'Submit',
    value => 'Submit',
    element_attr => {
        class => 'btn btn-success',
    },
);

has '+widget_wrapper' => (
    default => 'Bootstrap3',
);

1;
