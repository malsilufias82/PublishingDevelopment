#!"C:\xampp\perl\bin\perl.exe"

print "Content-type: text/html\n\n";
print <<'END';
    <html>
        <head>
            <meta name="author" content="Kay Vogelgesang">
            <link href="/xampp/xampp.css" rel="stylesheet" type="text/css">
        </head>
        <body>
            <h1>CGI with MiniPerl</h1>
            <p>CGI with MiniPerl is ready ...</p><br/>
            <p>Congratualtions!!! Saif, It's your first program successfully executed...</p>
        </body>
    </html>
END

# use strict;
# use warnings;
# use CGI;
# my $cgi = CGI->new();
# print $cgi->header;

# print <<'END';
# <!doctype html>
# <html> HTML Goes Here </html>
# END