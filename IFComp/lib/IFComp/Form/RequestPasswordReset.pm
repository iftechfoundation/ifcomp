package IFComp::Form::RequestPasswordReset;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has 'schema' => (
    required => 1,
    is => 'ro',
    isa => 'IFComp::Schema',
);

has_field 'email' => (
    type => 'Email',
    required => 1,
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Register',
    element_attr => {
        class => 'btn btn-success',
    },
);

has '+widget_wrapper' => (
    default => 'Bootstrap3',
);

sub validate_email {
    my $self = shift;
    my ( $field ) = @_;

    my $user_rs = $self->schema->resultset( 'User' );
    my $existing_user = $user_rs->search( { email => $field->value } )->single;
    unless ( $existing_user ) {
        $field->add_error( 'We have no account on record involving this email address.' );
    }
}

1;
