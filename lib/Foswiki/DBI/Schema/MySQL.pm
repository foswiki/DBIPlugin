# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# DBIPlugin is Copyright (C) 2021-2022 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::DBI::Schema::MySQL;

use strict;
use warnings;

use Foswiki::DBI::Schema;
our @ISA = ('Foswiki::DBI::Schema');

sub getDefinition {
  return [[
      'CREATE TABLE IF NOT EXISTS %prefix%meta (
          id SERIAL,
          type VARCHAR(255) NOT NULL, 
          version INT NOT NULL
      ) DEFAULT CHARSET=utf8 DEFAULT COLLATE utf8_unicode_ci',

      'CREATE UNIQUE INDEX %prefix%idx_meta_type ON %prefix%meta (type)',
  ]];
}

sub getType { return "db"; }


1;



