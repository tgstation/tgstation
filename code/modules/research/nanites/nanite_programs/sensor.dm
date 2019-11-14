/datum/nanite_program/sensor
	name = "Sensor Nanites"
	desc = "These nanites send a signal code when a certain condition is met."
	unique = FALSE
	extra_settings = list(NES_SENT_CODE)
	var/can_rule = FALSE
	var/sent_code = 0

/datum/nanite_program/sensor/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)

/datum/nanite_program/sensor/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code

/datum/nanite_program/sensor/copy_extra_settings_to(datum/nanite_program/sensor/target)
	target.sent_code = sent_code

/datum/nanite_program/sensor/proc/check_event()
	return FALSE

/datum/nanite_program/sensor/proc/send_code()
	if(activated)
		SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, sent_code, "a [name] program")

/datum/nanite_program/sensor/active_effect()
	if(sent_code && check_event())
		send_code()

/datum/nanite_program/sensor/proc/make_rule(datum/nanite_program/target)
	return

/datum/nanite_program/sensor/repeat
	name = "Signal Repeater"
	desc = "When triggered, sends another signal to the nanites, optionally with a delay."
	can_trigger = TRUE
	trigger_cost = 0
	trigger_cooldown = 10
	extra_settings = list(NES_SENT_CODE,NES_DELAY)
	var/spent = FALSE
	var/delay = 0

/datum/nanite_program/sensor/repeat/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_DELAY)
		var/new_delay = input(user, "Set the delay in seconds:", name, null) as null|num
		if(isnull(new_delay))
			return
		delay = (CLAMP(round(new_delay, 1), 0, 3600)) * 10 //max 1 hour

/datum/nanite_program/sensor/repeat/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_DELAY)
		return "[delay/10] seconds"

/datum/nanite_program/sensor/repeat/copy_extra_settings_to(datum/nanite_program/sensor/repeat/target)
	target.sent_code = sent_code
	target.delay = delay

/datum/nanite_program/sensor/repeat/trigger()
	if(!..())
		return
	addtimer(CALLBACK(src, .proc/send_code), delay)

/datum/nanite_program/sensor/relay_repeat
	name = "Relay Signal Repeater"
	desc = "When triggered, sends another signal to a relay channel, optionally with a delay."
	can_trigger = TRUE
	trigger_cost = 0
	trigger_cooldown = 10
	extra_settings = list(NES_SENT_CODE,NES_RELAY_CHANNEL,NES_DELAY)
	var/spent = FALSE
	var/delay = 0
	var/relay_channel = 0

/datum/nanite_program/sensor/relay_repeat/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_RELAY_CHANNEL)
		var/new_channel = input(user, "Set the relay channel (1-9999):", name, null) as null|num
		if(isnull(new_channel))
			return
		relay_channel = CLAMP(round(new_channel, 1), 1, 9999)
	if(setting == NES_DELAY)
		var/new_delay = input(user, "Set the delay in seconds:", name, null) as null|num
		if(isnull(new_delay))
			return
		delay = (CLAMP(round(new_delay, 1), 0, 3600)) * 10 //max 1 hour

/datum/nanite_program/sensor/relay_repeat/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_RELAY_CHANNEL)
		return relay_channel
	if(setting == NES_DELAY)
		return "[delay/10] seconds"

/datum/nanite_program/sensor/relay_repeat/copy_extra_settings_to(datum/nanite_program/sensor/relay_repeat/target)
	target.sent_code = sent_code
	target.delay = delay
	target.relay_channel = relay_channel

/datum/nanite_program/sensor/relay_repeat/trigger()
	if(!..())
		return
	addtimer(CALLBACK(src, .proc/send_code), delay)

/datum/nanite_program/sensor/relay_repeat/send_code()
	if(activated && relay_channel)
		for(var/X in SSnanites.nanite_relays)
			var/datum/nanite_program/relay/N = X
			N.relay_signal(sent_code, relay_channel, "a [name] program")

/datum/nanite_program/sensor/health
	name = "Health Sensor"
	desc = "The nanites receive a signal when the host's health is above/below a target percentage."
	extra_settings = list(NES_SENT_CODE,NES_HEALTH_PERCENT,NES_DIRECTION)
	can_rule = TRUE
	var/spent = FALSE
	var/percent = 50
	var/direction = "Above"

/datum/nanite_program/sensor/health/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_HEALTH_PERCENT)
		var/new_percent = input(user, "Set the health percentage:", name, null) as null|num
		if(isnull(new_percent))
			return
		percent = CLAMP(round(new_percent, 1), -99, 100)
	if(setting == NES_DIRECTION)
		if(direction == "Above")
			direction = "Below"
		else
			direction = "Above"

/datum/nanite_program/sensor/health/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_HEALTH_PERCENT)
		return "[percent]%"
	if(setting == NES_DIRECTION)
		return direction

