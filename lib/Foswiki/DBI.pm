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

package Foswiki::DBI;

=begin TML

---+ package Foswiki::DBI

Interface for Foswiki DBI developers

=cut

use strict;
use warnings;
use constant MEMORYCACHE => 0; # experimental
our $DB;

=begin TML

---++ StaticMethod getDB() -> $database

Creates a database connection to the configured implementation,
connects to it and loads the base schema.

=cut

sub getDB {

  unless ($DB) {
    my $impl = $Foswiki::cfg{DBI}{Implementation};
    eval "require $impl";
    die($@) if $@;

    $DB = $impl->new();

    loadSchema("Foswiki::DBI::Schema");
  }

  return $DB;
}

=begin TML

---++ StaticMethod loadSchema($schemaBase) -> $database

Loads a database schema and returns the db. The =$schemaBase= is the
base perl class of the caller. The real database schema being loaded
resides in a sub class of the =$schemaBase= according to the database
implementation of the system. 

For example a =MyPlugin= must provide the following classes to support
SQLite and <nop>MariaDB:

<verbatim>
Foswiki::Plugins::MyPlugin::Schema
Foswiki::Plugins::MyPlugin::Schema::MariaDB
Foswiki::Plugins::MyPlugin::Schema::SQLite
</verbatim>

The schema is then called using:

<verbatim class="perl">
my $db = Foswiki::DBI::loadSchema("Foswiki::Plugins::MyPlugin::Schema");
</verbatim>

Given =MariaDB= is the current database implementation, it actually loads the
schema =Foswiki::Plugins::MyPlugin::Schema::MariaDB= and returns a singleton
database object of type =Foswiki::DBI::Database::MariaDB=.
This singleton object is shared among all subsystems connecting to the
database.

=cut

sub loadSchema {
  my $schemaBase = shift;

  my $db = getDB();
  my $package = $schemaBase."::".$db->getClassName();

  eval "require $package";
  die("ERROR: $@") if $@;

  my $schema = $package->new();
  $db->applySchema($schema);

  return $db;
}

=begin TML

---++ StaticMethod finish()

Close any database connection being made during the session 

=cut

sub finish {
  unless (MEMORYCACHE) {
    $DB->finish if defined $DB;
    undef $DB;
  }
}


1;
