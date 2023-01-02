##############################################################################
#
#  WebTool::PageFormat
#
#    Copyright (c) 2002 Alan Raetz, Chico Digital Engineering
#    All Rights Reserved.
#
#    contact: support@chicodigital.com
#
##########################################################################
#
#    The contents of this file is copyrighted material, and is protected
#    by U.S. Copyright laws. You cannot copy or distribute this file or
#    any portion of it without express written permission by Alan Raetz.
#
###########################################################################
use strict;

package WebTool::PageFormat;

sub writeStaticHTMLFiles {

     my $do_all_pages = shift;

     # Pass in a code reference, because HTMLWriter is a completely generic
     # module, it should not be WebTool specific; the static HTML string
     # will use different templates and variable substitution, though, so
     # we can't just put it in HTMLWriter.

     my $stringCodeRef  = \&createStaticHTMLString;

     my $baseRef    = ChicoDigital::Common::getBaseReference();
     my $baseDir    = WebTool::Variables::getContentDirectory();
     my $delimiter  = WebTool::Variables::getDelimiter();
     my $slash      = WebTool::Variables::getFileDelimiter();

     ChicoDigital::HTMLWriter::writeStaticHTMLFiles(
                                                    $baseRef,
                                                    $baseDir,
                                                    $delimiter,
                                                    $slash,
                                                    $stringCodeRef,
                                                    $do_all_pages
                                                  );

     # Now that the modified pages have been written, the {dirtyBit}
     # tag for each modified page was cleared, so we update the
     # Perl Database file with this status.

     WebTool::FormMethods::saveDatabaseFile();
}

sub createStaticHTMLString {

     my $link_object = shift;

     my $previewFlag = shift;

     my (%HTML,$content,$template);

     my @path = $link_object->getCurrentPath();

     # the first entry in the path list is the main category
     $HTML{main_category} = WebTool::Variables::getBaseTitle(); #$path[0] ||

     # the last entry in the path list is the page title
     $HTML{title} =  $path[-1] || WebTool::Variables::getBaseTitle();

     $HTML{directory_path} = createDirectoryPath($previewFlag,@path);

     $HTML{link_list} = createVerticalLinkList($link_object,$previewFlag);

     $HTML{content_string} = $link_object->getStringField('content_string');

     # Every text instance of a link name is turned into a clickable link

     processText($previewFlag, $link_object, \$HTML{content_string});

     $HTML{style_sheet} = WebTool::Variables::getStyleSheet();

     # Convert any http: or https: or ftp: references into web links
     $HTML{content_string} =~
          s/([\s\(]|\A|<br>)(http:\/\/|ftp:\/\/|https:\/\/)([^\s\)"'<>]+)/$1<a
          href="$2$3">$2$3<\/a>/gi;

     # Choose which template file to use. If there is an override, use it.

     my $templateFile = $link_object->getStringField('template_file');

     $templateFile = WebTool::Variables::getUserTemplateDir() . $templateFile;

     if ( !$templateFile or !( -f $templateFile) ) {

          $templateFile = WebTool::Variables::getUserTemplateDir() .
          'default.html';
     }

     return ChicoDigital::Template::create_HTML_from_template_file(
                                                        $templateFile,
                                                        \%HTML
                                                        );
}

##############################################################################
# Call this when re-generating static pages. The links will have to
# point to files, not back to the main program.
#
# Note how the HTTP reference path must equal the path of the files written:
#
# getContentURL       => 'http://website.com/this/path/'
# getContentDirectory =>  '/home/website/www/this/path/'
#
# These references MUST point to the same directory on the web server.
#
##############################################################################
sub createVerticalLinkList {

     my $link_object = shift;

     my $previewFlag = shift;

     # This creates a vertical HTML list string

     return createLinkListHTML($link_object,$previewFlag,"<br>\n");
}

sub createLinkListHTML {

     my $link_object = shift;

     my $previewFlag = shift;

     my $delimiter = shift;

     my @linkList = $link_object->getLinkList();

     my $HTML;

     my $badLink = WebTool::Variables::getBaseURL() . '?submit=badlink';

     foreach my $link ( @linkList ) {

          if ( $link eq '' ) { next; }

          # If this is just a preview page, then don't use the real page links

          if ( $previewFlag ) {

               $HTML .= "<A HREF=\"$badLink\"> $link <\/A>" . $delimiter;

          } else {

               my $URL = create_HTTP_Link($link_object,$link);

               $HTML .= "<A HREF=\"$URL\"> $link <\/A>" . $delimiter;
          }
     }

     return $HTML;
}

sub processText {

     my ($previewFlag,$link_object,$textRef) = @_;

     if ( WebTool::Variables::addLinksToUserTextBox() eq 'yes' ) {

          addLinksToText($previewFlag,$link_object,$textRef);
     }

     WebTool::Customize::TextFilter($textRef);
}


sub addLinksToText {

     my ($previewFlag,$link_object,$lineRef) = @_;

     my @linkList = $link_object->getLinkList();

     my $badLink = WebTool::Variables::getBaseURL() . '?submit=badlink';

     # The $line represents the entire content string. Any instance of text
     # that matches the link name will be replaced with the HTTP link.

     foreach my $link ( @linkList ) {

          # don't turn stuff inside tags into links!

          if ( $$lineRef =~ /$link/ms ) {

               my $HTTP;

               if ( ! $previewFlag ) {

                    my $URL = create_HTTP_Link($link_object,$link);

                    $HTTP = "<A HREF=\"$URL\">$link<\/A>";

               } else {

                    $HTTP = "<A HREF=\"$badLink\">$link<\/A>";
               }

               # match before the first HTML tag bracket

               if ( $$lineRef !~ /[<>]/ ) {

                    $$lineRef =~ s/$link/$HTTP/msg;
               }

               # match before the first HTML tag bracket

               while ( $$lineRef =~ s/\G([^<]*\b)$link(\b)/$1$HTTP$2/msg ) {};

               # replace every match not inside a tag

               while ( $$lineRef =~ s/(>[^<]+\b)$link(\b[^>]+<)/$1$HTTP$2/msg ) {};

               # replace matches between the last tag and EOF

               while ( $$lineRef =~ s/([^>]*>[^<]+?\b)$link(\b[^>]*)\Z/$1$HTTP$2/msg ) {};

          }
     }
}

sub create_HTTP_Link {

     my $link_object = shift;

     my $linkName = shift;

     my $baseURL = WebTool::Variables::getContentURL();

     my @dirPath = $link_object->getCurrentPath();

     my $href = $baseURL .
           ChicoDigital::Common::getFullFilename(@dirPath,$linkName);

     return $href;
}

sub createDirectoryPath {

     my $previewFlag = shift;

     my @path = @_;

     my $baseURL = WebTool::Variables::getContentURL();

     my $delimiter = ' : ';

     if ($previewFlag) { return join ($delimiter,@path); }

     my @dirs;

     my $home = WebTool::Variables::getStaticRootURL();

     my $baseName = WebTool::Variables::getBaseTitle();

     my $HTML = "<A HREF=\"$home\"> $baseName <\/A>" . $delimiter;

     my $currentPage = pop(@path);

     foreach my $level (@path) {

          my $dir = ChicoDigital::Common::getFilePath('/',@dirs);

          my $href = $baseURL . $dir .
                            ChicoDigital::Common::getFilename($level);

          $HTML .= "<A HREF=\"$href\"> $level <\/A>" . $delimiter;

          push(@dirs,$level);  # go down one directory
     }

     # The current doesn't need a link to itself
     return $HTML . $currentPage;
}

1;

