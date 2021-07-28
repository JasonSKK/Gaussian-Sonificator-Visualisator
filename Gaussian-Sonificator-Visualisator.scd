//:
//Multimedia Application: Svoronos - Kanavas Jason [JasonSKK], Thessaloniki.
//Start date: 210222
//Finnish date: 21 ...

//Gaussian distribution random number generator
//A# Ionian Scale
//Helpfile-Example
//(0..1000).collect { |num| gauss(1000, num) }.plot;

//Make sure it is the correct IP
~n = NetAddr("192.168.1.8", 57120);
//192.168.43.220
~nsend = NetAddr("192.168.1.8", 12345);
//Initial values
~receiver = 0;
~stdevi = 1;
~genspeed = 1;
//NoiseDef-Synth
~freqnoisedef = 100;
~lpfnoisedef = 666;
//busses
s.newBusAllocators;
~vbus = Bus.audio(s, 2);

//Ionian
~scale = Scale.ionian.degreeToFreq([0, 2, 4, 5, 7, 9, 11, 12], 58.midicps, 1).round(1).asArray;
//tests
//~scale[7]/4

//SynthDefsFirst-For initial values - arguments
//reverb
SynthDef(\verb, {
	|in=0, out=0, lpf=1500|
	var sig;
	sig = In.ar(~vbus, 2).sum;
	sig = DelayC.ar(sig, 0.02, 0.02);
	sig = CombN.ar(sig, 0.1, rrand(0.01, 0.099)!24, 1);
	sig = SplayAz.ar(2, sig, 5);
	sig = LPF.ar(sig, lpf);
	5.do{sig = AllpassN.ar(sig, 0.1, rand(0.01,0.099)!4, 2.2)};
	sig = LPF.ar(sig, lpf);
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;
//Synth(\verb, [\in, ~vbus]);
//:NoiseDef start ambience
SynthDef("noisedef", {
	| amp = 0.5, freq = 100, lpf = 666| //try 10000 lpf
	var sig, env, out;
	sig = Gendy3.ar(freq:[freq, freq], initCPs:10) + GrayNoise.ar(0.133) ;
	//+ Dust.ar(400);
	sig = LPF.ar(sig, lpf + LFNoise1.kr(0.666).range(-10, 10));
	sig = Compander.ar(sig, sig, 0.666, slopeAbove:0.5);
	env = EnvGen.kr(Env.adsr(3, releaseTime:4, curve: 'squared'), Line.kr(1, 0, 3), doneAction:2);
	out = sig * env * amp * 0.15;
	Out.ar(0, Pan2.ar(out, 0));
}).add;

////:lowDef ambience higher
SynthDef("low", {
	| amp = 0.5, freq = 150, modf = 2, pan = 0.0| //try 100 mod
	var sig, env, out, sum, temp;
	sig = 0;
	10.do{
		temp =
		SinOscFB.ar(freq * ExpRand(0.5, 2.0),
			ExpRand(-pi, 2*pi), rrand(0.5, 1.0)
		)
		ring2: SinOsc.ar(freq * rrand(0.7, 1.0),
			SinOsc.ar(freq* modf).range(pi, -pi)); //Phase Mod
		sig = temp + sig * 0.15;
	};
	env = Env([0, 1, 0.6, 0.0], [2, 0.8, 3], 'sin').kr(doneAction:2);
	//env = Env.perc(8, 6, curve:'squared').kr(doneAction:2);
	out = sig * env * amp * 0.25;

	out = Compander.ar(out, out, thresh: 0.25,
        slopeBelow: 1,
        slopeAbove: 0.1,
        clampTime:  0.01,
        relaxTime:  0.01);
	Out.ar(~vbus, out * -5.dbamp);
	Out.ar(0, Pan2.ar(out, pan));
}).add;


//Synth3
SynthDef("noisy", {
	| amp = 0.5 , panst = 0.3, panend = 0.3, combdel = 0.1, freq = 444, pan = -0.8|
	var sig, env, out;
	//sig = BPF.ar(WhiteNoise.ar(2), 10222, 0.5);
	//sig = HPF.ar(WhiteNoise.ar(2), 1111);
	freq = freq * LFNoise2.kr(0.4).range(0.97, 1.03);
	sig = Mix.fill(20, {Saw.ar(freq * rrand(0.98, 1.02))});
	sig = LPF.ar(sig, Line.kr(18000, 2166, 2));
	//sig = CombC.ar(sig, 0.2, combdel * 10, 2);
	//sig = CombC.ar(sig, 0.1, combdel, 0.9);
	sig = sig + Pulse.ar(freq/2, combdel);
	env = EnvGen.kr(Env.adsr(5, 1, releaseTime:3, curve:'squared'), Line.kr(1,0, 1.2), doneAction:2);
	out = sig * env * amp * 6.dbamp;
	out = Compander.ar(out, out, thresh: 0.5,
        slopeBelow: 1,
        slopeAbove: 0.1,
        clampTime:  0.01,
        relaxTime:  0.01);
	Out.ar(~vbus, out * -15.dbamp);
	Out.ar(0, Pan2.ar(out, pan));
}).add;

//Synth4
SynthDef("clicking",{| freq = 1, pan = 0.666, amp = 0.5|
	var sig, env, out;
	sig = ClipNoise.ar(0.9) + BrownNoise.ar(0.5);
	env = Env.circle([0, 1, 0.001, 0], [0.001, 0.015, 1]/freq, -8).kr(doneAction:0);
	sig = BPF.ar(sig, 10000, 1);
	out = sig + FreeVerb.ar(sig, 1.0, 0.166,0.966);
	out = sig * env * 0.6;
	out = out * amp;
	EnvGen.kr(
		Env.adsr(0.0001, 0.2, 0.666, releaseTime: 2),
		Line.kr(1, 0, 1.1 + rrand(3, 5)), doneAction:2);
	Out.ar(0, Pan2.ar(out, pan))
}).add;

//On Off
(
OSCdef(\onoff, {
    |msg, time, addr, port|
	~onoff = msg[1];
	//~onoff.postln;
	if(~onoff == 0, {CmdPeriod.removeAll; s.freeAll; f.stop; "OFF".postln;
		//Pdef-Stop
		p[0].stop;
	});
	if(~onoff == 1, {
		"ON".postln;
		//Pdefstart
		if(~s1onoff == 1, {
			p[0].play;
		});
		//Synth2
		if(~s2onoff == 1, {
			x = Synth("low");
			x.set(\amp, 0.5);
		});
		if(~s2onoff == 0, {
			x.free;
		});
		//Synth3
		if(~s3onoff == 1, {
			y = Synth("noisy");
			y.set(\amp, 0.5);
		});
		if(~s3onoff == 0, {
			y.free;
		});
		//Synth4
		if(~s4onoff == 1, {
			z = Synth("clicking");
			z.set(\amp, 0.5);
		});
		if(~s4onoff == 0, {
			z.free;
		});

		(       //f => f.stop when onoff, if not routine does not stop
			f = {inf.do{(

				/////////////////////////////////////////////////////
				~gss = gauss(~receiver, ~stdevi).round(0.00001); //range 100////////GAUSS-Function
				if (~gss.isNegative, {~gss = ~gss * (-1)});//////////Negative values => asPositive
				~gss.postln;/////////////////////////////////////////
				/////////////////////////////////////////////////////

				
				//send OSC msg to Open Frameworks
				~nsend.sendMsg('/gauss-value',  ~gss.round(1));
				
				//\freq, Prand([~scale[0], ~scale[3], ~scale[4], ~scale[7]],inf),

				if(~gss < 10, {
					"<10".postln;
					//noisedef
					~freqnoisedef = ~scale[0]/8;
					~lpfnoisedef = 666;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, ~scale[0]]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [\freq, [~scale[0]/2, ~scale[7]/2].choose,
							\amp, rrand(0.3, 0.466) * [1, 0, 0, 0].choose, \pan, -0.8,
							\combdel, 0.5]);
					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.85, {
							Synth("clicking", [\freq, 1, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 1, \amp, 0.0]);});
					});

				});

				if((~gss >= 10) && (~gss < 30), {
					">10 && <30".postln;
					//noisedef
					~freqnoisedef = ~scale[1]/8;
					~lpfnoisedef = 1000;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[1]/2, ~scale[7]/2].choose,
							\pan, [-0.1, 0.1].choose,
							\modf, 4,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [\freq, [~scale[0], ~scale[4], ~scale[7]/2].choose,
							\amp, rrand(0.3, 0.466) * [1, 0, 0].choose, \pan, 0.7]);
					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.85, {
							Synth("clicking", [\freq, 1, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 1, \amp, 0.0]);});
					});
				});

				if((~gss >= 30) && (~gss < 50), {
					">30 && <50".postln;
					//noisedef
					~freqnoisedef = ~scale[2]/8;
					~lpfnoisedef = 1300;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[2], ~scale[6]].choose,
							\pan, [-0.2, 0.2].choose,
							\modf, 8,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [\freq, [~scale[0], ~scale[3], ~scale[4], ~scale[7]/2].choose,
							\amp, rrand(0.5, 0.666) * [1, 0, 0].choose, \pan, -0.6, \combdel, 0.08]);
					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.8, {
							Synth("clicking", [\freq, 2, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 2, \amp, 0.0]);});
					});

				});


				if((~gss >= 50) && (~gss < 70), {
					">50 && <70".postln;
					//noisedef
					~freqnoisedef = ~scale[3]/8;
					~lpfnoisedef = 1800;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[3], ~scale[5]].choose,
							\pan, [-0.3, 0.3].choose,
							\modf, 16,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [\freq, [
							~scale[0]/2, ~scale[2], ~scale[3], ~scale[4]/2, ~scale[7]].choose,
							\amp, rrand(0.8, 0.966) * [1, 0, 0], \pan, 0.5, \combdel, 0.08]);
					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.8, {
							Synth("clicking", [\freq, 3, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 3, \amp, 0.0]);});
					});

				});

				if((~gss >= 70) && (~gss < 90), {
					">70 && <90".postln;
					//noisedef
					~freqnoisedef = ~scale[4]/8;
					~lpfnoisedef = 2000;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[4], ~scale[5]/2].choose,
							\pan, [-0.4, 0.4].choose,
							\modf, 16,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [
							\freq, [
								[~scale[0], ~scale[4]/2],
								[~scale[1], ~scale[5]/2],
								[~scale[2], ~scale[4]/2],
								[~scale[2], ~scale[4]/2],
								[~scale[3], ~scale[7]/2],
							].choose,
							\amp, rrand(0.8, 0.966) * [1, 0], \pan, -0.4, \combdel, 0.08]);
						if(1.0.rand > 0.8, {
							~genspeed * (1/2).wait;
							Synth("noisy", [
								\freq, [~scale[0]/2, ~scale[1]/2, ~scale[2]/2, ~scale[3]/2,
									~scale[4], ~scale[7],
								],
								\amp, rrand(0.8, 0.966) * [1, 0, 0], \pan, -0.4, \combdel, 0.08]);
						})
					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.8, {
							Synth("clicking", [\freq, 4, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 4, \amp, 0.0]);});
					});

				});

				if((~gss >= 90) && (~gss < 110), {
					">70 && <90".postln;
					//noisedef
					~freqnoisedef = ~scale[5]/8;
					~lpfnoisedef = 2200;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[4], ~scale[0]*2].choose,
							\pan, [-0.5, 0.5].choose,
							\modf, 32,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [
							\freq, [
								[~scale[0], ~scale[4]/2],
								[~scale[1], ~scale[5]/2],
								[~scale[2], ~scale[4]/2],
								[~scale[3], ~scale[7]/2],
								[~scale[4], ~scale[6]/2],
								[~scale[7]/2, ~scale[7]]].choose,
							\amp, rrand(0.8, 0.966) * [1, 0], \pan, 0.3, \combdel, 0.08]);
						if(1.0.rand > 0.6, {
							~genspeed * (1/2).wait;
							Synth("noisy", [
								\freq, [
									~scale[0]/2, ~scale[1]/2,
									~scale[2]/2, ~scale[3]/2,
									~scale[4], ~scale[7],
									[~scale[2], ~scale[4]/2],
									[~scale[3], ~scale[7]/2]
								],
								\amp, rrand(0.8, 0.966) * [1, 0, 0], \pan, 0.3, \combdel, 0.08]);
						})
					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.8, {
							Synth("clicking", [\freq, 6, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 6, \amp, 0.0]);});
					});
				});


				if((~gss >= 110) && (~gss < 130), {
					">110 && <130".postln;
					//noisedef
					~freqnoisedef = ~scale[6]/8;
					~lpfnoisedef = 2600;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[7], ~scale[7]/2].choose,
							\pan, [-0.6, 0.6].choose,
							\modf, 48,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [
							\freq, [
								[~scale[0], ~scale[4]/2, ~scale[1]/2, ~scale[3]],
								[~scale[1], ~scale[5]/2, ~scale[5], ~scale[1]],
								[~scale[2], ~scale[4]/2, ~scale[7]/2, ~scale[5]],
								[~scale[3], ~scale[7]/2, ~scale[4]/2, ~scale[3]/2],
								[~scale[4], ~scale[6]/2, ~scale[0], ~scale[7]/2],
								[~scale[5], ~scale[1]/2, ~scale[2], ~scale[5]/2],
								[~scale[7]/2, ~scale[5], ~scale[6], ~scale[4]]].choose,
							\amp, rrand(0.8, 0.966) * [1, 0, 0].choose, \pan, -0.2, \combdel, 0.04]);
						if(1.0.rand > 0.6, {
							~genspeed * (1/2).wait;
							Synth("noisy", [
								\freq, [
									[~scale, ~scale*2]
								],
								\amp, rrand(0.8, 0.966) * [1, 0].choose, \pan, 0.3, \combdel, 0.04]);
						})
					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.8, {
							Synth("clicking", [\freq, 8, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 8, \amp, 0.0]);});
					});
				});


				if((~gss >= 130) && (~gss < 160), {
					">130 && <160".postln;
					//noisedef
					~freqnoisedef = ~scale[7]/8;
					~lpfnoisedef = 3000;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[6], ~scale[7]].choose,
							\pan, [-0.7, 0.7].choose,
							\modf, 80,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [
							\freq, [
								[~scale[0], ~scale[4]/2, ~scale[1]/2, ~scale[3]],
								[~scale[1], ~scale[5]/2, ~scale[5], ~scale[1]],
								[~scale[2], ~scale[4]/2, ~scale[7]/2, ~scale[5]],
								[~scale[3], ~scale[7]/2, ~scale[4]/2, ~scale[3]/2],
								[~scale[4], ~scale[6]/2, ~scale[0], ~scale[7]/2],
								[~scale[5], ~scale[1]/2, ~scale[2], ~scale[5]/2],
								[~scale[7]/2, ~scale[5], ~scale[6], ~scale[4]]].choose,
							\amp, rrand(0.5, 0.666) * [1, 0].choose, \pan, -0.4]);
						if(1.0.rand > 0.5, {
							~genspeed * (1/4).wait;
							Synth("noisy", [
								\freq, [
									[~scale, ~scale*2, ~scale/2]
								],
								\amp, rrand(0.5, 0.666), \pan, 0.1]);
							~genspeed * (1/4).wait;
							Synth("noisy", [
								\freq, [
									[~scale, ~scale*2, ~scale/2]
								],
								\amp, rrand(0.8, 0.966), \pan, 0.1]);
						});

					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.8, {
							Synth("clicking", [\freq, 16, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 16, \amp, 0.0]);});
					});

				});


				if(~gss > 160, {
					">160".postln;
					//noisedef
					~freqnoisedef = ~scale[1]/4;
					~lpfnoisedef = 3200;
					if(~s1onoff == 1, {
						Synth("noisedef", [\freq, ~freqnoisedef, \lpf, ~lpfnoisedef]).set;
					});
					//low
					if(~s2onoff == 1, {
						Synth("low", [\freq, [~scale[4]*2, ~scale[7]*2].choose,
							\pan, [-0.8, 0.8].choose,
							\modf, 160,
						]);
					});
					//noisy
					if(~s3onoff == 1, {
						Synth("noisy", [
							\freq, [
								[~scale[0], ~scale[4]/2, ~scale[1]/2, ~scale[3]],
								[~scale[1], ~scale[5]/2, ~scale[5], ~scale[1]],
								[~scale[2], ~scale[4]/2, ~scale[7]/2, ~scale[5]],
								[~scale[3], ~scale[7]/2, ~scale[4]/2, ~scale[3]/2],
								[~scale[4], ~scale[6]/2, ~scale[0], ~scale[7]/2],
								[~scale[5], ~scale[1]/2, ~scale[2], ~scale[5]/2],
								[~scale[7]/2, ~scale[5], ~scale[6], ~scale[4]]],
							\amp, rrand(0.85, 0.9666), \pan, -0.4]);
						if(1.0.rand > 0.5, {
							~genspeed * (1/4).wait;
							Synth("noisy", [
								\freq, [
									[~scale, ~scale*2, ~scale/2]
								],
								\amp, rrand(0.8, 0.966), \pan, 0.1, \combdel, 0.0001]);
							~genspeed * (1/4).wait;
							Synth("noisy", [
								\freq, [
									[~scale, ~scale*2, ~scale/2]
								],
								\amp, rrand(0.8, 0.966), \pan, 0.1]);
						});

					});
					//clicking
					if(~s4onoff == 1, {
						if(1.0.rand > 0.8, {
							Synth("clicking", [\freq, 32, \amp, 0.5]);
						}, {Synth("clicking", [\freq, 32, \amp, 0.0]);});
					});



				});
				~genspeed.wait;
			)}
			}.fork
		)

	});

},'/gauss/onoff');
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Synths-ON-OFF
//Synth1
OSCdef(\s1onoff, {
    |msg, time, addr, port|
	~s1onoff = msg[1];
	//~s1onoff.postln;
	if(~onoff == 1,{

		if(~s1onoff == 1, {Pdef(\noisedeff).set(\amp, Pwhite(0.33, 0.66)); Synth("noisedef",[\amp, 0.5]).set;
			"Synth 1 ON".postln;
		});

		if(~s1onoff == 0, {Pdef(\noisedeff).set(\amp, 0.0); Synth("noisedef", [\amp, 0.0]).set;
			"Synth 1 OFF".postln;
		});

	});
}, '/gauss/synth1');

