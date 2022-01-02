s.boot;

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


// define voice 1
~scale0 = Buffer.loadCollection(s, Scale.minorPentatonic.degrees); //scale

(
SynthDef.new(\saw, {
	arg gate=1, inote=12, atk=0.01, rel=0.5, out=0, pan=0, amp=0.8, dWet=0.2, rWet=0.3, width=0.5, freq=440; // use arguments rather than specific vlaues in synthDef
	var sig, index, pch, env;
	env = EnvGen.kr(
		Env.perc(atk, rel), doneAction:2);
	sig = LFPulse.ar(freq, 0, width: width, mul:0.05);
	sig = sig + VarSaw.ar(freq, 0, mul: 0.1);
	sig = sig * env;
	sig = LPF.ar(sig, 800);
	sig = sig.blend(
		CombN.ar(sig, 0.25, 0.25, 0.5, 0.2),
		dWet);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)


// routine - drums
(
d = Routine.new({
	loop{
		var buf;
		buf = [~bt, ~st, ~st2, ~ht, ~hc].wchoose([0.25, 0.10, 0.10, 0.50, 0.05]); // each loop it chooses a drum type, probabilities in the array
		Synth.new(\b, [
			\buf, buf,
			\ps, [-12, 0, 12, 24].choose, //pitchshift down or up two octaves, potentially
			\loop, 0,
			//\amp, rrand(0.1, 0.2)
		]);
		wait([1/8, 1/4, 1/2].choose); // choose for how long it waits
	}// must wait in a routine!
})
)

// routine - voice
(
r = Routine.new({
	inf.do{
		Synth(\saw, [\freq, rrand(220,660),
			\pan, rrand(-0.5,0.5),
			\dWet, rrand(0.1, 0.7),
			\width, exprand(0.1,0.9)
			;
		]);
		wait([1/4,1/2].choose); //always wait with inf.do - it crashes SC
	};
});
)

// play routines
d.reset;d.play;
r.reset;r.play;