package TestORM;
use parent 'SORM';

__PACKAGE__->meta({
    master_table => {
        id => { type => 'bigint', nullable => 0, primary_key => 1 },
        data => { type => 'text' },
    },
    slave_table => {
        id => { type => 'bigint', nullable => 0, primary_key => 1 },
        master_id => { type => 'bigint', references => 'master_table' },
        slave_data => { type => 'text' },
    }
});

1;
