package Jarvis::Persona::System;
use AI::MegaHAL;
use POE;
use POSIX qw( setsid );

sub new {
    my $class = shift;
    my $self = {};
    my $construct = shift if @_;
    $self->{'session_struct'}={};

    # list of required constructor elements
    $self->{'must'} = [ 'alias' ];

    # hash of optional constructor elements (key), and their default (value) if not specified
    $self->{'may'} = {};

    # set our required values fron the constructor or the defaults
    foreach my $attr (@{ $self->{'must'} }){
         if(defined($construct->{$attr})){
             $self->{$attr} = $construct->{$attr};
         }else{
             print STDERR "Required session constructor attribute [$attr] not defined. ";
             print STDERR "unable to define ". __PACKAGE__ ." object\n";
             return undef;
         }
    }

    # set our optional values fron the constructor or the defaults
    foreach my $attr (keys(%{ $self->{'may'} })){
         if(defined($construct->{$attr})){
             $self->{$attr} = $construct->{$attr};
         }else{
             $self->{$attr} = $self->{'may'}->{$attr};
         }
    }
    $self->{'states'} = { 
                          $self->{'alias'}.'_start'   => '_start',
                          $self->{'alias'}.'_stop'    => '_stop',
                          $self->{'alias'}.'_input'   => 'input',
                          $self->{'alias'}.'_output'  => 'output',
                          $self->{'alias'}.'_process' => 'process',
                          # special_events go here...
                        };


    bless($self,$class);
    return $self;
}

sub _start{
     my $self = $_[OBJECT]||shift;
     print STDERR __PACKAGE__ ." start\n";
     $self->{'megahal'} = new AI::MegaHAL(
                                           'Path'     => '/usr/lib/share/crunchy',
                                           'Banner'   => 0,
                                           'Prompt'   => 0,
                                           'Wrap'     => 0,
                                           'AutoSave' => 1
                                         );
     return $self;
}

sub _stop{
     my $self = $_[OBJECT]||shift;
     print STDERR __PACKAGE__ ." stop\n";
     return $self;
}

sub states{
     my $self = $_[OBJECT]||shift;
     return $self->{'states'};
}

sub alias{
     my $self = $_[OBJECT]||shift;
     return $self->{'alias'};
}

sub input{
     my ($self, $kernel, $heap, $sender, $who, $where, $what, $respond_event) = @_[OBJECT, KERNEL, HEAP, SENDER, ARG0 .. $#_];
     if(defined($what)){
         $kernel->post($sender, $respond_event, $who, $where, $self->{'megahal'}->do_reply( $what ) );
     }
     return $self->{'alias'};
}

sub output{
     my ($self, $kernel, $heap, $sender, $what) = @_[OBJECT, KERNEL, HEAP, SENDER, ARGV0];
     return $self->{'alias'};
}

sub process{
     my ($self, $kernel, $heap, $sender, $what) = @_[OBJECT, KERNEL, HEAP, SENDER, ARGV0];
     return $self->{'alias'};
}


1;