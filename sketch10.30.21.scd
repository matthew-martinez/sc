// boot server
s.boot;

//set tempo 120 beats per 60 seconds
t = TempoClock.new(120/60).permanent_(true);
t.tempo_(4);
t.beatsPerBar;

// load in tr909 samples
(
~bt = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\BT0A0A7.wav"); // bass
~st = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\ST0T0S3.wav"); // snare
~st2 = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\STAT0S7.wav"); // snare2
~hc = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\HANDCLP1.wav"); // handclap
~ht = Buffer.read(s, "C:\\Users\\mattr\\Documents\\Samples\\TR909\\HHCD2.wav"); // hi hat
)

////////////////// SYNTHS /////////////////////
// define drum samples synth
(
SynthDef.new(\b, {
	arg buf=0, rate=1, t_trig=1, spos=0, loop=0, da=2, amp=0.04, out=0, ps=0;
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

// snare synth
(
SynthDef(\perc1, {
	arg out=0, pan=0, atk=0.001, rel=0.2, amp = 0.5;
	var env, sig;
	env = EnvGen.kr(Env.perc(attackTime:atk, releaseTime:rel, curve:-4), doneAction:2);
	sig = WhiteNoise.ar();
	Out.ar(out, Pan2.ar(sig, pan, amp)* env);
}).add;
)

// bassy pulse synth
(
SynthDef.new(\s1, {
	arg freq=220, out=0, amp=0.4, atk=0.01, rel=0.8, wflo=1, wfhi=6, wfmax=8500, iphase;
	var sig, env;

	sig = PulseDPW.ar(freq);
	sig = MoogLadder.ar(sig,
		 LFCub.kr( // filter cutoff modulated by LF pulse
			freq:LFPulse.kr(0.25, iphase, width: 0.25).range(
				wflo, wfhi) ).exprange(40, wfmax),
		0.7);

	//sig = SVF.ar(sig, 2200, res:0.4, lowpass:1.0, notch:0.6, mul:amp);

	//sig = IIRFilter.ar(sig, 800, 0.9);

	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);

	sig = GVerb.ar(sig, 25, 0.6, 0.62);

	//sig = CombN.ar(sig, 0.2, 0.2);

	sig = sig * env;

	Out.ar(out, sig!2 * amp);
}).add;
)

// triangle synth w/ delay
(
SynthDef.new(\s2, {
	arg freq=220, out=0, amp=0.4, atk=0.01, rel=0.5;
	var sig, env;

	sig = SinOsc.ar(freq);
	//sig = MoogLadder.ar(sig, 2200, 0.9);

	//sig = SVF.ar(sig, 2200, res:0.4, lowpass:1.0, notch:0.6, mul:amp);

	sig = IIRFilter.ar(sig, 3200, 0.2);

	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);

	//sig = GVerb.ar(sig, 25, 0.6, 0.62);

	sig = sig.blend(
		CombN.ar(sig, 1.5, 0.8),
		0.4);

	sig = sig * env;

	Out.ar(out, sig!2 * amp);
}).add;
)

////////////////////// PATTERNS ////////////////////////

(
p = Pbind(
	\instrument, \s1,
	\freq, Pseq([24.midicps, 26.midicps, 24.midicps, 48.midicps, 36.midicps, 36.midicps, 38.midicps, 55.midicps], inf),
	\iphase, Prand([0,0.25,0.5,0.75], inf),
	\amp, 0.1,
	\dur, Prand([0.5, 0.25], inf)
);
)

p.play();

(
q = Pbind(
	\instrument, \s2,
	\freq, Pseq([24+54.midicps, 26+48.midicps, 24+48.midicps, 48+24.midicps], inf),
	\amp, 0.2
);
)

(
~seq2 = Pbind(
	\instrument, \b,
	\ps, Prand([-12, 0, 12, 24], inf),
	\buf, Pwrand([~bt, ~st, ~st2, ~ht, ~hc, \], [0.30, 0.10, 0.05, 0.15, 0.15, 0.25], inf),
	\dur, Prand([0.5, 0.25], inf)
);
)

p.play();~seq2.play();