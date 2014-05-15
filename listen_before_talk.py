#!/usr/bin/python
## This is an example of a simple sound capture script.
##
## The script opens an ALSA pcm for sound capture. Set
## various attributes of the capture, and reads in a loop,
## Then prints the volume.
##
## To test it out, run it and shout at your microphone:

# borrowed from http://ubuntuforums.org/showthread.php?t=500337

import alsaaudio
import time
import audioop
import sys


SAMPLE_FOR_SILENCE_SECONDS = 15

# Open the device in nonblocking capture mode. The last argument could
# just as well have been zero for blocking mode. Then we could have
# left out the sleep call in the bottom of the loop
inp = alsaaudio.PCM(alsaaudio.PCM_CAPTURE,alsaaudio.PCM_NONBLOCK)

# Set attributes: Mono, 8000 Hz, 16 bit little endian samples
inp.setchannels(1)
inp.setrate(8000)
inp.setformat(alsaaudio.PCM_FORMAT_S16_LE)

# The period size controls the internal number of frames per period.
# The significance of this parameter is documented in the ALSA api.
# For our purposes, it is suficcient to know that reads from the device
# will return this many frames. Each frame being 2 bytes long.
# This means that the reads below will return either 320 bytes of data
# or 0 bytes of data. The latter is possible because we are in nonblocking
# mode.
inp.setperiodsize(160)

sample_until = time.time() + SAMPLE_FOR_SILENCE_SECONDS

while time.time() < sample_until: #sample for 15 seconds
  # Read data from device
  l,data = inp.read()
  if l:
    # Return the maximum of the absolute value of all samples in a fragment.
    val = audioop.max(data, 2)
    if val != 0x7FFF:
      print "I HEARD SOMETHING!"
      sys.exit(-1)
    time.sleep(0.001)

print "SWEET SILENCE"
