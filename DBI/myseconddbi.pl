#!/usr/bin/perl
use strict;
use DBI;
use Data::Dumper;

my $driver = "mysql"; 
my $database = "sakila";
my $dsn = "DBI:$driver:database=$database:host=localhost:port=3000";
my $userid = "root";
my $password = "Bismillah";
my $host = "localhost";

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;

my ($statementhandler,$sth,$fth);
my ($totrows,$query,%tablecontent,@tabledata);

$query = qq(desc employee);
$fth = &prepquery($query);
&executedb($fth);
my @column_names = &getfieldname($fth);
# print "@column_names\n";
$fth->finish();

# my $sth = $dbh->prepare("SELECT * FROM employee;");

$query = qq(SELECT * FROM employee);
$sth = &prepquery($query);
&executedb($sth);

###############
# @tabledata = &fetchrowusingarray($sth);
# &showtabledatausingarray(@tabledata);

### or

%tablecontent = &fetchrowusinghash($sth);
&showtabledatausinghash(%tablecontent);
###############

$sth->finish();


# while (my @row = $sth->fetchrow_array()) {
   # my ($first_name, $last_name ) = @row;
   # print "First Name = $first_name, Last Name = $last_name\n";
# }

# Finish the statement handler.
# $sth->finish();
# Disconnect from the database.
$dbh->disconnect();

#################
### FUNCTIONS ###
#################
sub prepquery(){
	my ($query) = @_;
	$statementhandler = $dbh->prepare("$query;");
	return $statementhandler;
}

sub executedb(){
	$statementhandler = shift;
	$statementhandler->execute() or die $DBI::errstr;
}

sub executedbwithrownum(){
	$sth->execute() or die $DBI::errstr;
	$totrows = $sth->rows;

	print "Number of rows found: $totrows\n**********************************\n\n";
	return $totrows;
}

sub getfieldname(){
	$statementhandler = shift;
	my @fields;
	while (my @row = $statementhandler->fetchrow_array()) {
		push (@fields, @row[0]);
	}
	return @fields;
}


sub fetchrow(){
	my $statementhandler = shift;
	while (my @row = $statementhandler->fetchrow_array()) {
		print "@row\n";
	}
}

sub fetchrowusingarray(){
	my $statementhandler = shift;
	my @rowdata;
	while (my @row = $statementhandler->fetchrow_array()) {
		push (@rowdata, \@row);
	}
	return @rowdata;
}

sub fetchrowusinghash(){
	my $statementhandler = shift;
	my %rowdata;
	my $count = 0;
	while (my @row = $statementhandler->fetchrow_array()) {
		my $rowstr = join("|",@row);
		$rowdata{$count} = $rowstr;
		$count++;
	}
	return %rowdata;
}

sub showtabledatausingarray(){
	my @collectiondata = @_;
	
	for(my $m = 0; $m <= $#collectiondata; $m++)
	{  
	   for(my $n = 0; $n <= $#collectiondata ; $n++)
	   { 
			if($collectiondata[$m][$n]){
				print "$column_names[$n]: $collectiondata[$m][$n]\n"; 
			}
	   } 
	   print "\n*****************\n"; 
	} 	
}

sub showtabledatausinghash(){
	my %collectiondata = @_;

	foreach my $row_content(sort keys %collectiondata){
		my @rowdata = split(/\|/,$tablecontent{$row_content});
        for(my $n = 0; $n <= $#rowdata ; $n++)
        { 
     		if($rowdata[$n]){
     			print "$column_names[$n]: $rowdata[$n]\n"; 
     		}
        } 
        print "\n*****************\n"; 
	}
}
