s.boot;

(
{
	var sig;
	sig = SinOsc.ar(220);
	sig = sig * 2;
	sig = sig.softclip;
	sig = sig * 0.2!2;
}.play
)

(
f = {
	arg freq=220, boost=4, pan=0, amp=0.1;
	var sig;
	sig = SinOsc.ar(freq);
	sig = sig * boost;
	sig = sig.softclip;
	sig = Pan2.ar(sig, pan, amp);
};
)

x = f.play(args: [\freq, 110]);

(
a = [];
12.do({
	a = a.add(
		f.play(
			fadeTime: exprand(3,6),
			args: [
				\freq, ((32,39..63).choose - ([0,2].choose)).midicps.postln,
			\boost, exprand(1,8),
			\pan, rrand(-0.8, 0.8),
			\amp, exprand(0.04, 0.1)
		]);
	);
})
)
a.do({ arg n; n.release(exprand(1,10)) });

x.set(\freq, 330);
x.set(\freq, exprand(35,79).midicps.postln);
x.set(\freq, (35,37..79).choose.midicps.postln);
x.set(\freq, 60.midicps)
x.release(1);


x.free;



////////////////////////////////////// evenlopes

(
Env.new(
	[0, 1, 0.2, 0.2, 0], // levels
	[1, 2.5, 2, 3], //time at each level
	[2, -8, 0, -4] // curvature
)
)

(
f = {
	arg freq=220, boost=4, pan=0, amp=0.1;
	var sig, env;
	env = EnvGen.ar(
		Env.new(
	[0, 1, 0.2, 0.2, 0],
	[1, 2.5, 2, 3],
	[2, -8, 0, -4]
	),
		doneAction: 2;
	);
	sig = SinOsc.ar(freq);
	sig = sig * boost;
	sig = sig.softclip;
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
};
)

x = f.play;