/datum/nanite_program/sensor/health/copy_extra_settings_to(datum/nanite_program/sensor/health/target)
	target.sent_code = sent_code
	target.percent = percent
	target.direction = direction

/datum/nanite_program/sensor/health/check_event()
	var/health_percent = host_mob.health / host_mob.maxHealth * 100
	var/detected = FALSE
	if(direction == "Above")
		if(health_percent >= percent)
			detected = TRUE
	else
		if(health_percent < percent)
			detected = TRUE

	if(detected)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/health/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/health/rule = new(target)
	rule.above = (direction == "Above")
	rule.threshold = percent
	return rule

/datum/nanite_program/sensor/crit
	name = "Critical Health Sensor"
	desc = "The nanites receive a signal when the host first reaches critical health."
	can_rule = TRUE
	var/spent = FALSE

/datum/nanite_program/sensor/crit/check_event()
	if(host_mob.InCritical())
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/crit/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/crit/rule = new(target)
	return rule

/datum/nanite_program/sensor/death
	name = "Death Sensor"
	desc = "The nanites receive a signal when they detect the host is dead."
	can_rule = TRUE
	var/spent = FALSE

/datum/nanite_program/sensor/death/on_death()
	send_code()

/datum/nanite_program/sensor/death/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/death/rule = new(target)
	return rule

/datum/nanite_program/sensor/nanite_volume
	name = "Nanite Volume Sensor"
	desc = "The nanites receive a signal when the nanite supply is above/below a certain percentage."
	extra_settings = list(NES_SENT_CODE,NES_NANITE_PERCENT,NES_DIRECTION)
	can_rule = TRUE
	var/spent = FALSE
	var/percent = 50
	var/direction = "Above"

/datum/nanite_program/sensor/nanite_volume/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_NANITE_PERCENT)
		var/new_percent = input(user, "Set the nanite percentage:", name, null) as null|num
		if(isnull(new_percent))
			return
		percent = CLAMP(round(new_percent, 1), 1, 100)
	if(setting == NES_DIRECTION)
		if(direction == "Above")
			direction = "Below"
		else
			direction = "Above"

/datum/nanite_program/sensor/nanite_volume/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_NANITE_PERCENT)
		return "[percent]%"
	if(setting == NES_DIRECTION)
		return direction

/datum/nanite_program/sensor/nanite_volume/copy_extra_settings_to(datum/nanite_program/sensor/nanite_volume/target)
	target.sent_code = sent_code
	target.percent = percent
	target.direction = direction

/datum/nanite_program/sensor/nanite_volume/check_event()
	var/nanite_percent = (nanites.nanite_volume - nanites.safety_threshold)/(nanites.max_nanites - nanites.safety_threshold)*100
	var/detected = FALSE

	if(direction == "Above")
		if(nanite_percent >= percent)
			detected = TRUE
	else
		if(nanite_percent < percent)
			detected = TRUE

	if(detected)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/nanite_volume/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/nanites/rule = new(target)
	rule.above = (direction == "Above")
	rule.threshold = percent
	return rule

/datum/nanite_program/sensor/damage
	name = "Damage Sensor"
	desc = "The nanites receive a signal when a host's specific damage type is above/below a target value."
	extra_settings = list(NES_SENT_CODE,NES_DAMAGE_TYPE,NES_DAMAGE,NES_DIRECTION)
	can_rule = TRUE
	var/spent = FALSE
	var/damage_type = BRUTE
	var/damage = 50
	var/direction = "Above"

/datum/nanite_program/sensor/damage/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_DAMAGE)
		var/new_damage = input(user, "Set the damage threshold:", name, null) as null|num
		if(isnull(new_damage))
			return
		damage = CLAMP(round(new_damage, 1), 0, 500)
	if(setting == NES_DAMAGE_TYPE)
		var/list/damage_types = list(BRUTE,BURN,TOX,OXY,CLONE)
		var/new_damage_type = input("Choose the damage type", name) as null|anything in sortList(damage_types)
		if(!new_damage_type)
			return
		damage_type = new_damage_type
	if(setting == NES_DIRECTION)
		if(direction == "Above")
			direction = "Below"
		else
			direction = "Above"

/datum/nanite_program/sensor/damage/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_DAMAGE)
		return damage
	if(setting == NES_DAMAGE_TYPE)
		return capitalize(damage_type)
	if(setting == NES_DIRECTION)
		return direction

/datum/nanite_program/sensor/damage/copy_extra_settings_to(datum/nanite_program/sensor/damage/target)
	target.sent_code = sent_code
	target.damage = damage
	target.damage_type = damage_type
	target.direction = direction

