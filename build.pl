#!/usr/lib/perl

use FindBin;

opendir( my $dh, $FindBin::Bin . '/plus') || die $!;
while(my $folder = readdir $dh){
    $folder = $FindBin::Bin . '/plus/' . $folder;
    next if $folder =~ /.*\/\.+$/;

    my $cmd = "cd $folder && perl Makefile.PL PREFIX=$FindBin::Bin/var/lib && make test install && cd \$OLDPWD";
    print "Building next module ...\n$cmd\n\n";
    system $cmd;
}
closedir $dh;