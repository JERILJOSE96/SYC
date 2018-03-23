#!/opt/bin/perl
use strict;
use warnings;
use Test::More;

use lib "/home/devel/diya-jerilj/site_perl/BL";

use Firebase::Notifications;
use constant API_KEY => 'AIzaSyATLNRsfds14P4q4YhDgr9_XgPlgZEXADc';
use constant REGISTERATION_ID => [
    "AAAAzk-Ilkc:APA91bFatHA3W9ve5s-tCZXVzi7uKjS5kvv7v60JJgvy_nGE6qaDSTvfjeGLL1j1_tnZIpxfa1r4IQSheQXOTuBv6N-NxZZPonharrUhOjlJq3f0absYJupVERsCFVjaggYm29Avc2Uo"
];
use constant USER_ID => "AAAAzk-Ilkc:APA91bFatHA3W9ve5s-tCZXVzi7uKjS5kvv7v60JJgvy_nGE6qaDSTvfjeGLL1j1_tnZIpxfa1r4IQSheQXOTuBv6N-NxZZPonharrUhOjlJq3f0absYJupVERsCFVjaggYm29Avc2Uo";
use constant TOPIC => "Your Custom Topic";

my $notification = { 
    "title" => "dfgsdfgsdfhgsd",
    "body"  => "dsfgfdgsdf",
};
my $data = {
    "name" => "sender",
    "role" => "reader",
};

my $expected_output_topic = qq{

};

my $expected_output_single_device = qq{

};

my $expected_output_multiple_device = qq{

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
    ok( $firebase->isa('Firebase::Notifications'), 'Firebase object Created' );
};

subtest 'Send Message Test - Devices' => sub {

    my $response = $firebase->sendToDevices( REGISTERATION_ID() );
    ok($response->{msg} eq "OK", "Send message to devices - Request sent.");
    
    my($response_content);
    eval {
        $response_content = JSON::to_json( $respose->{content}, {utf8 => 1} );
    };
    if($@) {
        fail("Testing Response content : Not a vaild JSON");
        skip_all("Not a vaild JSON");
    }

    like($respose->{content}, $expected_output_multiple_device, "Response Structure Test - Multiple Devices");

    ok( $response_content->{success} eq 1, "Send message to devices" );
};

subtest 'Send Message Test - Device' => sub {

    my $response = $firebase->sendToUser( USER_ID() );
    ok($response->{msg} eq "OK", "Send message to single device - Request sent.");

    my($response_content);
    eval {
        $response_content = JSON::to_json( $respose->{content}, {utf8 => 1} );
    };
    if($@) {
        fail "Testing Response content : Not a vaild JSON";
        skip_all "Not a vaild JSON";
    }

    like($respose->{content}, $expected_output_single_device, "Response Structure Test - Single Device");

    ok( $response_content->{success} eq 1, "Send message to device" );
};

subtest 'Send Message Test - Topic' => sub {

    my $response = $firebase->sendToTopic( TOPIC() );
    ok($response->{msg} eq "OK", "Send message to Topic - Request sent.");

    my($response_content);
    eval {
        $response_content = JSON::to_json( $respose->{content}, {utf8 => 1} );
    };
    if($@) {
        fail "Testing Response content : Not a vaild JSON";
        skip_all "Not a vaild JSON";
    }

    like($respose->{content}, $expected_output_topic, "Response Structure Test - Topic")

    ok( $response_content->{success} eq 1, "Send message to Topic" );
};

done_testing;