/datum/nanite_program/sensor/damage/check_event()
	var/reached_threshold = FALSE
	var/check_above = (direction == "Above")
	var/damage_amt = 0
	switch(damage_type)
		if(BRUTE)
			damage_amt = host_mob.getBruteLoss()
		if(BURN)
			damage_amt = host_mob.getFireLoss()
		if(TOX)
			damage_amt = host_mob.getToxLoss()
		if(OXY)
			damage_amt = host_mob.getOxyLoss()
		if(CLONE)
			damage_amt = host_mob.getCloneLoss()

	if(damage_amt >= damage)
		if(check_above)
			reached_threshold = TRUE
	else if(!check_above)
		reached_threshold = TRUE

	if(reached_threshold)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/damage/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/damage/rule = new(target)
	rule.above = (direction == "Above")
	rule.threshold = damage
	rule.damage_type = damage_type
	return rule

/datum/nanite_program/sensor/voice
	name = "Voice Sensor"
	desc = "Sends a signal when the nanites hear a determined word or sentence."
	extra_settings = list(NES_SENT_CODE,NES_SENTENCE,NES_INCLUSIVE_MODE)
	var/spent = FALSE
	var/sentence = ""
	var/inclusive = TRUE

/datum/nanite_program/sensor/voice/on_mob_add()
	. = ..()
	RegisterSignal(host_mob, COMSIG_MOVABLE_HEAR, .proc/on_hear)

/datum/nanite_program/sensor/voice/on_mob_remove()
	UnregisterSignal(host_mob, COMSIG_MOVABLE_HEAR, .proc/on_hear)

/datum/nanite_program/sensor/voice/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_SENTENCE)
		var/new_sentence = stripped_input(user, "Choose the sentence that triggers the sensor.", NES_SENTENCE, sentence, MAX_MESSAGE_LEN)
		if(!new_sentence)
			return
		sentence = new_sentence
	if(setting == NES_INCLUSIVE_MODE)
		var/new_inclusive = input("Should the sensor detect the sentence if contained within another sentence?", name) as null|anything in list("Inclusive","Exclusive")
		if(!new_inclusive)
			return
		inclusive = (new_inclusive == "Inclusive")

/datum/nanite_program/sensor/voice/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_SENTENCE)
		return sentence
	if(setting == NES_INCLUSIVE_MODE)
		if(inclusive)
			return "Inclusive"
		else
			return "Exclusive"

/datum/nanite_program/sensor/voice/copy_extra_settings_to(datum/nanite_program/sensor/voice/target)
	target.sent_code = sent_code
	target.sentence = sentence
	target.inclusive = inclusive

/datum/nanite_program/sensor/voice/proc/on_hear(datum/source, list/hearing_args)
	if(!sentence)
		return
	if(inclusive)
		if(findtextEx(hearing_args[HEARING_RAW_MESSAGE], sentence))
			send_code()
	else
		if(hearing_args[HEARING_RAW_MESSAGE] == sentence)
			send_code()

/datum/nanite_program/sensor/species
	name = "Species Sensor"
	desc = "When triggered, the nanites scan the host to determine their species and output a signal depending on the conditions set in the settings."
	can_trigger = TRUE
	trigger_cost = 0
	trigger_cooldown = 5

	extra_settings = list(NES_SENT_CODE,NES_RACE,NES_MODE)
	var/species_type = "Human"
	var/mode = "Is"
	var/list/static/allowed_species = list(
    	"Human" = /datum/species/human,
    	"Lizard" = /datum/species/lizard,
		"Moth" = /datum/species/moth,
		"Ethereal" = /datum/species/ethereal,
		"Pod" = /datum/species/pod,
		"Fly" = /datum/species/fly,
		"Felinid" = /datum/species/human/felinid,
		"Jelly" = /datum/species/jelly
	)

/datum/nanite_program/sensor/species/set_extra_setting(user, setting)
	if(setting == NES_SENT_CODE)
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == NES_RACE)
		var/list/species_types = list()
		for(var/name in allowed_species)
			species_types += name
		species_types += "Other"
		var/new_species_type = input("Choose the species", name) as null|anything in sortList(species_types)
		if(!new_species_type)
			return
		species_type = new_species_type
	if(setting == NES_MODE)
		mode = mode == "Is" ? "Is Not" : "Is"


/datum/nanite_program/sensor/species/get_extra_setting(setting)
	if(setting == NES_SENT_CODE)
		return sent_code
	if(setting == NES_RACE)
		return species_type
	if(setting == NES_MODE)
		return mode

/datum/nanite_program/sensor/species/copy_extra_settings_to(datum/nanite_program/sensor/species/target)
	target.sent_code = sent_code
	target.species_type = species_type
	target.mode = mode

/datum/nanite_program/sensor/species/trigger()
	if(!..())
		return

	var/species = allowed_species[species_type]
	var/species_match = FALSE

	if(species)
		if(is_species(host_mob, species))
			species_match = TRUE
	else	//this is the check for the "Other" option
		species_match = TRUE
		for(var/name in allowed_species)
			var/species_other = allowed_species[name]
			if(is_species(host_mob, species_other))
				species_match = FALSE
				break

	switch(mode)
		if("Is")
			if(species_match)
				send_code()
		if("Is Not")
			if(!species_match)
				send_code()
