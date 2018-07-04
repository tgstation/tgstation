/datum/nanite_program/sensor
	name = "Sensor Nanites"
	desc = "These nanites send a signal code when a certain condition is met."
	unique = FALSE
	extra_settings = list("Sent Code")

	var/sent_code = 0

/datum/nanite_program/sensor/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)

/datum/nanite_program/sensor/get_extra_setting(setting)
	if(setting == "Sent Code")
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

/datum/nanite_program/sensor/repeat
	name = "Signal Repeater"
	desc = "When triggered, sends another signal to the nanites, optionally with a delay."
	can_trigger = TRUE
	trigger_cost = 0
	trigger_cooldown = 10
	extra_settings = list("Sent Code","Delay")
	var/spent = FALSE
	var/delay = 0

/datum/nanite_program/sensor/repeat/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Delay")
		var/new_delay = input(user, "Set the delay in seconds:", name, null) as null|num
		if(isnull(new_delay))
			return
		delay = (CLAMP(round(new_delay, 1), 0, 3600)) * 10 //max 1 hour

/datum/nanite_program/sensor/repeat/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Delay")
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
	extra_settings = list("Sent Code","Relay Channel","Delay")
	var/spent = FALSE
	var/delay = 0
	var/relay_channel = 0

/datum/nanite_program/sensor/relay_repeat/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Relay Channel")
		var/new_channel = input(user, "Set the relay channel (1-9999):", name, null) as null|num
		if(isnull(new_channel))
			return
		relay_channel = CLAMP(round(new_channel, 1), 1, 9999)
	if(setting == "Delay")
		var/new_delay = input(user, "Set the delay in seconds:", name, null) as null|num
		if(isnull(new_delay))
			return
		delay = (CLAMP(round(new_delay, 1), 0, 3600)) * 10 //max 1 hour

/datum/nanite_program/sensor/relay_repeat/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Relay Channel")
		return relay_channel
	if(setting == "Delay")
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
		for(var/datum/nanite_program/relay/N in SSnanites.nanite_relays)
			N.relay_signal(sent_code, relay_channel, "a [name] program")

/datum/nanite_program/sensor/health_high
	name = "Health Sensor \[Above\]"
	desc = "The nanites receive a signal when the host's health is equal or above a target percentage."
	extra_settings = list("Sent Code","Health Percent")
	var/spent = FALSE
	var/percent = 75

/datum/nanite_program/sensor/health_high/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Health Percent")
		var/new_percent = input(user, "Set the health percentage:", name, null) as null|num
		if(isnull(new_percent))
			return
		percent = CLAMP(round(new_percent, 1), -99, 100)

/datum/nanite_program/sensor/health_high/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Health Percent")
		return "[percent]%"

/datum/nanite_program/sensor/health_high/copy_extra_settings_to(datum/nanite_program/sensor/health_high/target)
	target.sent_code = sent_code
	target.percent = percent

/datum/nanite_program/sensor/health_high/check_event()
	var/health_percent = host_mob.health / host_mob.maxHealth * 100
	if(health_percent >= percent)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/health_low
	name = "Health Sensor \[Below\]"
	desc = "The nanites receive a signal when the the host's health is below a target percentage."
	extra_settings = list("Sent Code","Health Percent")
	var/spent = FALSE
	var/percent = 25

/datum/nanite_program/sensor/health_low/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Health Percent")
		var/new_percent = input(user, "Set the health percentage:", name, null) as null|num
		if(isnull(new_percent))
			return
		percent = CLAMP(round(new_percent, 1), -99, 100)

/datum/nanite_program/sensor/health_low/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Health Percent")
		return "[percent]%"

/datum/nanite_program/sensor/health_low/copy_extra_settings_to(datum/nanite_program/sensor/health_low/target)
	target.sent_code = sent_code
	target.percent = percent

/datum/nanite_program/sensor/health_low/check_event()
	var/health_percent = host_mob.health / host_mob.maxHealth * 100
	if(health_percent < percent)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/crit
	name = "Critical Health Sensor"
	desc = "The nanites receive a signal when the host first reaches critical health."
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

/datum/nanite_program/sensor/death
	name = "Death Sensor"
	desc = "The nanites receive a signal when they detect the host is dead."
	var/spent = FALSE

/datum/nanite_program/sensor/death/on_death()
	send_code()

/datum/nanite_program/sensor/nanites_low
	name = "Nanite Volume Sensor \[Below\]"
	desc = "The nanites receive a signal when the nanite supply is below a certain percentage."
	extra_settings = list("Sent Code","Nanite Percent")
	var/spent = FALSE
	var/percent = 25

