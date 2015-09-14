package SORM::Meta::Column;
use strict;
use SORM;
use Class::XSAccessor;
use Class::Accessor::Inherited::XS {
    inherited => [qw/db_id name type is_primary_key/]
};

__PACKAGE__->db_id(undef);
__PACKAGE__->name(undef);
__PACKAGE__->type(undef);
__PACKAGE__->is_primary_key(undef);

sub _make_column_class {
    my ($class, $orm, $name, $info) = @_;

    die "Unknown type $info->{type} for column $name" unless exists $orm->column_types->{$info->{type}};
    my $type = $orm->column_types->{$info->{type}};

    $class->name($name);
    $class->type($type);
    $class->is_primary_key(1) if $info->{primary_key};

    return $class;
}

1;
