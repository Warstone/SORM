package SORM::Meta;
use strict;
use warnings;
use SORM::Meta::Table;
use Class::XSAccessor {
    accessors => [qw/tables column_by_db_id/],
    constructor => 'new'
};

sub parse_meta {
    my ($self, $orm, $meta) = @_;

    my $tables = {};
    foreach my $table (keys %$meta){
        $tables->{$table} = SORM::Meta::Table->_make_table_class($orm, $table, $meta->{$table});
    }
    $self->tables($tables);
    $self->load_db_meta($orm);
}

sub load_db_meta {
    my ($self, $orm) = @_;
    my $dbh = $orm->dbh;
    my $db_meta = $dbh->selectall_arrayref('
SELECT c.relname, a.attname, c.oid, a.attnum
FROM pg_class c
LEFT JOIN pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN pg_attribute a ON a.attrelid = c.oid
WHERE c.relname IN (' . join(", ", map { $dbh->quote($_) } keys %{$self->tables}) . ')
ORDER BY c.relname, a.attnum
');
    my %columns_by_db_id;
    foreach my $row (@$db_meta){
        my $table_class = $self->tables->{$row->[0]};
        next unless defined $table_class;
        my $column_class = $table_class->columns->{$row->[1]};
        next unless defined $column_class;

        my $column_db_id = $row->[2] . '_' . $row->[3];
        my $table_db_id = $row->[2];

        $column_class->db_id($column_db_id);
        $table_class->db_id($table_db_id);
        $columns_by_db_id{$column_db_id} = $column_class;
    }
    $self->column_by_db_id(\%columns_by_db_id);
}

1;
