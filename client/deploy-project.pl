#!/usr/bin/env perl
use strict;
use warnings;
use 5.010001;
use Pod::Usage;
use Cwd;

my $BASE = '/usr/local/webapp/';
our $VERSION='0.01';

&main; exit;

sub main {
    my $command = shift @ARGV // pod2usage();
       $command =~ s/-/_/g;

    my $code = __PACKAGE__->can("CMD_$command") // pod2usage();
    $code->();
}

sub run {
    print "[run] @_\n";
    system(@_) == 0 or die "[run][FAIL] $!";
}

sub ssh_cmd {
    my ($project) = (shift);
    my $server = get_server();
    run('ssh', "$project\@$server", @_);
}

sub CMD_push {
    my $project   = shift @ARGV // pod2usage();
    my $directory = shift @ARGV // pod2usage();

    my $server = get_server();
    {
        my $guard = Chdir::Guard->new();
        chdir($directory);
        run(
            'rsync',
            qw(-avz),
            qw(-e ssh),
            qw(--delete),
            # qw(--dry-run),
            './',                                           # src
            "$project\@$server:$BASE/$project/code/", # dst
        );
    }

    ssh_cmd($project, "cpanm -l $BASE/$project/perl5/ --notest --verbose --no-man-pages --installdeps $BASE/$project/code/");
    ssh_cmd($project, "/bin/bash", '-c', "pwd; cd $BASE/$project/code/; if [ -x ./postinstall ]; then ./postinstall; fi");
    for ('reread', 'update', 'restart all') {
        ssh_cmd($project, "supervisorctl", $_);
    }
}

sub CMD_log {
    my $project = shift @ARGV // pod2usage();
    ssh_cmd($project, "tail", '-f', "$BASE/$project/log/plackup.log", "$BASE/$project/log/nginx/error.log");
}

sub get_server {
    my $server = $ENV{TENMAYA_SERVER} || 'localhost';
    return $server;
}

package # hide from pause
    Chdir::Guard;

sub new {
    my $class = shift;
    bless \do { my $cwd = Cwd::getcwd() }, $class;
}

sub DESTROY {
    my $self = shift;
    chdir($$self);
}

__END__

=head1 NAME

deploy-project.pl- yet another container environment.

=head1 SYNOPSIS

    push project directory to the remote server
    % deploy-project.pl push foo ~/dev/foo

    tail -f log files
    % deploy-project.pl log foo

=head1 DESCRIPTION

This is a client script for tenmaya environment.

=head1 ENVIRONMENT VARIABLES

=over 4

=item TENMAYA_SERVER

The server name for tenmaya environment.

=back