/datum/nanite_program/sensor/nanites_low/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Nanite Percent")
		var/new_percent = input(user, "Set the nanite percentage:", name, null) as null|num
		if(isnull(new_percent))
			return
		percent = CLAMP(round(new_percent, 1), 1, 100)

/datum/nanite_program/sensor/nanites_low/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Nanite Percent")
		return "[percent]%"

/datum/nanite_program/sensor/nanites_low/copy_extra_settings_to(datum/nanite_program/sensor/nanites_low/target)
	target.sent_code = sent_code
	target.percent = percent

/datum/nanite_program/sensor/nanites_low/check_event()
	var/nanite_percent = (nanites.nanite_volume - nanites.safety_threshold)/(nanites.max_nanites - nanites.safety_threshold)*100
	if(nanite_percent <= percent)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/nanites_high
	name = "Nanite Volume Sensor \[Above\]"
	desc = "The nanites receive a signal when the nanite supply is above a certain percentage."
	extra_settings = list("Sent Code","Nanite Percent")
	var/spent = FALSE
	var/percent = 75

/datum/nanite_program/sensor/nanites_high/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Nanite Percent")
		var/new_percent = input(user, "Set the nanite percentage:", name, null) as null|num
		if(isnull(new_percent))
			return
		percent = CLAMP(round(new_percent, 1), 1, 100)

/datum/nanite_program/sensor/nanites_high/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Nanite Percent")
		return "[percent]%"

/datum/nanite_program/sensor/nanites_high/copy_extra_settings_to(datum/nanite_program/sensor/nanites_high/target)
	target.sent_code = sent_code
	target.percent = percent

/datum/nanite_program/sensor/nanites_high/check_event()
	var/nanite_percent = (nanites.nanite_volume - nanites.safety_threshold)/(nanites.max_nanites - nanites.safety_threshold)*100
	if(nanite_percent >= percent)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/brute_high
	name = "Brute Sensor \[Above\]"
	desc = "The nanites receive a signal when the host's brute damage is equal or above a target value."
	extra_settings = list("Sent Code","Brute Damage")
	var/spent = FALSE
	var/brute = 50

/datum/nanite_program/sensor/brute_high/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Brute Damage")
		var/new_brute = input(user, "Set the brute threshold:", name, null) as null|num
		if(isnull(new_brute))
			return
		brute = CLAMP(round(new_brute, 1), 0, 500)

/datum/nanite_program/sensor/brute_high/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Brute Damage")
		return brute

/datum/nanite_program/sensor/brute_high/copy_extra_settings_to(datum/nanite_program/sensor/brute_high/target)
	target.sent_code = sent_code
	target.brute = brute

/datum/nanite_program/sensor/brute_high/check_event()
	if(host_mob.getBruteLoss() >= brute)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/brute_low
	name = "Brute Sensor \[Below\]"
	desc = "The nanites receive a signal when the the host's brute damage is below a target value."
	extra_settings = list("Sent Code","Brute Damage")
	var/spent = FALSE
	var/brute = 50

/datum/nanite_program/sensor/brute_low/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Brute Damage")
		var/new_brute = input(user, "Set the brute threshold:", name, null) as null|num
		if(isnull(new_brute))
			return
		brute = CLAMP(round(new_brute, 1), 0, 500)

/datum/nanite_program/sensor/brute_low/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Brute Damage")
		return brute

/datum/nanite_program/sensor/brute_low/copy_extra_settings_to(datum/nanite_program/sensor/brute_low/target)
	target.sent_code = sent_code
	target.brute = brute

/datum/nanite_program/sensor/brute_low/check_event()
	if(host_mob.getBruteLoss() < brute)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/burn_high
	name = "Burn Sensor \[Above\]"
	desc = "The nanites receive a signal when the host's burn damage is equal or above a target value."
	extra_settings = list("Sent Code","Burn Damage")
	var/spent = FALSE
	var/burn = 50

/datum/nanite_program/sensor/burn_high/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Burn Damage")
		var/new_burn = input(user, "Set the burn threshold:", name, null) as null|num
		if(isnull(new_burn))
			return
		burn = CLAMP(round(new_burn, 1), 0, 500)

/datum/nanite_program/sensor/burn_high/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Burn Damage")
		return burn

/datum/nanite_program/sensor/burn_high/copy_extra_settings_to(datum/nanite_program/sensor/burn_high/target)
	target.sent_code = sent_code
	target.burn = burn

/datum/nanite_program/sensor/burn_high/check_event()
	if(host_mob.getFireLoss() >= burn)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/burn_low
	name = "Burn Sensor \[Below\]"
	desc = "The nanites receive a signal when the the host's burn damage is below a target value."
	extra_settings = list("Sent Code","Burn Damage")
	var/spent = FALSE
	var/burn = 50

