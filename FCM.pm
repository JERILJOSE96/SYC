package FCM;

use Moose;

has firebase_api_key => (
   is  => 'ro',
   isa => 'Str'
);

has debug => (
    is          => 'ro',
    default     => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;
