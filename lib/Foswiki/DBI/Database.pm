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

package Foswiki::DBI::Database;

=begin TML

---+ package Foswiki::DBI::Database

=cut

use strict;
use warnings;

use Foswiki::Func ();
use Error qw(:try);
use DBI;
use Foswiki::Iterator::DBIterator();
#use Data::Dump qw(dump);

=begin TML

---++ ClassMethod new()

Constructs a Foswiki::DBI::Database object. This class is mostly subclassed
by the acutal database implementation being configured, such as =Foswiki::DBI::Database::MariaDB=.
Subclasses need to specify the actual DBD driver to connect to the database.

=cut

sub new {
  my $class = shift;

  my $this = bless({
    debug => $Foswiki::cfg{DBI}{Debug} // 0,
    dsn => $Foswiki::cfg{DBI}{DSN},
    database => $Foswiki::cfg{DBI}{Database} || 'foswiki',
    host => $Foswiki::cfg{DBI}{Host} // 'localhost',
    port => $Foswiki::cfg{DBI}{Port} // '',
    username => $Foswiki::cfg{DBI}{Username},
    password => $Foswiki::cfg{DBI}{Password},
    filename => $Foswiki::cfg{DBI}{SQLite}{Filename} // $Foswiki::cfg{WorkingDir} . "/foswiki.db",
    params => $Foswiki::cfg{DBI}{Params},
    @_
  }, $class);

  $this->{params}{PrintError} = 0;
  $this->{params}{RaiseError} = 1;
  $this->{params}{AutoCommit} = 1;
  $this->{params}{ShowErrorStatement} = 1;

  return $this;
}

=begin TML

---++ ObjectMethod getClassName() -> $string

Returns the base name of this database representing the current implementation,
such as =MariaDB=

=cut

sub getClassName {
  my $this = shift;

  my $class = ref($this);
  $class =~ s/^.*:://;

  return $class;
}

=begin TML

---++ ObjectMethod applySchema($schema)

Applies the Schema to the connected database. this is called only once when the database
is connected. note that the schema must test for existing tables and indexes on its own.

=cut

sub applySchema {
  my ($this, $schema) = @_;

  return unless defined $schema && ref($schema);

  my $type = $schema->getType();
  my $definition = $schema->getDefinition();

  $this->writeDebug("called applySchema($schema)");

  my $index = $this->schemaVersion($type);

  while(my $stms = $definition->[$index]) {
    $this->writeDebug("... applying version=$index to $type");

    $this->handler->begin_work;
    my $error;
    try {
      foreach my $stm (@$stms) {
        if (ref($stm) eq 'CODE') {
          $stm->($this->handler);
        } else {
          my $prefix = $type."_";
          $stm =~ s/\%prefix\%/$prefix/g;
          $this->writeDebug("stm=$stm");
          my $res = $this->handler->do($stm);
          $this->writeDebug("...res=$res");
        }
      }
    } catch Error with {
      $error = shift;
    };

    if (defined $error) {
      $this->handler->rollback;
      throw Error::Simple("ERROR during applySchema(): ".$error);
    }

    $this->schemaVersion($type, $index+1);
    $this->handler->commit();
    $index++;
  }

  $this->writeDebug("... type=$type, index=$index");
}

=begin TML

---++ ObjectMethod schemaVersion($type, $version) -> $version

getter/setter for the schema version meta data

=cut

sub schemaVersion {
  my ($this, $type, $version) = @_;

  unless (keys %{$this->{_schemaVersions}}) {
    my $error;
    try {
      $this->writeDebug("... loading schemaVersions($type)");
      my $res = $this->handler->selectall_hashref("SELECT * FROM db_meta", "type");
      $this->{_schemaVersions} = $res;

    } catch Error with {
      $error = shift;
      print STDERR "ERROR: $error\n" if $type ne 'db'; # ignore initial creation of db_meta
      $this->{_schemaVersions} = {};
    };
  }

  if (defined $version) {
    my $res = $this->handler->do("REPLACE INTO db_meta (type, version) VALUES(?, ?)", {}, $type, $version);
    $this->{_schemaVersions}{$type}{version} = $version;
  } else {
    $version = $this->{_schemaVersions}{$type}{version} || 0;
  }

  #$this->writeDebug("schemaVersion($type)=$version");

  return $version;
}

=begin TML

---++ ObjectMethod handler() -> $dbh

Returns the DBD handler that this class is delegating all work to

=cut

sub handler {
  my $this = shift;

  $this->connect() unless defined $this->{_dbh};
  return $this->{_dbh};
}

=begin TML

---++ ObjectMethod connect()

Connects to the database if not already done so and returns a DBI::db handler.
this method is called automatically when the db handler is established

