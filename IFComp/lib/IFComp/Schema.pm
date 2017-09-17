#<<<
use utf8;
package IFComp::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-06-08 23:46:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uxXflUCGtsGN5LDbi7A+7A

use MooseX::ClassAttribute;
use List::Util qw(none);

class_has 'email_template_basedir' => (
    is  => 'rw',
    isa => 'Path::Class::Dir',
);

class_has 'entry_directory' => (
    is  => 'rw',
    isa => 'Path::Class::Dir',
);

sub emails_for_comp {
    my $self = shift;

    return $self->_get_emails( @_, 0 );

}

sub anti_emails_for_comp {
    my $self = shift;

    # The "anti-email" list is all holders of disqualified games that
    # don't also hold qualified games.
    my @emails              = $self->_get_emails( @_, 0 );
    my @disqualified_emails = $self->_get_emails( @_, 1 );
    my @anti_emails         = grep {
        my $dq_email = $_;
        none { $_ eq $dq_email } @emails;
    } @disqualified_emails;

    return @anti_emails;
}

sub _get_emails {
    my $self = shift;
    my ( $comp, $is_disqualified ) = @_;

    my @emails = $self->resultset('User')->search(
        {   'entries.comp'            => $comp->id,
            'entries.is_disqualified' => $is_disqualified,
        },
        {   join     => 'entries',
            group_by => 'email',
            order_by => 'email',
        },
    )->get_column('email')->all;

    return @emails;

}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
1;
