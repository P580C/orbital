// CroneEngine_1505Drums
// basic drum sounds

Engine_1505Drums : CroneEngine {
	var subOSC = 60;
	var adsrAttack = 1;
	var adsrLength = 1;
	var clickAmount = 1500;


	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		SynthDef('1505KickDrum', {

			var subosc, subenv, suboutput, clickosc, clickenv, clickoutput;

			subosc = {SinOsc.ar(60)};
			subenv = {Line.ar(adsrAttack, 5, adsrLength, doneAction: 2)};

			clickosc = {LPF.ar(WhiteNoise.ar(1),clickAmount)};
			clickenv = {Line.ar(1, 0, 0.02)};

			suboutput = (subosc * subenv);
			clickoutput = (clickosc * clickenv);

			Out.ar(0,
				Pan2.ar(suboutput + clickoutput, 0)
			)
		}).add;
	}

	this.addCommand("subOSC", "f", { arg msg;
		subOSC = msg[1];
	});

	this.addCommand("adsrAttack", "f", { arg msg;
		adsrAttack = msg[1];
	});

	this.addCommand("adsrLength", "f", { arg msg;
		adsrLength = msg[1];
	});

	this.addCommand("clickAmount", "f", { arg msg;
		clickAmount = msg[1];
	});
}