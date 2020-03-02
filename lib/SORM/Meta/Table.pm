package SORM::Meta::Table;
use strict;
use SORM;
use SORM::Meta::Column;

use Class::Accessor::Inherited::XS {
    inherited => [qw/db_id name columns primary_key/]
};

use Class::XSAccessor {
    accessor => [qw/key/]
};

sub new {
    my ($package, $data) = @_;
    my $self = bless {
        key => $data->{key},
    }, ref $package || $package || __PACKAGE__;
    return $self;
}

sub create {
    my ($self, $data) = @_;
}

sub read {
    my ($self, $data) = @_;
}

sub update {
    my ($self, $data) = @_;
}

sub delete {
    my ($self, $data) = @_;
}

# Class methods

__PACKAGE__->db_id(undef);
__PACKAGE__->name(undef);
__PACKAGE__->columns(undef);
__PACKAGE__->primary_key(undef);

sub _make_table_class {
    my ($class, $orm, $name, $meta) = @_;
    $name = lc($name);
    my $class = ref($orm) . "::Tables::$name";
    {
        no strict 'refs';
        my $isa = \@{"${class}::ISA"};
        push(@$isa, $orm->table_base_class);
    }
    $class->name($name);

    my $columns = {};
    my $primary_key = {};
    foreach my $column (keys %$meta){
        my $info = $meta->{$column};
        my $class = ref($orm) . "::Tables::${name}::" . lc($column);
        {
            no strict 'refs';
            my $isa = \@{"${class}::ISA"};
            push(@$isa, $orm->column_base_class);
        }
        my $column_class = $class->_make_column_class($orm, $column, $info);
        $columns->{$column} = $column_class;
        $primary_key->{$column_class} = undef if $column_class->is_primary_key;
    }

    $class->primary_key($primary_key) if scalar keys %$primary_key > 0;
    $class->columns($columns);

    return $class;
}

1;
