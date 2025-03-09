// stupid hacky solution to send something over command comms
/obj/item/radio/one_shot_broadcaster
	name = "NLP-NAV-TC"
	desc = "You should never ever see this."
	freqlock = RADIO_FREQENCY_LOCKED
	invisibility = 30
	var/custom_say_mod = "says"

/obj/item/radio/one_shot_broadcaster/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_COMMAND)
	set_broadcasting(TRUE)

/obj/item/radio/one_shot_broadcaster/New(loc, our_name, say_mod, frequency, thing_to_say)
	. = ..()
	if (our_name)
		name = our_name
	if (say_mod)
		custom_say_mod = say_mod
	if (frequency)
		set_frequency(frequency)
	if (thing_to_say)
		src.say(thing_to_say)

	// my final message, goodbye
	qdel(src)

/obj/item/radio/one_shot_broadcaster/get_default_say_verb()
	return custom_say_mod || "says"
