package IFComp::Form::UpdatePrize;

use Regexp::Common qw( URI );
use Email::Valid;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+name'        => ( default => 'prizedit' );
has '+html_prefix' => ( default => 1 );

has '+widget_wrapper' => ( default => 'Bootstrap3', );

has_field 'donor' => (
    required => 1,
    type => 'Text',
    maxlength => 64,
);

has_field 'donor_email' => (
    required => 1,
    type => 'Text',
    maxlength => 64,
);

has_field 'name' => (
    required => 1,
    type => 'Text',
    maxlength => 128,
);

has_field 'notes' => (
    type => 'Text'
);

has_field 'url' => (
    type => 'Text',
    maxlength => 128,
);

has_field 'category' => (
    type => 'Select',
    id => 'category',
    label => 'Prize Category',
    options => [
        { value => 'money', label => "Money and gift certificates" },
        { value => 'expertise', label => "Expert services" },
        { value => 'food', label => "Food" },
        { value => 'apparel', label => "Apparel" },
        { value => 'games', label => "Games" },
        { value => 'hardware', label => "Computer hardware and other electronics" },
        { value => 'software', label => "Non-game software" },
        { value => 'books', label => "Books and magazines" },
        { value => 'av', label => "Music and movies" },
        { value => 'misc', label => "Other stuff" },
        { value => 'special', label => "Special prizes" },
    ],
);

has_field 'location' => (
    type => 'Text',
    maxlength => 64,
);

has_field 'ships_internationally' => (
    default => 1,
    label => "Will ship internationally",
    type => 'Checkbox',
);

has_field 'submit' => (
    type         => 'Submit',
    value        => 'Submit',
    element_attr => { class => 'btn btn-primary', },
);

sub validate_url {
    my $self = shift;
    my ($field) = @_;

    if ( my $url = $field->value ) {
        unless ( $url =~ /^$RE{URI}$/ ) {
            $url = $field->value("http://$url");
        }
        unless ( $url =~ /^$RE{URI}$/ ) {
            $field->add_error("This doesn't look like a valid URL.");
        }
    }

}

sub validate_donor_email {
    my $self = shift;
    my ($field) = @_;

    if ( my $email = $field->value ) {
        unless ( Email::Valid->address( $email ) ) {
            $field->add_error("This doesn't look like a valid email address.");
        }
    }
}

__PACKAGE__->meta->make_immutable;
1;
