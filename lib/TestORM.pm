package TestORM;
use parent 'SORM';


__PACKAGE__->meta(
    table1 => {
        id => { type => 'bigint', nullable => 0, primary_key => 1 },
        data => { type => 'json' },
        details => { reference => 'table2' },
        details2 => { reference => { table => 'table2', method => 'hash' } },
        details3 => { reference => { table => 'table2', method => 'array', sort => 'id' } },
    },
    table2 => {
        id => { type => 'bigint', nullable => 0, primary_key => 1 },
        detail => { type => 'bytea' },
        table1_id => { type => 'bigint', nullable => 0, references => 'table1' }
#        table1_id => { type => 'bigint', nullable => 0, references => { table => 'table1', column => 'id' } }
    },
);

# __PACKAGE__->meta_autoget(1);
# sub meta_override { my ($self, $meta) = @_; return $meta; }


sub init {
    my ($self) = @_;
    print "Initializing ORM ... ";
    $self->SUPER::init;
    print "done.\n";
}