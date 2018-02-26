package Firebase::Notifications;

use Data::Dumper;
use HTTP::Request::Common;
use JSON;
use LWP::UserAgent;

use constant VERSION => 1.0;
use constant FIREBASE_URL => 'https://fcm.googleapis.com/fcm/send';

sub new {

    my ($class, %args ) = @_;

    my $self = bless {
        data              => $args{ data } || {},
        to                => $args{ to } || "",
        topic             => $args{ topic } || "",
        debug             => $args{ debug } || 0,
        notification      => $args{ notification } ||  {},
        firebase_api_key  => $args{ firebase_api_key } ||  "",
    }, $class;

    return $self;
}

sub sendToUser {

    my ($self) = shift;

    $data{to}           = $self->{to} if (defined $self->{to});
    $data{data}         = $self->{data} if (defined $self->{data});
    $data{notification} = $self->{notification} if (defined $self->{notification});

    my $payload = JSON::objToJson(\%data);

    return $self->_send($payload);
}

sub sendToTopic {

    my ($self) = shift;

    $data{data}         = $self->{data} if (defined $self->{data});
    $data{topic}        = $self->{topic} if (defined $self->{topic});
    $data{notification} = $self->{notification} if (defined $self->{notification});

    my $payload = JSON::objToJson(\%data);

    return $self->_send($payload);
}

sub sendToDevices {

    my ($self) = shift;

    $data{data}             = $self->{data} if (defined $self->{data});
    $data{notification}     = $self->{notification} if (defined $self->{notification});
    $data{registration_ids} = $self->{topic} if (defined $self->{registration_ids});

    my $payload = JSON::objToJson(\%data);

    return $self->_send($payload);
}

sub _send {

    my ($self, $payload) = @_;
    my $req = HTTP::Request->new( POST => FIREBASE_URL );
    $req->header( "Authorization"  => 'key=' . $self->firebase_api_key );
    $req->header( 'Content-Type' => 'application/json; charset=UTF-8' );
    $req->content( $payload );
    my $ua = LWP::UserAgent->new;
    my $response = $ua->request($req);

    print "RESPONSE: " . Dumper($response) . "\n" if($self->debug);

    return { msg => $response->{_msg}, rc => $response->{_rc}, response => $response->{_content} };
}

1;
