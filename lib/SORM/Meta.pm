package SORM::Meta;
use SORM::Meta::Table;
use Class::XSAccessor {
    accessors => [qw/tables/],
    constructor => 'new'
};


=cut
__PACKAGE__->table('my_table');
__PACKAGE__->columns({
    id => { type => 'integer', nullable => 1, primary_key => 1},
    non_id => { type => 'integer' },
    non_id2 => { type => 'text' },
    theirs_id => { type => 'integer', nullable => 1, references => { table => 'theirs', column => 'id' } },
    theirs_id2 => { type => 'integer', nullable => 0, references => { table => 'theirs' } },
    theirs_id2 => { type => 'integer', references => 'theirs' },
    _complex => {
        references => {
            ['non_id', 'non_id2'] => [ { table => 'theirs', columns => ['data1', 'data2'] } ]
        },
        uniqs => [
            ['non_id', 'non_id2'],
        ],
    },
    ref_set => { reference => 'theirs', 
});
=cut

sub parse_meta {
    my ($self, $orm, $meta) = @_;

    my $tables = {};
    foreach my $table (keys %$meta){
        $tables->{$table} = SORM::Meta::Table->make_table($orm, $table, $meta->{$table});
    }
    $self->tables($tables);

}

1;
