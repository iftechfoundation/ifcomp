package IFComp::Form::Login;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+widget_wrapper' => ( default => 'Bootstrap3', );

has_field 'email' => (
    type     => 'Email',
    required => 1,
);
has_field 'password' => (
    type     => 'Password',
    required => 1,
);

has_field 'submit' => (
    type         => 'Submit',
    value        => 'Log in',
    element_attr => { class => 'btn btn-success', },
);

1;
