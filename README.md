# DBIPlugin
Database middle layer to manage connections and schemes

This plugin offers a middle layer for Foswiki extensions to ease connecting to 
SQL databases and manage schemes of table and index definitions. The idea is to
keep things as lean as possible without imposing any additional structure. <nop>DBIPlugin
will maintain a plugin's database scheme to make sure it is created and updated as required.

A plugin sub-classes Foswiki::DBI::Schema which is then loaded before
connecting to a database. While connecting to the database the schema then is added to the database.

<nop>DBIPlugin supports any database for which a DBD perl driver is available. A plugin may support
multiple databases where the schemes differ in parts. For example the schema for SQLite differs
from the one for <nop>MariaDB, <nop>MySQL or <nop>PostgreSQL. The plugin will then implement:

   * Foswiki::DBISchema::SQLite
   * Foswiki::DBISchema::MariaDB
   * Foswiki::DBISchema::MySQL
   * Foswiki::DBISchema::PostgreSQL

The syntax of each of them are custom tailored towards the respective database vendor. Note
however that from there on it is the plugin's responsibility to cope with further differences
among databases beyond just schema definitions.

Have a look at [DBIPluginPerlAPI](data/System/DBIPluginPerlAPI.txt) for further information.
