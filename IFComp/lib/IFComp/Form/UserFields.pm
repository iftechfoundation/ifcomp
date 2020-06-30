package IFComp::Form::UserFields;

use HTML::FormHandler::Moose::Role;
with 'IFComp::Form::PasswordFields';

use Regexp::Common qw( URI );

has_field 'email' => (
    type      => 'Email',
    required  => 1,
    maxlength => 64,
);

has_field 'email_is_public' => (
    type    => 'Checkbox',
    default => 0,
    label   => 'Display your email address',
);

has_field 'name' => (
    type     => 'Text',
    required => 1,
);

has_field 'twitter' => (
    type  => 'Text',
    label => 'Twitter handle',
);

has_field 'url' => (
    type  => 'Text',
    label => 'Homepage',
);

has_field 'forum_handle' => (
    type  => 'Text',
    label => 'Intfiction.org forum handle',
);

has_field 'paypal' => (
    type      => 'Email',
    label     => 'Paypal address',
    maxlength => 64,
);

has_field 'submit' => (
    type         => 'Submit',
    value        => 'Register',
    element_attr => { class => 'btn btn-success', },
);

sub validate_twitter {
    my $self = shift;
    my ($field) = @_;

    my $handle = $field->value;
    return unless $handle;

    $handle =~ s/^\s*@?//;
    $handle =~ s/\s*$//;

    # Tests based on:
    # http://smallbusiness.chron.com/maximum-length-twitter-handle-61818.html
    my $MAX_LENGTH = 15;
    if ( ( length $handle <= $MAX_LENGTH ) && ( $handle =~ /^[\w\d]+$/ ) ) {
        $field->value($handle);
    }
    else {
        $field->add_error("This doesn't look like a valid Twitter handle.");
    }
}

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

1;
