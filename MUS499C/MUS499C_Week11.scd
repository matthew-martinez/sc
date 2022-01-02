s.boot;

(
SynthDef.new(\blip, {
	arg freq=300, amp=0.5, pan=0, out=0,
	atk=0.002, sus=0, rel=0.2, atkcrv=1, relcrv=(-10);
	var sig, env;
	env = EnvGen.ar(Env.new([0,1,1,0],[atk,sus,rel],[atkcrv,0,relcrv]), doneAction:2);
	sig = SinOsc.ar(freq);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

Synth(\blip, [\freq, 200, \rel, 3, \amp, 0.2]);

// patterns and streams

(
p = Pseq([1,0,17],2); // pattern
q = p.asStream; // turning pattern into a process that we can play
)

q.next;
q.reset;
q.nextN(10);

// events

// events can model objects and actions

(
~box = (
	height: 18,
	width: 10.5,
	depth: 4
);
)

~box[\width];

~box.play; // it will play a sound because there is a default note event (default SynthDef plays default note event)

// Pbind pattern classes

// Pbind generate events - creates key and value pairs (which make up events)

().play;

(
p = Pbind( // Pbinds have some default arguments that we can fill in
	\instrument, \blip,
	//\freq, Pseq([300, 500, 700], inf),
	\midinote, Pseq([60,72], inf),
	\ctranspose, Pseq([0,0,1,1,2,2],inf), // transposition value in semitones
	\harmonic, Pseq((1!6) ++ (3!6), inf),
	\amp, Prand([0.1, 0.3], inf),
	\dur, Prand([0.5, 0.25], inf), // 1 beat is 1 second
	\rel, Prand([0.2, 0.1, 0.4], inf),
	\legato, Prand([0.1, 0.5, 0.8],inf)
);
q = p.play;
)

(
p = Pbind( // Pbinds have some default arguments that we can fill in
	\instrument, \blip,
	\note, Pseq([0,2,4,6], inf),
	\gtranspose, 10,
	\root, 2,
	\amp, Prand([0.1, 0.3], inf),
	\dur, Prand([0.5, 0.25], inf), // 1 beat is 1 second
	\rel, Prand([0.2, 0.1], inf),
	\legato, Prand([0.1, 0.5, 0.8],inf)
);
q = p.play;
)


(
p = Pbind( // Pbinds have some default arguments that we can fill in
	\instrument, \blip,
	\degree, Pseq([0,2,1,3,2,4], inf),
	\scale, #[0,2,4,5,7,9,11],
	\amp, Prand([0.1, 0.3], inf),
	\dur, Prand([0.5, 0.25], inf), // 1 beat is 1 second
	\rel, Prand([0.2, 0.1], inf),
	\legato, Prand([0.1, 0.5, 0.8],inf)
);
q = p.play;
)

// ended at 44 mins - need to pick back up there

(
p = Pbind( // Pbinds have some default arguments that we can fill in
	\instrument, \blip,
	\degree, Pseq([0,2,1,3,2,4], inf),
	\scale, #[0,2,4,5,7,9,11],
	\amp, Prand([0.1, 0.3], inf),
	\dur, Prand([0.5, 0.25], inf), // 1 beat is 1 second
	\rel, Prand([0.2, 0.1], inf)
);
q = p.play;
)


(
SynthDef.new(\blip, {
	arg freq=300, amp=0.5, pan=0, out=0,
	atk=0.002, rel=0.2;
	var sig, env;
	env = EnvGen.ar(Env.perc(atk, rel), doneAction:2);
	sig = SinOsc.ar(freq);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

(
p = Pbind( // Pbinds have some default arguments that we can fill in
	\instrument, \blip,
	\freq, Pseq([300, 500, 700], inf),
	\amp, Prand([0.1, 0.3], inf),
	\dur, Prand([0.5, 0.25], inf), // 1 beat is 1 second
);
q = p.play;
)
// you don't need to turn Pbind into a stream

q = p.play; // plays p

q.pause;
q.resume;
q.stop;

//// tempo

TempoClock.default;
t = TempoClock.new(130/60).permanent_(true); // allow this tempo to survey command + .
t.beats;

// 2 Pbinds at the same time

(
~p1 = Pbind( // Pbinds have some default arguments that we can fill in
	\instrument, \blip,
	\note, Pseq([0,7,10,3,5,7,5,3], inf),
	\amp, 0.2,
    \dur, Pseq([0.5], inf), // eigth notes
    \rel, 0.08,
	\pan, Pseq([-1,1], inf)
);
~q1 = ~p1.play(t, quant:4);
)

(
~p2 = Pbind( // Pbinds have some default arguments that we can fill in
	\instrument, \blip,
	\note, Pseq([0,7,10,3,5,7], inf),
	\gtranspose, 19, // up an octave and a fifth
	\amp, 0.2,
    \dur, Pseq([1/4], inf), // quarter notes
    \rel, 0.08,
	\pan, Pseq([1,-1], inf)
);
~q2 = ~p2.play(t, quant:4); // quantize the action of playing the Pbind - quantize to nearest whole note
)


t.tempo_(90/60); // can change when it is running