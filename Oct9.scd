s.boot;


(
SynthDef("synth1", {arg freq = 440, amp = 0.3;
	var env = Env.perc(attackTime: 0.07, releaseTime: 1.5, level: amp, curve: -2.0).kr(2);
	var chorus = Lag.kr(freq, 2) * LFNoise2.kr([0.2, 0.3, 0.1, 2, 1, 3, 7]).range(1, 1.05);
	var source = SinOsc.ar(chorus) * 0.2;
	var snd = LPF.ar(in: source, freq: freq, mul: env);
	Out.ar(0, Splay.ar(snd));
}).add;
)

(
SynthDef("synth3", {arg freq = 440, amp = 0.1;
	var env = Env.perc(releaseTime: 0.5, level: amp).kr(2);
	var source = LFPulse.ar(freq);
	var snd = LPF.ar(in: source, freq: freq, mul: env);
	Out.ar(0, Splay.ar(snd));
}).add;
)


(
SynthDef("synth2", {arg freq = 440, amp = 0.1;
	var env = Env.perc(level: amp).kr(2);
	var chorus = Lag.kr(freq, 2) * LFNoise2.kr([0.2, 0.3, 0.1, 2, 1, 3, 7]).range(1, 1.05);
	var source = LFSaw.ar(chorus) * 0.2;
	var snd = LPF.ar(in: source, freq: freq, mul: env);
	Out.ar(0, Splay.ar(snd));
}).add;
)

(
var clock;

clock = TempoClock(0.75);

Pbind(
	\instrument, "synth1",
	\degree, Pwhite(-15,10),
	\dur, Prand([0.5, 1.75], inf),
	\amp, Pwhite(0.1, 0.3)
).play(clock);
)


(
var clock;

clock = TempoClock(0.75);

Pbind(
	\instrument, "synth2",
	\degree, Pwhite(1,7),
	\dur, Prand([0.125, 0.25], inf),
	\amp, Pwhite(0.05, 0.2)
).play(clock);
)


(
var clock;

clock = TempoClock(0.75);

Pbind(
	\instrument, "synth3",
	\degree, Pwhite(-10,-5),
	\dur, Prand([0.125, 0.25], inf),
	\amp, Pwhite(0.05, 0.2)
).play(clock);
)