##############################################################################
#
#  WebTool::Setup.pm
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

package WebTool::Setup;

use CGI;  # need self_url() of CGI.pm for setup only

my $getSelf = new CGI;

my $scriptURL = $getSelf->url();

###########################################################################
# MODIFY THIS FILE IN THIS SECTION ONLY!
#
# Some web servers do not provide a standard URL path to cgi-bin; this
# program uses standard methods for automatically determining the URL,
# but this doesn't work on some web servers.
#
# Option 1: Remove the "#" character from the front of the line below and
# try to run the webtool.cgi script again from your browser.

#$scriptURL = $getSelf->url(-absolute=>1); # relative URL addressing

# If this still does not work, take a stab at defining the
# path to webtool.cgi yourself. Remove the '#' signs from each line
# below and modify each lines to match your web server cgi-bin path:

# Option 2:
# $scriptURL = '/cgi-bin/WebTool/webtool.cgi'; # or try

# Option 3:
# $scriptURL = 'http://yourSite.com/cgi-bin/WebTool/webtool.cgi';


# If you STILL can't get past this step in the setup script, please
# contact us and we'd be glad to help you get Web Tool up and running
# on your web server. Contact support@chicodigital.com
#
# END OF MODIFY
###########################################################################

if ( !$scriptURL ) {

    print "Content-type: text/html\n\n";

    print q~ <ul><font size=+1><b><br>
    Your web server environment did not supply the correct script path.<br>
    You must edit the top of the file cgi-bin/WebTool/Webtool/Setup.pm.<br>
    </font><br></ul>
    ~;

    exit;
}

     ###########################################################################
     #
     # These are the default values that will appear in the web form fields.
     #
     ###########################################################################
my %defaults = (

              WEB_ROOT   => 'http://yourWebSite.com/WebTool/',

              HOME       => '/users/home/yourDirectory/www/WebTool/',

              CGI_PATH    => '/users/home/yourDirectory/cgi-bin/WebTool/',

              CONTENT_URL =>  'http://yourWebSite.com/webt/',

              CONTENT_DIR =>  '/users/home/yourDirectory/www/webt/',

              BASE_TITLE  => 'must be unique',

              REMOVE_SSI  =>  'yes', # removes javascript and SSI by default

              TEXTBOX_LINKS => 'yes',

              PLATFORM      =>  'Unix',

              ARCHIVE_DEPTH     =>  '20', # 20 archive files by default

              MAIL_PATH         =>  '/bin/mail',

              MAIL_ERRORS_TO    =>  'support@yourWebSite.com'
          );

     #
     # These files should be in the www/WebTool directory specified by the user
     #
     my @wwwFiles = qw(
                    images/WebTool.jpg
                    docs/userDiagram.html
                    docs/AdminGuide.html
                    docs/UsersGuide.html
                    docs/ProgrammersGuide.html
                    docs/graphics/ColorLogo3.gif
                    docs/graphics/userDiagram.gif
                    css/tool-style.css
                    css/WebTool1-style.css
                    Templates/messagePage.html
                    Templates/toolPage.html
                    Templates/user/default.html
                    Templates/user/default2.html
               );

#
# These files should be in the CGI directory specified by the user
#
my @cgiFiles = qw ( webtool.cgi
                    WebTool/Setup.pm
                    WebTool/Variables.pm
                    WebTool/PageFormat.pm
                    WebTool/FormMethods.pm
                    WebTool/Customize.pm
                    ChicoDigital/Common.pm
                    ChicoDigital/HashWriter.pm
                    ChicoDigital/HTMLWriter.pm
                    ChicoDigital/LinkMethods.pm
                    ChicoDigital/Lock.pm
                    ChicoDigital/Template.pm
                    ChicoDigital/CGI_Lite.pm
                    ChicoDigital/DataDumper.pm
               );

my @menuOrder = qw(
          CGI_PATH
          WEB_ROOT
          HOME
          CONTENT_URL
          CONTENT_DIR
          BASE_TITLE
          TEXTBOX_LINKS
          PLATFORM
          REMOVE_SSI
          ARCHIVE_DEPTH
          MAIL_PATH
          MAIL_ERRORS_TO
     );

