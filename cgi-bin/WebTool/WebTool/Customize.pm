##########################################################################
#
#  WebTool::Customize.pm
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

package WebTool::Customize;

sub TextFilter {

     my $textref = shift;

     my $eol = ChicoDigital::Common::getEndOfLineCharacter();

     # Change all instances of newlines into <br> the user text string.
     # Enabled by default. To disable this and cause text submitted
     # by users to wrap regardless of their formatting ('pure' HTML),
     # put a pound sign '#' in front of this line:

     $$textref =~ s/$eol/<br>/msg;

     # Using the $textref variable (a reference to the text string),
     # you can add your own processing in here. Use the /msg suffix
     # on all string matches (the string is multiple lines, and this
     # option allows global multi-line matches).

     # For example, this line puts any instances of 'try this test'
     # into HTML BOLD (remove the # sign to enable this line):

     # $$textref =~ s/try this test/<b>try this test</b>/msg;

     # Or remove any bad words, like 'idiot','dummy', or 'stupid'

     # $$textref =~ s/idiot/id!##!/msg;
     # $$textref =~ s/dummy/d!@!##y/msg;
     # $$textref =~ s/stupid/st!@!##!/msg;
}

sub SetLinkFormat {

    my $Link_Address = shift;

    my $Link_Title = shift;

    my $tab = '&nbsp&nbsp&nbsp&nbsp&nbsp';

    #   Edit the HTML Format of Web Tool internal links here:
    #
    #   Each link on a page is represented by the following HTML snippet,
    #   where the $Link_Address is the URL and the $Link_Title is the
    #   text that will be visible to the web site visitor.
    #
    #   $Link_Address and $Link_Title MUST appear in this line.
    #
    # This is the default vertical format.

    my $Each_Link_Entry =

    "<p>$tab<B><A HREF=\"$Link_Address\"> $Link_Title <\/A><\/B><br>\n";


    # Here is an example of how you would create a horizontal
    # list of links. The '#' signs in front of the line disable this version

    # my $Each_Link_Entry =
    #         "<p><A HREF=\"$Link_Address\"> $Link_Title <\/A> | \n";



# DO NOT EDIT THIS!
return $Each_Link_Entry;
}


1;
