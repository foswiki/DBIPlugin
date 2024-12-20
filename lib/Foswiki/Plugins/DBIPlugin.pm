# Extension for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# DBIPlugin is Copyright (C) 2021-2024 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::DBIPlugin;

use strict;
use warnings;
use Foswiki::DBI;

our $VERSION = '2.02';
our $RELEASE = '%$RELEASE%';
our $SHORTDESCRIPTION = 'Database middle layer to manage connections and schemes';
our $LICENSECODE = '%$LICENSECODE%';
our $NO_PREFS_IN_TOPIC = 1;

sub initPlugin {
  return 1;
}

sub finishPlugin {
  Foswiki::DBI::finish();
}

1;
