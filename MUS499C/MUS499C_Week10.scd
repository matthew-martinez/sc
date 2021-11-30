s.boot;

(
SynthDef.new(\blip, {
	arg freq=300, amp=0.4, pan=0, out=0;
	var sig, env;
	env = EnvGen.ar(Env.perc(0.002, 0.2), doneAction:2);
	sig = SinOsc.ar(freq);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

Synth(\blip);

// pattern is the blueprint, stream is the output

p = Pseries(start: 0, step: 1, length:inf)
q = p.asStream;
q.next;

p = Pseq([1,14,200,94], inf).asStream;
p.nextN(10);

p = Prand([1,14,200,94], inf).asStream;
p.nextN(10);

p = Pxrand([1,14,200,94], inf).asStream;
p.nextN(10);

p = Pshuf([1,14,200,94], inf).asStream;
p.nextN(10);

p = Pseq([1,2,3, Prand([100, 200,300],1)], inf).asStream; // can nest patterns
p.next(20);

// Pbrown might be interseting

p = Pbrown(200,800,Pwhite(20,200,inf),inf).asStream;
p.nextN(16);

// Pbind is everyone's favorite - most common
// engineered for flexibly producing a sequence of sound

(
p = Pbind(
	\instrument, \blip, // name your instrument
	\freq, Pseq([200, 300, 400], inf)// using Pseq to specify the sequence of values to pass to freq
);
)

p.play;