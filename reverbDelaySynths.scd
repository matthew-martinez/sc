s.boot;

~scale0 = Buffer.loadCollection(s, Scale.minorPentatonic.degrees);

(
{
	arg gate = 1;
	var sig, index, pch, freq;
	index = LFDNoise0.kr(3).range(0,4);
	index = index * BufFrames.kr(~scale0);
	index.poll(2);
	pch = DegreeToKey.kr(~scale0, index) + 36;
	freq = pch.midicps;
	sig = VarSaw.ar(freq, mul:0.05!2);

	sig = sig.blend(
		CombN.ar(sig, 0.25, 0.25, 2),
		0.5);

	sig = sig.blend(
		LPF.ar(GVerb.ar(sig.sum, 200, 3), 1000), 0.4);
}.play;
)

(
SynthDef.new(\synth1, {
	arg gate=1, pan=0, inote=24, dWet=0.4, rWet=0.5;
	var sig, index, pch, freq;
	index = LFDNoise0.kr(1!4).range(0,4);
	index = index * BufFrames.kr(~scale0);
	//index.poll(7);
	pch = DegreeToKey.kr(~scale0, index) + inote;
	freq = pch.midicps;
	freq.poll(1);
	sig = VarSaw.ar(freq, mul:0.02);
	sig = Splay.ar(sig, 0.75);
	sig = sig * EnvGen.kr(
		Env([0, 1, 0, 0],[0.05, 4, 7],[0,-2,0],1), gate, doneAction:2);

	sig = sig.blend(
		CombN.ar(sig, 0.25, 0.25, 2),
		dWet);

	sig = sig.blend(
		LPF.ar(GVerb.ar(sig.sum, 200, 3), 1000), rWet);

	sig = Pan2.ar(sig, pan);

	Out.ar(0, sig);
}).add;
)

x = Synth(\synth1);
x.set(\inote, 36, \pan, rrand(-0.5,0.5));
x.set(\inote, 24, \pan, rrand(-0.5,0.5), \dWet, 0.5);
x.set(\inote, 36, \pan, rrand(-0.5,0.5), \dWet, 0.1);
x.set(\inote, 24, \pan, rrand(-0.5,0.5), \dWet, 0.9, \rWet, 0.8);
x.set(\gate, 0);