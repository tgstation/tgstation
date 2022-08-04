/datum/instrument/fun
	name = "Generic Fun Instrument"
	category = "Fun"
	abstract_type = /datum/instrument/fun

/datum/instrument/fun/honk
	name = "!!HONK!!"
	id = "honk"
	real_samples = list("74"='sound/items/bikehorn.ogg') // Cluwne Heaven

/datum/instrument/fun/signal
	name = "Ping"
	id = "ping"
	real_samples = list("79"='sound/machines/ping.ogg')

/datum/instrument/fun/chime
	name = "Chime"
	id = "chime"
	real_samples = list("79"='sound/machines/chime.ogg')

/datum/instrument/fun/meowsynth
	name = "MeowSynth"
	id = "meowsynth"
	real_samples = list("24"='sound/runtime/instruments/synthesis_samples/meowsynth/c1.ogg',
				   "36"='sound/runtime/instruments/synthesis_samples/meowsynth/c2.ogg',
				   "48"='sound/runtime/instruments/synthesis_samples/meowsynth/c3.ogg',
				   "60"='sound/runtime/instruments/synthesis_samples/meowsynth/c4.ogg',
				   "72"='sound/runtime/instruments/synthesis_samples/meowsynth/c5.ogg')

/datum/instrument/fun/spaceman
	name = "Spaceman"
	id = "spaceman"
	real_samples = list("24"='sound/runtime/instruments/synthesis_samples/spaceman/c1.ogg',
				   "36"='sound/runtime/instruments/synthesis_samples/spaceman/c2.ogg',
				   "48"='sound/runtime/instruments/synthesis_samples/spaceman/c3.ogg',
				   "60"='sound/runtime/instruments/synthesis_samples/spaceman/c4.ogg')

/datum/instrument/fun/sans
	name = "Sans"
	id = "sans"
	real_samples = list("40"='sound/runtime/instruments/synthesis_samples/sans/e2.ogg')

/datum/instrument/fun/mothscream
	name = "Moth Scream"
	id = "mothscream"
	real_samples = list("60"='sound/voice/moth/scream_moth.ogg')
	admin_only = TRUE
