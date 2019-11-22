//Programs that are generally useful for population control and non-harmful suppression.

/datum/nanite_program/sleepy
	name = "Sleep Induction"
	desc = "The nanites cause rapid narcolepsy when triggered."
	can_trigger = TRUE
	trigger_cost = 15
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/sleepy/on_trigger(comm_message)
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

/datum/nanite_program/shocking
	name = "Electric Shock"
	desc = "The nanites shock the host when triggered. Destroys a large amount of nanites!"
	can_trigger = TRUE
	trigger_cost = 10
	trigger_cooldown = 300
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/shocking/on_trigger(comm_message)
	host_mob.electrocute_act(rand(5,10), "shock nanites", 1, SHOCK_NOGLOVES)

/datum/nanite_program/stun
	name = "Neural Shock"
	desc = "The nanites pulse the host's nerves when triggered, inapacitating them for a short period."
	can_trigger = TRUE
	trigger_cost = 4
	trigger_cooldown = 300
	rogue_types = list(/datum/nanite_program/shocking, /datum/nanite_program/nerve_decay)

/datum/nanite_program/stun/on_trigger(comm_message)
	playsound(host_mob, "sparks", 75, TRUE, -1)
	host_mob.Paralyze(80)

/datum/nanite_program/pacifying
	name = "Pacification"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/pacifying/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_PACIFISM, "nanites")

/datum/nanite_program/pacifying/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_PACIFISM, "nanites")

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
	ADD_TRAIT(host_mob, TRAIT_MUTE, "nanites")

/datum/nanite_program/mute/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_MUTE, "nanites")

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

//Can receive transmissions from a nanite communication remote for customized messages
/datum/nanite_program/comm
	can_trigger = TRUE
	var/comm_code = 0
	var/comm_message = ""

/datum/nanite_program/comm/proc/receive_comm_signal(signal_comm_code, comm_message, comm_source)
	if(!activated || !comm_code)
		return
	if(signal_comm_code == comm_code)
		host_mob.investigate_log("'s [name] nanite program was messaged by [comm_source] with comm code [signal_comm_code] and message '[comm_message]'.", INVESTIGATE_NANITES)
		trigger(comm_message)

/datum/nanite_program/comm/speech
	name = "Forced Speech"
	desc = "The nanites force the host to say a pre-programmed sentence when triggered."
	unique = FALSE
	trigger_cost = 3
	trigger_cooldown = 20
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

	extra_settings = list(NES_SENTENCE,NES_COMM_CODE)
	var/sentence = ""

/datum/nanite_program/comm/speech/set_extra_setting(user, setting)
	if(setting == NES_SENTENCE)
		var/new_sentence = stripped_input(user, "Choose the sentence that the host will be forced to say.", NES_SENTENCE, sentence, MAX_MESSAGE_LEN)
		if(!new_sentence)
			return
		if(copytext(new_sentence, 1, 2) == "*") //emotes are abusable, like surrender
			return
		sentence = new_sentence
	if(setting == NES_COMM_CODE)
		var/new_code = input(user, "Set the communication code (1-9999) or set to 0 to disable external signals.", name, null) as null|num
		if(isnull(new_code))
			return
		comm_code = CLAMP(round(new_code, 1), 0, 9999)

/datum/nanite_program/comm/speech/get_extra_setting(setting)
	if(setting == NES_SENTENCE)
		return sentence
	if(setting == NES_COMM_CODE)
		return comm_code

/datum/nanite_program/comm/speech/copy_extra_settings_to(datum/nanite_program/comm/speech/target)
	target.sentence = sentence
	target.comm_code = comm_code

/datum/nanite_program/comm/speech/on_trigger(comm_message)
	var/sent_message = comm_message
	if(!comm_message)
		sent_message = sentence
	if(host_mob.stat == DEAD)
		return
	to_chat(host_mob, "<span class='warning'>You feel compelled to speak...</span>")
	host_mob.say(sent_message, forced = "nanite speech")

/datum/nanite_program/comm/voice
	name = "Skull Echo"
	desc = "The nanites echo a synthesized message inside the host's skull."
	unique = FALSE
	trigger_cost = 1
	trigger_cooldown = 20
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

	extra_settings = list(NES_MESSAGE,NES_COMM_CODE)
	var/message = ""