my %prompts = (

CGI_PATH => q~
CGI_PATH: The file directory path to the cgi-bin WebTool sub-directory. This is the directory where the main program webtool.cgi is
~,

WEB_ROOT => q ~
WEB_ROOT: The http URL address where Web Tool's www directory has been installed.
The Web Tool distribution had two main directories, www and cgi-bin. Files within
the www folder should be installed in a directory that can be accessed here
~,

HOME => q~
HOME: The corresponding file directory path to the above Web Tool www sub-directory
~,


CONTENT_URL => q~
CONTENT_URL: The http URL address of the directory that will contain the
web pages created by Web Tool
~,

CONTENT_DIR => q~
CONTENT_DIR: The file directory path to the above CONTENT_URL
~,

BASE_TITLE => q~
BASE_TITLE: This is the page title of the root area (letters, numbers and spaces only). Choose this title carefully. Once the configuration file is written, changing the base title will cause the application to not work
~,

TEXTBOX_LINKS => q~
TEXTBOX_LINKS: Change subpage names into clickable links in the main text area (yes or no)
~,

PLATFORM => q~
PLATFORM: The type of server this script is running on. Must be one of the following (case insensitive): Unix, Windows or Mac (MacOS X servers should be set as Unix)
~,

ARCHIVE_DEPTH => q~
ARCHIVE_DEPTH: Maximum number of archive files to create (enter zero to disable the archive function)
~,

REMOVE_SSI => q~
REMOVE_SSI: Remove javascript, PHP, and other scripting from text input (yes or no). Note that this disables web users from adding scripting to pages as a security precaution; it has no effect on scripting you add to HTML templates
~,

MAIL_PATH => q~
MAIL_PATH: Path to the unix mail program on your server (ie, /bin/mail). Leave empty to disable
~,

MAIL_ERRORS_TO => q~
MAIL_ERRORS_TO: The admin email address that will receive script error messages.
If this is disabled, Perl error messages are sent to the web browser
~,

);

#######################  START OF MAIN PROGRAM  ##########################

##########################################################################
#
# This is called by webtool.cgi when the eval { use Data::wtConfig; } fails.
# It actually loops 3 times, until the wtConfig.pm file is created.
#
##########################################################################
sub doSetup {

     my $configFileExists = shift;

     print "Content-type: text/html\n\n";

     print HTML_header('Web Tool Setup Script');


     # Create the configuration file via a web browser form input

     eval {

          my $cgi = new ChicoDigital::CGI_Lite; # my $cgi = new CGI;
          my %FORM = $cgi->parse_form_data();   # my %FORM = $cgi->Vars();

          if ( $FORM{submit} eq 'Test Script Path' ){

               showStartingMessage();
               showSetupForm($configFileExists);

          } elsif ( $FORM{submit} eq 'Submit Configuration' ){

               processSetupForm(\%FORM);

          } elsif ( $FORM{submit} eq 'Create Config File' ){

               createConfigFile(\%FORM);

          } else {

               showScriptURLForm(\%FORM);
          }
     };

     if ($@) {

          # send error to web browser user:

          print qq~</td></tr></table><br>

               <br><h3><center>Web Tool Setup Error:</center></h3>

               <b><br>$@</b>
          ~;
     }

     print HTML_footer();

exit;

} # end of doSetup

########################   END OF MAIN PROGRAM   ############################

sub showStartingMessage {

     print q{<p>All path information should end with a trailing '/' (slash).};

     print q{<p>There are two types of addresses required in the form below.
             The http URL address is what web users would type into their
             browser to access that directory.<br><p>The file directory is the
             location of a directory on the server hard drive; this is generally
             the directory you would see accessing your web account via FTP.
             <br>};
}

sub showScriptURLForm {

     print qq~<FORM ACTION="$scriptURL">~;

     print q{<p>This first step will determine if your web server
             uses a standard script path.<br><br>

             <p>When you click on the button below, a Configuration
             Form should appear in your browser window. <br><br>

             <p>If the browser hangs or returns an error,
             edit this file:<br>
             <p><ul><b> cgi-bin/WebTool/WebTool/Setup.pm</b></ul></p> 

             <p>Follow the instructions at the top of this file. If you are still unable to get the Configuration Form to appear in your web browser after editing Setup.pm, please contact us at support@chicodigital.com. We want Web Tool to work for everyone!
             <br><br>

            };


     print q~<input type="submit" name="submit" value="Test Script Path">~;
}

sub showSetupForm {

     my $configFileExists = shift;

     if ( $configFileExists eq 'yes' ) {

          #######################################################
          # Override the defaults from this file with the values
          # imported from the current config file.
          #######################################################

          %defaults = %Config::wtConfig::var;

     }

     print qq~<FORM ACTION="$scriptURL">~;

     foreach my $key ( @menuOrder ) {

          my $value = $defaults{$key};

          my $userPrompt = $prompts{$key};

          print qq~$userPrompt: <input type="text" name="$key"
                   value="$value" size="70" maxlength="256"></input><br><br>~;
     }

     print q~<input type="submit" name="submit" value="Submit Configuration">~;

}

sub processSetupForm {

     my $form = shift;

     ##################################################################
     # Check that the files and the script path info match.
     ##################################################################

     my @needEndingSlash = qw( WEB_ROOT
                               HOME
                               CGI_PATH
                               CONTENT_URL
                               CONTENT_DIR );

     foreach my $needSlash ( @needEndingSlash ) {

          addEndingSlash( \$form->{$needSlash} );
     }

     checkDirectoryExists($form->{HOME});

     fileCheck($form->{HOME},@wwwFiles);

     checkDirectoryExists($form->{CGI_PATH});

     fileCheck($form->{CGI_PATH},@cgiFiles);

     createDirectory($form->{CONTENT_DIR});

     checkDirectoryExists($form->{CONTENT_DIR});

     if ( $form->{ARCHIVE_DEPTH} =~ /\d+/ ) {

          my $archiveDir = $form->{CGI_PATH} .'Data/archive';

          createDirectory($archiveDir);

          checkDirectoryExists($archiveDir);
     }

     if ( $form->{MAIL_PATH} eq '' ) {

          $form->{MAIL_ERROR_ENABLE} = 'no';

     } else {

          checkFileExists($form->{MAIL_PATH});

          $form->{MAIL_ERROR_ENABLE} = 'yes';
     }

     setWriteable( $form->{CGI_PATH} . 'Data' );

     setWriteable( $form->{CGI_PATH} . 'Config' );

     if ( $form->{BASE_TITLE} =~ /[^\w\s]+/ ) {

          print q~<p><b>ERROR: your BASE TITLE entry can only have letters,
                  numbers and spaces. Go back and fix it!</b>~;
     } else {

          createEmptyDatabaseFile($form->{BASE_TITLE},$form->{CGI_PATH});
     }

     print "<br><hr><br>\n";

     print qq~<FORM ACTION="$scriptURL">~;

     # pass all the user variables to the next step using hidden variables

     $form->{SCRIPT_URL} = $scriptURL;

     foreach my $key ( keys %$form ) {

          if ( $key eq 'submit' ) { next; }

          print addHiddenVariable($key,$form->{$key});
     }

     print "\n<p><h3>Repair any errors before you create the config
     file. Go back to the Setup Form using the \'back\' button on your browser.</h3>";

     print q~<p><b>If everything is okay, Click Here ==><b><input type="submit" name="submit" value="Create Config File">~;

}

sub addHiddenVariable {

     my ($name,$value) = @_;

     # Add the path variable to the form for the next level of selection.

     return qq~<input type=hidden name="$name" value="$value">\n~;
}

sub addEndingSlash {

     my $ref = shift;

     # if the last character is a word, then replace it with the word + slash

     if ( $$ref =~ /\w\Z/ ) {

           $$ref .= '/';
     }
}

