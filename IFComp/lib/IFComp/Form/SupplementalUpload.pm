package IFComp::Form::SupplementalUpload;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

use Readonly;
Readonly my $MAX_DIR_SIZE => 10485760;

has '+enctype' => ( default => 'multipart/form-data');

has '+widget_wrapper' => (
    default => 'Bootstrap3',
);

has 'directory' => (
    is => 'ro',
    required => 1,
);

has 'description' => (
    is => 'ro',
    lazy_build => 1,
);

has_field 'upload' => (
    type => 'Upload',
    label => 'Add a file',
    required => 1,
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Add this file',
    element_attr => {
        class => 'btn btn-success',
    },
);

sub validate_upload {
    my $self = shift;
    my ( $field ) = @_;

    my $upload_size = $field->value->size;

    my $current_total_size = 0;
    for my $file ( $self->directory->children ) {
        $current_total_size += $file->stat->size;
    }

    if ( $current_total_size + $upload_size > $MAX_DIR_SIZE ) {
        my $description = $self->description;
        $field->add_error( 'Adding this file would bring your total size of '
                           . "$description above the allowed maximum "
                           . "($MAX_DIR_SIZE)."
        );
    }
}

sub _build_description {
    my $self = shift;
    return $self->directory->basename;
}

1;
