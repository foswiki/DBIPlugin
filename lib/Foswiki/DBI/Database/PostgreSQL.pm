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

package Foswiki::DBI::Database::PostgreSQL;

=begin TML

---+ package Foswiki::DBI::Database::PostgreSQL

connects to a <nop>PostgreSQL database

=cut

use strict;
use warnings;

use Foswiki::DBI::Database;
our @ISA = ('Foswiki::DBI::Database');

=begin TML

---++ ClassMethod new()

Construtor for this class.

=cut

sub new {
  my $class = shift;

  my $this = bless($class->SUPER::new(@_), $class);

  $this->{dsn} = 'dbi:Pg:database=' . $this->{database};
  $this->{dsn} .= ';host=' . $this->{host};
  $this->{dsn} .= ';port=' . $this->{port} if $this->{port};
  $this->{params}{pg_enable_utf8} = 1;

  return $this;
}

1;
