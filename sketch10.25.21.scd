s.boot;

t = TempoClock.new(200/60).permanent_(true);

t.beats;

// load in tr909 samples
(
~bt = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\BT0A0A7.wav"); // bass
~st = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\ST0T0S3.wav"); // snare
~st2 = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\STAT0S7.wav"); // snare2
~hc = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\HANDCLP1.wav"); // handclap
~ht = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\HHCD2.wav"); // hi hat
)


// define drum synth
(
SynthDef.new(\b, {
	arg buf=0, rate=1, t_trig=1, spos=0, loop=0, da=2, amp=0.02, out=0, ps=0;
	var sig;
	sig = PlayBuf.ar(
		1, // mono playbuf - use 2 for stereo typically, need two synthDefs for samples
		buf, //buf is initialized as 0, so the first sample you load is in the 0 position
		BufRateScale.ir(buf) * ps.midiratio,
		t_trig,
		spos,
		loop,
	);
	sig = sig * amp!2; // !2 to stereo - multichannel expansion for a mono sound source
	Out.ar(out, sig);
}).add;
)


(
SynthDef.new(\blip, {
	arg freq=300, amp=0.4, pan=0, out=0;
	var sig, env, rev;
	env = EnvGen.ar(Env.perc(0.002, 0.2), doneAction:2);
	sig = SinOsc.ar(freq);
	sig = sig * env;
	sig = LPF.ar(sig,600);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

Synth(\blip);

(
~seq1 = Pbind(
	\instrument, \blip,
	\freq, Prand([200, 300, \, 400, 600], inf) // \ is rest
);
)

(
~seq2 = Pbind(
	\instrument, \b, // name your instrument
	\ps, Prand([-12, 0, 12, 24], inf),
	\buf, Pwrand([~bt, ~st, ~st2, ~ht, ~hc, \], [0.30, 0.10, 0.05, 0.15, 0.05, 0.35], inf);
);
)

~seq1.play(t);~seq2.play(t);