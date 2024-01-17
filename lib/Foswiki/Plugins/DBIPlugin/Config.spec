# ---+ Store
# ---++ DBI
# This section configures the database connectivity of Foswiki.

# **BOOLEAN**
$Foswiki::cfg{DBI}{Debug} = 0;

# **SELECTCLASS Foswiki::DBI::Database::* LABEL="Database Implementation"**
$Foswiki::cfg{DBI}{Implementation} = 'Foswiki::DBI::Database::SQLite';

# **STRING 100 LABEL="DBI DSN" DISPLAY_IF="{DBI}{Implementation} && {DBI}{Implementation} == 'Foswiki::DBI::Database::Generic' " CHECK="iff:'{DBI}{Implementation} && {DBI}{Implementation} =~ /Generic$/'"**
# Database driver DSN. See the documentation of your DBI driver for the exact syntax of the DSN parameter string.
$Foswiki::cfg{DBI}{DSN} = '';

# **STRING 80 LABEL="Database Filename" DISPLAY_IF="{DBI}{Implementation} && {DBI}{Implementation} == 'Foswiki::DBI::Database::SQLite' " CHECK="iff:'{DBI}{Implementation} && {DBI}{Implementation} =~ /SQLite$/'"**
$Foswiki::cfg{DBI}{SQLite}{Filename} = '$Foswiki::cfg{WorkingDir}/foswiki.db';

# **STRING 80 LABEL="Database Host" DISPLAY_IF="{DBI}{Implementation} != 'Foswiki::DBI::Database::SQLite'" CHECK="undefok emptyok"**
# Name or IP address of the database server
$Foswiki::cfg{DBI}{Host} = 'localhost';

# **STRING 80 LABEL="Database Port" DISPLAY_IF="{DBI}{Implementation} != 'Foswiki::DBI::Database::SQLite'" CHECK="undefok emptyok"**
# Port on the database server to connect to
$Foswiki::cfg{DBI}{Port} = '';

# **STRING LABEL="Database Name" CHECK="undefok emptyok" **
# Name of the database.
$Foswiki::cfg{DBI}{Database} = '';

# **STRING LABEL="Database Username" CHECK="undefok emptyok" **
# Database user name. Add a value if your database needs authentication.
$Foswiki::cfg{DBI}{Username} = '';

# **PASSWORD LABEL="Database Password" CHECK="undefok emptyok" **
# Database user name. Add a value if your database needs authentication.
$Foswiki::cfg{DBI}{Password} = '';

# **PERL LABEL="Database Parameters" CHECK="undefok emptyok" **
$Foswiki::cfg{DBI}{Params} = {};

1;
