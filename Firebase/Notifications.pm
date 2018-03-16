package Firebase::Notifications;

use HTTP::Request::Common qw( POST );
use JSON;
use LWP::UserAgent;

use constant VERSION => 1.0;
use constant FIREBASE_URL => 'https://fcm.googleapis.com/fcm/send';

sub new {

    my ( $class, %args ) = @_;

    my $self = bless {
        data              => $args{ data }             || {},  # Can be hash ref of data to be send.
        to                => $args{ to }               || "",  # User registeration id can be string.
        topic             => $args{ topic }            || "",  # Topic ID can be a string.
        debug             => $args{ debug }            || 0,   # 1 => enables debug mode.
        notification      => $args{ notification }     || {},  # Can be hash ref with valid firebase Notification Message.
        registration_ids  => $args{ registration_ids } || [],  # Device Registeration IDs as array ref.
        firebase_api_key  => $args{ firebase_api_key } || "",  # Web App Key in lagacy flow. 
    }, $class;

    return $self;
}

sub sendToUser {

    my ( $self, $to ) = @_;
    $self->{to} = $to || $self->{to};

    return { msg => "User registeration ID not found." } unless( $self->{to} );

    my $payload = JSON::objToJson({
                    to           => $self->{to},
                    data         => $self->{data},
                    notification => $self->{notification},
                });
    return $self->_send( $payload );
}

sub sendToTopic {

    my ( $self, $topic ) = @_;
    $self->{topic} = $topic || $self->{topic};
    
    return { msg => "Topic not found." } unless( $self->{topic} );

    my $payload = JSON::objToJson({
                    data         => $self->{data},
                    topic        => $self->{topic},
                    notification => $self->{notification},
                });
    return $self->_send( $payload );
}

sub sendToDevices {

    my ( $self, $registration_ids ) = @_;   
    $self->{registration_ids} = $registration_ids || $self->{registration_ids};
 
    return { msg => "Device Registration IDs not found." } unless( $self->{registration_ids} );

    my $payload = JSON::objToJson({
                    data             => $self->{data},
                    notification     => $self->{notification},
                    registration_ids => $self->{registration_ids},
                });
    return $self->_send( $payload );
}

sub _send {

    my ( $self, $payload ) = @_;
    
    if( $self->{firebase_api_key} eq "" ) {
        return { msg => "Firebase API Key is invalid" };
    }

    my $req = HTTP::Request->new( POST => FIREBASE_URL );
    $req->header( "Authorization"  => 'key=' . $self->{firebase_api_key} );
    $req->header( 'Content-Type' => 'application/json; charset=UTF-8' );
    $req->content( $payload );

    my $ua       = LWP::UserAgent->new;
    my $response = $ua->request($req);

    print "RESPONSE: " . Dumper($response) . "\n" if ($self->{debug});

    return {
        msg => $response->{_msg},
        rc  => $response->{_rc},
        is_success => $response->{_content}->{success}
    };
}

=pod

=head1 NAME

Firebase::Notifications - Firebase Cloud Messaging Client Library

=head1 SYNOPSIS

  use Firebase::Notifications;

  my $firebase_api_key = 'Your API Key';
  my $firebase = FCM::Notifications->new( 
                    firebase_api_key => $firebase_api_key,
                    notification     => $notification,
                    data             => $data,
                );
  my @device_ids = qw(); #registeration ids as array , Max limit  is 1000
                    
  my $res = $firebase->sendToDevices(\@device_ids);
  OR
  my $res = $firebase->sendToTopic("Topic");
  OR
  my $res = $firebase->sendToUser("User Registration ID");

  die $res->msg unless $res->is_success;

=head1 DESCRIPTION

Firebase::Notifications is Firebase Cloud Messaging (FCM) Client Library used for sending all 
type of messages.

=head1 METHODS

=head2 new(%args)

Create a Firebase::Notifications instance.

    my $firebase = Firebase::Notifications->new(
                        firebase_api_key => $firebase_api_key,
                        notification     => $notification,
                        data             => $data,
                    );

Supported options are:

=over

=item firebase_api_key : Str

Required. Set your API key.

For more information, please check L<< https://firebase.google.com/docs/cloud-messaging/ >>.

=item notification : Hash ref

Optional. Keys can be as C<< https://firebase.google.com/docs/cloud-messaging/ >>.

=item data : hash ref 

Optional. data sent to device can carry any keys.

=item registration_ids : Array ref 

Optional. can hold Registered device ids.

=item debug : Int 

Optional. can be 1 or 0. 1 enables debug mode. Default : 0

=item topic : Str 

Optional. Topic id for which the subscribers need to be alerted.

=item to : Str 

Optional. User Device ID.

=back

=head2 sendToUser($to)

    Send message to registered user.
    
    $firebase->sendToUser("Device registeration id");

=head2 sendToTopic($topic)
    
    Send message to users subscribed the topic.
    
    $firebase->sendToUser("Topic");

=head2 sendToDevices($registeration_ids)
    
    Send Message or data to registeration ids.

    $firebase->sendToUser(["Device registeration id", "id 2", "id 3"]);

    Maximum registeration ids can be used is limited to 1000. If we need to alert more than 1000 devices,
    then send as batches.

=head1 AUTHOR

Jeril Jose E<lt>jeriljose@outlook.comE<gt> with much inspiration
from xaicron's WWW::Google::Cloud::Messaging.

=head1 SOURCE

The source code repository for Firebase::Notifications can be found at
F<https://github.com/****/tree/master/Firebase>.

=head1 COPYRIGHT

Copyright 2018 by Jeril Jose E<lt>jeriljose@outlook.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

SEE ALSO L<< https://firebase.google.com/docs/cloud-messaging/http-server-ref#error-codes >>.

=cut

1;
