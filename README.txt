--------------------------------------------------------------------
Chico Digital Web Tool 1.0
--------------------------------------------------------------------

  Copyright (c) 2002 Alan Raetz, Chico Digital Engineering

  http://www.chicodigital.com

  support@chicodigital.com

---------------------------------------------------------------------
WARNING
---------------------------------------------------------------------
This software is provided 'as-is' and without warranty. Use it at
your own risk. See the full disclaimer at the end of this document.

All files in this distribution are copyrighted material, and are
protected by U.S. Copyright laws. You cannot copy or distribute these
files or any portion of them without express written permission by
Alan Raetz, with the exception of these two modules:

This distribution includes two Perl modules that are publicly distributed
via CPAN.org and are made available under their respective licenses.
This distribution complies with all requirements of these licenses.

Our thanks to the authors:

     CGI-Lite 2.0 (renamed cgi-bin/WebTool/ChicoDigital/CGI_Lite.pm)

          Copyright (c) 1995, 1996, 1997 by Shishir Gundavaram

     Data::Dumper (renamed cgi-bin/WebTool/ChicoDigital/DataDumper.pm)

          Copyright (c) 1996-98 Gurusamy Sarathy.

------------------------------------------------------------------------
LICENSING AND PAYMENT INFORMATION
------------------------------------------------------------------------

    This is proprietary commercial software and can be used without
    a license only for evaluation purposes. See the complete evaluation
    license in LICENSE.TXT.

    We distribute this program without cost to ensure you can install
    and configure it properly, and to allow you to evaluate it for your
    particular purposes.

    THIS IS NOT A FREE PROGRAM. If you decide to use Web Tool 1.0, you
    must pay for it. Any use of this software to manage web pages on a
    web site without a license will be considered software theft.

    The cost of a single web site license is $25(US).

    Licensed users will receive free unlimited email support. They will
    also be eligible for free upgrades to any Version 1.xx of Web Tool.

    The easiest way to buy a license is via our web site. Go to:

          http://chicodigital.com/payment.html

          This is a secure service that accepts international payments.

    If you live within the United States, you can also send us a check
    or money order via postal mail:

          Make your check or money order out to "Chico Digital Engineering".

          BE SURE TO INCLUDE your email address and the web address of
          the site using Web Tool with your payment. Send to:

               Chico Digital Engineering
               201 Vilas Road
               Chico, Calif. 95973

     You will recieve an email confirmation of your license via email,
     regardless of payment method. Because we're developing enhancements
     and want to keep you informed, you will be signed up to our update
     mailing list; however, you may unsubscribe yourself at any time, or
     you can request not to be added with your payment.

     For any other payment methods, or terms for multiple licensing, please
     contact us at support@chicodigital.com. We offer significant discounts
     for web site developers who need Web Tool for multiple clients.

============================================================================

----------------------------------------------------------------------
SERVER COMPATABILITY
----------------------------------------------------------------------

Chico Digital Web Tool will work on all Unix flavors and seems to
work on most Windows-based server platforms. Perl 5.xxx is required;
on Windows, a recent version of ActivePerl is recommended.
Please report any problems.

Windows NT/2000 installers please carefully read the NT-specific
installation instructions below; there are significant differences
in the installation process.

----------------------------------------------------------------------
INSTALLATION OVERVIEW
----------------------------------------------------------------------

PLEASE READ THESE INSTRUCTIONS COMPLETELY.

Setting up Web Tool requires knowledge using FTP, HTML, and some
knowledge of Perl or previous experience setting up Perl/CGI scripts.

Your web hosting account must support CGI scripts (have a cgi-bin).

The main configuration is done by an automated web-based installation
script that runs the first time run the main program (webtool.cgi).

This script creates the configuration file
cgi-bin/WebTool/Config/wtConfig.pm, which can be manually edited at
any time after the initial install.

Most other customization can be done by modifying the Perl module
cgi-bin/WebTool/Customize.pm or WebTool/Variables.pm. Email any questions
to support@chicodigital.com.

An overview of how to create template files is in the Administrator's
Guide, in www/WebTool/docs/AdminGuide.html.

There are separate install instructions for Unix and NT-based servers.
Skip the Unix section if you are on a NT/2000 Windows server.

------------------------------------------------------------------------
UNIX INSTALLATION PROCESS
------------------------------------------------------------------------

This describes how to install this application on a UNIX / Linux /
BSD / MacOS-X web server. Some of the details assume:

     - You've downloaded the entire Web Tool package and unzipped it
     on your local Windows machine.

     - You have an FTP client that will remotely connect with your
     linux/unix/BSD-based web server account.


But note that this package can be installed many other ways; for
example, the package .tgz file can be directly downloaded onto the
server and unzipped there, and the files can be moved locally to
the correct areas using unix shell commands.

