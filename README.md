# orbital

hello
  
welcome to orbital, version 1.1 (alpha) by 1505 

orbital is an experiment in simple sequences and interface design
it was created to learn lua scripting for norns
it is very much a work in progress

the code is messy, the capability small
orbital has a roadmap, the things still to do are...

- move trig calculations into external class - done.
- add ability to change sequence length - do to.
- add up to 4 sequences - this was canned due to UI limitations, it will come in a future script. For now you can have two sequences and have control over the frequencies of each. For now the left is treble, the right is bass.
- get saving and loading of sequence data into an external file - done but I will test heavily before release.
- set BPM on each sequence indivdually - done.

only then will orbital be considered release 1

please comment, suggest, tell me where the code is a mess

enjoy

## how do you use this?

copy the "1505" folder to code using SFTP (excellent guide here: https://monome.org/docs/norns/sftp/) or if you prefer use maiden to copy and paste the code over to a new folder/file of your choosing

orbital has no dependencies, it should load and run without you doing anything else

## what are the controls?

encoder 1 chooses the sequence
encoder 2 changes the pitch/frequency of the notes being played
encoder 3 changes the beats per minute - you may notice a slight delay/pause when changing, this is on the fix list although... it adds a nice something to the sound so it may be allowed to roam

button 2 randomises the sequence
button 3 starts/stops playback

## what is the point?

does there have to be one?

## will you do anything else to this?

yes

specifically I want to allow up to four (now two) sequences, each of different lengths and possibly running at different speeds
i want to get sequence data to load/save from external files
i want to add a visual sequence builder, possibly on a grid or maybe directly on the circles
i want to test out more SuperCollider engines and make my own percussion engine
i want to integrate grid

orbital is a way for me to learn on simpler things while I design more complex scripts for norns and grid. it also taught me trigonometry

### what about a license?

use it, have fun with it, do whatever floats your boat

### what is a norns?

monome.org - you can read about it there
not that is really says anything useful
buy one, play, you'll figure out what norns is after you build what you want with it
