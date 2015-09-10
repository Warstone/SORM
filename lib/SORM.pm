package SORM;
use strict;
use Class::XSAccessor {
    accessors => [qw/dbh dsn mobj/],
};
use Class::Accessor::Inherited::XS {
    inherited => [qw/table_base_class column_base_class meta_base_class query_base_class result_base_class meta/]
};

__PACKAGE__->table_base_class('SORM::Meta::Table');
__PACKAGE__->column_base_class('SORM::Meta::Column');
__PACKAGE__->meta_base_class('SORM::Meta');
__PACKAGE__->query_base_class('SORM::Query');
__PACKAGE__->result_base_class('SORM::ResultRow');


sub new {
    my ($class) = @_;

    foreach my $class ( $class->table_base_class, $class->column_base_class, $class->meta_base_class, $class->query_base_class, $class->result_base_class ){
        eval "require $class";
        die $@ if $@;
    }
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

$DB::single = 1;
    $self->mobj( $self->meta_base_class->new() )->parse_meta($self, $self->meta);
}

sub q {
    my ($self, $sql) = @_;
    return $self->query_base_class->new( $self, $self->dbh->prepare($sql) );
}

1;
