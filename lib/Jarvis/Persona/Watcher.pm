package Jarvis::Persona::Watcher;
use parent Jarvis::Persona::Base;

################################################################################
# Watcher logs into every non-private chat he can find, logs everything he sees, 
# periodically commit's the logs to gitosis, and can post gists when requested.
################################################################################

sub input{
    my ($self, $kernel, $heap, $sender, $msg) = @_[OBJECT, KERNEL, HEAP, SENDER, ARG0];
    # un-wrap the $msg
    my ( $sender_alias, $respond_event, $who, $where, $what, $id ) =
       ( 
         $msg->{'sender_alias'},
         $msg->{'reply_event'},
         $msg->{'conversation'}->{'nick'},
         $msg->{'conversation'}->{'room'},
         $msg->{'conversation'}->{'body'},
         $msg->{'conversation'}->{'id'},
       );
    my $direct=$msg->{'conversation'}->{'direct'}||0;
    if(defined($what)){
        if(defined($heap->{'locations'}->{$sender_alias}->{$where})){
            foreach my $chan_nick (@{ $heap->{'locations'}->{$sender_alias}->{$where} }){
                if($what=~m/^\s*$chan_nick\s*:*\s*/){
                    $what=~s/^\s*$chan_nick\s*:*\s*//;
                    $direct=1;
                }
            }
        }
        my $replies=[];
        ########################################################################
        #                                                                      #
        ########################################################################
        for ( $what ) {
            /^\s*!*help(.*)/      && return $self->help($1);
            /^\s*!*spawn(.*)/     && return $self->spawn($1)     if $direct;
            /^\s*!*terminate(.*)/ && return $self->terminate($1) if $direct;
            /.*/                  && return  [];        # say nothing by default
        }
        ########################################################################
        #                                                                      #
        ########################################################################
        if($direct==1){
            foreach my $line (@{ $replies }){
                if($msg->{'conversation'}->{'direct'} == 0){
                    if( defined($line) && ($line ne "") ){ $kernel->post($sender, $respond_event, $msg, $who.': '.$line); }
                }else{
                    if( defined($line) && ($line ne "") ){ $kernel->post($sender, $respond_event, $msg, $line); }
                }
            }
        }else{
            foreach my $line (@{ $replies }){
                    if( defined($line) && ($line ne "") ){ $kernel->post($sender, $respond_event, $msg, $line); }
            }
        }
    }
    return $self->{'alias'};
}


sub help(){
    my $self=shift;
    my $topic=shift if @_;
    $topic=~s/^\s+//;
    return  [ "commands: help spawn terminate" ];
}

sub spawn(){
    my $self=shift;
    my $target=shift if @_;
    $target=~s/^\s+// if $target;
    return  [ "I need a spawn routine" ];
}

sub terminate(){
    my $self=shift;
    my $target=shift if @_;
    $target=~s/^\s+// if $target;
    return  [ "I need a terminate routine" ];
}

1;