---------------------------------------------------------------
UNIX STEP ONE: Fix File/Directory Permission Issues
---------------------------------------------------------------

     Modify the top of cgi-bin/WebTool/webtool.cgi to point to
     the path of your Perl executable (ie, #!/usr/bin/perl ).

     Set the file permissions on webtool.cgi to allow it to be
     executable.

     Change the write permissions on these two directories to
     allow them to be writeable by the web server.

          cgi-bin/WebTool/Data

          cgi-bin/WebTool/Config

--------------------------------------------------------------------
UNIX STEP TWO: Copy all files and directories using your FTP client.
--------------------------------------------------------------------

     Part A) Copy cgi-bin/WebTool to your cgi-bin/WebTool.

     Part B) Copy www/WebTool to YourWebDirectory/WebTool.

Details:

     Go to your cgi-bin directory on the server using FTP.

     Highlight your local cgi-bin/WebTool and copy it over using
     'text' mode (do not use 'binary' mode). This should copy all
     files within the directory and create all subdirectories. If
     your FTP software doesn't support this, manually create all
     directories and copy all files (file and directory names are
     usually case sensitive).

     Go to your web-accessable directory. This may be your base
     directory, or it may be the www/ or htdocs/ sub-directory.
     See your web server account information or server documents.

     Highlight your local www/WebTool and copy it over. This should
     copy all files within the directory and create all
     subdirectories. If that doesn't work, manually create all
     directories and copy all files.

     Note you will need to copy the .gif and .jpg files manually using
     'binary' mode if your FTP client does not support auto typing.

     Here is the default cgi-bin directory structure:

                  cgi-bin
                     |
                  WebTool
                     |
     -------------------------------------------------------------
     |               |              |             |              |
   Data          WebTool       ChicoDigital     Config      webtool.cgi
     |               |              |             |
 <yourDB>.pm  FormMethods.pm   LinkMethods.pm   wtConfig.pm
                    etc.           etc.

     <yourDB>.pm is the Perl database file.

     wtConfig.pm is the Web Tool configuration file.

     Note that if the directories are manually created using your FTP
     client, files and directory names are case sensitive (capitals
     and lower case must be copied exactly).

     The integrity of all the Web Tool cgi-bin files is automatically
     checked when the setup script is executed.

---------------------------------------------------------------
UNIX STEP THREE: Run webtool.cgi from your web browser
---------------------------------------------------------------

Type in the web address of the Web Tool script into your web browser:

(for example) http://yourSite.com/cgi-bin/WebTool/webtool.cgi

The first step will check that Web Tool can run on your server
without modification.

Click on submit and you should see the Configuration Form.

If you get an error, follow the instructions on manually editing
the Setup.pm file.

The next screen will ask you to specify your web account path and
URL information. Follow the instructions carefully and hit submit.

     NOTE: This form asks for two types of path information; be
     sure you understand the difference. If the form asks for
     a web address URL, that entry would be the address that a web
     user would type into a web browser to access that file or
     directory.

     If the form asks for a "full directory path", that entry
     is the file directory path on your web server. This is the
     path you see when you use your FTP client.

     Both these path types to the different directories should be
     provided by your web hosting service provider.

The script will then use the path information you specified and
check that the required application files exist. It will check to
see that the Config and Data directories to be writeable by the
web server user process.

Fix any problems shown. If you are not installing files in the
default locations, you may choose to ignore these warnings.

If you click 'Create Config File' the config file wil be written.

You should now be able to re-run webtool.cgi and get the main web
page editor application to appear.

You may need to manually edit the Config/wtConfig.pm file. Note
that the automated web installation simply creates this config
file. Any manual edits will have the same effect; the only exception
is the BASE_TITLE.

The setup script writes the initial database file using the BASE_TITLE
entry. If you change the BASE_TITLE, you must also rename and edit the
cgi-bin/WebTool/Data/<yourBaseTitle>.pm file. You cannot simply rename
this file; you must also edit the declaration at the top of the file,
"package Data::<yourBaseTitle>.pm. Change this entry to your new
BASE_TITLE.

Any changes should be immediately recognized the next time webtool.cgi
is run.

An overview of how to create template files is in the Administrator's
Guide, in www/WebTool/docs/AdminGuide.html.

---------------------------------------------------------------------
END OF UNIX INSTALL
---------------------------------------------------------------------
---------------------------------------------------------------------
WINDOWS NT/2000 INSTALLATION PROCESS
---------------------------------------------------------------------
------------------------------------------------------------------------
NT/2000 STEP ONE: Fix File/Directory Permission Issues
------------------------------------------------------------------------

Set the first line of webtool.cgi to the Perl executable; follow your
web server instructions, usually something like: #!c:\perl\bin\perl.exe

If required by your web host, rename the script from webtool.cgi to
webtool.pl. You only need to rename the file webtool.cgi. The other Web
Tool files in cgi-bin that end in '.pm' should not be renamed.

Some web hosts do not allow perl scripts to write files by default.
If you get a 'Permission denied' message at any point during the
installation, contact your technical support and request that your
Perl scripts be given write permission within your directory.

------------------------------------------------------------------------
NT/2000 STEP TWO: Copy files to server
------------------------------------------------------------------------

Most NT servers allow you to execute scripts from any web-accessable
(www) directory. If this is the case, create a cgi-bin directory
inside your www directory: www/cgi-bin.

