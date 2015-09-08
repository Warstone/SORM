#!/usr/bin/perl
use strict;
use warnings;
use lib::abs qw\lib var/lib plus/DBD-Pg/t/lib\;
use FindBin;
use App::Info::RDBMS::PostgreSQL;
use DBI;

my $dsn = init_database();

print "Executable here\n";

kill_database();

sub init_database {
    kill_database();
    $| = 1;
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

    return $dsn;
}

sub kill_database {
    $| = 1;
    my $pg = App::Info::RDBMS::PostgreSQL->new;
    die "PostgreSQL is not installed. :-(\n" unless $pg->installed;

    my $target_dir = $FindBin::Bin . '/var/testdb';
    (my $pg_ctl = $pg->initdb) =~ s/initdb/pg_ctl/;
    if(-e "$target_dir/data/postmaster.pid"){
        open my $pidf, "< $target_dir/data/postmaster.pid" || die $!;
        my $pid = <$pidf>;
        close $pidf;
        print "==> Killing old postmaster\n";
        `$pg_ctl -D $target_dir/data stop`;
    }

    if(-e $target_dir) {
        print "==> Removing old database\n";
        system ("rm -rf $target_dir");
    }

}