//Synth2
OSCdef(\s2onoff, {
    |msg, time, addr, port|
	~s2onoff = msg[1];
	//~s2onoff.postln;
	if(~onoff == 1,{

		if(~s2onoff == 1, {Synth("low",[\amp, 0.5]).set;
			"Synth 2 ON".postln;
		});

		if(~s2onoff == 0, {Synth("low", [\amp, 0.0]).set;
			"Synth 2 OFF".postln;});

	});
}, '/gauss/synth2');

//Synth3
OSCdef(\s3onoff, {
    |msg, time, addr, port|
	~s3onoff = msg[1];
	//~s2onoff.postln;
	if(~onoff == 1,{

		if(~s3onoff == 1, {Synth("noisy",[\amp, 0.5]).set;
			"Synth 3 ON".postln;
		});

		if(~s3onoff == 0, {Synth("noisy", [\amp, 0.0]).set;
			"Synth 3 OFF".postln;});

	});
}, '/gauss/synth3');

//Synth4
OSCdef(\s4onoff, {
    |msg, time, addr, port|
	~s4onoff = msg[1];
	//~s2onoff.postln;
	if(~onoff == 1,{

		if(~s4onoff == 1, {Synth("clicking",[\amp, 0.5]); Synth("clicking",[\amp, 0.5]).set;
			"Synth 4 ON".postln;
		});

		if(~s4onoff == 0, {Synth("clicking", [\amp, 0.0]).set;
			"Synth 4 OFF".postln;});

	});
}, '/gauss/synth4');

