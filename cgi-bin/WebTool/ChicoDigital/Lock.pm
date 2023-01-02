##############################################################################
#
#  ChicoDigital::Lock.pm  Simple file locking mechanism using flock.
#
##############################################################################
#
#    Copyright (c) 2002 Alan Raetz, Chico Digital Engineering
#    All Rights Reserved.
#
#    contact: support@chicodigital.com
#
##########################################################################
#
#    The content of this file is copyrighted material, and is protected
#    by U.S. Copyright laws. You cannot copy or distribute this file or
#    any portion of it without express written permission by Alan Raetz.
#
################################################################################
use strict;

package ChicoDigital::Lock;

use Fcntl qw(:DEFAULT :flock);

# With flock DISABLED, there is code to do locking with
# a semaphore file, however Active State Perl on NT/2000 servers
# has problems with the unlink() command (as of 5.6.1 build 631),
# and so we disable this for now; when flock is disabled via the
# config file, there is no locking for the data file.

my $FLOCK_DISABLED_LOCK = 0; # set to 1 to enable

sub LockAndOpen {

     my $mode = shift;
     my $filename = shift;
     my $doFlock = shift;
     my $log = shift;

     my $lock = ChicoDigital::Lock->new($filename,$doFlock);

     if( ! $lock ) { die "lock $filename failed\n"; }

     my $open = open(PAGE,"$mode$filename");

     if( ! $open ) { die "open $filename failed\n"; }

     return (*PAGE,$lock);
}

sub new {

     my $class = shift;

     my $dir = shift;

     my $flockEnable = shift;

     my $self = bless({ }, $class);

     $self->{dir} = $dir;

     $self->{flockEnabled} = $flockEnable;

     my $lockfile;
     my $lastdir = $dir;

     if ( -d $dir ) { # directory review will create 'review\review.lok'

          if ( substr($dir,-1) ne '/' ) {
                $lastdir =~ s/.*\/(.*?)\Z/$1/;
                $dir .= '/';
          } else {
                $lastdir =~ s/.*\/(.*?)\/\Z/$1/;
          }

          $lockfile = $self->{filename} = $dir . $lastdir . '.lok';

     } else {

          $lockfile = $self->{filename} = $dir . '.lok';
     }

     if ( $flockEnable eq 'yes' ) {

          # Open non-exclusive append; in the race condition, two handles
          # will be open, but flock() will reject one of them.

          open(LOCKFILE,">>$lockfile") || return undef;

          # lock exclusive, but allow wait until timeout failure

          if (flock(LOCKFILE, LOCK_EX)==0) { # lock failed if zero

               return undef;
          }

     } else {

          if ( $FLOCK_DISABLED_LOCK != 0) {

               # Note that even without flock enabled, this code still locks
               # the file specified with a semaphore file; it's just that the
               # semaphore file itself is not locked at the OS level, and thus
               # there exists the possibility of a race condition.

               my $count = 0;

               while ( -e $lockfile && $count < 5 ) {

                    $count++;
                    sleep 1;
               }

               if ( $count == 5 ) { die "Unable to open $lockfile<br>\n"; }

               open(LOCKFILE,">$lockfile");
          }
     }

     $self->{filehandle} = *LOCKFILE;

     return $self;
}

sub release {

     my $self = shift;

     if ( $self->{flockEnabled} eq 'yes' ) {

          # unlink before closing to prevent race condition

          unlink ( $self->{filename} )
                    or die "Unable to unlink " . $self->{filename};

          if ($self->{filehandle}) {

              close( $self->{filehandle} )
                    or die "Unable to close " . $self->{filename};
          }

     } else {

          if ( $FLOCK_DISABLED_LOCK != 0 ) {

               if ($self->{filehandle}) {

                   close( $self->{filehandle} )
                         or die "Unable to close " . $self->{filename};
               }

               unlink ( $self->{filename} )
                         or die "Unable to unlink " . $self->{filename};

          }

     }
}

return (1);
