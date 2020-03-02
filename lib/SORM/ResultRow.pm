package SORM::ResultRow;
use strict;
use Class::XSAccessor;
use Class::Accessor::Inherited::XS {
    inherited => [qw/_generated_results _meta _query/]
};
use Sub::Name qw/subname/;

__PACKAGE__->_generated_results(undef);
__PACKAGE__->_meta(undef);
__PACKAGE__->_query(undef);

sub make_resultrow_class {
    my ($class, $query, $signature, $columns) = @_;

    my $orm = $query->orm;
    my $sth = $query->sth;
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
    my $names = {};
    foreach my $column (@{$sth->{NAME}}){
        die "Column $column already defined for this resultset. Please rename it" if exists $names->{$column};
        Class::XSAccessor::newxs_accessor("${result_class}::$column", $column, 0);
        $names->{$column} = undef;
    }
    {
        no strict 'refs';

        my $code = "sub {\n\tmy \$self = bless {\n";

        for(my $i = 0; $i < scalar(@$columns); $i++){
            my $column = $columns->[$i];
            my $name = $sth->{NAME}->[$i];
            if($column && $column->type){
                $code .= "\t\t\"$name\" => \$_[0]->_meta->[$i]->{column}->type->{inflate}->(\$_[1], \$_[2]->[$i]),\n";
            } else {
                $code .= "\t\t\"$name\" => \$_[2]->[$i],\n";
            }
        }

        $code .= "\t}, \$_[0];\n\treturn \$self;\n}";
        *{"${result_class}::new"} = subname "${result_class}::new" => eval("$code");

        my $isa = \@{"${result_class}::ISA"};
        push(@$isa, $orm->result_base_class);
    }
    $result_class->_query($query);

    $class->_generated_results->{$signature} = $result_class;
    return $result_class;
}

# Object

sub as {
    my ($self, $table) = @_;

    my $meta = $self->query->orm->mobj;
    my $table_class = $meta->tables->{$table};
    die "Table $table not defined in metadata." unless defined $table_class;
    die "Table $table has not defined its primary key" unless defined $table_class->primary_key;

    my $pk = [];
    for(my $i = 0; $i < scalar @{$self->query->columns}; $i++){
        my $column_id = $self->quesy_columns->[$i];
        my $column_class = $meta->column_by_db_id->{$column_id};
        next unless exists $table_class->primary_key->{$column_class};

        push(@$pk, {
            class => $column_class,
            value => $self->{$self->query->sth->{NAME}->[$i]},
        });
    }
    die "This query hasn't all PK columns for table $table (it must contain: " . join(", ", map { $_->name } keys %{$table_class->primary_key}) . ")" if scalar @$pk != scalar keys %{$table_class->primary_key};

    return $table_class->new({
        key => $pk
    });
}

1;
