package SORM::ResultRow;
use strict;
use Class::XSAccessor;
use Class::Accessor::Inherited::XS {
    inherited => [qw/_generated_results _meta/]
};
use Sub::Name qw/subname/;

__PACKAGE__->_generated_results(undef);
__PACKAGE__->_meta(undef);

sub make_resultrow_class {
    my ($class, $orm, $sth, $signature, $columns) = @_;

    $class->_generated_results({}) unless defined  $class->_generated_results;
    my $result_class = $orm->results_namespace . "::$signature";
    {
        no strict 'refs';
        my $isa = \@{"${result_class}::ISA"};
        push(@$isa, $orm->result_base_class);
    }
    my $meta;
    for(my $i = 0; $i < scalar(@$columns); $i++){
        push(@$meta, {
            column => $columns->[$i],
            name => $sth->{NAME}->[$i]
        });
    }
    $result_class->_meta($meta);
    Class::XSAccessor::newxs_accessor("${result_class}::$_", $_, 0) foreach @{$sth->{NAME}};
    {
        no strict 'refs';

        my $code = "sub {\n\treturn bless {\n";

        for(my $i = 0; $i < scalar(@$columns); $i++){
            my $column = $columns->[$i];
            my $name = $sth->{NAME}->[$i];
            if($column && $column->type){
                $code .= "\t\t\"$name\" => \$_[0]->_meta->[$i]->{column}->type->{inflate}->(\$_[1], \$_[2]->[$i]),\n";
            } else {
                $code .= "\t\t\"$name\" => \$_[2]->[$i],\n";
            }
        }

        $code .= "\t}, \$_[0];\n}";
        *{"${result_class}::new"} = subname "${result_class}::new" => eval("$code");
    }

    $class->_generated_results->{$signature} = $result_class;
    return $result_class;
}

=cut
sub new {
    my ($class, $query, $data) = @_;
    my $self = bless {}, $class;

    for (my $i = 0; $i < scalar(@$data); $i++){
        my $meta = $self->_meta->[$i];
        if($meta->{column} && $meta->{column}->type){
            $self->{$meta->{name}} = $meta->{column}->type->{inflate}->($query, $data->[$i]);
        } else {
            $self->{$meta->{name}} = $data->[$i];
        }
    }

    return $self;
}
=cut
1;
