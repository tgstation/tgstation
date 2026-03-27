/mob/living/basic/flock
	abstract_type = /mob/living/basic/flock
	name = "Flock Error"
	desc = "oh no this shouldn't be happening CALL CIRR IMMEDIATELY"
	icon = 'troutstation/icons/mob/simple/flock.dmi'
	gender = NEUTER
	mob_biotypes = MOB_SPECIAL // MOB_ROBOTIC means "does it have wires" and they don't, not in the same way a robot does
	faction = list(FACTION_FLOCK)
	speed = 1
	// teaaalllll
	lighting_cutoff_red = 15
	lighting_cutoff_green = 30
	lighting_cutoff_blue = 30
	unsuitable_atmos_damage = 0 // they don't need air!
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	minimum_survivable_temperature = 150
	maximum_survivable_temperature = 450
	fire_stack_decay_rate = -5 // todo: self-extinguish behaviour for all flock mobs
	pressure_resistance = 50
	damage_coeff = list(BRUTE = 1.1, BURN = 0.9, TOX = 0, STAMINA = 0.8, OXY = 0)
	unique_name = TRUE
	initial_language_holder = /datum/language_holder/flock
	death_message = "cracks and splinters, falling over."
	speech_span = SPAN_FLOCK
	bubble_icon = "flock"

	speak_emote = list("chimes", "intones", "hums", "chirps", "peeps")
	verb_ask = "enquires"
	verb_exclaim = "cries"
	verb_whisper = "softly warbles"
	verb_sing = "birdsings"
	verb_yell = "squawks"
	response_help_continuous = "pats"
	response_help_simple = "pat"
	response_disarm_continuous = "shoves"
	response_disarm_simple = "shove"
	response_harm_continuous = "smacks"
	response_harm_simple = "smack"

	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	friendly_verb_continuous = "preens"
	friendly_verb_simple = "preen"
	melee_attack_cooldown = CLICK_CD_MELEE

	var/lord_name = "???" // TODO: replace this


/mob/living/basic/flock/Initialize(mapload)
	. = ..()
	lord_name = generate_flock_name("CV.CV")


/// Generate a name with a pattern using C for consonant and V for vowel
/mob/living/basic/flock/proc/generate_flock_name(pattern = "CV.CV.CV")
	var/new_name = ""
	// use old procs instead of _char procs because we're only using basic latin characters
	var/pattern_len = length(pattern)
	for(var/i in 1 to pattern_len)
		var/char = copytext(pattern, i, i+1)
		switch(char)
			if("C")
				char = pick(CONSONANTS)
			if("V")
				char = pick(VOWELS)
		if(i == 1)
			char = uppertext(char)
		new_name += char
	return new_name

/mob/living/basic/flock/proc/get_scream_sound()
	return pick(
		'troutstation/sound/effects/flock/flock_scream1.ogg',
		'troutstation/sound/effects/flock/flock_scream2.ogg',
	)

/mob/living/basic/flock/proc/get_lord_name()
	return lord_name // todo: better than this

// really this should be much higher up
/mob/living/basic/flock/proc/toggle_internals(obj/item/tank)
	return FALSE