=cut

sub connect {
  my $this = shift;

  return if defined $this->{_dbh};

  $this->writeDebug("connecting to $this->{dsn}");

  # add unicode to some known drivers

  $this->{_dbh} = DBI->connect(
    $this->{dsn},
    $this->{username},
    $this->{password},
    $this->{params},
  );

  throw Error::Simple("Can't open database $this->{dsn}: " . $DBI::errstr)
    unless defined $this->{_dbh};
}

=begin TML

---++ ObjectMethod finish()

Called solely by =Foswikik::DBI::finish()= to finalize the database connection
and close any open sockets.

=cut

sub finish {
  my $this = shift;

  $this->writeDebug("called finish");

  $this->{_dbh}->disconnect if defined $this->{_dbh};

  undef $this->{_dbh};
  undef $this->{_schemaVersions};

  return;
}


=begin TML

---++ ObjectMethod eachRow($tableName, %params) -> $iterator

Returns an object of class =Foswiki::Iterator::DBIterator=
for the given parameters. This is a convenience wrapper for 

<verbatim class="perl">
my $it = Foswiki::Iterator::DBIterator->new($dbh, $stm);
</verbatim>

The statement handler is created based on the parameters
provided. The =%params= parameter is a hash with the following values:

   * columns: list of columns to return, defaults to "*"
   * avg: column to compute an average for 
   * sum: column to compute the sum for 
   * having: "HAVING" clause SQL statement 
   * groupBy: groupBy "GROUP BY" clause
   * sort, orderBy: "SORT" clause 
   * filter: "WHERE" clause 
   * groupConcat: "GROUP_CONCAT(DISTINCT ...)" clause 
   * count: if defined adds a "COUNT(*) clause, if count is prefixed with "unique" will add a "COUNT(DISTINCT ...)"
   * &lt;colName>: &lt;colVal> ... will add a "colName1='colVal1'" to the "WHERE" clause

Note that all parameters except =$tableName= are optional.

Example:

<verbatim class="perl">
my $it = Foswiki::DBI::getDB->eachRow("SomeTable", 
  count => "*"
  firstName => "Michael"
);

while ($it->hasNext) {
  my $row = $it->next();

  my $firstName = $row->{firstName};
  my $middleName = $row->{middleName};
  my $lastName = $row->{lastName};
  my $count = $row->{count};

  ...
}
</verbatim>

=cut

sub eachRow {
  my ($this, $table, %params) = @_;

  $this->writeDebug("called eachRow($table)");

  my @order = ();
  my @where = ();
  my @groupBy = ();
  my @having = ();
  my $count = "";
  my $groupConcat = "";
  my $sum = "";
  my $avg = "";
  my $cols = "*";

  while (my ($k, $v) = each %params) {
    next unless defined $v && $v ne "";;
    if ($k eq 'columns') {
       $cols = $v; 
    } elsif ($k eq 'avg') {
      $avg = ", AVG($v) as avg";
    } elsif ($k eq 'sum') {
      $sum = ", SUM($v) as sum";
    } elsif ($k eq 'having') {
      push @having, $v;
    } elsif ($k eq 'groupBy') {
      push @groupBy, $v;
    } elsif ($k eq 'sort' || $k eq 'orderBy') {
      push @order, $v;
    } elsif ($k eq 'filter') {
      push @where, $v;
    } elsif ($k eq 'from') { # smell
      push @where, "time >= $v";
    } elsif ($k eq 'to') { # smell
      push @where, "time <= $v";
    } elsif ($k eq 'groupConcat') {
      $groupConcat = ", GROUP_CONCAT(DISTINCT $v) as $v";
    } elsif ($k eq 'count') {
      if ($v =~ /^unique\s+(.*)\s*$/) {
        $count = "COUNT(DISTINCT $1) as count";
      } else {
        $count = "COUNT(*) as count";
      }
    } else {
      push @where, "$k='$v'";
    }
  }


  my $stm = "SELECT $cols". ($count?", $count":"") . 
    $sum .
    $avg .
    $groupConcat .
    " FROM $table" .
    (@where ? " WHERE ". join(" AND ", @where) : "") . 
    (@groupBy ? " GROUP BY ".join(", ", @groupBy) : "") .
    (@having ? " HAVING ".join(" AND ", @having) : "") .
    (@order ? " ORDER BY ".join(", ", @order) : "");

  $this->writeDebug("... stm=$stm");

  return Foswiki::Iterator::DBIterator->new(
    $this->handler, 
    $stm
  );
}

sub writeDebug {
  my $this = shift;
  print STDERR "DBI::Database - $_[0]\n" if $this->{debug};
}

1;
