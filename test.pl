#!/usr/bin/perl
use strict;
use warnings;
use FindBin;

BEGIN {unshift @INC, map { $FindBin::Bin . '/var/lib/lib/' . $_ } qw[ 5.20.1/x86_64-linux site_perl/5.20.1/x86_64-linux ] }

use lib::abs qw\lib plus/DBD-Pg/t/lib\;
use FindBin;
use App::Info::RDBMS::PostgreSQL;
use DBI;
use TestORM;
use JSON::XS;

$| = 1;
my $dsn = init_database();

my $orm = TestORM->new();
$orm->connect($dsn);

#for (1..10000){
foreach my $row ($orm->q("SELECT * FROM master_table")) {
    print $row->id . ": " . encode_json($row->data) . "\n";
}

print "\n\n";

my $query = $orm->q("
    SELECT m.data AS my_cool_data, 1 AS this_is_one, 2, 3, s.*
    FROM master_table m
    LEFT JOIN slave_table s ON s.master_id = m.id
    WHERE s.id <= 25
");
foreach my $row ($query->all) {
    print $row->id . ": " . $row->slave_data . ", " . encode_json($row->my_cool_data) . ", this_is_one: " . $row->this_is_one ."\n";
}
print "\n\n";

use Data::Dumper;
print Dumper($query->sth->{NAME});
#}

$orm->disconnect;
kill_database();

sub init_database {
    kill_database();
    my $pg = App::Info::RDBMS::PostgreSQL->new;

    my $target_dir = $FindBin::Bin . '/var/testdb';
    (my $pg_ctl = $pg->initdb) =~ s/initdb/pg_ctl/;

    print "==> Initializing database\n";
    my $cmd = $pg->initdb . " --pgdata=$target_dir/data --locale=C --auth=trust";
    `$cmd`;

    print "==> Starting PostgreSQL\n";
    $cmd = "$pg_ctl -o '-k $target_dir/ -h \"\"' -l $target_dir/logfile -D $target_dir/data start";
    `$cmd`;
    sleep 1;

    my $dsn = "dbi:Pg:dbname=postgres;host=$target_dir";
    my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1} );

    print "==> Filling database\n";

    {
        local $/ = undef;
        open my $fh, "test_database.sql";
        my $sql = <$fh>;
        close $fh;
        $dbh->do($sql);
    }
    $dbh->disconnect;

    print "==> Database ready\n";
    return $dsn;
}

sub kill_database {
    my $pg = App::Info::RDBMS::PostgreSQL->new;
    die "PostgreSQL is not installed. :-(\n" unless $pg->installed;

    my $target_dir = $FindBin::Bin . '/var/testdb';
    (my $pg_ctl = $pg->initdb) =~ s/initdb/pg_ctl/;
    if(-e "$target_dir/data/postmaster.pid"){
        print "==> Killing old postmaster\n";
        my $cmd = "$pg_ctl -D $target_dir/data stop";
        `$cmd`;
    }

    if(-e $target_dir) {
        print "==> Removing old database\n";
        my $cmd = "rm -rf $target_dir";
        system ($cmd);
    }

}