package FCM::Notifications;

use Moose;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use FCM::Constants;

extends 'FCM';

has to                  => ( is => 'rw', isa => 'Str' );
has topic               => ( is => 'rw', isa => 'Str' );
has tag                 => ( is => 'rw', isa => 'Str' );
has body                => ( is => 'rw', isa => 'Str' );
has icon                => ( is => 'rw', isa => 'Str' );
has color               => ( is => 'rw', isa => 'Str' );
has title               => ( is => 'rw', isa => 'Str' );
has sound               => ( is => 'rw', isa => 'Str' );
has click_action        => ( is => 'rw', isa => 'Str' );
has body_loc_key        => ( is => 'rw', isa => 'Str' );
has body_loc_args       => ( is => 'rw', isa => 'Str' );
has title_loc_key       => ( is => 'rw', isa => 'Str' );
has title_loc_args      => ( is => 'rw', isa => 'Str' );
has android_channel_id  => ( is => 'rw', isa => 'Str' );

sub sendToDevice {

    my ($self, $device_ids) = @_;

    my %notification;
    my @arr_notification_params = qw(
        title                icon                 to
        click_action         body_loc_args        tag
        title_loc_key        title_loc_args       body
        android_channel_id   body_loc_key color   sound
    );

    foreach (@arr_notification_params) {
        $notification{notification}{$_} = $self->$_ if (defined $self->$_);
    }

    $notification{registration_ids} = $device_ids;
    my $payload = JSON::objToJson(\%notification);

    my $req = HTTP::Request->new( POST => FCM::Constants::FIREBASE_URL );
    $req->header( "Authorization"  => 'key=' . $self->firebase_api_key );
    $req->header( 'Content-Type' => 'application/json; charset=UTF-8' );
    $req->content( $payload );
    my $ua = LWP::UserAgent->new;
    my $response = $ua->request($req);

    print "RESPONSE: " . Dumper($response) . "\n" if($self->debug);

    return { msg => $response->{_msg}, rc => $response->{_rc} };
} 

no Moose;
__PACKAGE__->meta->make_immutable;

=encoding utf-8

=for stopwords

=head1 NAME

FCM::Notifications - Firebase Cloud Messaging (FCM) Client Library

=head1 SYNOPSIS

  use FCM::Notifications;

  my $firebase_api_key = 'Your API Key';
  my $firebase = FCM::Notifications->new( 
                    firebase_api_key => $firebase_api_key,
                    body             => "Message",
                    title            => "Title"
                );
  my @device_ids = qw(); #registeration ids as array , Max limit  is 1000
                    
  my $res = $firebase->sendToDevice(\@device_ids);

  die $res->msg unless $res->is_success;

=head1 DESCRIPTION

FCM::Notifications is Firebase Cloud Messaging (FCM) Client Library used for sending all type of messages.

On progress.

SEE ALSO L<< https://firebase.google.com/docs/cloud-messaging/http-server-ref#error-codes >>.
