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
	desc = "The nanites force muscle contraction, effectively paralyzing the host."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/paralyzing/active_effect()
	host_mob.Stun(40)

/datum/nanite_program/paralyzing/enable_passive_effect()
	. = ..()
	to_chat(host_mob, "<span class='warning'>Your muscles seize! You can't move!</span>")

/datum/nanite_program/paralyzing/disable_passive_effect()
	. = ..()
	to_chat(host_mob, "<span class='notice'>Your muscles relax, and you can move again.</span>")

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
	host_mob.Paralyze(80)

/datum/nanite_program/pacifying
	name = "Pacification"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/pacifying/enable_passive_effect()
	. = ..()
	host_mob.add_trait(TRAIT_PACIFISM, "nanites")

/datum/nanite_program/pacifying/disable_passive_effect()
	. = ..()
	host_mob.remove_trait(TRAIT_PACIFISM, "nanites")

/datum/nanite_program/blinding
	name = "Blindness"
	desc = "The nanites suppress the host's ocular nerves, blinding them while they're active."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/blinding/enable_passive_effect()
	. = ..()
	host_mob.become_blind("nanites")

/datum/nanite_program/blinding/disable_passive_effect()
	. = ..()
	host_mob.cure_blind("nanites")

/datum/nanite_program/mute
	name = "Mute"
	desc = "The nanites suppress the host's speech, making them mute while they're active."
	use_rate = 0.75
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mute/enable_passive_effect()
	. = ..()
	host_mob.add_trait(TRAIT_MUTE, "nanites")

/datum/nanite_program/mute/disable_passive_effect()
	. = ..()
	host_mob.remove_trait(TRAIT_MUTE, "nanites")

/datum/nanite_program/fake_death
	name = "Death Simulation"
	desc = "The nanites induce a death-like coma into the host, able to fool most medical scans."
	use_rate = 3.5
	rogue_types = list(/datum/nanite_program/nerve_decay, /datum/nanite_program/necrotic, /datum/nanite_program/brain_decay)

/datum/nanite_program/fake_death/enable_passive_effect()
	. = ..()
	host_mob.emote("deathgasp")
	host_mob.fakedeath("nanites")

/datum/nanite_program/fake_death/disable_passive_effect()
	. = ..()
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
		if(copytext(new_sentence, 1, 2) == "*") //emotes are abusable, like surrender
			return
		sentence = new_sentence

/datum/nanite_program/triggered/speech/get_extra_setting(setting)
	if(setting == "Sentence")
		return sentence

/datum/nanite_program/triggered/speech/copy_extra_settings_to(datum/nanite_program/triggered/speech/target)
	target.sentence = sentence

/datum/nanite_program/triggered/speech/trigger()
	if(!..())
		return
	if(host_mob.stat == DEAD)
		return
	to_chat(host_mob, "<span class='warning'>You feel compelled to speak...</span>")
	host_mob.say(sentence, forced = "nanite speech")

/datum/nanite_program/triggered/voice
	name = "Skull Echo"
	desc = "The nanites echo a synthesized message inside the host's skull."
	unique = FALSE
	trigger_cost = 1
	trigger_cooldown = 20
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

	extra_settings = list("Message")
	var/message = ""

/datum/nanite_program/triggered/voice/set_extra_setting(user, setting)
	if(setting == "Message")
		var/new_message = stripped_input(user, "Choose the message sent to the host.", "Message", message, MAX_MESSAGE_LEN)
		if(!new_message)
			return
		message = new_message

/datum/nanite_program/triggered/voice/get_extra_setting(setting)
	if(setting == "Message")
		return message

/datum/nanite_program/triggered/voice/copy_extra_settings_to(datum/nanite_program/triggered/voice/target)
	target.message = message

/datum/nanite_program/triggered/voice/trigger()
	if(!..())
		return
	if(host_mob.stat == DEAD)
		return
	to_chat(host_mob, "<i>You hear a strange, robotic voice in your head...</i> \"<span class='robot'>[message]</span>\"")

/datum/nanite_program/triggered/hallucination
	name = "Hallucination"
	desc = "The nanites make the host hallucinate something when triggered."
	trigger_cost = 4
	trigger_cooldown = 80
	unique = FALSE
	rogue_types = list(/datum/nanite_program/brain_misfire)
	extra_settings = list("Hallucination Type")
	var/hal_type
	var/hal_details

