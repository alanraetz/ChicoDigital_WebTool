##############################################################################
#
#  ChicoDigital::HTMLWriter
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

package ChicoDigital::HTMLWriter;

#############################################################################
# Use package global data instead of object data, since the traversal engine
# would have to carry around a pointer to object data. There is only one
# entry point into this file, calling writeStaticHTMLFiles().
#############################################################################

use vars qw($baseRef $baseDir $delimiter $slash $stringCodeRef $do_all_pages);

#############################################################################
# External API: writeStaticHTMLFiles()
#
#      write all HTML pages contained in the passed in hash reference.
#############################################################################
sub writeStaticHTMLFiles {

     ($baseRef,$baseDir,$delimiter,$slash,$stringCodeRef,$do_all_pages) = @_;

     my $status = 1;

     # The very top level can only have references to hashes

     $status &= _TraversalEngine($do_all_pages,$baseRef);

     return $status;
}

#############################################################################
# Traversal Engine:
#        Descend into the hash structure from the top by calling itself.
#############################################################################
sub _TraversalEngine {

     my ($do_all_pages,$baseRef,@path) = @_;

     my $ret_val = 1; # 1 is success

     my $link_object = ChicoDigital::LinkMethods->new($baseRef,\@path);

     my @linkList = $link_object->getLinkList();

     foreach my $key ( @linkList ) {

          # Descend to the bottom first
          # Any failures will stick return status to zero

          # iterate on itself to descend into perl hash structure.

          push(@path,$key);
          $ret_val &= _TraversalEngine($do_all_pages,$baseRef, @path);
          pop(@path);
     }

     ####################################################################
     # Only write the page if it has been modified (is marked 'dirty')
     # or if it doesn't already exist (admin erased the content dir).
     ####################################################################

     my $filename = $baseDir .
                      ChicoDigital::Common::getFullFilename(@path);

     if ( ($link_object->isDirty() eq 'yes')
               or ($do_all_pages eq 'yes')
                       or !( -e $filename) ) {

           $ret_val &= writePage($filename,$link_object,\@path);
     }

     $link_object->clearDirtyBit();

return $ret_val;
}

sub writePage {

     my ($filename,$link_object,$pathRef) = @_;

     my @path = @$pathRef;

     ####################################################################
     # Call the code reference, which executes a method
     # that will return the properly formatted HTML string.
     # (Web Tool uses WebTool::FormMethods::createStaticHTMLString())
     ####################################################################

     my $HTML_string = $stringCodeRef->($link_object);

     ####################################################################
     # Now we have all the information for the entire file in a string.
     # Write out an HTML file where the directory path is created to
     # duplicate the link path; there will be one directory for each
     # level of links.
     ####################################################################

     pop(@path); # remove the last entry, which is used as the filename

     create_directories(@path);

     my $flockEnable = WebTool::Variables::isFlockEnabled();

     my ($FILE,$lock) =
               ChicoDigital::Lock::LockAndOpen('>',$filename,$flockEnable)
                    or die "Unable to lock file $filename\n";

     print $FILE $HTML_string
               or die "Unable to write file $filename\n";

     close($FILE) or die "Unable to close file $filename\n";

     release($lock);

     return 1; # successful
}

sub create_directories {

    my @dirs = @_;

    my $new_path;

    foreach my $path (@dirs) {

         $path =~ s/\s*//g;

         if ( $path eq '' ) { next; };

         $new_path .= $path;

         my $dir = $baseDir . $new_path;

         if ( !( -d $dir ) ) {

              mkdir($dir,0777) or die "<br>Could not make directory $dir.
                                        <br><br>$!";
         }

         $new_path .= $slash;
    }
}

sub release {

     my $lock = shift;

     if ( ref($lock) && $lock->can("release") ) { $lock->release(); }
}

1;
