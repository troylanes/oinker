#!/usr/bin/perl -w
use strict;
use POSIX;
use MIME::Base64; 
use Net::IMAP::Simple::SSL;
use Data::Dumper;
use Email::MIME;
$| = 1;

#daemon config -- you need to update these variables to suit your needs
my $base64_password = "cGFzc3dvcmQ="; #by no means is this secure!! -- base64 encode your password
my $email_server_address = "gmail.com"; #e.g. gmail.com, af7hg.com, etc
my $folder = "INBOX"; #folder on your IMAP server
my $check_for_messages_every_x_seconds = 30; #something sensible but practical
my $ham_speak_script = "/home/troy/projects/oinker/oink.sh"; #where you put the shell script
my $logfile = "/tmp/oinker.log";
my $username = "relay";

#create a hash of from addresses to call signs
#NOTE the phonetic spelling and ellipses -- adds pause and clarity to the text2speech
#these are a list of acceptable relays for your gateway.  In the future I'll be updating
#this project to be more elegant in terms of not using shell scripts, hardcoded relays, etc
#ALSO there needs to be a listen before transmit mechanism.  Please use best engineering
#practices and be courteous as always.

our %call_sign_hash = (
    '4065551234@vzwpix.com' => "... alpha... fox trot... seven... hotel... golf...", #example verizon
    '4065556789@txt.att.net' => "... kilo... golf.. seven...kilo ... charlie... victor...", #example att
);

# housekeeping
my $password = decode_base64($base64_password);
my $count = 0;
my $number_of_messages = 0;
$password =~ s/[\r\n\t\s]*//g;

# if you don't want to fork into the background, just append any old junk as options to this script
if (!@ARGV){
  daemonize();
}
else{
  print "Not daemonizing....\n";
}


#on and on
while(1){
 
  #setup a connection to the IMAP server 
  my $server = new Net::IMAP::Simple($email_server_address, use_ssl=>1) or die "$! -- " . $Net::IMAP::Simple::errstr . "\n";
  
  #login
  if($server->login( $username , $password )){

    #check for messages
    my $messages = $server->select( $folder );
    
    #iterate messages
    for (my $i = 1; $i <= $messages; $i++){
      if(1 != $server->seen($i))
      {
        if(!$server->get($i)){
          next;
        }
        my @message = @{ $server->get( $i ) };
        if(!@message){
          next;
        }

        #render the email usable by this script
        my $es = Email::MIME->new(join '', @message );

        #check sender -- this is also not super secure -- consider some form of password/auth
        my $call_sign = do_sender_lookup($es->header('From'));

        if($call_sign){

          #find the body of the message -- e.g. what we'd like to say
          $es->walk_parts(sub {
              my ($part) = @_;
              my $body = $part->body;
              $body =~ s/'/\\'/g;
              if(length($body)){
                  #alright, we've got something... let's pack it up for the glue scripts 
                  my $to_say = $body . " ... " . $call_sign . "\n";
                  my $outfile = "/tmp/" . time() . "-hamtxt.txt";

                  #write text to slurp into the shell glue script
                  open(OUT, ">$outfile") or die($!);
                  print OUT $to_say;
                  print $to_say;
                  close(OUT);

                  #call the shell wrapper to festival's text2speech
                  `$ham_speak_script $outfile`;
              }

          });
        }
      }
      #delete message
      $server->delete($i);
    }
    #logout after parsing all messages
    $server->quit();
  }
  else{
    print "Can't log in... -- $!\n";
  }
  #take a rest for a while
  sleep($check_for_messages_every_x_seconds);
}


#this is ugly -- will move to an sqlite database
sub do_sender_lookup{
  my $from = shift;

  if(exists($call_sign_hash{ $from })){
    return $call_sign_hash{ $from };
  }

  return undef;
}

#that's not a knife, it's a fork()!
sub daemonize {
  chdir '/'               or die "Can't chdir to /: $!";
  open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
  open (STDOUT, ">>$logfile") or die "Can't write to STDERR $!";
  defined(my $pid = fork) or die "Can't fork: $!";
  if ($pid){
    print "Daemonized on pid $pid\n";
    exit;
  }
  setsid                  or die "Can't start a new session: $!";
  open STDERR, ">>$logfile" or die "Can't dup stdout: $!";
}
