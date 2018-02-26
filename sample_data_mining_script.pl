#!/opt/bin/perl

use strict;
use warnings;
use Text::CSV_XS qw( csv );
use BL::SQL;

my $file_path = 'FILE PATH';
my $dbh_trans = BL::SQL::ConnectToDB( 'trans', '', '', '', 'db-report' );
my $csv       = Text::CSV_XS->new ( { eol => $/, binary => 1 } ) or die "Cannot use CSV";

open my $fh_write, ">", qq{$file_path/transtablereport.csv} or die "transtablereport.csv: $!";

#Query cannot be shared with you
my @user_list = qw("1", "2");

my $get_transtablereport = $dbh_trans->prepare(qq{
    Business Logic
});

foreach (@user_list) {

    $get_transtablereport->execute( $_ ) or die $dbh_trans->errstr;

    while ( my $data = $get_transtablereport->fetchrow_hashref() ){

        my(@row);
        my $data_internal_score = 0;
        my $data_max_mind_score = 0;
        my $data_email_address = "";
        my(@interscores, @maxpoints);

        next unless ( $data->{Content} =~ /Points\:/ );

        if($data->{Content} ne "" ) {
            
            my @contents = split /MaxMind Info:/, $data->{Content};

            if($contents[0]) {
                push @interscores, ($contents[0] =~ /(\d+) points/g) if ($contents[0] =~ /(\d+) points/);
                push @interscores, ($contents[0] =~ /points:(\d+)/g) if ($contents[0] =~ /points:(\d+)/);
                push @interscores, ($contents[0] =~ /points (\d+)/g) if ($contents[0] =~ /points (\d+)/);
                push @interscores, ($contents[0] =~ /points: (\d+)/g) if ($contents[0] =~ /points: (\d+)/);
                @interscores = grep { $_ ne '' } @interscores;
                $data_internal_score = eval join '+', @interscores if(@interscores);
            }

            if($contents[1]) {
                push @maxpoints, ($contents[1] =~ /(\d+) points/g) if ($contents[1] =~ /(\d+) points/);
                push @maxpoints, ($contents[1] =~ /points:(\d+)/g) if ($contents[1] =~ /points:(\d+)/);
                push @maxpoints, ($contents[1] =~ /points (\d+)/g) if ($contents[1] =~ /points (\d+)/);
                push @maxpoints, ($contents[1] =~ /points: (\d+)/g) if ($contents[1] =~ /points: (\d+)/);
                @maxpoints = grep { $_ ne '' } @maxpoints;
                $data_max_mind_score = eval join '+', @maxpoints if(@maxpoints);
            }

            if($data->{Content} =~ /(emailexact - )(.*)( -1 Points)/) {
                $data_email_address = $2;
            }

            $row[0] = $data->{UserName};
            $row[1] = $data_email_address;
            $row[2] = $data_internal_score;
            $row[3] = $data_max_mind_score;
            $row[4] = $data->{Content};

            $csv->print( $fh_write, \@row );
            last;

        }else {

            next;

        }
    }
}

$csv->eof or $csv->error_diag();
close $fh_write or die "transtablereport.csv: $!";

$get_transtablereport->finish;
$dbh_trans->disconnect();

1;