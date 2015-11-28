s.boot;
(
SynthDef(\kick01, {
  var e0, e1, out;
  e0 = EnvGen.ar(Env.perc(0.001, 0.3), doneAction: 2);
	e1 = EnvGen.ar(Env.new([4000, 200, 40], [0.001, 0.2], [-4, -10]));
  out = LPF.ar(WhiteNoise.ar(1), e1 * 1.5, e0);
  out = out + SinOsc.ar(e1, 0.5, e0);
  Out.ar(0, out.dup);
}).add;

SynthDef(\clap01, {|amp=1.0|
	var e1, e2, n1, n2, out;
  e1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
  e2 = EnvGen.ar(Env.perc(0.01, 0.4), doneAction:2);
  n1 = BPF.ar(HPF.ar(WhiteNoise.ar(e1), 600), 2000, 3);
	n2 = BPF.ar(HPF.ar(WhiteNoise.ar(e2), 1000), 1200, 0.7, 0.7);
  out = n1 + n2;
  out = out * amp;

  Out.ar(0, out.dup);
}).add;

SynthDef(\hat01, {|amp=0.1, dur=0.5|
  var e1, out;
  e1 = EnvGen.ar(Env.perc(0.0001, dur, 1, -8), doneAction:2);
  out = RHPF.ar(ClipNoise.ar(1), 9000, 0.2) * e1 * amp;
  Out.ar(0, out.dup);
}).add;

SynthDef(\fmchord01, {|freq=440, amp=0.2, dur=2|
  var index_env, amp_env, out;
  index_env = EnvGen.ar(Env.perc(0.0001, 0.2, 1, -4));
  amp_env = EnvGen.ar(Env.perc(0.0001, 1, dur, -4), doneAction:2);
  out = PMOsc.ar(freq, freq * 1.02, (index_env * 2)) * amp_env;
  out = FreeVerb.ar(out.dup, 0.5, 0.8, 0.9);
  Out.ar(0, out * amp);
}).add;

SynthDef(\pad01, {|freq=440, amp=0.5, dur=2|
  var env1, out;
  env1 = EnvGen.ar(Env.linen(4, 0.3, 4, 1, -4), doneAction:2);
  out = Pulse.ar([freq, freq * 1.01, freq * 0.99], SinOsc.kr(1, 0, 0.3, 1.5), env1);
  out = RLPF.ar(out, freq * 1.1, 0.9);
  out = FreeVerb.ar(out.dup, 0.8, 0.8, 0.9);
  Out.ar(0, out * 0.3);
}).add;

SynthDef(\bass01, {|freq=440, ffreq=1000, amp=1.0, dur=2, slew=0.08, gate=1|
  var e1, e2, o;
  e1 = EnvGen.ar(Env.adsr(0.001, 0.1, 0.8, 0.1, 1, -4), gate);
  e2 = EnvGen.ar(Env.adsr(0.001, 0.6, 0.2, 0.4, ffreq, -4), gate);
  o = RLPF.ar(Saw.ar(Lag.kr(freq, slew)), freq + e2, 0.1) * e1;
  Out.ar(0, o.softclip.dup);
}).add;
)