//Gaussian Function Receiver
OSCdef(\receiver, {
    |msg, time, addr, port|
	if(~onoff == 1, {
		~receiver = msg[1].round(0.00001).linlin(0.0, 1.0, 0.0, 100);
		["Receiver:", ~receiver].postln;
	});
},'/gauss/receiver');

//Gaussian Function Standard deviation
OSCdef(\stdevi, {
    |msg, time, addr, port|
	if(~onoff == 1, {
		~stdevi = msg[1].round(0.00001).linlin(0.0, 1.0, 1, 100);
		["Standard Deviation:", ~stdevi].postln;
	});
},'/gauss/stdeviation');

//Generation speed
OSCdef(\genspeed, {
    |msg, time, addr, port|
	if(~onoff == 1, {
		~genspeed = msg[1].linlin(0.0, 1.0, 1, 6.66);
		["Generated value frequecny:", ~genspeed].postln;
	});
},'/gauss/genspeed');

);

p = [
	//Pdefs - register-----------------------
	//NoiseDef-Initial
	Pdef(\noisedeff,
		Pbind(
			\instrument,
			\noisedef,
			\dur, Pwhite(6, 12),
			\amp, Pwhite(0.33, 0.66),
		)
	),

];

//if right after SynthDef "synth not found" error
x = Synth("low", [\amp, 0.0]);
//:




