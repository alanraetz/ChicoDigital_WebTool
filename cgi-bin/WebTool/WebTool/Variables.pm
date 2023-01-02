##############################################################################
#
#  WebTool::Variables
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

package WebTool::Variables;

use vars qw(%var); # package global

###########################################################################
# The contents of data/wtConfig.pl are imported into this file by
#     WebTool::Variables::initializeVariables(%var)
#
# You can manually edit the data/wtConfig.pl file to change variables
# that are not included below.
###########################################################################
sub InitializeVariables {

     # THIS READS IN THE CONFIGURATION HASH FROM Config/wtConfig.pm

     %var = @_;

##############################################################################
# Run-time configuration variables
##############################################################################
$var{DEBUG} = 'no';       # must be 'yes' or 'no'
$var{DELIMITER} = 'x-x';  # URL query string delimiter
$var{FILE_DELIMITER} = '/'; # always forward, even on NT(??)

##############################################################################
# This directory must contain the HTML template files linkPage.html,
# contentPage.html, toolPage.html, and messagePage.html.
##############################################################################
$var{TEMPLATE_DIR} = $var{HOME} . 'Templates/';

$var{USER_TEMPLATE_DIR}= $var{TEMPLATE_DIR} . 'user/';
$var{LINK_TEMPLATE}    = $var{TEMPLATE_DIR} . 'linkPage.html';
$var{TOOL_TEMPLATE}    = $var{TEMPLATE_DIR} . 'toolPage.html';
$var{MESSAGE_TEMPLATE} = $var{TEMPLATE_DIR} . 'messagePage.html';

##############################################################################
# The Web URL path to the Cascading Style Sheets and documentation URLs
##############################################################################
$var{STYLE_SHEET} =      $var{WEB_ROOT} . 'css/WebTool1-style.css';
$var{TOOL_STYLE} =       $var{WEB_ROOT} . 'css/tool-style.css';
$var{USER_GUIDE_LINK} =  $var{WEB_ROOT} . 'docs/UsersGuide.html';
$var{OVERVIEW_LINK} =    $var{WEB_ROOT} . 'docs/userDiagram.html';

##############################################################################
# Dependencies on fields in the wtConfig.pm file.
##############################################################################

my $title = $var{BASE_TITLE};

$title =~ s/\s*//g;

$var{LINK_DB}  = $var{CGI_PATH} . 'Data/' . $title . '.pm';

$var{STATIC_ROOT_URL} = $var{CONTENT_URL} . $title . '.html';

# We leave FLOCK_ENABLE as a separate variable in case there are
# Unix platforms that don't properly support flock().

if ( $var{PLATFORM} =~ /unix/i ) {

     $var{FLOCK_ENABLE} = 'yes';

} else {

     $var{FLOCK_ENABLE} = 'no';
}

##############################################################################
# Other strings that are pasted in the templates.
##############################################################################

my $script = $var{SCRIPT_URL};

$var{LOGO_URL} = $var{WEB_ROOT} . 'images/WebTool.jpg';

my $logo = $var{LOGO_URL};

$var{TOOL_LOGO} = qq~
           <tr>
           <td ALIGN=CENTER VALIGN=TOP COLSPAN="3">
           <img SRC="$logo" ALT="Chico Digital Web Tool" height="60"
           width="550">
           </td>
           </tr>
          ~;

} # end of initializeVariables

###########################################################################
#
# DO NOT EDIT ANYTHING BELOW THIS LINE...
#
###########################################################################

########################### GET METHODS #####################################

#############################################################################
# Run-time environment
#############################################################################

sub getPlatform { return $var{PLATFORM}; }

sub getDebugStatus { return $var{DEBUG}; }

sub getDelimiter { return $var{DELIMITER}; }

sub getArchiveDepth { return $var{ARCHIVE_DEPTH}; }

sub getFileDelimiter { return $var{FILE_DELIMITER}; }

sub getTechEmail { return $var{MAIL_ERRORS_TO}; }

sub getEmailPath { return $var{MAIL_PATH}; }

sub emailErrorEnable { return $var{MAIL_ERROR_ENABLE}; }

sub isFlockEnabled { return $var{FLOCK_ENABLE}; };

sub removeServerSideCode { return $var{REMOVE_SSI}; }

sub getBaseURL { return $var{SCRIPT_URL}; }

sub addLinksToUserTextBox { return $var{TEXTBOX_LINKS}; }

#############################################################################
# Directories and base URLs
#############################################################################

sub getContentDirectory { return $var{CONTENT_DIR}; }

sub getContentURL { return $var{CONTENT_URL}; }

sub getBaseTitle { return $var{BASE_TITLE}; }

sub getStaticRootURL { return $var{STATIC_ROOT_URL} };

sub getCGIdir { return $var{CGI_PATH}; }

sub getWebURL { return $var{WEB_ROOT}; }

sub getBadLinkMessage { return $var{WEB_ROOT} . 'Templates/badLink.html'; }

#############################################################################
# Files
#############################################################################

sub getLogFileName { return $var{LOG_FILE}; }

sub getDatabaseName { return $var{LINK_DB}; }

sub getToolStyleSheet { return $var{TOOL_STYLE}; }

sub getStyleSheet { return $var{STYLE_SHEET}; }

sub getOverviewURL { return $var{OVERVIEW_LINK}; }

sub getUsersGuideURL { return $var{USER_GUIDE_LINK}; }

sub getLogoURL { return $var{LOGO_URL}; }

sub getToolLogo { return $var{TOOL_LOGO}; }

#############################################################################
# TEMPLATE FILES
#############################################################################

sub getUserTemplateDir { return $var{USER_TEMPLATE_DIR}; }

sub getToolTemplateDir { return $var{TEMPLATE_DIR}; }

sub getLinkTemplate    { return $var{LINK_TEMPLATE}; }

sub getToolTemplate    { return $var{TOOL_TEMPLATE}; }

sub getMessageTemplate { return $var{MESSAGE_TEMPLATE}; };


1;

