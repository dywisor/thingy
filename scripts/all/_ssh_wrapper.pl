#!/usr/bin/perl
# Usage:
#   ssh-<FEAT>{-<FEAT>}
#   scp-<FEAT>{-<FEAT>}
#   sftp-<FEAT>{-<FEAT>}
#
# DEP: perl5
#

package SSHWrapper::Main;

use strict;
use warnings;
use feature qw( say );
use English qw( -no_match_vars );

use File::Basename ();
use File::Spec ();

# name => empty | command
# str  -> undef | ArrayRef<str>
my %DEFAULT_SSH_COMMANDS = (
    ssh  => undef,
    scp  => undef,
    sftp => undef,
);

my @SSH_OPTS_UNSAFE = (
    '-o', 'UserKnownHostsFile=/dev/null',
    '-o', 'StrictHostKeyChecking=no',
);


my @parts = grep { $_; } split /[\-]/sx, (File::Basename::basename($PROGRAM_NAME));

my @cmdv;

my $ssh_prog = shift @parts;
if ( ! $ssh_prog ) {
    die "No SSH program requested.";

} elsif ( exists $DEFAULT_SSH_COMMANDS{$ssh_prog} ) {
    if ( $DEFAULT_SSH_COMMANDS{$ssh_prog} ) {
        push @cmdv, @{ $DEFAULT_SSH_COMMANDS{$ssh_prog} };

    } else {
        push @cmdv, $ssh_prog;
    }

} else {
    die "SSH program wrapper not implemented: ${ssh_prog}";
}

my %feats = map { $_ => 1; } @parts;

# unsafe: disable host key verification / known_hosts
if (delete $feats{'unsafe'}) {
    push @cmdv, @SSH_OPTS_UNSAFE;
}

# jump [via_jumphost]   // consumes ARGV
if (delete $feats{'jump'}) {
    my $jump_via = shift @ARGV;
    if ( ! $jump_via ) {
        die "missing jump host argument."
    }
    push @cmdv, '-o';
    push @cmdv, (sprintf 'ProxyCommand="ssh -W %%h:%%p %s"', $jump_via);
    # there's also ssh -J <jump_via>
}

my @missing = keys %feats;
if ( scalar @missing ) {
    die ( "features not implemented: " . (join ' ', sort @missing) );
}

push @cmdv, @ARGV;

exec @cmdv;
