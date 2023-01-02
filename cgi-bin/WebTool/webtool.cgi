#!/usr/bin/perl

BEGIN { push(@INC,'./cgi-bin/WebTool'); } # sometimes needed...

##########################################################################
#
#    Chico Digital Web Tool 1.0
#
#    Copyright (c) 2002 Alan Raetz, Chico Digital Engineering
#    All Rights Reserved.
#
#    contact: support@chicodigital.com
#
#    All content and source code in this distribution is protected by U.S.
#    Copyright laws and relevant international treaties, laws and provisions.
#    You cannot copy or distribute these files or any portion of them, other
#    than to make backup copies for internal use.
#
#    This distribution includes Perl modules that are publicly distributed
#    via CPAN.org and are made available under their respective licenses.
#    This distribution of Web Tool 1.0 complies with all requirements of
#    these licenses. Thanks to the authors:
#
#     CGI-Lite 2.0 (renamed cgi-bin/WebTool/ChicoDigital/CGI_Lite.pm)
#
#          Copyright (c) 1995, 1996, 1997 by Shishir Gundavaram
#
#     Data::Dumper (renamed cgi-bin/WebTool/ChicoDigital/DataDumper.pm)
#
#          Copyright (c) 1996-98 Gurusamy Sarathy.
#
##########################################################################
#
#    We distribute this program without charge to ensure you can install
#    and configure it properly, and to allow you to evaluate it for your
#    particular purposes.
#
#    THIS IS NOT A FREE PROGRAM. If you decide to use Web Tool 1.0, you
#    must pay for it. Any use of this software to manage web pages on a
#    web site without payment of the license fee will be considered
#    a violation of the evaluation license agreement. See LICENSE.TXT
#    for the full license text.
#
#    See the README.txt for payment details.
#
#    This software is provided on an "as-is" basis and without warranty.
#
###########################################################################
use strict;

#######################################################################
# Eval use statements if cgi-bin is not set-up correctly.
#######################################################################
useExternalModules();

#######################################################################
# Import configuration file 'Config/wtConfig.pm', and run setup
# if not present.
#######################################################################
importConfigFile();

#######################################################################
# The Perl Database File
# ----------------------
# This is a Perl module that is rewritten every time the user saves
# information in the editor. It needs to be in a writeable directory.
#######################################################################
importDataFile();

#######################################################################
#
# MAIN PROGRAM
#
#######################################################################

eval { mainProgram(); }; # Trap most perl errors and 'die' statements

if ($@) { exceptionHandler($@); }

exit;

sub mainProgram {

     print "Content-type: text/html\n\n";

     my $cgi = new ChicoDigital::CGI_Lite;

     # $platform can be one of (case insensitive):
     # Unix, Windows, Windows95, DOS, NT, PC, Mac or Macintosh

     $cgi->set_platform( WebTool::Variables::getPlatform() );

     my %FORM = $cgi->parse_form_data();

     # The FormMethods package uses the path as a persistent global variable;
     # the path will essentially be static for the duration of the process,
     # because each editor operation will re-execute this script. The path is
     # simply a hidden form variable.

     WebTool::FormMethods::setPath($FORM{path});

     if ( $FORM{submit} eq 'Create Page' ) {

          $FORM{newPageName} = checkPageName($FORM{newPageName},$FORM{path});

          if ( $FORM{newPageName} ) {

               WebTool::FormMethods::addEmptyLinkToDatabase($FORM{newPageName});

               savePageChanges(\%FORM);

               showEditPage($FORM{path},'enableLogo');

          }

     } elsif ( $FORM{submit} eq 'Save and Preview Page' ) {

          savePageChanges(\%FORM);

          print WebTool::FormMethods::previewCurrentPage();

          showEditPage($FORM{path},'enableLogo');

     } elsif ( $FORM{submit} eq 'Delete Page' ) {

          showDeletePage(\%FORM);
          #print "<p>The delete function has been disabled for this #demo.<br><br>";

     } elsif ( $FORM{submit} eq 'Confirm Page Delete' ) {

          deletePage($FORM{path});
          #print "<p>The delete function has been disabled for this
          #demo.<br><br>";

     } elsif ( $FORM{submit} eq 'End Session' ) {

          ShowEndSessionPage($FORM{path});

     } elsif ( $FORM{submit} eq 'Regenerate Web Pages' ) {

          # run-time include
          require ChicoDigital::HTMLWriter;

          # Write static HTML files
          EndSession($FORM{do_all},$FORM{path});

     } elsif ( $FORM{submit} eq 'badlink' ) {

          print "<br><b><font color=red>&nbsp&nbsp&nbsp Links on the preview page are not
                functional. Use the link list in the editor below to go to different pages.</font></b>\n";

          showEditPage($FORM{path},'enableLogo');

     } elsif ( $FORM{path} ) { # if any path is specified, show it.

          showEditPage($FORM{path},'enableLogo');

     } elsif ( !$FORM{path} ) { # && $FORM{'program name'} ) {

          # Begin with program name root on first log-in
          # $FORM{path} =  $FORM{'program name'};

          showEditPage($FORM{path},'enableLogo');

     } else {

          die 'Invalid script parameter';
     }
}

