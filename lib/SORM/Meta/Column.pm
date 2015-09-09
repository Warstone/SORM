package SORM::Meta::Column;
use strict;
use SORM;
use Class::XSAccessor;
use Class::Accessor::Inherited::XS {
    inherited => [qw/types/]
};

__PACKAGE__->types({
    bigint => 'simple',
    int    => 'simple',
    text   => 'simple',
});

sub _make_column {
    my ($class, $orm, $name, $info) = @_;
    my $type_data = $class->types->{$info->{type}};
    die "Unknown type $info->{type} for column $name" unless defined $type_data;
    if($type_data eq 'simple'){
        Class::XSAccessor::newxs_accessor("${class}::$name", $name, 0);
    } else {
        die "Only simple datatype implemented";
    }
    return $class;
}

1;
