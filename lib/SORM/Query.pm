package SORM::Query;
use Class::XSAccessor {
    accessors => [qw/query cb params engine/],
};

sub new {
    my ($class, $orm, $query) = @_;
    return bless {
        query => $query,
        engine => $orm->engine
    }, $class || ref $class || __PACKAGE__;
}

sub cb {
    my ($self, $cb, $params) = @_;
    $self->cb( { cb => $cb, params => $params } );
    return $self;
}

sub run {
    return $_[0]->engine->run($_[0]);
}

sub done {
    my ($self, $objects) = @_;
    
}