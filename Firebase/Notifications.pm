package Firebase::Notifications;

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
        notification      => $args{ notification } || {},
        registration_ids  => $args{ registration_ids } || [],
        firebase_api_key  => $args{ firebase_api_key } || "",
    }, $class;

    return $self;
}

sub sendToUser {

    my ($self, $to) = @_;
    my(%data);
    $data{to} = $to || $self->{to};

    return $self->_createPayload(\%data);
}

sub sendToTopic {

    my ($self, $topic) = @_;
    my(%data);
    $data{topic} = $topic || $self->{topic};

    return $self->_createPayload(\%data);
}

sub sendToDevices {

    my ($self, $registration_ids) = @_;
    my(%data);
    $data{registration_ids} = $registration_ids || $self->{registration_ids};

    return $self->_createPayload(\%data);
}

sub _createPayload {

	my ($self, $data) = @_;

    $data->{data} 			= $self->{data};
    $data->{notification} 	= $self->{notification};

    my $payload = JSON::objToJson($data);

	return $self->_send($payload);
}

sub _send {

	my ($self, $payload) = @_;
	
	if($self->firebase_api_key eq "") {
		return { msg => "Firebase API Key is invalid" };
	}

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
