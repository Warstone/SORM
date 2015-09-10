package SORM::ResultRow;
use strict;
use mro 'c3';
use Class::XSAccessor;
use Class::Accessor::Inherited::XS {
    inherited => [qw/_generated_results _column_meta _sth_meta/]
};

__PACKAGE__->_generated_results(undef);
__PACKAGE__->_column_meta(undef);
__PACKAGE__->_sth_meta(undef);

sub make_resultrow_class {
    my ($class, $orm, $sth, $signature, $columns) = @_;

    $class->_generated_results({}) unless defined  $class->_generated_results;
    my $result_class = $orm->results_namespace . "::$signature";
    {
        no strict 'refs';
        my $isa = \@{"${result_class}::ISA"};
        push(@$isa, $orm->result_base_class);
    }
    $result_class->_column_meta($columns);
    $result_class->_sth_meta($sth->{NAME});
    Class::XSAccessor::newxs_accessor("${result_class}::$_", $_, 0) foreach @{$sth->{NAME}};

    $class->_generated_results->{$signature} = $result_class;
    return $result_class;
}

sub new {
    my ($class, $query, $data) = @_;
    my $self = bless {}, $class;

    for (my $i = 0; $i < scalar(@$data); $i++){
        my $meta = $self->_column_meta->[$i];
        my $name = $self->_sth_meta->[$i];
        if($meta->type){
            $self->{$name} = $meta->type->{inflate}->($query, $data->[$i]);
        } else {
            $self->{$name} = $data->[$i];
        }
    }

    return $self;
}

1;
