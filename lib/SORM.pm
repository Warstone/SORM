package SORM;
use strict;
use Class::XSAccessor {
    accessors => [qw/dbh dsn mobj/],
};
use Class::Accessor::Inherited::XS {
    inherited => [qw/table_base_class column_base_class meta_base_class query_base_class result_base_class results_namespace meta column_types additional_column_types/],
    class => [qw/default_column_types/]
};

__PACKAGE__->table_base_class('SORM::Meta::Table');
__PACKAGE__->column_base_class('SORM::Meta::Column');
__PACKAGE__->meta_base_class('SORM::Meta');
__PACKAGE__->query_base_class('SORM::Query');
__PACKAGE__->result_base_class('SORM::ResultRow');
__PACKAGE__->results_namespace(undef);
__PACKAGE__->additional_column_types(undef);


__PACKAGE__->default_column_types({
    bigint => undef,
    int    => undef,
    text   => undef,
});


sub new {
    my ($class) = @_;

    foreach my $class ( $class->table_base_class, $class->column_base_class, $class->meta_base_class, $class->query_base_class, $class->result_base_class ){
        eval "require $class";
        die $@ if $@;
    }
    $class->results_namespace("${class}::ResultRow") unless defined $class->results_namespace;
    my $self = bless {}, $class || ref $class || __PACKAGE__;
    return $self;
}

sub connect {
    my ($self, $dsn, $login, $password) = @_;
    $self->dsn($dsn);
    $self->dbh(DBI->connect($dsn, $login, $password, {AutoCommit => 1, RaiseError => 1}));

    $self->make_meta();
}

sub disconnect {
    my ($self) = @_;
    $self->dbh->disconnect;
}

sub make_meta {
    my ($self) = @_;

    my $types = {};
    $types->{$_} = __PACKAGE__->default_column_types->{$_} foreach keys %{__PACKAGE__->default_column_types};
    if(defined $self->additional_column_types){
        $types->{$_} = $self->additional_column_types->{$_} foreach keys %{$self->additional_column_types};
    }
    $self->column_types($types);

    $self->mobj( $self->meta_base_class->new() )->parse_meta($self, $self->meta);
}

sub q {
    my ($self, $sql) = @_;
    return $self->query_base_class->new( $self, $self->dbh->prepare($sql) );
}

1;
