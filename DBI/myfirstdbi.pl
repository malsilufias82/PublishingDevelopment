#!/usr/bin/perl
use strict;
use DBI;
use Data::Dumper;

my $driver = "mysql"; 
my $database = "sakila";
my $host = "localhost";
# my $host = "127.0.0.1";
my $dsn = "DBI:$driver:database=$database:host=$host:port=3000";
my $userid = "root";
my $password = "Bismillah";
my $sth;
my ($totrows,$query);

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;
# my $dbh = DBI->connect("$dsn","$userid","Bismillah", {'RaiseError' => 1});

# my $sth = $dbh->prepare("SELECT * FROM employee;");

# $query = qq(desc employee);
$query = qq(select * from actor limit 10);
&prepquery($query);
&executedb;
&fetchrow;

# my @column_names = &getfieldname;
# &fetchrow(@column_names);

# while (my @row = $sth->fetchrow_array()) {
   # my ($first_name, $last_name ) = @row;
   # print "First Name = $first_name, Last Name = $last_name\n";
# }

# Finish the statement handler.
$sth->finish();
# Disconnect from the database.
$dbh->disconnect();

#################
### FUNCTIONS ###
#################
sub prepquery(){
	my ($query) = @_;
	$sth = $dbh->prepare("$query;");
}

sub executedb(){
	$sth->execute() or die $DBI::errstr;
}

sub executedbwithrownum(){
	$sth->execute() or die $DBI::errstr;
	$totrows = $sth->rows;

	print "Number of rows found: $totrows\n**********************************\n\n";
	return $totrows;
}

sub getfieldname(){
	my @fields;
	while (my @row = $sth->fetchrow_array()) {
		push (@fields, @row[0]);
	}
	return @fields;
}

sub fetchrow(){
	while (my @row = $sth->fetchrow_array()) {
		print "@row\n";
	}
}

