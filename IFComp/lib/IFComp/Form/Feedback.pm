package IFComp::Form::Feedback;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+widget_wrapper' => ( default => 'Bootstrap3', );

use Readonly;
Readonly my $MAX_TEXT_LENGTH => 8192;    # 8K is enough for anyone...

has_field 'text' => (
    type               => 'TextArea',
    build_label_method => \&_build_text_label,
    maxlength          => $MAX_TEXT_LENGTH,
);

has_field 'submit' => ( type => 'Submit', );

has 'title' => (
    is       => 'ro',
    required => 1,
    isa      => 'Str',
);

sub _build_text_label {
    my $self = shift;

    return "Your feedback for " . $self->form->title;
}

1;
