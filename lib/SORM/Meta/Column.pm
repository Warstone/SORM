package SORM::Meta::Column;
use strict;
use SORM;
use Class::XSAccessor;
use Class::Accessor::Inherited::XS {
    inherited => [qw/db_id name type/]
};

__PACKAGE__->db_id(undef);

sub _make_column {
    my ($class, $orm, $name, $info) = @_;

    die "Unknown type $info->{type} for column $name" unless exists $orm->column_types->{$info->{type}};
    my $type = $orm->column_types->{$info->{type}};

    $class->name($name);
    $class->type($type);

    return $class;
}

1;
