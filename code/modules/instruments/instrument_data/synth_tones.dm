/datum/instrument/tones
	name = "Ideal tone"
	category = "Tones"
	abstract_type = /datum/instrument/tones

/datum/instrument/tones/square_wave
	name = "Ideal square wave"
	id = "square"
	real_samples = list("81"='sound/runtime/instruments/synthesis_samples/tones/Square.ogg')

/datum/instrument/tones/sine_wave
	name = "Ideal sine wave"
	id = "sine"
	real_samples = list("81"='sound/runtime/instruments/synthesis_samples/tones/Sine.ogg')

/datum/instrument/tones/saw_wave
	name = "Ideal sawtooth wave"
	id = "saw"
	real_samples = list("81"='sound/runtime/instruments/synthesis_samples/tones/Sawtooth.ogg')
