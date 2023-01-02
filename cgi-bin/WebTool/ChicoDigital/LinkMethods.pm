##############################################################################
#
#  ChicoDigital::LinkMethods
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
################################################################################
use strict;

package ChicoDigital::LinkMethods;

############################################################################
# The http query string forms a path to the hash.
# The delimiter is used to parse the query string path.
# The path array is a list of keys in the baseRef hash.
# The resultant hash is the corresponding entry in the baseRef hash.
#
# Return the object, the hash reference to the current hash, and the
# array list of keys that point to the current hash.
#
############################################################################
sub new {

     my ($class,$baseRef,$arrayRef) = @_;

     my $self = bless({},$class);

     $self->{baseRef} = $baseRef;

     $self->{arrayRef} = $arrayRef;

     $self->{currentRef} = $self->_getHashFromArray($arrayRef);

     return ($self);
}

sub getCurrentHash {

     my $self = shift;

     return ($self->{currentRef});
}

sub getLinkList {

     my $self = shift;

     # Need to debug through this and figure out how to pass back
     # the base dir reference if the current one is not valid.

     # if ( $self->{currentRef}->{link_order1} =~ /ARRAYREF/ ) {

          return @{$self->{currentRef}->{link_order1}};

     # } else {

     return ();
}

sub getCurrentPath {

     my $self = shift;

     if ( wantarray() ) {

          return @{$self->{arrayRef}};

     } else {

          return $self->{arrayRef};
     }
}

sub addEntry {

     my $self = shift;
     my $newPage = shift;

     my %defaults = @_;

     my @linkList = @{$self->{currentRef}->{link_order1}};

     my $duplicate=0; # don't add duplicates

     foreach my $link (@linkList) {

          if ( $newPage eq $link ) { $duplicate=1; }
     }

     if ( $duplicate == 0 ) {

          push(@linkList,$newPage);

          $self->{currentRef}->{link_order1} = [@linkList];

          # There has to be an empty 'content_string' entry to get a page.
          # This directly modifies the current global hash in memory
          # so that now any references to $globalHashRef will have this
          # new entry.

          $self->{currentRef}->{links1}{$newPage}{content_string} = '';
          $self->{currentRef}->{links1}{$newPage}{dirtyBit} = 'yes';
          $self->{currentRef}->{links1}{$newPage}{links1} = {};
          $self->{currentRef}->{links1}{$newPage}{link_order1} = [];

          foreach my $key ( keys %defaults ) {

               $self->{currentRef}->{links1}{$newPage}{$key} = $defaults{$key};
          }
     }
}

sub deleteEntry {

     my $self = shift;

     $self->_deleteSubHash();
}

sub isDirty {

     my $self = shift;

     if ( $self->{currentRef}->{dirtyBit} eq 'yes' ) {

          return 'yes';

     } else {

          return undef;
     }
}

sub clearDirtyBit {

     my $self = shift;

     if ( exists $self->{currentRef}->{dirtyBit} ) {

          delete $self->{currentRef}->{dirtyBit};
     }
}

sub setStringField {

     my $self = shift;
     my $fieldName = shift;
     my $value = shift;

     $self->{currentRef}->{$fieldName} = $value;

     $self->{currentRef}->{dirtyBit} = 'yes';

}

sub getStringField {

     my $self = shift;
     my $fieldName = shift;

     return $self->{currentRef}->{$fieldName};

}

###################  END OF EXTERNAL API ##################################

############################################################################
# Although this seems like the more elegant and flexible solution,
# it loops once for every entry, whereas the old version uses a
# single if-else statement to dispatch all requests... much faster.
# We use this by default, because who knows what people will do...
############################################################################

sub _getHashFromArray {

     my $self = shift;
     my $arrayRef = shift;

     my @arr = @$arrayRef; # ordered list of sub-categories

     my $baseRef = $self->{baseRef};

     # always start at root node, since the query string url is the full path
     my $sub_cat = $baseRef;

     foreach my $entry ( @arr ) {

          if ($entry eq '') { next; }

          if ($entry eq undef) { next; }

          if ( exists($sub_cat->{links1}->{$entry}) ) {

               $sub_cat = $sub_cat->{links1}->{$entry};

          } else {

               my $index = join(' => ',@arr);

               # Throw a fatal error, the URL was corrupted or
               # something went wrong...
               #
               print "<br><p><b>The page you requested: \"$index\" is no longer
               valid.<br>\n";
               exit;
          }
     }

     # This is a reference to the next hash to be displayed

     return $sub_cat;
}

############################################################################
#
# Delete a sub hash of the global hash, including any sub-hashes below it.
#
############################################################################
sub _deleteSubHash {

     my $self = shift;

     my $baseRef   = $self->{baseRef};
     my @arr       = @{$self->{arrayRef}};

     # always start list at root node,
     # since the query string url is the full path

     my $sub_cat = $baseRef;

     my $pageName = pop(@arr); # the last entry is the page name

     foreach my $entry ( @arr ) {

          if ( exists($sub_cat->{links1}->{$entry}) ) {

               $sub_cat = $sub_cat->{links1}->{$entry};

          } else {

               last;
               # Throw a fatal error, the URL was corrupted or
               # something went wrong...
               # die "invalid URL path: " . join(' => ',@arr) . ' => ' . $pageName;
          }
     }

     #
     # Delete the hash entry pointed to by the current path
     #
     delete ($sub_cat->{links1}->{$pageName});

     #
     # Delete the entry from the ordered link list array
     #
     my @linkList = @{$sub_cat->{link_order1}};

     my @newList;

     foreach my $link (@linkList) {

           if ($link eq $pageName) { next; }

           push(@newList,$link);
     }

     $sub_cat->{link_order1} = [@newList];
}

1;
