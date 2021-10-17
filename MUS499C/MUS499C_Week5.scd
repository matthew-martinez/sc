s.boot;

///////// two envelopes, one frequency envelope and one for the sound signal
// includes low pass filter

(
x = {
	var sig, env, freqEnv; // signal and envelope
	freqEnv = EnvGen.kr(
		Env.new(
			[15000, 500],
			[0.5],
			[-12]
		)
	);
	env = EnvGen.kr(
		Env.new(
			[0, 1, 0],
			[0.5, 0.75],
			[0,0]
		),
		doneAction:2
	);
	sig = Saw.ar(80);
	sig = LPF.ar(sig, freqEnv); //second valuen is cutoff - low pass filter
	sig = sig * env;
	sig = sig * 0.2;
	sig = sig!2;
}.play
)


//////////////// percussive envelope w/ trigger control


(
f = {
	arg t_gate=1; // t_ is trigger, trigger gates do not need a x.set \gate 0 to retrigger
	var sig, env;// signal and envelope
	env = EnvGen.kr(
		Env.perc(0.01, 0.5),
		t_gate // gate is needed for sustaining envelope ADSR
	);
	sig = SinOsc.ar(200);
	sig = sig * env;
	sig = sig * 0.2;
	sig = sig!2;
}
)

x = f.play(args:[\t_gate, 0]);

x.set(\t_gate, 1);
x.free;

//////////////////// indefinite length envelopes (ADSR)

(
f = {
	arg gate=1;
	var sig, env;// signal and envelope
	env = EnvGen.kr(
		Env.adsr(0.01, 0.3, 0.5, 1),
		gate // gate is needed for sustaining envelope ADSR
	);
	sig = SinOsc.ar(200);
	sig = sig * env;
	sig = sig * 0.2;
	sig = sig!2;
}
)

x = f.play(args:[\gate, 0]);

x.set(\gate, 1);
x.set(\gate, 0);
x.free;


///////////// multi channel expansion
(
x = {
	var sig, freqs;
	freqs = Array.exprand(20, 200, 800);
	sig = LFSaw.ar(freqs, 0, 0.01);
	sig = LPF.ar(sig, 600);
	sig = sig.sum;
	sig = sig * 0.4;
	sig = sig!2;
}.play
)



(
x = {
	var sig, freqs;
	freqs = Array.exprand(8, 200, 800);
	sig = SinOsc.ar(freqs, 0, 0.07);
	sig = sig.collect({
		arg n;
		Pan2.ar(n, rrand(-1.0, 1.0)); //panning the pairs of signals randomly across the stereo field
	});
	sig = sig * 0.2;
	sig = sig.sum; // sum all signals from different channels
}.play
)


(
x = {
	var sig, freqs;
	freqs = Array.exprand(20, 200, 1200);
	sig = SinOsc.ar(freqs, 0, 0.2);
	sig = Splay.ar(sig);
}.play
)