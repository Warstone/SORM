package SORM;
use SORM::Query;
use Mojo::URL;
use Class::XSAccessor {
    accessors => [qw/dbi username password options dsn pool meta/],
};

our %PROTOCOLS_SUPPORTED = (
    postgresql => 'Pg',
    pgsql => 'Pg',
    pg => 'Pg',
);

sub new {
    my ($class, $url, $params) = @_;
    $params \\= {};
    my $self = bless $params, $class || ref $class || __PACKAGE__;

    $self->from_string($url) if defined $url;
    $self->pool(SORM::Pool->new($self, $self->pool));
}

sub init {
    my ($self) = @_;
    $self->meta( $self->pool->provider->load_meta ) if $self->meta_autoget;
    $self->meta( $self->meta_override($self->meta) );
    $self->build_meta( $self->meta );
    $self->pool->provider->process_meta($self->meta);
}

sub meta_override { return $_[1]; }

sub from_string {
    my ($str) = @_;

    my $url = Mojo::URL->new($str);
    croak qq{Invalid PostgreSQL connection string "$str"} unless defined $PROTOCOLS_SUPPORTED{$url->protocol};

    $self->dbi($PROTOCOLS_SUPPORTED{$url->protocol});
    my $db = $url->path->parts->[0];
    my $dsn = $PROTOCOLS_SUPPORTED{$url->protocol} . ":";
    $dsn .= "dbname=$db" if defined $db;

    if (my $host = $url->host) { $dsn .= ";host=$host" }
    if (my $port = $url->port) { $dsn .= ";port=$port" }

    if (($url->userinfo // '') =~ /^([^:]+)(?::([^:]+))?$/) {
        $self->username($1);
        $self->password($2) if defined $2;
    }

    my $hash = $url->query->to_hash;
    if (my $service = delete $hash->{service}) { $dsn .= ";service=$service" }

    @{$self->options}{keys %$hash} = values %$hash;

    $dsn =~ s/(.*):/$1/;

    return $self->dsn($dsn);
}

sub q {
    my $self = $_[0];
    return SORM::Query->new(@_);
}