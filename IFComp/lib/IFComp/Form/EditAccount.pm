package IFComp::Form::EditAccount;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'IFComp::Form::UserFields';

has 'user' => (
    required => 1,
    is       => 'ro',
    isa      => 'IFComp::Model::IFCompDB::User',
);

has_field '+password' => (
    label    => 'Password (if changing it)',
    required => 0,
);

has_field '+password_confirmation' => ( required => 0, );

has '+widget_wrapper' => ( default => 'Bootstrap3', );

has_field '+submit' => ( value => 'Update', );

sub validate_email {
    my $self = shift;
    my ($field) = @_;

    my $user_rs       = $self->schema->resultset('User');
    my $existing_user = $user_rs->search(
        {   email => $field->value,
            id    => { '!=', $self->user->id },
        }
    )->single;

    if ($existing_user) {
        $field->add_error(
            'A different user account is already using that address.');
    }
}

1;
