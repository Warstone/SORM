package SORM::Query;
use Class::XSAccessor {
    accessors => [qw/sth orm result_class columns executed col_id_to_name/]
};

sub new {
    my ($class, $orm, $sth) = @_;
    my $self = bless {}, ref $class || $class || __PACKAGE__;
    $self->sth($sth);
    $self->orm($orm);
    return $self->all if wantarray;
    return $self;
}

sub all {
    my ($self) = @_;

    $self->execute;

    my @all = map { $self->result_class->new($self, $_) } @{$self->sth->fetchall_arrayref};
    return @all if wantarray;
    return \@all;
}

sub execute {
    my ($self) = @_;

    return if $self->executed;

    my $sth = $self->sth;
    $sth->execute;

    my $columns = [ map { join("_", @$_) if defined $_ } @{$sth->pg_canonical_ids} ];
    my $signature = join("|", @$columns);

    my $class = $self->orm->result_base_class;
    unless(defined $class->_generated_results && defined $class->_generated_results->{$signature}){
        $self->orm->result_base_class->make_resultrow_class($self, $signature, [ map { $self->orm->mobj->column_by_db_id->{$_}} @$columns ] );
    }
    $class = $class->_generated_results->{$signature};
    die "Shit happens. This must not be" unless defined $class;
    $self->result_class($class);
    $self->columns($columns);

    $self->executed(1);
}

1;
