# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
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

package Foswiki::DBI::Database::Generic;

=begin TML

---+ package Foswiki::DBI::Database::Generic

Connects to a generic database supported by perl's DBI. This class does not
have a constructor of its own. See Foswiki::DBI::Database instead.

=cut

use strict;
use warnings;

use Foswiki::DBI::Database;
our @ISA = ('Foswiki::DBI::Database');

1;