####################   END OF MAIN PROGRAM   ############################

#########################################################################
#
# Extract or generate these variables to be pasted into the HTML:
#
#    $HTML{title}           - page title
#    $HTML{enablePreview}   - mark preview button 'DISABLED'
#    $HTML{childWindow}     - the name of the preview file
#    $HTML{link_list}       - the HTML list of left column web links
#    $HTML{textEditBox}     - the main body of text content
#    $HTML{self_URL}        - the URL to this script
#
# We just plug these variables into the HTML template and print the
# output to the screen.
#
#########################################################################
sub showEditPage {

     my ($path,$enableLogo) = @_;

     my (%HTML,$content);

     ($HTML{title},$HTML{link_list},$content) =

                                   WebTool::FormMethods::getHTMLStrings();
     if ( !$HTML{link_list} ) {

           $HTML{link_list} = '&lt none &gt<p>';
     }

     $HTML{title} = $HTML{title} || WebTool::Variables::getBaseTitle();

     $HTML{self_URL} = WebTool::Variables::getBaseURL();

     $HTML{templateSelect} = WebTool::FormMethods::createTemplateSelector();

     $HTML{textEditBox} = getTextEditBox($content);

     $HTML{textEditBox} .= addHiddenVariable('path',$path);

     $HTML{tool_style}         = WebTool::Variables::getToolStyleSheet();
     $HTML{tool_overview_link} = WebTool::Variables::getOverviewURL();
     $HTML{users_guide_link}   = WebTool::Variables::getUsersGuideURL();

     if ( $enableLogo ) {
          $HTML{tool_logo} = WebTool::Variables::getToolLogo();
     }

     my $templateFile = WebTool::Variables::getToolTemplate();

     print ChicoDigital::Template::create_HTML_from_template_file(
                                                        $templateFile,
                                                        \%HTML);
}

use CGI;

sub getTextEditBox {

     my $data = shift;

     $data = ChicoDigital::CGI_Lite::browser_escape($data);

     my $width = 88;

     my $text = qq~<textarea name="content_string" cols="$width" rows="20"
                   WRAP>$data</textarea><br>
                ~;

     return $text;
}

###########################################################################
# We save the entire database file to disk each time someone does a save.
# It's expensive, but that's the way Perl/CGI works. The next call
# to the script will 'use Data/BaseName.pm' and will read in the new changes.
###########################################################################
sub savePageChanges {

     my $form_ref = shift;

     if ( WebTool::Variables::removeServerSideCode() eq 'yes' ) {

          ChicoDigital::Common::removeServerSideCode($form_ref);
     }

     # $form_ref->{content_string} =~ s/\n<br>/<br>/msg;
     # $form_ref->{content_string} =~ s/<br>\n/<br>/msg;

     WebTool::FormMethods::updateEntry('content_string',
                                           $form_ref->{content_string});

     # Save user selection of template file into data structure.

     if ( $form_ref->{template} && $form_ref->{template} ne '' ) {

          WebTool::FormMethods::updateEntry('template_file',$form_ref->{template});
     }

     WebTool::FormMethods::saveDatabaseFile();
}


