package FCM;

use Moose;

has firebase_api_key => (
   is  => 'ro',
   isa => 'Str',
   default => 'AIzaSyBf_s9Iz-V6cBvhxZT_7Z3YmncWWm7XAXQ'
);

has debug => (
    is          => 'ro',
    default     => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;
