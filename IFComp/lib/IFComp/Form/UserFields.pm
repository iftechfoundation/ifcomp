package IFComp::Form::UserFields;

use HTML::FormHandler::Moose::Role;
with 'IFComp::Form::PasswordFields';

has_field 'email' => (
    type => 'Email',
    required => 1,
);

has_field 'email_is_public' => (
    type => 'Checkbox',
    default => 0,
    label => 'Display your email address',
);

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'twitter' => (
    type => 'Text',
    label => 'Twitter handle',
);

has_field 'url' => (
    type => 'Text',
    label => 'Homepage URL',
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Register',
    element_attr => {
        class => 'btn btn-success',
    },
);

1;
