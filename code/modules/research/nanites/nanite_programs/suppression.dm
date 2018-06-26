//Programs that are generally useful for population control and non-harmful suppression.

/datum/nanite_program/triggered/sleepy
	name = "Sleep Induction"
	desc = "The nanites cause rapid narcolepsy when triggered."
	trigger_cost = 15
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/triggered/sleepy/trigger()
	if(!..())
		return
	to_chat(host_mob, "<span class='warning'>You start to feel very sleepy...</span>")
	host_mob.drowsyness += 20
	addtimer(CALLBACK(host_mob, /mob/living.proc/Sleeping, 200), rand(60,200))
	
/datum/nanite_program/paralyzing
	name = "Paralysis"
	desc = "The nanites actively suppress nervous pulses, effectively paralyzing the host."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/paralyzing/active_effect()
	host_mob.Knockdown(30)

/datum/nanite_program/triggered/shocking
	name = "Electric Shock"
	desc = "The nanites shock the host when triggered. Destroys a large amount of nanites!"
	trigger_cost = 10
	trigger_cooldown = 300
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/shocking/trigger()
	if(!..())
		return
	host_mob.electrocute_act(rand(5,10), "shock nanites", TRUE, TRUE)

/datum/nanite_program/triggered/stun
	name = "Neural Shock"
	desc = "The nanites pulse the host's nerves when triggered, inapacitating them for a short period."
	trigger_cost = 4
	trigger_cooldown = 300
	rogue_types = list(/datum/nanite_program/triggered/shocking, /datum/nanite_program/nerve_decay)

/datum/nanite_program/triggered/stun/trigger()
	if(!..())
		return
	playsound(host_mob, "sparks", 75, 1, -1)
	host_mob.Knockdown(80)	
	
/datum/nanite_program/pacifying
	name = "Pacification"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/pacifying/enable_passive_effect()
	..()
	host_mob.add_trait(TRAIT_PACIFISM, "nanites")

/datum/nanite_program/pacifying/disable_passive_effect()
	..()
	host_mob.remove_trait(TRAIT_PACIFISM, "nanites")
	
/datum/nanite_program/blinding
	name = "Blindness"
	desc = "The nanites suppress the host's ocular nerves, blinding them while they're active."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/blinding/enable_passive_effect()
	..()
	host_mob.add_trait(TRAIT_BLIND, "nanites")

/datum/nanite_program/blinding/disable_passive_effect()
	..()
	host_mob.remove_trait(TRAIT_BLIND, "nanites")
	
/datum/nanite_program/mute
	name = "Mute"
	desc = "The nanites suppress the host's speech, making them mute while they're active."
	use_rate = 0.75
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mute/enable_passive_effect()
	..()
	host_mob.add_trait(TRAIT_MUTE, "nanites")

/datum/nanite_program/mute/disable_passive_effect()
	..()
	host_mob.remove_trait(TRAIT_MUTE, "nanites")

/datum/nanite_program/fake_death
	name = "Death Simulation"
	desc = "The nanites induce a death-like coma into the host, able to fool most medical scans."
	use_rate = 3.5
	rogue_types = list(/datum/nanite_program/nerve_decay, /datum/nanite_program/necrotic, /datum/nanite_program/brain_decay)

/datum/nanite_program/fake_death/enable_passive_effect()
	..()
	host_mob.emote("deathgasp")
	host_mob.fakedeath("nanites")

/datum/nanite_program/fake_death/disable_passive_effect()
	..()
	host_mob.cure_fakedeath("nanites")

/datum/nanite_program/triggered/speech
	name = "Forced Speech"
	desc = "The nanites force the host to say a pre-programmed sentence when triggered."
	unique = FALSE
	trigger_cost = 3
	trigger_cooldown = 20
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)
	
	extra_settings = list("Sentence")
	var/sentence = ""
	
/datum/nanite_program/triggered/speech/set_extra_setting(user, setting)
	if(setting == "Sentence")
		var/new_sentence = stripped_input(user, "Choose the sentence that the host will be forced to say.", "Sentence", sentence, MAX_MESSAGE_LEN)
		if(!new_sentence)
			return
		sentence = new_sentence
		
/datum/nanite_program/triggered/speech/get_extra_setting(setting)
	if(setting == "Sentence")
		return sentence

/datum/nanite_program/triggered/speech/trigger()
	if(!..())
		return
	to_chat(host_mob, "<span class='warning'>You feel compelled to speak...</span>")
	host_mob.say(sentence)