/datum/nanite_program/triggered/hallucination/trigger()
	if(!..())
		return
	if(!iscarbon(host_mob))
		return
	var/mob/living/carbon/C = host_mob
	if(!hal_type)
		C.hallucination += 15
	else
		switch(hal_type)
			if("Message")
				new /datum/hallucination/chat(C, TRUE, null, hal_details)
			if("Battle")
				new /datum/hallucination/battle(C, TRUE, hal_details)
			if("Sound")
				new /datum/hallucination/sounds(C, TRUE, hal_details)
			if("Weird Sound")
				new /datum/hallucination/weird_sounds(C, TRUE, hal_details)
			if("Station Message")
				new /datum/hallucination/stationmessage(C, TRUE, hal_details)
			if("Health")
				new /datum/hallucination/hudscrew(C, TRUE, hal_details)
			if("Alert")
				new /datum/hallucination/fake_alert(C, TRUE, hal_details)
			if("Fire")
				new /datum/hallucination/fire(C, TRUE)
			if("Shock")
				new /datum/hallucination/shock(C, TRUE)
			if("Plasma Flood")
				new /datum/hallucination/fake_flood(C, TRUE)

/datum/nanite_program/triggered/hallucination/set_extra_setting(user, setting)
	if(setting == "Hallucination Type")
		var/list/possible_hallucinations = list("Random","Message","Battle","Sound","Weird Sound","Station Message","Health","Alert","Fire","Shock","Plasma Flood")
		var/hal_type_choice = input("Choose the hallucination type", name) as null|anything in possible_hallucinations
		if(!hal_type_choice)
			return
		switch(hal_type_choice)
			if("Random")
				hal_type = null
				hal_details = null
			if("Message")
				hal_type = "Message"
				var/hal_chat = stripped_input(user, "Choose the message the host will hear, or leave empty for random messages.", "Message", hal_details, MAX_MESSAGE_LEN)
				if(hal_chat)
					hal_details = hal_chat
			if("Battle")
				hal_type = "Battle"
				var/sound_list = list("random","laser","disabler","esword","gun","stunprod","harmbaton","bomb")
				var/hal_choice = input("Choose the hallucination battle type", name) as null|anything in sound_list
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Sound")
				hal_type = "Sound"
				var/sound_list = list("random","airlock","airlock pry","console","explosion","far explosion","mech","glass","alarm","beepsky","mech","wall decon","door hack")
				var/hal_choice = input("Choose the hallucination sound", name) as null|anything in sound_list
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Weird Sound")
				hal_type = "Weird Sound"
				var/sound_list = list("random","phone","hallelujah","highlander","laughter","hyperspace","game over","creepy","tesla")
				var/hal_choice = input("Choose the hallucination sound", name) as null|anything in sound_list
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Station Message")
				hal_type = "Station Message"
				var/msg_list = list("random","ratvar","shuttle dock","blob alert","malf ai","meteors","supermatter")
				var/hal_choice = input("Choose the hallucination station message", name) as null|anything in msg_list
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Health")
				hal_type = "Health"
				var/health_list = list("random","critical","dead","healthy")
				var/hal_choice = input("Choose the health status", name) as null|anything in health_list
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					switch(hal_choice)
						if("critical")
							hal_details = SCREWYHUD_CRIT
						if("dead")
							hal_details = SCREWYHUD_DEAD
						if("healthy")
							hal_details = SCREWYHUD_HEALTHY
			if("Alert")
				hal_type = "Alert"
				var/alert_list = list("random","not_enough_oxy","not_enough_tox","not_enough_co2","too_much_oxy","too_much_co2","too_much_tox","newlaw","nutrition","charge","gravity","fire","locked","hacked","temphot","tempcold","pressure")
				var/hal_choice = input("Choose the alert", name) as null|anything in alert_list
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Fire")
				hal_type = "Fire"
			if("Shock")
				hal_type = "Shock"
			if("Plasma Flood")
				hal_type = "Plasma Flood"

/datum/nanite_program/triggered/hallucination/get_extra_setting(setting)
	if(setting == "Hallucination Type")
		if(!hal_type)
			return "Random"
		else
			return hal_type

/datum/nanite_program/triggered/hallucination/copy_extra_settings_to(datum/nanite_program/triggered/hallucination/target)
	target.hal_type = hal_type
	target.hal_details = hal_details