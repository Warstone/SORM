package SORM::ResultRow;
use strict;
use mro 'c3';
use Class::Accessor::Inherited::XS {
    inherited => [qw/generated_results/]
};

__PACKAGE__->generated_results(undef);

sub new {
    my ($class, $query, $data) = @_;
    my $self = bless {}, $class;
    my $isa;
    {
        no strict 'refs';
        $isa = \@{"${class}::ISA"};
    }

    for (my $i = 0; $i < scalar(@$data); $i++){
        my $class = $isa->[$i + 1];
        my $t_info = $class->type;
        if(defined $t_info){
            $self->{$class->name} = $t_info->{inflate}->($query, $data->[$i]);
        } else {
            $self->{$class->name} = $data->[$i];
        }
    }
    return $self;
}

sub make_resultrow_class {
    my ($class, $orm, $signature, $columns) = @_;

    $class->generated_results({}) unless defined  $class->generated_results;
    my $class = $orm->results_namespace . "::$signature";
    {
        no strict 'refs';
        my $isa = \@{"${class}::ISA"};
        push(@$isa, $orm->result_base_class);
        push(@$isa, @$columns);
    }
    $class->generated_results->{$signature} = $class;
    return $class;
}

1;