/datum/nanite_program/sensor/burn_low/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Burn Damage")
		var/new_burn = input(user, "Set the burn threshold:", name, null) as null|num
		if(isnull(new_burn))
			return
		burn = CLAMP(round(new_burn, 1), 0, 500)

/datum/nanite_program/sensor/burn_low/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Burn Damage")
		return burn

/datum/nanite_program/sensor/burn_low/copy_extra_settings_to(datum/nanite_program/sensor/burn_low/target)
	target.sent_code = sent_code
	target.burn = burn

/datum/nanite_program/sensor/burn_low/check_event()
	if(host_mob.getFireLoss() < burn)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/tox_high
	name = "Toxin Sensor \[Above\]"
	desc = "The nanites receive a signal when the host's toxin damage is equal or above a target value."
	extra_settings = list("Sent Code","Toxin Damage")
	var/spent = FALSE
	var/toxin = 50

/datum/nanite_program/sensor/tox_high/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Toxin Damage")
		var/new_toxin = input(user, "Set the toxin threshold:", name, null) as null|num
		if(isnull(new_toxin))
			return
		toxin = CLAMP(round(new_toxin, 1), 0, 500)

/datum/nanite_program/sensor/tox_high/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Toxin Damage")
		return toxin

/datum/nanite_program/sensor/tox_high/copy_extra_settings_to(datum/nanite_program/sensor/tox_high/target)
	target.sent_code = sent_code
	target.toxin = toxin

/datum/nanite_program/sensor/tox_high/check_event()
	if(host_mob.getToxLoss() >= toxin)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/tox_low
	name = "Toxin Sensor \[Below\]"
	desc = "The nanites receive a signal when the the host's toxin damage is below a target value."
	extra_settings = list("Sent Code","Toxin Damage")
	var/spent = FALSE
	var/toxin = 50

/datum/nanite_program/sensor/tox_low/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Toxin Damage")
		var/new_toxin = input(user, "Set the toxin threshold:", name, null) as null|num
		if(isnull(new_toxin))
			return
		toxin = CLAMP(round(new_toxin, 1), 0, 500)

/datum/nanite_program/sensor/tox_low/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Toxin Damage")
		return toxin

/datum/nanite_program/sensor/tox_low/copy_extra_settings_to(datum/nanite_program/sensor/tox_low/target)
	target.sent_code = sent_code
	target.toxin = toxin

/datum/nanite_program/sensor/tox_low/check_event()
	if(host_mob.getToxLoss() < toxin)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE
		
/datum/nanite_program/sensor/voice
	name = "Voice Sensor"
	desc = "Sends a signal when the nanites hear a determined word or sentence."
	extra_settings = list("Sent Code","Sentence","Inclusive Mode")
	var/spent = FALSE
	var/sentence = ""
	var/inclusive = TRUE

/datum/nanite_program/sensor/voice/set_extra_setting(user, setting)
	if(setting == "Sent Code")
		var/new_code = input(user, "Set the sent code (1-9999):", name, null) as null|num
		if(isnull(new_code))
			return
		sent_code = CLAMP(round(new_code, 1), 1, 9999)
	if(setting == "Sentence")
		var/new_sentence = stripped_input(user, "Choose the sentence that triggers the sensor.", "Sentence", sentence, MAX_MESSAGE_LEN)
		if(!new_sentence)
			return
		sentence = new_sentence
	if(setting == "Inclusive Mode")
		var/new_inclusive = input("Should the sensor detect the sentence if contained within another sentence?", name) as null|anything in list("Inclusive","Exclusive")
		if(!new_inclusive)
			return
		inclusive = (new_inclusive == "Inclusive")

/datum/nanite_program/sensor/voice/get_extra_setting(setting)
	if(setting == "Sent Code")
		return sent_code
	if(setting == "Sentence")
		return sentence
	if(setting == "Inclusive Mode")
		if(inclusive)
			return "Inclusive"
		else
			return "Exclusive"

/datum/nanite_program/sensor/voice/copy_extra_settings_to(datum/nanite_program/sensor/voice/target)
	target.sent_code = sent_code
	target.sentence = sentence
	target.inclusive = inclusive

/datum/nanite_program/sensor/voice/on_hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(!sentence)
		return
	//To make it not case sensitive
	var/low_message = lowertext(raw_message)
	var/low_sentence = lowertext(sentence)
	if(inclusive)
		if(findtext(low_message, low_sentence))
			send_code()
	else
		if(low_message == low_sentence)
			send_code()