/datum/nanite_program/comm/voice/set_extra_setting(user, setting)
	if(setting == NES_MESSAGE)
		var/new_message = stripped_input(user, "Choose the message sent to the host.", NES_MESSAGE, message, MAX_MESSAGE_LEN)
		if(!new_message)
			return
		message = new_message
	if(setting == NES_COMM_CODE)
		var/new_code = input(user, "Set the communication code (1-9999) or set to 0 to disable external signals.", name, null) as null|num
		if(isnull(new_code))
			return
		comm_code = CLAMP(round(new_code, 1), 0, 9999)

/datum/nanite_program/comm/voice/get_extra_setting(setting)
	if(setting == NES_MESSAGE)
		return message
	if(setting == NES_COMM_CODE)
		return comm_code

/datum/nanite_program/comm/voice/copy_extra_settings_to(datum/nanite_program/comm/voice/target)
	target.message = message
	target.comm_code = comm_code

/datum/nanite_program/comm/voice/on_trigger(comm_message)
	var/sent_message = comm_message
	if(!comm_message)
		sent_message = message
	if(host_mob.stat == DEAD)
		return
	to_chat(host_mob, "<i>You hear a strange, robotic voice in your head...</i> \"<span class='robot'>[sent_message]</span>\"")

/datum/nanite_program/comm/hallucination
	name = "Hallucination"
	desc = "The nanites make the host hallucinate something when triggered."
	trigger_cost = 4
	trigger_cooldown = 80
	unique = FALSE
	rogue_types = list(/datum/nanite_program/brain_misfire)
	extra_settings = list(NES_HALLUCINATION_TYPE, NES_COMM_CODE)
	var/hal_type
	var/hal_details

/datum/nanite_program/comm/hallucination/on_trigger(comm_message)
	if(comm_message && (hal_type != NES_MESSAGE)) //Triggered via comm remote, but not set to a message hallucination
		return
	var/sent_message = comm_message //Comm remotes can send custom hallucination messages for the chat hallucination
	if(!sent_message)
		sent_message = hal_details

	if(!iscarbon(host_mob))
		return
	var/mob/living/carbon/C = host_mob
	if(!hal_type)
		C.hallucination += 15
	else
		switch(hal_type)
			if(NES_MESSAGE)
				new /datum/hallucination/chat(C, TRUE, null, sent_message)
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

/datum/nanite_program/comm/hallucination/set_extra_setting(user, setting)
	if(setting == NES_COMM_CODE)
		var/new_code = input(user, "(Only for Message) Set the communication code (1-9999) or set to 0 to disable external signals.", name, null) as null|num
		if(isnull(new_code))
			return
		comm_code = CLAMP(round(new_code, 1), 0, 9999)

	if(setting == NES_HALLUCINATION_TYPE)
		var/list/possible_hallucinations = list("Random",NES_MESSAGE,"Battle","Sound","Weird Sound","Station Message","Health","Alert","Fire","Shock","Plasma Flood")
		var/hal_type_choice = input("Choose the hallucination type", name) as null|anything in sortList(possible_hallucinations)
		if(!hal_type_choice)
			return
		switch(hal_type_choice)
			if("Random")
				hal_type = null
				hal_details = null
			if(NES_MESSAGE)
				hal_type = NES_MESSAGE
				var/hal_chat = stripped_input(user, "Choose the message the host will hear, or leave empty for random messages.", NES_MESSAGE, hal_details, MAX_MESSAGE_LEN)
				if(hal_chat)
					hal_details = hal_chat
			if("Battle")
				hal_type = "Battle"
				var/sound_list = list("random","laser","disabler","esword","gun","stunprod","harmbaton","bomb")
				var/hal_choice = input("Choose the hallucination battle type", name) as null|anything in sortList(sound_list)
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Sound")
				hal_type = "Sound"
				var/sound_list = list("random","airlock","airlock pry","console","explosion","far explosion","mech","glass","alarm","beepsky","mech","wall decon","door hack")
				var/hal_choice = input("Choose the hallucination sound", name) as null|anything in sortList(sound_list)
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Weird Sound")
				hal_type = "Weird Sound"
				var/sound_list = list("random","phone","hallelujah","highlander","laughter","hyperspace","game over","creepy","tesla")
				var/hal_choice = input("Choose the hallucination sound", name) as null|anything in sortList(sound_list)
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Station Message")
				hal_type = "Station Message"
				var/msg_list = list("random","ratvar","shuttle dock","blob alert","malf ai","meteors","supermatter")
				var/hal_choice = input("Choose the hallucination station message", name) as null|anything in sortList(msg_list)
				if(!hal_choice || hal_choice == "random")
					hal_details = null
				else
					hal_details = hal_choice
			if("Health")
				hal_type = "Health"
				var/health_list = list("random","critical","dead","healthy")
				var/hal_choice = input("Choose the health status", name) as null|anything in sortList(health_list)
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
				var/hal_choice = input("Choose the alert", name) as null|anything in sortList(alert_list)
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

