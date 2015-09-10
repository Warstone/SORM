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
        $self->{$isa->[$i + 1]->name} = $data->[$i];
    }
    return $self;
}

sub make_resultrow_class {
    my ($class, $orm, $signature, $columns) = @_;

    $class->generated_results({}) unless defined  $class->generated_results;
    my $class = $orm->result_base_class . "::$signature";
    {
        no strict 'refs';
        $DB::single = 1;
        my $isa = \@{"${class}::ISA"};
        push(@$isa, $orm->result_base_class);
        push(@$isa, @$columns);
    }
    $class->generated_results->{$signature} = $class;
    return $class;
}

1;
