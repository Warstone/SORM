package SORM;
use strict;
use SORM::Meta;
use Class::XSAccessor {
    accessors => [qw/dbh dsn mobj/],
};
use Class::Accessor::Inherited::XS {
    inherited => [qw/table_base_class column_base_class meta_base_class query_base_class meta/]
};

__PACKAGE__->table_base_class('SORM::Meta::Table');
__PACKAGE__->column_base_class('SORM::Meta::Column');
__PACKAGE__->meta_base_class('SORM::Meta');
__PACKAGE__->query_base_class('SORM::Query');


sub new {
    my ($class) = @_;
    my $self = bless {}, $class || ref $class || __PACKAGE__;
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

    $self->mobj( $self->meta_base_class->new() )->parse_meta($self, $self->meta);
}

sub q {
    my ($self, $sql) = @_;
    return $self->query_base_class->new( $self, $self->dbh->prepare($sql) );
}

1;
