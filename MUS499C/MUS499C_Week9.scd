s.boot;

// modularize our synthDefs - one for signal generation, another for effect

(
SynthDef.new(\drops, {
	arg freqMin=100, freqMax=3000, gate=1, amp=0.3;
	var sig, trigEnv, env, freq, trig;

	freq = LFNoise1.kr(0.2!2).exprange(freqMin, freqMax); // random noise generator spits out values between 100 and 3000 hertz
	sig = SinOsc.ar(freq);

	trig = Dust.ar(1!2); // trigger signal set up
	trigEnv = EnvGen.ar(Env.perc(0.002,0.1), trig); // to retrigger a percussive envelope
	sig = sig * trigEnv; // makes it sound drippy

	env = EnvGen.kr(Env.asr(0.01,1,1,-1), gate, doneAction:2);
	sig = sig * env * amp;

	Out.ar(0, sig);
}).add;
)

x = Synth.new(\drops);
x.set(\gate, 0);
x.free;

// lets add a reverb effect

(
SynthDef.new(\drops, {
	arg freqMin=100, freqMax=3000, gate=1, amp=0.3;
	var sig, trigEnv, env, freq, trig, reverb;

	freq = LFNoise1.kr(0.2!2).exprange(freqMin, freqMax); // random noise generator spits out values between 100 and 3000 hertz
	sig = SinOsc.ar(freq);

	trig = Dust.ar(1!2); // trigger signal set up
	trigEnv = EnvGen.ar(Env.perc(0.002,0.1), trig); // to retrigger a percussive envelope
	sig = sig * trigEnv; // makes it sound drippy

	reverb = GVerb.ar(sig, 250, 4); // input, room size (meters), reverb time in seconds
	reverb = LPF.ar(reverb, 1200); // will filter out some parts of reverb signal above 1200 hertz, adds some dampening
	sig = (sig + reverb) * 0.5; // wet and dry signal, add them together, then scale back

	env = EnvGen.kr(Env.asr(0.01,1,1,-1), gate, doneAction:2);
	sig = sig * env * amp;

	Out.ar(0, sig);
}).add;
)

x = Synth.new(\drops);
x.set(\gate, 0);
x.free;

// two synthDefs

(
SynthDef.new(\drops, {
	arg freqMin=100, freqMax=3000, gate=1, amp=0.3, out=0; // use an output argument
	var sig, trigEnv, env, freq, trig, reverb;

	freq = LFNoise1.kr(0.2!2).exprange(freqMin, freqMax); // random noise generator spits out values between 100 and 3000 hertz
	sig = SinOsc.ar(freq);

	trig = Dust.ar(1!2); // trigger signal set up
	trigEnv = EnvGen.ar(Env.perc(0.002,0.1), trig); // to retrigger a percussive envelope
	sig = sig * trigEnv; // makes it sound drippy

	env = EnvGen.kr(Env.asr(0.01,1,1,-1), gate, doneAction:2);
	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;
)

(
SynthDef.new(\reverb, {
	arg in=0, out=0;
	var sig, reverb;

	sig = In.ar(in, 2);
	reverb = In.ar(in, 2);

	reverb = GVerb.ar(sig, 250, 4); // input, room size (meters), reverb time in seconds
	reverb = LPF.ar(reverb, 1200); // will filter out some parts of reverb signal above 1200 hertz, adds some dampening
	sig = (sig + reverb) * 0.5; // wet and dry signal, add them together, then scale back

	Out.ar(out, sig);
}).add
)

r = Synth.new(\reverb, [\in, 48]);
d = Synth.new(\drops, [\out, 48]);
d.set(\gate, 0); // now the decay on the reverb bus lasts as the gate is closed on drops
d.free;

// using a Bus object
~reverbBus = Bus.audio(s, 2);
~bus2 = Bus.audio(s, 4);
~bus3 = Bus.audio(s, 1);

s.newBusAllocators;

r = Synth.new(\reverb, [\in, ~reverbBus]); // need to turn on reverb before sending sound in
d = Synth.new(\drops, [\out, ~reverbBus]);
d.set(\gate, 0); // now the decay on the reverb bus lasts as the gate is closed on drops
r.free;


///// targets and actions

d = Synth.new(\drops, [\out, ~bus]); // drops comes before reverb only becuase of \addAfter
r = Synth.new(\reverb, [\in, ~bus], d, \addAfter);

d.set(\gate,0);
r.free;


(
SynthDef.new(\drops2, {
	arg freqMin=100, freqMax=3000, gate=1, amp=0.3, out=0; // use an output argument
	var sig, trigEnv, env, freq, trig, reverb;

	freq = LFNoise1.kr(0.2!2).exprange(freqMin, freqMax); // random noise generator spits out values between 100 and 3000 hertz
	sig = Pulse.ar(freq);

	trig = Dust.ar(1!2); // trigger signal set up
	trigEnv = EnvGen.ar(Env.perc(0.002,0.1), trig); // to retrigger a percussive envelope
	sig = sig * trigEnv; // makes it sound drippy

	env = EnvGen.kr(Env.asr(0.01,1,1,-1), gate, doneAction:2);
	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;
)

d = Synth.new(\drops, [\out, ~bus]);
r = Synth.new(\reverb, [\in, ~bus], d, \addAfter);

p = Synth.new(\drops2, [\out, ~bus], d, \addReplace); // replacing d w/ p

p.set(\gate,0);
r.free;

///////// using groups to do this - way more organized

~grp0 = Group.new // groups are a lot like synths - both are nodes
// can make groups for different things
// effects group, synth group, control signal group

~srcGrp = Group.new;
~fxGrp = Group.new(~srcGrp, \addAfter); // can add right after source group!


d = Synth.new(\drops, [\out, ~bus], ~srcGrp);
p = Synth.new(\drops2, [\out, ~bus, \amp, 0.05], ~srcGrp);
r = Synth.new(\reverb, [\in, ~bus], ~fxGrp);

~srcGrp.set(\gate, 0);