sub showDeletePage {

     my $form_ref = shift;

     my $title = 'Confirm Page Delete';

     my $message =
         qq~<p><h3>This deletes the current page and all pages linked from
         the current page (all pages that are accessed via the current
         page). <br><br>There is no way to recover the deleted information.
         </h3>~;

     $message .= addHiddenVariable('path',$form_ref->{path});

     $message .= q~<p>
          <center><input type="submit" name='submit' value="Confirm Page Delete">
          </center>~;

     WebTool::FormMethods::showMessagePage($title,
                                           url_encode($form_ref->{path}),
                                           $message);
}

sub deletePage {

     my $path = shift;

     my $status = WebTool::FormMethods::deleteEntry($path);

     my $delimiter = WebTool::Variables::getDelimiter();

     print qq~<br><b> &nbsp The page has been deleted.</b><br>~;

     # TRICKY: We set the path variable in the FormMethods package
     # back to the previous page, then display the previous page,
     # (since the current page has been deleted).

     # chop off the last entry in the path string (name of current page)

     if ( $path =~ s/^(.*)$delimiter.*?\Z/$1/ ) {
          $path = $path;
     } else {
          $path = '';
     }

     WebTool::FormMethods::setPath($path);

     showEditPage($path);

}

sub ShowEndSessionPage {

     my $path = shift;

     my $title = 'End Web Tool Session';

     my $message = qq~<p><h3>
               All pages added or changed will appear on the web site
               if you confirm this operation.
         </h3>~;

     $message .= addHiddenVariable('path',$path);

     $message .= q~<table width="300"><tr>
          <td>
          Regenerate New or Modified Pages Only
          </td><td>
          <input type="radio" name='do_all' value="regenerate modified pages
          only" CHECKED></td></tr><tr><td>
          Regenerate All Pages
          </td><td>
          <input type="radio" name='do_all' value="regenerate all pages">
          </td></tr></table><br>
          <input type="submit" name='submit' value='Regenerate Web Pages'><br><br>
          ~;

     WebTool::FormMethods::showMessagePage($title,url_encode($path),$message);

}

sub EndSession {

     my $do_all_pages = shift;

     my $path = shift;

     my $do_all;

     if ($do_all_pages eq 'regenerate all pages') { $do_all = 'yes'; }

     WebTool::PageFormat::writeStaticHTMLFiles($do_all);

     my $title = 'Web Tool End Session';

     my $url = WebTool::Variables::getStaticRootURL();

     print  qq~<br><p><b> &nbsp Go to <a href="$url">this page</a> to view your
              changes as static files.
              (be sure to hit 'reload' on your browser to view any changes).</b><br>
         ~;

     showEditPage($path);
}

sub getHTMLfileList {

     my $dir = shift;

     my @result;

     opendir(DIR,$dir) or die "Unable to open directory $dir.\n";

     my @files = readdir(DIR);

     foreach my $file (@files) {

          if ( $file =~ /\.htm[l]$/ ) { push(@result,$file); }
     }

     return @result;
}

sub checkPageName {

     my ($name,$path) = @_;

     # No puncuation is allowed in link name,
     # because it becomes a file or directory name.

     my $message = '';

     my $linkDelimiter = WebTool::Variables::getDelimiter();

     if ( $name =~ /[^\w\s]+/ ) {

          # If one non-character or non-space, fail

          $message = 'Page names can only have letters, numbers, spaces,
                      and underscore characters. "<b>' .  $name . '</b>"
                      is an invalid name.';

     } elsif ( $name =~ /$linkDelimiter/ ) {

          # can't have the link delimiter in the name, of course...

          $message = 'The page name you specified has the internal
                      delimiter <b>' .  $linkDelimiter . '</b>"
                      in it. You must remove this part of the name.';

     } elsif ( $name !~ /\w+/ ) {

          # If it doesn't contain any word characters, not valid

          $message = q~<h2>Page Name not specified. The page name must be
                          typed in the text box in the left column.</h2>~;

     } else {

          # remove leading/trailing whitespace

          $name =~ s/^\s*(.*?)\s*\Z/$1/;

          # change any spacing between words to a single space

          $name =~ s/\s+/ /g;

          # Check the name to be added to the database against what's already
          # there. The class method getLinkList uses the current page as
          # default.

          my @linkList = WebTool::FormMethods::getLinkList();

          foreach my $link ( @linkList ) {

               if ( $link eq $name ) {

                   $message =
                       q~<h2>Duplicate page name.</h2>
                         <p>The page name must be unique.~;
               }
          }
     }

     # If everything was okay, return the name, else show the error message

     if ( $message eq '' ) {

       return $name;

     } else {

           WebTool::FormMethods::showMessagePage(
                                        'Web Tool Error',
                                        url_encode($path),
                                        $message);

           return undef;
     }
}

