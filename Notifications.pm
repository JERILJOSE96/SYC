package Firebase::Notifications;

use 5.006;
use strict;
use warnings;
use vars qw( $AUTOLOAD $Firebase_API_VERSION %response_code );

use Data::Dumper;
use HTTP::Request::Common qw( POST );
use JSON;
use LWP::UserAgent;

require Exporter;
our @ISA              = qw(Exporter);
our $VERSION          = '1.0';
our @EXPORT_OK        = qw();

$Firebase_API_VERSION = '1.0';

use constant FIREBASE_URL => 'https://fcm.googleapis.com/fcm/send';

%response_code = (
    1 => "User registeration ID not found.",
    2 => "Invalid Data",
    3 => "Topic not found.",
    4 => "Device Registration IDs not found.",
    5 => "Firebase API Key is invalid",
    6 => "Connection error"
);

sub new {

    my ( $class, %args ) = @_;

    my $self = bless {
        data              => $args{data}             || {},  # Can be a hash ref of the data to be send.
        to                => $args{to}               || "",  # User registeration id can be string.
        topic             => $args{topic}            || "",  # Topic ID can be a string.
        debug             => $args{debug}            || 0,   # 1 => enables debug mode, 0 => Default.
        notification      => $args{notification}     || {},  # Can be hash ref with valid firebase Notification Message.
        registration_ids  => $args{registration_ids} || [],  # Device Registeration IDs as array ref.
        firebase_api_key  => $args{firebase_api_key} || "",  # Web App Key in lagacy flow. 
    }, $class;

    return $self;
}

sub sendToUser {

    my ( $self, $to ) = @_;
    $self->{to} = $to || $self->{to};

    return {
        rc  => 1,
        msg => $response_code{1}
    } unless( $self->{to} );

    my($payload);
    eval {
        $payload = JSON::objToJson({
                    to           => $self->{to},
                    data         => $self->{data},
                    notification => $self->{notification}
                });
    };
    if($@) {
        print STDERR Dumper($@) . "\n" if ($self->{debug});
        return {
            rc  => 2,
            msg => $response_code{2}
        };
    }
    return $self->_send( $payload );
}

sub sendToTopic {

    my ( $self, $topic ) = @_;
    $self->{topic} = $topic || $self->{topic};
    
    return {
        rc  => 3,
        msg => $response_code{3}
    } unless( $self->{topic} );
    
    my($payload);
    eval {
        $payload = JSON::objToJson({
                    data         => $self->{data},
                    topic        => $self->{topic},
                    notification => $self->{notification}
                });
    };
    if($@) {
        print STDERR Dumper($@) . "\n" if ($self->{debug});
        return {
            rc  => 2,
            msg => $response_code{2}
        };
    }
    return $self->_send( $payload );
}

sub sendToDevices {

    my ( $self, $registration_ids ) = @_;   
    $self->{registration_ids} = $registration_ids || $self->{registration_ids};
 
    return {
        rc  => 4,
        msg => $response_code{4}
    } unless( $self->{registration_ids} );

    my($payload);
    eval {
        $payload = JSON::objToJson({
                    data             => $self->{data},
                    notification     => $self->{notification},
                    registration_ids => $self->{registration_ids}
                });
    };
    if($@) {
        print STDERR Dumper($@) . "\n" if ($self->{debug});
        return {
            rc  => 2,
            msg => $response_code{2}
        };
    }
    return $self->_send( $payload );
}

sub _send {

    my ( $self, $payload ) = @_;
    
    return {
        rc  => 5,
        msg => $response_code{5}
    } unless $self->{firebase_api_key};

    my $req = HTTP::Request->new( POST => FIREBASE_URL );
    $req->header( "Authorization"  => 'key=' . $self->{firebase_api_key} );
    $req->header( 'Content-Type' => 'application/json; charset=UTF-8' );
    $req->content( $payload );

    my $ua       = LWP::UserAgent->new;
    my $response = $ua->request($req);

    return {
        rc  => 6,
        msg => $response_code{6}
    } unless ($response);

    print "RESPONSE: " . Dumper($response) . "\n" if ($self->{debug});

    return {
        rc      => $response->{_rc},
        msg     => $response->{_msg},
        content => $response->{_content}
    };
}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak("$self is not an object");
    # my $field = $AUTOLOAD;
    # $field =~ s/.*://;
    # my $temp='';
    # unless (exists $self->{$field}) {
    #     die "$field does not exist in object/class $type";
    # }
    # exit(1);
}

sub DESTROY {
    my $self = undef;
}

1;
__END__

=pod

=head1 NAME

Firebase::Notifications - Firebase Cloud Messaging Client Library

=head1 SYNOPSIS

    use Firebase::Notifications;

    my $firebase_api_key = 'Your API Key';
    my $firebase = Firebase::Notifications->new( 
                      firebase_api_key => $firebase_api_key,
                      notification     => $notification,
                      data             => $data,
                  );
    my @device_ids = qw(); #registeration ids as array , Max limit  is 1000
    
Message to multiple devices

    my $res = $firebase->sendToDevices(\@device_ids);
    
Message to Topic

    my $res = $firebase->sendToTopic("Topic");
    
Message to Single device or user

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

=over 3

=item B<firebase_api_key : Str>

Required. Set your API key.

For more information, please check L<< https://firebase.google.com/docs/cloud-messaging/ >>.

=item B<notification : Hash ref>

Optional. Keys can be as L<< https://firebase.google.com/docs/cloud-messaging/ >>.

=item B<data : hash ref >

Optional. data send to device can carry any keys.

=item B<registration_ids : Array ref> 

Optional. can hold Registered device ids.

=item B<debug : Int>

Optional. can be 1 or 0. 1 enables debug mode.

=item B<topic : Str>

Optional. Topic id to which the subscribers need to be alerted.

=item B<to : Str>

Optional. User Device ID.

=back

=head2 sendToUser($to)

=over 3

Send message to registered user.
    
    $firebase->sendToUser("Device registeration id");

=back

=head2 sendToTopic($topic)

=over 3
    
Send message to users subscribed the topic.
    
    $firebase->sendToUser("Topic");

=back

=head2 sendToDevices($registeration_ids)

=over 3    

Send Message or data to registeration ids.

    $firebase->sendToUser(["Device registeration id", "id 2", "id 3"]);

Maximum registeration ids can be used is limited to 1000. If we need to alert more than 1000 devices,
it is recommend to send as batches of 1000.

=back

=head1 AUTHOR

Jeril Jose E<lt>jeriljose@outlook.comE<gt> with much inspiration
from xaicron's L<< WWW::Google::Cloud::Messaging >>.

=head1 SOURCE

The source code repository for Firebase::Notifications can be found at
L<< https://github.com/****/tree/master/Firebase >>.

=head1 COPYRIGHT

Copyright 2018 by Jeril Jose E<lt>jeriljose@outlook.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

SEE ALSO L<< https://firebase.google.com/docs/cloud-messaging/http-server-ref#error-codes >>.

=cut

1;