Copy the Web Tool CGI file into that directory so you have this
directory structure:

     www/cgi-bin/WebTool/webtool.cgi (the main script)

     www/cgi-bin/WebTool/WebTool/FormMethods.pm
          (and all other files from cgi-bin/WebTool/)

     www/cgi-bin/WebTool/ChicoDigital/LinkMethods.pm
          (and all other files from cgi-bin/ChicoDigital/)

     www/cgi-bin/WebTool/Config/*

     www/cgi-bin/WebTool/Data/*

------------------------------------------------------------------------
NT/2000 STEP THREE: Run webtool.cgi from your web browser
------------------------------------------------------------------------

Type in the web address of the Web Tool script into your web browser:

(for example) http://yourSite.com/cgi-bin/WebTool/webtool.cgi

The first step will check that Web Tool can run on your server
without modification.

Click on submit and you should see the Configuration Form.

If you get an error, follow the instructions on manually editing
the Setup.pm file.

This will ask you to specify your web account path and URL information.

     NOTE: This form asks for two types of path information; be
     sure you understand the difference. If the form asks for
     a web address URL, that entry would be the address that a web
     user would type into a web browser to access that file or
     directory.

     SPECIAL NOTE FOR NT SERVERS: Do not use the full path for
     file directories; in our experience, that hasn't worked. All
     path information should start with a './' from your root
     account directory. For example:

          CGI_PATH => './cgi-bin/WebTool/',

          HOME => './WebTool/',

          CONTENT_DIR => './webt/',

     ALSO: If you install the cgi-bin/WebTool files in a directory
     other than cgi-bin/WebTool, you probably need to change the
     following statement at the top of webtool.cgi:

          BEGIN { push(@INC,'./cgi-bin/WebTool'); }

     Change the path so that it points to the directory where
     webtool.cgi is.

The script will then use the path information you specified and
check that the required application files exist. It will check to
see that the Config and Data directories to be writeable by the
web server user process.

Fix any problems shown. If you are not installing files in the
default locations, you may choose to ignore these warnings.

If you click 'Create Config File' the config file wil be written.

You should now be able to re-run webtool.cgi and get the main web
page editor application to appear.

---------------------------------------------------------------------
END OF WINDOWS NT/2000 INSTALL PROCESS
---------------------------------------------------------------------
--------------------------------------------------------------------
USING .htaccess FOR PASSWORD PROTECTION
--------------------------------------------------------------------
An easy way to add password protection for editor access is to
setup your cgi-bin/WebTool sub-directory with the .htaccess
protocol (as the demo does on the chicodigital.com site).

This will prompt users to enter a name and password in
order to access any file in the protected directory, including
scripts such as webtool.cgi or webtoolsetup.pl.

There are many tutorials on the web regarding setting up the
.htaccess file on unix/linux web servers, just do a google
search for .htaccess. Note that the actual password file should
not exist within a directory that is web-accessable, if at all
possible.

.htaccess supports access groups and so adding new users is a
1-line shell command (you must have shell/SSH access to your web
server).

Another option for password protection are free password protection
scripts such as those found in:

http://cgi.resourceindex.com/Programs_and_Scripts/Perl/Password_Protection/

DC_protect98 and Protect.pl seem to be well-suited, however, we have
not tested any of these products with Web Tool, and do not support
any of them.

---------------------------------------------------------------------
DESCRIPTION OF WEB DIRECTORIES AND FILES
---------------------------------------------------------------------

1) The Perl Database File
-------------------------
This file is named after your BASE_TITLE that is specified in the
installation config menu. It is a Perl module that is rewritten
every time the user saves information in the editor. Because it
needs to be in a writable directory, it is in a separate directory
cgi-bin/WebTool/Data.

Note that a directory named 'archive' is automatically created in
the data directory and old linkDB.pm files are stored; this can be
disabled or configured to store N old files via the setup script.

You can put this database file anywhere by changing the directory
by manually editing the Config/wtConfig.pm file.


2) The HTML Output directory
-----------------------------
CONTENT_URL and CONTENT_DIR in the config file Config/wtConfig.pm
control where the static HTML pages are created. These variables
are initially set up by the installation script.

Links from other areas of your web site can link into the
WebTool-generated pages by pointing to the base HTML file in this
directory, name from your 'BASE_TITLE' variable in Config/wtConfig.pm.


3) The HTML Template files
--------------------------
These files are configured by default to go into a subdirectory of the
www/WebTool/Templates directory, but can go in any web-accessable area
of your web account by editing Variables.pm.


4) The HTML Cascading Style Sheet files, graphics, documentation URLs
----------------------------------------------------------------------
These are the web URLs to the .css files; they must be in the
web-accessable area of your web server. By default they are put
in the www/WebTool directory.

$STYLE_SHEET = 'css/WebTool1-style.css';
$TOOL_STYLE  = 'css/tool-style.css';

These are the full web URLs to documentation HTML files:

$USER_GUIDE_LINK = 'http://yourSite.com/WebTool/docs/UsersGuide.html';
$OVERVIEW_LINK = 'http://yourSite.com/WebTool/docs/webtool.html';

======================================================================
======================================================================
DISCLAIMER:
-----------

This software is provided 'as-is' and without warranty. Use it at
your own risk.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



