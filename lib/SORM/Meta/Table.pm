package SORM::Meta::Table;
use strict;
use SORM;
use SORM::Meta::Column;

use Class::XSAccessor {
    accessors => [qw/name columns/],
};


sub new {
    my $package = shift;
    my $self = bless {}, ref $package || $package || __PACKAGE__;
    $self->parse_meta(@_) if scalar(@_) > 1;
    return $self;
}

sub parse_meta {
    my ($self, $orm, $name, $meta) = @_;
    $self->name($name);
    my $columns = {};
    foreach my $column (keys %$meta){
        my $info = $meta->{$column};
        my $class = ref($orm) . "::Tables::${name}::" . lc($column);
        {
            no strict 'refs';
            my $isa = \@{"${class}::ISA"};
            push(@$isa, $orm->column_base_class);
        }
        $columns->{$column} = $class->_make_column($orm, $column, $info);
    }
    $self->columns($columns);
}

# Class methods

sub make_table {
    my ($class, $orm, $name, $meta) = @_;
    $name = lc($name);
    my $class = ref($orm) . "::Tables::$name";
    {
        no strict 'refs';
        my $isa = \@{"${class}::ISA"};
        push(@$isa, $orm->table_base_class);
    }
    return $class->new($orm, $name, $meta);
}

1;
