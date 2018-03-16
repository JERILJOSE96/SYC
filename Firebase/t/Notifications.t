#!/opt/bin/perl
use strict;
use warnings;
use Test::More;

use Firebase::Notifications;
use constant API_KEY => 'YOUR API KEY';
use constant REGISTERATION_ID => [
    "YOUR REGISTERED DEVICE IDS"
];
use constant USER_ID => "Registered Device ID of the particular user";
use constant TOPIC   => "YOUR TOPIC";

my $notification = { "title" => "Title",
                      "body"  => "Body of the message",
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

subtest 'Firebase Object Creation Test' => sub {
    ok( $firebase->isa('Firebase::Notifications'), 'Firebase object created' );
};

subtest 'Send Message Test' => sub {
    my $response = $firebase->sendToDevices( REGISTERATION_ID() );
    ok($response->{msg} eq "OK", "Message sent to devices");

    $response = $firebase->sendToUser( USER_ID() );
    ok($response->{msg} eq "OK", "Message sent to user");

    $response = $firebase->sendToTopic( TOPIC() );
    ok($response->{msg} eq "OK", "Message sent to topic");
};

done_testing;
