#############################################################################
#
#  ChicoDigital::Template.pm
#
#      Create an HTML string and/or a file with a template string
#      or a template file.
#
##############################################################################
#
#    Copyright (c) 2001 Alan Raetz, Chico Digital Engineering
#    All Rights Reserved.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version. See http://www.gnu.org/fsf/
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details, available
#    at http://www.gnu.org/copyleft/gpl.html
#
#    Under the terms of this license, this code can NOT be incorporated
#    into proprietary software. The source code and the application itself
#    can only be used and distributed if the terms of the GNU Public License
#    are preserved.
#
##############################################################################
use strict;

package ChicoDigital::Template;

################################################################################
#
# Write a new file based on a template file. Expects full path of file names.
#
################################################################################
sub create_file_using_template {

     my ($fileName,$templateFileName,$FORM_ref,$log_object) = @_;

     my $lock = ChicoDigital::Lock->new($fileName) or return 0;

     if ( !(open(NEW_FILE, ">$fileName")) ) {
          if ( $log_object ) { $log_object->write("Could not create file
          $fileName for writing.\n"); }
          die "Could not create file $fileName for writing.\n";
     }

     # write the entire HTML page with one string.
     print NEW_FILE create_HTML_from_template_file( $templateFileName,
                                                    $FORM_ref,
                                                    $log_object
                                                  );

     # Unlock the output file.

     release($lock);

     close(NEW_FILE);

     # force the file as writable
     # chmod($fileName,766);

     if ($log_object) {
          $log_object->write("Successfully created $fileName using
          $templateFileName\n");
     }

return(1); # successful
}

################################################################################
#
# Create an HTML string based on a template file.
#
################################################################################
sub create_HTML_from_template_file {

    my ($template_file,$FORM_ref,$log) = @_;

    if (!open(TEMPLATE,"$template_file")) {
         if ($log) { $log->write("Could not open $template_file ($!)."); }
         die "Could not read template file $template_file.\n";
    }

    local $/; # slurp all lines

    my $text = <TEMPLATE>;

    close (TEMPLATE);

    # The string create by the method is returned to the caller

    return (create_string_from_template($FORM_ref,\$text));
}

################################################################################
#
# Create an HTML string based on an array of lines (of the template).
#
################################################################################
sub create_string_from_template {

    # $hash_ref is a reference to the hash of variables to be inserted into
    # the template. This is typically the CGI form data, but can be anything,
    # such as a hash with only one entry.

    # $line_ref is a reference to an array of lines that contain the template.
    # This can be from a file (as directly above) or from a file (such as
    # ChicoDigital::LinkTemplate.pm

    my ($hash_ref,$line_ref) = @_;

    $$line_ref =~ s{ <!--\s*INSERT_TEXT\s*=\s*(.*?)\s*--> }

                   { exists ( $hash_ref->{$1} )

                       ? $hash_ref->{$1} : ""

                   }gsex;


     return $$line_ref;
}


sub grabTextBlock {

     # @mark_list is a list of start/end text marker pairs
     # Handle a max of 4 pairs.
     #
     my ($file,@mark_list) = @_;

     my @blockList;

     my $lock = ChicoDigital::Lock->new($file) or return;

     open(FILE,"$file") or print "unable to open file $file.\n";
                       # and $log->write("unable to open $file.\n");

     my @lines = <FILE>; my $lines = join('',@lines);

     release($lock);

     #
     # grab the text between the $start and $end markers,
     # using ~ as the match delimiter. The 's' suffix forces the
     # match across the entire string (matches newlines as spaces).
     #
     while ( my($start,$end) = splice(@mark_list,0,2) ) {

          if ( $lines =~ m~$start(.*)$end~s ) {
               push(@blockList,$1);
          } else {
               push(@blockList,'');
          }
     }

     return @blockList;
}

sub release {

     my $lock = shift;

     if ( ref($lock) && $lock->can("release") ) { $lock->release(); }
}

1;