sub createConfigFile {

     my %form = %{ shift() };

     # A couple things that need to be in the config file, yet are not
     # user prompts.
     #
     push(@menuOrder,('SCRIPT_URL','MAIL_ERROR_ENABLE'));

     my $configFile = $form{CGI_PATH} . 'Config/wtConfig.pm';

     open(CONFIG,">$configFile") or die "
          <p>Unable to write new config file $configFile.
          <p>Check the write permissions of this directory.<br>\n";

     print CONFIG qq~\n\npackage Config::wtConfig;\n\n\%var = (\n\n~;

     foreach my $key ( @menuOrder ) {

          my $value = $form{$key};

          print CONFIG $key . ' => \'' . $value . "\',\n\n";
     }

     print CONFIG ");\n\n1;\n\n";

     close(CONFIG);

     print "<br><h3>The Web Tool configuration was saved in $configFile.
           You can manually edit this file at any time to change the configuration.</h3>";

     print "<br><p><b>You should now be able to click \'Refresh\' on your web browser
           to run webtool.cgi and get the main Web Tool editor screen.<br><br>";

     # Disable this...
     sendConfirmEmail($form{CONTENT_URL},$form{BASE_TITLE},$form{MAIL_PATH});

}

sub sendConfirmEmail {

     my($url,$title,$mail) = @_;

     if ( ! -e $mail ) { return; }

     $title =~ s/\s*//g;

     $title .= '.html';

     my $message = "Site $url, area $title completed install process.\n";

     my $mailString =
          "echo \'$message\' | $mail -s\'$message\' register\@chicodigital.com";

     system($mailString);

}

sub setWriteable {

     my $dir = shift;

     if ( ! -d $dir ) {
           print "<p><b>Error: Did not detect directory $dir</b>";
           return;
     }

     if ( ! -w $dir ) {

          print qq~<p>Directory $dir was detected as not writeable,
                    attempting to set it writeable using Perl chmod()....
                    ~;

          if ( !chmod($dir,0777) ) {

               print qq~<p>
                    <b>chmod() failed.</b> If you have not already done so, you
                    MUST set these directories as writeable manually, using your
                    FTP software or shell access.<br>\n
                    ~;

          } else {

               print qq~ Set directory $dir to writeable okay.\n~;
          }

     } else {

          print qq~<p>Directory $dir detected as being writeable.\n~;
     }
}

sub fileCheck {

     my $dir = shift;

     my @files = @_;

     foreach my $file (@files) {

          print "<BR>\n";

          if ( ! -e $dir . $file ) {

               print "<p><b>ERROR: File $dir$file not found.</b>\n";

          } else {

               print "<p>File $dir$file found.\n";
          }
     }
}

sub checkFileExists {

     my $file = shift;

     if ( !$file ) { return; }

     if ( -e $file ) {

          print "<p>File $file found.\n";

     } else {

          print "<p><b>ERROR: File $file not found.</b>\n";
     }
}

sub createDirectory {

     my $dir = shift;

     $dir =~ s/\/\Z//; # remove trailing slash

     if ( ! -d $dir ) {

          if ( mkdir($dir,0777) ) {

               print "<p>Created $dir okay.";

          } else {

               print "<p><b>ERROR: Unable to create $dir.</b>";
          }
     }
}

sub checkDirectoryExists {

     my $dir = shift;

     $dir =~ s/\/\Z//; # remove trailing slash

     if ( -d $dir ) {

          print "<p>Directory $dir found okay.\n";

     } else {

          print "<p><b>ERROR: Directory $dir not found.</b>\n";
     }
}

sub HTML_header {

     my $title = shift;

     return qq~<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<TITLE>$title</TITLE>
</HEAD>
          <center>
          <table border=0 width="650">
          <tr>
          <td  bgcolor="black" width="13%">&nbsp;</td>
          <td  width="60">&nbsp;</td>
          <td width="520" align=left>
          <br>
          <h1>$title</h1>
          ~;
}

sub HTML_footer {

     return qq~</FORM></td><td width="60"></td>
          </tr></TABLE><br><hr></center><br>
          </BODY></HTML>~;
}

sub createEmptyDatabaseFile {

     my $baseName = shift;

     my $CGIdir = shift;

     $baseName =~ s/\s*//g;

     my $dbFile = $CGIdir . 'Data/' . $baseName . '.pm';
     # my $dbFile = 'testThis.txt'; #  . $baseName . '.pm';

     if ( ! -e $dbFile ) {

          open(DB,">$dbFile"); #  or die "<p>$@<br>\n";

          #                          "<p>Unable to write new database file
          #                              $dbFile. Check the write
          #                              permissions of this directory.<br>\n";

          print DB qq~\n\npackage Data::$baseName;\n\n\$everything = {

               "content_string" => '<h1>Welcome to Web Tool!</h1>
               <p>Let us know if you have any problems or questions: email
               support\@chicodigital.com<br>
               ',
               "link_order1" => [],
               "template_file" => "default.html",
               "links1" => {}
               };
               1;
               ~;

          close(DB);

          print "<p>Created empty database file $dbFile okay.<br>\n";

     } else {

          print "<p><b>WARNING: Database file $dbFile already exists,
                 will be using previous file.</b><br>\n";
     }
}

1;

