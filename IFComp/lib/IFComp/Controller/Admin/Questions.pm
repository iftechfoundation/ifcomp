package IFComp::Controller::Admin::Questions;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::Questions - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub root : Chained('/admin/root') : PathPart('questions') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user && $c->check_any_user_role('cheez') ) {
        $c->res->redirect('/');
        $c->detach()
    }

}

sub index : Chained('root') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;

    my @questions = $c->model('IFCompDB::Question')->all;

    $c->stash(
        template  => 'admin/questions/index.tt',
        questions => \@questions,
    );
}


sub save_questions :Chained('root') :PathPart('save') :Args(0) :Method('POST') {
    my ( $self, $c ) = @_;
    
    my $params = $c->req->body_parameters;
    my $guard  = $c->model('IFCompDB')->txn_scope_guard;
    
    foreach my $param_name ( keys %$params ) {
        
        if ( $param_name =~ /^question_(\d+)$/ ) {
            my $question_id   = $1;
            my $question_text = $params->{$param_name};
            
            my $question_row = $c->model('IFCompDB::Question')->find($question_id);
            
            if ($question_row) {
                if ( $params->{"disable_$question_id"} ) {
                    $question_row->update({ disabled => 1 });;
                }  else {
                    $question_row->update({ disabled => 0 });;
                }
                $question_row->update({ question_text => $question_text });
            }
        }
    }
    
    if ( $params->{new_question} && $params->{new_question} =~ /\S/ ) {
        $c->model('IFCompDB::Question')->create({
            question_text => $params->{new_question}
        });
    }
    
    $guard->commit;
    
    $c->flash->{status_msg} = "Questions successfully updated.";
    $c->res->redirect($c->uri_for('/admin/questions/view'));
}


=encoding utf8

=head1 AUTHOR

Mark Musante

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