/datum/nanite_program/comm/hallucination/get_extra_setting(setting)
	if(setting == NES_HALLUCINATION_TYPE)
		if(!hal_type)
			return "Random"
		else
			return hal_type
	if(setting == NES_COMM_CODE)
		return comm_code

/datum/nanite_program/comm/hallucination/copy_extra_settings_to(datum/nanite_program/comm/hallucination/target)
	target.hal_type = hal_type
	target.hal_details = hal_details
	target.comm_code = comm_code

/datum/nanite_program/good_mood
	name = "Happiness Enhancer"
	desc = "The nanites synthesize serotonin inside the host's brain, creating an artificial sense of happiness."
	use_rate = 0.1
	rogue_types = list(/datum/nanite_program/brain_decay)
	extra_settings = list(NES_MOOD_MESSAGE)
	var/message = "HAPPINESS ENHANCEMENT"

/datum/nanite_program/good_mood/set_extra_setting(user, setting)
	if(setting == NES_MOOD_MESSAGE)
		var/new_message = stripped_input(user, "Choose the message visible on the mood effect.", NES_MESSAGE, message, MAX_NAME_LEN)
		if(!new_message)
			return
		message = new_message

/datum/nanite_program/good_mood/get_extra_setting(setting)
	if(setting == NES_MOOD_MESSAGE)
		return message

/datum/nanite_program/good_mood/copy_extra_settings_to(datum/nanite_program/good_mood/target)
	target.message = message

/datum/nanite_program/good_mood/enable_passive_effect()
	. = ..()
	SEND_SIGNAL(host_mob, COMSIG_ADD_MOOD_EVENT, "nanite_happy", /datum/mood_event/nanite_happiness, message)

/datum/nanite_program/good_mood/disable_passive_effect()
	. = ..()
	SEND_SIGNAL(host_mob, COMSIG_CLEAR_MOOD_EVENT, "nanite_happy")

/datum/nanite_program/bad_mood
	name = "Happiness Suppressor"
	desc = "The nanites suppress the production of serotonin inside the host's brain, creating an artificial state of depression."
	use_rate = 0.1
	rogue_types = list(/datum/nanite_program/brain_decay)
	extra_settings = list(NES_MOOD_MESSAGE)
	var/message = "HAPPINESS SUPPRESSION"

/datum/nanite_program/bad_mood/set_extra_setting(user, setting)
	if(setting == NES_MOOD_MESSAGE)
		var/new_message = stripped_input(user, "Choose the message visible on the mood effect.", NES_MESSAGE, message, MAX_NAME_LEN)
		if(!new_message)
			return
		message = new_message

/datum/nanite_program/bad_mood/get_extra_setting(setting)
	if(setting == NES_MOOD_MESSAGE)
		return message

/datum/nanite_program/bad_mood/copy_extra_settings_to(datum/nanite_program/bad_mood/target)
	target.message = message

/datum/nanite_program/bad_mood/enable_passive_effect()
	. = ..()
	SEND_SIGNAL(host_mob, COMSIG_ADD_MOOD_EVENT, "nanite_sadness", /datum/mood_event/nanite_sadness, message)

/datum/nanite_program/bad_mood/disable_passive_effect()
	. = ..()
	SEND_SIGNAL(host_mob, COMSIG_CLEAR_MOOD_EVENT, "nanite_sadness")
