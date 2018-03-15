#!/opt/bin/perl
use strict;
use warnings;
use Test::More;

use lib "/home/devel/diya-jerilj/site_perl/BL";

use Firebase::Notifications;
use constant API_KEY => 'YOUR API KEY';
use constant REGISTERATION_ID => [
    "YOUR REGISTERED DEVICE IDS"
];
use constant USER_ID => "Registered Device ID of the particular user";
use constant TOPIC   => "YOUR TOPIC";

my $notification = { "title" => "TITLE",
                      "body"  => "Body of the Message",
                  };
my $data         = { "name" => "name",
                      "role" => "reader",
                  };

use_ok('Firebase::Notifications') or BAIL_OUT q~
    failed to use Firebase::Notifications!
~;

my $firebase = Firebase::Notifications->new(
                  firebase_api_key => API_KEY(),
                  notification     => $notification,
                  data             => $data,
               );

subtest Firebase_object_Creation_test => sub {
    ok( $firebase->isa('Firebase::Notifications'), 'Firebase object Created' );
};

subtest sendMessage_test => sub {
    my $response = $firebase->sendToDevices( REGISTERATION_ID() );
    print STDERR $response->{msg};
    ok($response->{msg} eq "OK", "Message Send to devices");

    $response = $firebase->sendToUser( USER_ID );
    ok($response->{msg} eq "OK", "Message Send to user");

    $response = $firebase->sendToTopic( TOPIC );
    ok($response->{msg} eq "OK", "Message Send to Topic");
};

done_testing;
