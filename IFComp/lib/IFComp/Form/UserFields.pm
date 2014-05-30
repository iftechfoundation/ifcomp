package IFComp::Form::UserFields;

use HTML::FormHandler::Moose::Role;
with 'IFComp::Form::PasswordFields';

use HTML::FormHandlerX::Field::URI::HTTP;

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
    type => 'URI::HTTP',
    label => 'Homepage (or other URL)',
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Register',
    element_attr => {
        class => 'btn btn-success',
    },
);

sub validate_twitter {
    my $self = shift;
    my ( $field ) = @_;

    my $handle = $field->value;
    return 1 unless $handle;

    $handle =~ s/^\s*@?//;
    $handle =~ s/\s*$//;

    # Tests based on:
    # http://smallbusiness.chron.com/maximum-length-twitter-handle-61818.html
    my $MAX_LENGTH = 15;
    if ( ( length $handle <= $MAX_LENGTH ) && ( $handle =~ /^[\w\d]+$/ ) ) {
        $field->value( $handle );
        return 1;
    }
    else {
        $field->add_error( "This doesn't look like a valid Twitter handle." );
    }
}

1;
