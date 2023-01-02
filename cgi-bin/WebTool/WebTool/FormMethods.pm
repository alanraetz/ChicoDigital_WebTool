##########################################################################
#
#  WebTool::FormMethods
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

package WebTool::FormMethods;

use vars qw($link_object);

##############################################################################
# Set path for all methods for the LinkMethods object. MUST be done before
# anything is called (so just do it right after getting the form data).
# It also must be done when the 'current page' is changed, such as when
# a page is deleted and the current page is pointed to the previous one.
##############################################################################
sub setPath {

     my $path = shift;

     my $baseRef   = ChicoDigital::Common::getBaseReference();
     my $DELIMITER = WebTool::Variables::getDelimiter();

     my @arr = split(/$DELIMITER/,$path);

     $link_object = ChicoDigital::LinkMethods->new($baseRef,\@arr);
}

sub getLinkList {

     return $link_object->getLinkList();
}

sub updateEntry {

     # The passed in string updates the hash content string

     my $name = shift;

     my $value = shift;

     $link_object->setStringField($name,$value);
}

sub saveDatabaseFile {

     my $baseRef      = ChicoDigital::Common::getBaseReference();
     my $databaseFile = WebTool::Variables::getDatabaseName();
     my $flockEnable  = WebTool::Variables::isFlockEnabled();

     require ChicoDigital::HashWriter;

     ChicoDigital::HashWriter::saveDatabaseFile($baseRef,
                                                $databaseFile,
                                                $flockEnable);
}

#sub getHashList {
#
#     return $link_object->getHash();
#}

sub getHTMLStrings {

     my $text = $link_object->getStringField('content_string');

     my $topBanner = createSubCategoryBanner();

     my $linkHTML = createDynamicLinks();

     return ($topBanner,$linkHTML,$text);
}

sub previewCurrentPage {

     my $previewFlag = 1;

     return

           WebTool::PageFormat::createStaticHTMLString($link_object,$previewFlag);
}

sub deleteEntry {

     my $path = shift;

     my $fileName = getStaticFileName($link_object);

     if ( -e $fileName ) { unlink($fileName); }

     # Now the hard part; the page deleted may have many subpages, which
     # all have to be deleted. We can't use 'rm -rf', because this might
     # be a Windows (or some other) OS. So we have to use Perl rmdir() and
     # Perl unlink() only.

     $fileName =~ s/\A(.*)\.htm[l]\Z/$1/;

     if ( -d $fileName ) {

          deleteAllFiles($fileName);

          rmdir($fileName); # now it's empty, so delete the dir
     }

     # Delete the current database entry

     $link_object->deleteEntry();

     WebTool::FormMethods::saveDatabaseFile();
}

sub addEmptyLinkToDatabase {

     my $newPage = shift;

     my %defaultEntries = ( 'template_file' => 'default.html' );

     $link_object->addEntry($newPage,%defaultEntries);
}

sub createTemplateSelector {

     my $dir = WebTool::Variables::getUserTemplateDir();

     my @templates = ChicoDigital::Common::getHTMLfileList($dir,'short');

     my $pulldown = q~<SELECT NAME="template">~;

     my $currentTemplate = $link_object->getStringField('template_file');

     $pulldown .= "<OPTION VALUE=\"$currentTemplate\" DEFAULT> $currentTemplate";

     foreach my $file (@templates) {

          if ($file eq $currentTemplate) { next; }

          $pulldown .= "<OPTION VALUE=\"$file\"> $file";
     }

     $pulldown .= "</SELECT>";

return $pulldown;
}

#######################################################################
# This creates the top banner list of sub-categories
#######################################################################
sub createSubCategoryBanner {

     my $DELIMITER = WebTool::Variables::getDelimiter();

     # Create a title string from the category path

     my $baseURL   = WebTool::Variables::getBaseURL() . '?path=';
     my $titleHref = $baseURL;

     my $banner = "<A HREF=\"$titleHref\"> Home <\/A> : ";

     my @currentPath = $link_object->getCurrentPath();

     foreach my $sub_category ( @currentPath ) {

         $titleHref .= ChicoDigital::CGI_Lite::url_encode($sub_category);

         $banner .= "<A HREF=\"$titleHref\"> $sub_category <\/A> : ";

         $titleHref .= $DELIMITER;
     }

return $banner;
}

#########################################################################
# This creates the left column list of page links for the editor screen.
#
# Print out each entry as a line of HTML with a link. The link for
# all entries will execute the ChicoLinks CGI script again with the
# query string 'path' entry set to that sub-hash.
#
# When the user selects that link, the script is called again, but
# $FORM{path} now points to a new sub-hash for that link.
#########################################################################
sub createDynamicLinks {

     my ($path,$encoded_path,$HTML);

     my $DELIMITER = WebTool::Variables::getDelimiter();

     my $baseURL   = WebTool::Variables::getBaseURL() . '?path=';

     my @currentPath = $link_object->getCurrentPath();

     foreach my $sub_category ( @currentPath ) {

         $path .= ChicoDigital::CGI_Lite::url_encode($sub_category) . $DELIMITER;
     }
     $baseURL .= $path;

     my @linkList = $link_object->getLinkList();

     KEY: foreach my $newSubDir ( @linkList ) {

         if ( $newSubDir eq '' ) { next KEY; }

         my $href = $baseURL . ChicoDigital::CGI_Lite::url_encode($newSubDir);

         $HTML .= WebTool::Customize::SetLinkFormat($href,$newSubDir);
     }

     return $HTML;
}

sub showMessagePage {

     my ($title,$path,$message) = @_;

     my $templateFile = WebTool::Variables::getMessageTemplate();

     my %HTML;

     $HTML{title}        = $title;
     $HTML{message}      = $message;
     $HTML{big_logo_url} = WebTool::Variables::getLogoURL();

     my $baseURL = WebTool::Variables::getBaseURL();

     $HTML{self_URL} = $baseURL;

     my $script = $baseURL . '?path=' . $path;

     $HTML{back_button} = qq~
                           <a href="$script"><<< Back to previous screen</a>
                          ~;

     print ChicoDigital::Template::create_HTML_from_template_file(
                                                    $templateFile,
                                                    \%HTML
                                                    );
}

sub deleteAllFiles {

     my $dir = shift;

     my @files = ChicoDigital::Common::getHTMLfileList($dir);

     foreach my $file ( @files ) {

          unlink($file); # delete the file

          # Cut off .html suffix to get the directory name

          $file =~ s/\A(.*)\.htm[l]\Z/$1/;

          if ( -d $file ) {

               # iterate by calling itself

               deleteAllFiles($file);

               # if it was a directory, it should now be empty

               rmdir($file);
          }

     }
}

sub getStaticFileName {

     my $link_object = shift;

     my $baseDir = WebTool::Variables::getContentDirectory();

     my @path = $link_object->getCurrentPath();

     my $filePath = ChicoDigital::Common::getFullFilename(@path);

     return $baseDir . $filePath;
}

1;

