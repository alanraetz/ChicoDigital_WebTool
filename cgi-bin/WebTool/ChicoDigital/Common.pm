##############################################################################
#
#  ChicoDigital::Common
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
use strict;

package ChicoDigital::Common;

sub getBaseReference {

     my $title = WebTool::Variables::getBaseTitle();

     $title =~ s/\s*//g;

     no strict 'refs';

     return ${'Data::' . $title . '::everything'};
}

sub removeServerSideCode {

     my $hash_ref = shift;

     $hash_ref->{title}          = removeSSI( $hash_ref->{title} );
     $hash_ref->{self_URL}       = removeSSI( $hash_ref->{self_URL} );
     $hash_ref->{link_list}      = removeSSI( $hash_ref->{link_list} );
     $hash_ref->{content_string} = removeSSI( $hash_ref->{content_string} );
}

sub removeSSI {

     my $text = shift;

     #
     # Remove server-side include code (hacker precaution)
     #
     $text =~ s/<[\!\?\%][\s\S]*?>[\!\?\%]*//g;
     $text =~ s/<\s*script[^>]*language\s*=\s*["']?PHP\d*["']?[^>]*>//gi;

     return $text;
}

sub getHTMLfileList {

     my $dir = shift;

     my $type = shift; # if 'short' return names w/o full path

     if ( !( -d $dir) ) { return undef; }

     opendir(DIR,$dir) or die "Unable to open directory $dir.\n";

     my @files = readdir(DIR);

     my @result;

     foreach my $file (@files) {

          if ( $file =~ /\.htm[l]$/ ) { push(@result,$file); }
     }

     if ( $type eq 'short' ) { return @result; }

     # append the full directory path onto the filename

     my @fullPath = map {$dir . '/' . $_ } @result;

     return @fullPath;
}

sub getFullFilename {

     my @dirPath = @_;

     # remove the last entry, which is used as the filename
     my $file = pop(@dirPath);

     return getFilePath(@dirPath) . getFilename($file);
}

sub getFilename {

     my $file = shift;

     # If this is the base directory, get the base title

     $file = $file || WebTool::Variables::getBaseTitle();

     $file =~ s/\s*//g;

     return $file . '.html';
}

sub getFilePath {

     my @dirPath = @_;
     my $path;
     my $slash = WebTool::Variables::getFileDelimiter();

     foreach my $dir (@dirPath) {

          $dir =~ s/\s*//g;
          $path .= $dir . $slash;
     }

return $path;
}


sub getEndOfLineCharacter {

     my $eol;

     my $eolTypes  = { Unix => "\012", Mac => "\015", PC => "\015\012" };

     my $platform = WebTool::Variables::getPlatform();

     if ($platform =~ /(?:PC|NT|Windows(?:95)?|DOS)/i) {

          $eol = $eolTypes->{PC};

     } elsif ($platform =~ /Mac(?:intosh)?/i) {

          $eol = $eolTypes->{Mac};

     } else {

          $eol = $eolTypes->{Unix};
     }

     return $eol;
}

1;