sub release {

     my $lock = shift;

     if ( ref($lock) && $lock->can("release") ) { $lock->release(); }
}

sub addHiddenVariable {

     my ($name,$value) = @_;

     # Add the path variable to the form for the next level of selection.

     return qq~<input type=hidden name="$name" value="$value">~;
}

sub useExternalModules {

  BEGIN {

     #########################################################################
     # INTERNAL PACKAGES. These are included with this application.
     #########################################################################

     # These *.pm files are in cgi-bin/WebTool/WebTool/
     import ("WebTool::FormMethods");
     import ("WebTool::PageFormat");
     import ("WebTool::Variables");
     import ("WebTool::Customize");

     # These *.pm files are in cgi-bin/WebTool/ChicoDigital/
     import ("ChicoDigital::Common");
     import ("ChicoDigital::Lock");
     import ("ChicoDigital::Template");
     import ("ChicoDigital::LinkMethods");
     import ("ChicoDigital::CGI_Lite");

     # run-time includes, loaded only when needed
     # import ("ChicoDigital::HTMLWriter");
     # import ("ChicoDigital::HashWriter");
     # import ("ChicoDigital::DataDumper");

     sub import {

          my $pkg = shift;

          eval "use $pkg";

          if ( $@ ) {

               $pkg =~ s/::/\//; # replace '::' with forward slash

               print "Content-type: text/html\n\n";

               print qq~<h3><center>Web Tool Setup Error</center></h3>
                   <p><b>Could not find file $pkg.pm.</b><br>
               ~;

               print qq~
               <p>Web Tool could not find it's own *.pm modules.
               <p>Perl error: $! $@
               ~;
               exit;
          }
     }

  } # end BEGIN
}

sub importConfigFile {

     eval "use Config::wtConfig";

     if ( ! defined (%Config::wtConfig::var) ) {

          # run-time include of Setup.pm. We only compile and load the
          # Setup.pm module if the configuration file has not been defined.

          require WebTool::Setup;

          # Create the configuration file via a web browser form input

          WebTool::Setup::doSetup();

     } else {

          # export the contents of wtConfig.pm into the Variables.pm namespace

          WebTool::Variables::InitializeVariables(%Config::wtConfig::var);
     }

}

sub importDataFile {

     my $dbName = WebTool::Variables::getBaseTitle();

     no strict 'refs';

     #######################################################################
     # The Perl Database File
     # ----------------------
     # This is a Perl module that is rewritten every time the user saves
     # information in the editor. It needs to be in a writeable directory.
     #######################################################################

     $dbName =~ s/\s*//g;

     my $database = 'Data::' . $dbName ;

     my $dbRef = 'Data::' . $dbName . '::everything';

     eval "use $database;";

     if ( $@ ) {

          print "Content-type: text/html\n\n";
          print "<h3>I couldn't find the Perl database file!</h3>";
          print "<h3>The database file $dbName.pm. does not exist or is not valid. </h3>";
          exit;
     }
}

sub exceptionHandler {

     my $errorMessage = shift;

     my $email_address  = WebTool::Variables::getTechEmail();
     my $mailProgram    = WebTool::Variables::getEmailPath();
     my $emailErrors    = WebTool::Variables::emailErrorEnable();

     if ($emailErrors eq 'yes') {

          print qq~<h3><center>Internal Web Tool Error</center></h3>
              <p>
              Unable to complete the requested operation. An email has
              been sent to the system administration with the error
              message.
              ~;

          my $mailString =
               "echo \'$errorMessage\' | $mailProgram -s\'Web Tool Error\' $email_address";

          system($mailString);

     } else {

          # send to web browser user:

          print qq~<h3><center>Internal Web Tool Error</center></h3>
              <b>program returned: <br>$errorMessage</b>
              ~;
     }
}

