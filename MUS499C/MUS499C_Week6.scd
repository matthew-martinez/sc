s.boot;

(
f = {
	arg freq=100;
	var sig;
	sig = Pulse.ar(freq * [1,1.01], 0.5, 0.04);
	sig = sig + SinOsc.ar(freq * [1.5, 1.004], 0, 0.15);
	sig = sig + BrownNoise.ar(0.04!2);
	sig = sig * Line.ar(9,1,10)
};
)

x = f.play; // f.play creates a synthDef and then an instance of it (i.e., synth)
x.free

x = f.play(args:[\freq, 200]);
x.set(\freq, 220);
x.set(\freq, 140);
x.set(\gate, 0, \fadeTime, 5);


///////////// lets make a synthDef - think of a synthDef as a recipe for a sound

(
SynthDef.new(\ocean, {
	arg freq=100;
	var sig;
	sig = Pulse.ar(freq * [1,1.01], 0.5, 0.04);
	sig = sig + SinOsc.ar(freq * [1.5, 1.004], 0, 0.15);
	sig = sig + BrownNoise.ar(0.04!2);
	sig = sig * Line.ar(9,1,10);
	Out.ar(0, sig); //handled behind the scenes when using the function - need to be explicit with a synthDef
}).add; // need to include .add method - .add builds the uGen graph function
)

x = Synth.new(\ocean, [\freq, 160]);
x.set(\freq, 180);
x.set(\freq, 240);
x.set(\freq, 160);
x.set(\gate, 0, \fadeTime, 5); // wont work - uGen automatically adds a linen env - we need to explicitly call one

x.free;

// adding an envelope

(
SynthDef.new(\ocean, {
	arg freq=100, gate=1, atk=3, rel=3,out=0, pan=0; // use arguments rather than specific vlaues in synthDef
	var sig, env;
	env = EnvGen.kr(
		Env.asr(atk, 1, rel, [1,1]),
		gate,
		doneAction:2
	);
	sig = Pulse.ar(freq * [1,1.01], 0.5, 0.04);
	sig = sig + SinOsc.ar(freq * [1.5, 1.004], 0, 0.15);
	sig = sig + BrownNoise.ar(0.04!2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig); //handled behind the scenes when using the function - need to be explicit with a synthDef
}).add; // include .add method - .add builds the uGen graph function- adds it to a collection of synthDefs that live on the server
)

x = Synth.new(\ocean, [\freq, 160]);
x.set(\freq, 180, \atk, 1, \pan, 0.5);
x.set(\freq, 240, \atk, 4, \pan, 1.2);
x.set(\freq, 160, \atk, 0.2, \pan, 0);
x.set(\gate, 0, \rel, 10); // now it works! \fadeTime won't work, but we can make our own release as an argument

// layering synths - cool drone

a = [];
a = a.add(Synth.new(\ocean, [\freq, 160]));
a = a.add(Synth.new(\ocean, [\freq, 200, \pan, 0.5]));
a = a.add(Synth.new(\ocean, [\freq, 240, \pan, 1.2, \atk, 0.5]));
a = a.add(Synth.new(\ocean, [\freq, 180, \pan, 0.2, \atk, 1]));
a.do({arg synth; synth.set(\gate, 0, \rel, 6)}); // iterate across the array to release all

/////////////// making melodies - routines - sequencing

// Routines are types of functions that can be played

// automate instruction over time

(
r = Routine.new(
	{
		"Hello".postln;
		wait(1);
		"how are you?".postln;
		wait(3);
		"goodbye".postln;
	}
);
)

r.play;
r.reset;


///////////// rebuild a synth - sequence it with Routines

(
SynthDef.new(\ocean, {
	arg freq=100, gate=1, atk=0.01, rel=1, out=0, pan=0; // use arguments rather than specific vlaues in synthDef
	var sig, env;
	env = EnvGen.kr(
		Env.new(
			[0,1,0],
			[atk, rel],
			[0,-4]),
		doneAction:2
	);
	sig = Pulse.ar(freq * [1,1.01], 0.5, 0.04);
	sig = sig + SinOsc.ar(freq * [1.5, 1.004], 0, 0.15);
	sig = sig + BrownNoise.ar(0.04!2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig); //handled behind the scenes when using the function - need to be explicit with a synthDef
}).add; // include .add method - .add builds the uGen graph function- adds it to a collection of synthDefs that live on the server
)

Synth(\ocean, [\pan, -0.5]);

(
r = Routine.new({
	Synth(\ocean, [\freq, 60.midicps, \pan, rrand(-0.5,0.5)]);
	wait(0.5);
	Synth(\ocean, [\freq, 62.midicps, \pan, rrand(-0.5,0.5)]);
	wait(0.5);
	Synth(\ocean, [\freq, 67.midicps, \pan, rrand(-0.5,0.5)]);
	wait(0.5);
});
)

r.reset;r.play;

(
r = Routine.new({
	100.do{
		Synth(\ocean, [\freq, rrand(48,72).midicps, \pan, rrand(-0.5,0.5)]);
		wait(exprand(0.1,0.8));
	};
});
)

r.reset;r.play;

(
r = Routine.new({
	inf.do{
		Synth(\ocean, [\freq, rrand(48,72).midicps, \pan, rrand(-0.5,0.5)]);
		wait(0.5); //always wait with inf.do - it crashes SC
	};
});
)

r.reset;r.play;
r.stop;

// nesting routines


(
r = Routine.new({
	inf.do{
		3.do{
		Synth(\ocean, [\freq, 60.midicps, \pan, rrand(-0.5,0.5)]);
		wait(0.5);
		};

		5.do{
		Synth(\ocean, [\freq, rrand(48,72).midicps, \pan, rrand(-0.5,0.5)]);
		wait(0.5);
		};

		wait(0.01);
	};
});
)

r.reset;r.play;
r.stop;