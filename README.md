oinker
======

SMS to Ham via text to speech

Driving to work one day, I realized I had left my handy Baofeng UV5R at home.
There was an overturned semi on the Interstate that had traffic snarled. If only
I had a way to notify fellow hams to avoid the route I was on...  Thus oinker was
born.

If you haven't already guessed, oinker is a play on twitter -- tweet:Twitter::Oink::oinker
and what do hams do?  They oink of course.  Anyway...

The setup is pretty simple, get yourself a raspberry pi, an old laptop, etc with an
analog audio output, wire it to your rig taking care to properly adjust levels, switching on
vox, rigging up PTT, etc.  Next get ahold of the source for this package at: 

https://github.com/troylanes/oinker.git

Then proceed to install the dependencies:

Text to speech engine, audio utilities, and perl:
sudo apt-get install festival perl 

Better quality voices for festival (I prefer voice_cmu_us_clb_arctic_clunits ):
http://ubuntuforums.org/showthread.php?t=751169

perl modules:
sudo cpan Net::IMAP::Simple::SSL
sudo cpan Email::MIME

Next, edit oinker.pl and oink.sh to specify your email account info, etc. At this point
you should be ready to go.  Unhook your rig and do some sanity checking on the output.
Send some txt messages to the delivery address and make sure that they are received and
the audio output through the headphone jack is acceptable.  Finally, tune your rig to
desired frequency, hook things back up, and you're ready to oink!

Please send any suggestions or patches to tango romeo oscar yankee lanes@gmail.com
