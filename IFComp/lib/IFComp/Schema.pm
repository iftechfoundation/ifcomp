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

class_has 'email_template_basedir' => (
    is => 'rw',
    isa => 'Path::Class::Dir',
);

class_has 'entry_directory' => (
    is => 'rw',
    isa => 'Path::Class::Dir',
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
