# Extension for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
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

package Foswiki::Iterator::DBIterator;

=begin TML

---+ package Foswiki::Iterator::DBIterator

=cut

use strict;
use warnings;

use Foswiki::Iterator ();
our @ISA = ('Foswiki::Iterator');

=begin TML

---++ ClassMethod new($dbh, $select, $values, $process)

Constructs a Foswiki::DBI::DBIterator object. Parameters are:

   * $dbh: the database being used to connect to the actual database (mandatory)
   * $select: SQL select clause that is being prepared using the $dbh (mandatory)
   * $values: array reference of values being used when executing the statement; this must match the "?" placeholders in the select clause (optional)
   * $process: function reference that is called when iterator fetched the next value from the database, see =next()= below (optional)

A =DBIterator= may be used in its own but is mostly created as part of =Foswiki::DBI::Database::eachRow()=.

Example use:

<verbatim class="perl">
my $it = Foswiki::Iterator::DBIterator($dbh, "select * from ... where ...");

while ($it->hasNext) {
  my $row = $it->next();

  my $firstName = $row->{firstName};
  my $middleName = $row->{middleName};
  my $lastName = $row->{lastName};

  ...
}
</verbatim>

=cut

sub new {
  my ($class, $dbh, $select, $values, $process) = @_;

  my $this = bless({
    dbh => $dbh,
    select => $select,
    process => $process,
    values => $values // [],
  }, $class);

  $this->reset();

  return $this;
}

sub DESTROY {
  my $this = shift;

  undef $this->{sth};
  undef $this->{_row};
}

=begin TML

---++ ObjectMethod hasNext() -> $boolean

returns true if the iterator still has values to be returened by =next()=.

=cut

sub hasNext {
  my $this = shift;

  return defined($this->{_row}) ? 1:0;
}

=begin TML

---++ ObjectMethod next() -> $row

returns the next row available in the result set of the select statement.
The =$row= return value is a hash reference as being created by =DBI::fetchrow_hashref=

=cut

sub next {
  my $this = shift;

  my $row = $this->{_row};
  $this->{_row} = $this->{sth}->fetchrow_hashref();

  $row = &{$this->{process}}($row) if defined $this->{process};

  return $row;
}

=begin TML

---++ ObjectMethod reset() 

resets the iterator to restart the search to the beginning. note that the
select statement (provided to the constructor) will be prepared and executed
once again

=cut

sub reset {
  my $this = shift;

  $this->{sth}->finish() if defined $this->{sth};
  $this->{sth} = $this->{dbh}->prepare($this->{select});
  $this->{sth}->execute(@{$this->{values}});

  $this->{_row} = $this->{sth}->fetchrow_hashref();
}

1;
