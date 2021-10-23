// sampling, reading audio files, and loading the files into buffers

s.boot;

~bt = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\BT0A0A7.wav"); // .aiff or .wav only - no mp3

~bt.play; // good way to test if file loaded

// audio files have different number of channels
~bt.numChannels;

// if the audio file is mono, buffer will be mono

~bt.duration; // how long in seconds the audio file is

~bt.numFrames; // a snapshot of time for the buffer across channels

// number of frames = number of samples ( * num of channels in stereo)

~bt.sampleRate; //

~bt.bufnum; // every buffer has an integer associated with it

~bt.free; // clear buffer off the server

// the above is not best practice - PATH is relative to where it is stored - cant esaily send it around

// better way: always PATH accurate

thisProcess.nowExecutingPath; // absolute path to saved script

PathName.new(thisProcess.nowExecutingPath).parentPath; // string representing the path to the parent folder of the script

PathName.new(thisProcess.nowExecutingPath).parentPath ++ "audio/"; // concat to make a folder directory

// working example of how to read in audio files
(
~path = PathName.new(thisProcess.nowExecutingPath).parentPath ++ "audio/";
~var = Buffer.read(s, ~path ++ "filename.aiff");
)

// ugens for buffers - two play buffers - 31 min in

(
{
	var sig;
	sig = PlayBuf.ar(
		1,
		~bt.bufnum,
		1, // 1 is regular sample rate, can mess with pitch with diff values
		doneAction:2 // need to turn off the sample otherwise it stays alive in the server
	);
}.play;
)

(
{
	var sig;
	sig = PlayBuf.ar(
		1,
		~bt.bufnum,
		BufRateScale.ir(~bt.bufnum), // scaled so it is at the correct sample rate (48000)
		doneAction:2 // need to turn off the sample otherwise it stays alive in the server
	);
}.play;
)

(
{
	var sig;
	sig = PlayBuf.ar(
		1,
		~bt.bufnum,
		BufRateScale.ir(~bt.bufnum) * 0.midiratio, // shifting the pitch by semi tones (12 is an octave)
		doneAction:2 // need to turn off the sample otherwise it stays alive in the server
	);
}.play;
)

(
{
	arg t_trig=1;
	var sig;
	sig = PlayBuf.ar(
		1,
		~bt.bufnum,
		BufRateScale.ir(~bt.bufnum) * 0.midiratio, // shifting the pitch by semi tones (12 is an octave)
		t_trig, // we can also do a var.set(\t_trig, 1) to retrigger sample
		100, // the frame where the sample starts
		doneAction:2 // need to turn off the sample otherwise it stays alive in the server
	);
}.play;
)

// impulse and dust Ugens can be used to trigger samples

// impulse is full amplitude 0 to 1
// dust is more random, not the sample amplitude
// can be used to automate the retriggering of a soundfile

(
x = {
	var sig;
	sig = PlayBuf.ar(
		1,
		~bt.bufnum,
		BufRateScale.ir(~bt.bufnum) * 0.midiratio,
		Impulse.ar(1),
		doneAction:0
	);
}.play;
)


(
x = {
	arg loop=1;
	var sig;
	sig = PlayBuf.ar(
		1,
		~bt.bufnum,
		BufRateScale.ir(~bt.bufnum) * 0.midiratio,
		loop:loop,
		doneAction:0
	);
}.play;
)

x.set(\loop,0);