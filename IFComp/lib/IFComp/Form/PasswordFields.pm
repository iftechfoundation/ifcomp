package IFComp::Form::PasswordFields;

use HTML::FormHandler::Moose::Role;

has_field 'password' => (
    type     => 'Password',
    required => 1,
);

has_field 'password_confirmation' => (
    type     => 'Password',
    required => 1,
);

sub validate_password_confirmation {
    my $self = shift;
    my ($field) = @_;

    if ( $field->value ne $self->field('password')->value ) {
        $field->add_error('The two password fields do not match.');
    }
}

1;
