##############################################################################
#
#  ChicoDigital::HashWriter.pm
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
###########################################################################
#
# Write the Perl structure '%everything' to disk using Data::Dumper.
#
# The alternative to this is to use the CPAN Storable.pm module which will be
# faster and more efficient for large structures; the advantage of using
# Data::Dumper is that the data file is readable, and thus makes the data
# modifiable by an administrator (and also easier to debug).
#
##############################################################################
use strict;

package ChicoDigital::HashWriter;

my $log_object;

sub saveDatabaseFile{

     my ($baseHashRefName,$databaseFile,$flockEnable) = @_;

     saveArchiveFile($databaseFile); # save a copy of linkDB.pm into ./archive/

     # We write the file, but that file won't be used until the next
     # ChicoLinks.cgi process starts up.

     my ($FILE,$lock) =
          ChicoDigital::Lock::LockAndOpen('>',$databaseFile,$flockEnable)
                    or return 0;

     # my $header = createFileHeader($databaseFile);
     # print $FILE $header;

     # Avoid local copy of entire string, use ref to string instead.

     # we write the entire hash to disk
     my $string_ref = createHashString($baseHashRefName,$databaseFile);

     print $FILE $$string_ref . "\n\n";

     close($FILE);

     release($lock);
}

sub saveArchiveFile {

     my $DATABASE = shift;

     my $archiveDepth = WebTool::Variables::getArchiveDepth();

     if ( $archiveDepth == 0 ) { return; }

     my ($path,$file) = parseFullFilePathName($DATABASE);

     my $archiveDir = $path . 'archive/';

     if ( !(-e $archiveDir) ) {

          mkdir($archiveDir,0777);
     }

     # Need to limit archive directory to 20-30 files max.
     # Count files and delete the oldest ones

     opendir(DIR, $archiveDir) || die "Could not open directory $archiveDir\n";
     my @raw_list = map($archiveDir.$_, readdir(DIR));
     closedir(DIR);

     # because the filenames are dated year/month/day, 'sort' will put
     # the oldest files at the end of the array.

     my @src_files = sort grep(/$file/, @raw_list);

     # Delete the oldest (first) files
     if ( @src_files > $archiveDepth ) {
          my $oldFile = $src_files[0];
          unlink($oldFile);
     }

     my $datestamp = getDateStamp();

     my $archive_file = $archiveDir . '/' . $file . '.' . $datestamp . $$;

     open(ARCHIVE,">$archive_file") or die "Unable to open archive file
                                             $archive_file.<br>\n";

     open(DB,"<$DATABASE") or die "Unable to open database file
                                             $DATABASE<br>\n";

     undef $/; # input delimiter variable
     my $entireFile = <DB>;
     $/ = "\n";
     print ARCHIVE $entireFile;

     close(ARCHIVE);
     close(DB);

     chmod($archive_file,0666);
}

###########################################################################
# The Data::Dumper package does not handle hashes correctly.
# We have to convert from a hash ref to an array ref, then
# write out a true hash manually from that array.
###########################################################################

sub createHashString {

     my ($hashref,$filename) = @_;

     require ChicoDigital::DataDumper;

     # Configure the Data Dumper module

     $ChicoDigital::DataDumper::Purity   = 1;
     $ChicoDigital::DataDumper::Useqq    = 1;
     $ChicoDigital::DataDumper::Deepcopy = 1;
     $ChicoDigital::DataDumper::Varname  = 'VAR';

     my ($path,$file) = parseFullFilePathName($filename);

     my $hashString = "package Data::$file;\n\n\$everything = {\n";

     # The top level must be rewritten as hash entries

     foreach my $key ( keys %$hashref ) {

          my @list = $hashref->{$key};

          my $substring =  ChicoDigital::DataDumper->Dump(\@list);

          # remove starting variable name

          $substring =~ s/^\$VAR\d+\s*=\s*//;

          # remove ending semicolon

          $substring =~ s/;\n$//;

          $hashString .= "\t\"" . $key . "\" => " . $substring . ",\n";
    }

    $hashString =~ s/\,\Z//; # remove trailing comma

    $hashString .= "\n};\n\n1;\n"; # module has to return (1)

return \$hashString;

}

sub createFileHeader {

     my $filename = shift;
     my ($path,$file) = parseFullFilePathName($filename);

     # The text between the 'END_HEADER' declarations are put in $fileHeader
     my $fileHeader = <<END_HEADER;
##############################################################################
#
#  $file.pm  Perl Database of Link Structure
#
#  Each data structure entry represents either a web link or page content
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

# To access this package, the calling program must push the WRITEABLE
# directory where this file exists into \@INC
#        BEGIN { push(\@INC, <this directory>); }


END_HEADER

     return $fileHeader;
}

sub parseFullFilePathName {

     my $DATABASE = shift;

     my ($path,$file);

     # $DATABASE is the file name with full path; extract directory, and filename w/o suffix

     if ( $DATABASE =~ /(.*\/)(.*?)\..*?\Z/ ) {

          $path = $1;

          $file = $2;

     } else {

          die "Unable to parse filename \$DATABASE: $DATABASE\n";
     }

return ($path,$file);
}

sub getDateStamp {

     my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

     $year += 1900;

     my $datestamp = sprintf("%04d_%02d%02d_%02d%02d%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);

     # for demonstration, not currently used.
     my $datestring = sprintf("%02d/%02d/%04d %02d:%02d:%02d",$mon+1,$mday,$year+1900,$hour,$min,$sec);

     return $datestamp;
}

sub release {

     my $lock = shift;

     if ( ref($lock) && $lock->can("release") ) { $lock->release(); }
}

1;
