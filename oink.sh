#/bin/bash

curr_time=`date +%s-hamwave`

text2wave   -eval "(voice_cmu_us_clb_arctic_clunits)" -o /tmp/$curr_time.wav $1

#play a 200hz tone to key VOX circuit if necessary
aplay /home/troy/200hz.wav
aplay /tmp/$curr_time.wav
	     
