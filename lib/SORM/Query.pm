package SORM::Query;
use Class::XSAccessor {
    accessors => [qw/sth/]
};

sub new {
    my ($class, $orm, $sth) = @_;
    my $self = bless {}, ref $class || $class || __PACKAGE__;
    $self->sth($sth);
    return $self->all if wantarray;
    return $self
}

sub all {
    my ($self) = @_;

    my $sth = $self->sth;
    $sth->execute;
}

sub execute {
    my ($self) = @_;

    my $sth = $self->sth;
    $sth->execute;
}

1;
