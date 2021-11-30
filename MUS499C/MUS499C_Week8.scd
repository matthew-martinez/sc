s.boot;

~bt = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\BT0A0A7.wav"); // .aiff or .wav only - no mp3
~st = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\ST0T0S3.wav");
~ht = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\HHCD2.wav");
(
x = {
	var sig;
	sig = PlayBuf.ar(
		1,
		~bt.bufnum,
		BufRateScale.ir(~bt.bufnum),
		doneAction:2
	);
	sig = sig * 0.3!2; // !2 to stereo
}.play;
)

/////////// synth def w/ samples


// drum synth, can use the buf arg to change samples
(
SynthDef.new(\b, {
	arg buf=0, rate=1, t_trig=1, spos=0, loop=0, da=2, amp=0.3, out=0, ps=0;
	var sig;
	sig = PlayBuf.ar(
		1, // mono playbuf - use 2 for stereo typically, need two synthDefs for samples
		buf, //buf is initialized as 0, so the first sample you load is in the 0 position
		BufRateScale.ir(buf) * ps.midiratio,
		t_trig,
		spos,
		loop,
		da
	);
	sig = sig * amp!2; // !2 to stereo - multichannel expansion for a mono sound source
	Out.ar(out, sig);
}).add;
)


(
Synth.new(\b, [
	\ps, 0,
	\loop, 1
]);
)

(
x = 2.collect({
	Synth.new(\b, [
		\ps, rrand(-12,36),
		\loop, 1
]);
}))

x.do({arg n; n.free});


(
x = 5.collect({
	arg n;
	Synth.new(\b, [
		\ps, (n/10), // can modify pithc, works more interestingly on longer samples
		\loop, 1
]);
}))

x.do({arg n; n.free});


//using a routine to make a steady rhythm - using bass, snare, and high hat
(
r = Routine.new({
	loop{
		var buf;
		buf = [~bt, ~st, ~ht].wchoose([0.25, 0.25, 0.50]); // each loop it chooses a drum type, probabilities in the array
		Synth.new(\b, [
			\buf, buf,
			\ps, [-12, 0, 12, 24].choose, //pitchshift down or up two octaves, potentially
			\loop, 0,
			\amp, rrand(0.1, 0.4)
		]);
		wait([1/8, 1/4, 1/2].choose); // choose for how long it waits
	}// must wait in a routine!
}).play;
)

r.stop;