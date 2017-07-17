package IFComp::Form::Register;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'IFComp::Form::UserFields';

has 'schema' => (
    required => 1,
    is       => 'ro',
    isa      => 'IFComp::Schema',
);

has '+widget_wrapper' => ( default => 'Bootstrap3', );

sub validate_email {
    my $self = shift;
    my ($field) = @_;

    my $user_rs = $self->schema->resultset('User');
    my $existing_user =
        $user_rs->search( { email => $field->value } )->single;
    if ($existing_user) {
        $field->add_error(
            'We already have a user account with this email address. (Click "Forgot Password" if you need to recover your existing password.)'
        );
    }
}

1;
