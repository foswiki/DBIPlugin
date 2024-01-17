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

package Foswiki::DBI::Schema;

=begin TML

---+ package Foswiki::DBI::Schema

A schema is used to define tables and indexes in an SQL database.
Plugins may define a schema for their own needs by subclassing this class.
In general a plugin must define a schema class for each database vendor
it desires to support, such as <nop>SQLite, <nop>MariaDB, Oracle etc.

Two functions need to be implemented: =getType()= and =getDefinition()=
The schema base is then passed on to =Foswiki::DBI::loadSchema()= 
See =Foswiki::DBI= for more information.

=cut

use strict;
use warnings;

=begin TML

---++ ClassMethod new()

Constructs an object of this type.

=cut

sub new {
  my $class = shift;

  my $this = bless({
    @_
  }, $class);

  return $this;
}

=begin TML

---++ ObjectMethod getType() -> $string

Returns a string representing the type of this schema.
For example =Foswiki::Plugins::LikePlugin::Schema::getType()=
returns the string "LikePlugin". This string may be used in the 
schema definition using the ="%prefix%"= placeholder. 

=cut

sub getType {
  die "not implemented";
}

=begin TML

---++ ObjectMethod getDefinition() -> $array

Returns an array of arrays of SQL statements to define the schema.
Each SQL statement may contain the =%prefix%= placeholder being 
replaced by the value of =getType()= 

For example, the =$array= returned by the subclass may look like this:

<verbatim>
sub getDefinition {
  return [[
      'CREATE TABLE IF NOT EXISTS %prefix%likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        web VARCHAR(255),
        topic VARCHAR(255),
        meta_type CHAR(20), 
        meta_id VARCHAR(255),
        username VARCHAR(255),
        like_count INTEGER DEFAULT 0,
        dislike_count INTEGER DEFAULT 0,
        timestamp INTEGER
      )',

      'CREATE UNIQUE INDEX IF NOT EXISTS %prefix%_idx_likes on %prefix%likes (web, topic, username, meta_type, meta_id)'
  ], [
    "ALTER TABLE %prefix%likes ..."
  ]];
}
</verbatim>

In a first version of the schema definition, it create a table =LikePlugin_likes= and an index =LikePlugin_idx_likes=.
Later on during the life span of the <nop>LikePlugin a modification to the initial definition is required. That's why
there is a second element with an "ALTER TABLE" clause to update any preexisting SQL structure incrementally.
This approach migrates a table structure seamlessly as required. The required updates are tracked by the schema loader
of <nop>DBIPlugin. The version of the schema is being tracked in a separate table =db_meta=. In the above example
an entry will be added to the =db_meta= table for the "LikePlugin" schema being of version 2 (as there are two elements in
the returned =$array=. 

=cut

sub getDefinition {
  die "not implemented";
}

1;
