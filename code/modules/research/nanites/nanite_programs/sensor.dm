/datum/nanite_program/sensor
	name = "Sensor Nanites"
	desc = "These nanites send a signal code when a certain condition is met."

	has_extra_code = TRUE
	extra_code = 0
	extra_code_name = "Sent Code"
	extra_code_min = 1
	extra_code_max = 9999

/datum/nanite_program/sensor/proc/check_event()
	return FALSE

/datum/nanite_program/sensor/proc/send_code()
	SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, extra_code, "a [name] program")

/datum/nanite_program/sensor/active_effect()
	if(extra_code && check_event())
		send_code()

/datum/nanite_program/sensor/healthy
	name = "Perfect Health Sensor"
	desc = "The nanites receive a signal when the host is in perfect health."
	var/spent = FALSE

/datum/nanite_program/sensor/healthy/check_event()
	if(host_mob.health == host_mob.maxHealth)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/health_high
	name = "High Health Sensor"
	desc = "The nanites receive a signal when the host's health is above 75%."
	var/spent = FALSE

/datum/nanite_program/sensor/health_high/check_event()
	var/health_percent = host_mob.health / host_mob.maxHealth * 100
	if(health_percent > 75)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/health_low
	name = "Low Health Sensor"
	desc = "The nanites receive a signal when the the host's health is below 25%."
	var/spent = FALSE

/datum/nanite_program/sensor/health_low/check_event()
	var/health_percent = host_mob.health / host_mob.maxHealth * 100
	if(health_percent < 25)
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
	if(host_mob.health < 0 && !(host_mob.stat == DEAD))
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
	name = "Nanite Volume Sensor - LOW"
	desc = "The nanites receive a signal when the nanite supply is below 25%."
	var/spent = FALSE

/datum/nanite_program/sensor/nanites_low/check_event()
	var/nanite_percent = (nanites.nanite_volume - nanites.safety_threshold)/(nanites.max_nanites - nanites.safety_threshold)*100
	if(nanite_percent <= 25)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/nanites_high
	name = "Nanite Volume Sensor - HIGH"
	desc = "The nanites receive a signal when the nanite supply is over 75%."
	var/spent = FALSE

/datum/nanite_program/sensor/nanites_high/check_event()
	var/nanite_percent = (nanites.nanite_volume - nanites.safety_threshold)/(nanites.max_nanites - nanites.safety_threshold)*100
	if(nanite_percent >= 75)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE

/datum/nanite_program/sensor/nanites_full
	name = "Nanite Volume Sensor - FULL"
	desc = "The nanites receive a signal when the nanite supply is at the cap."
	var/spent = FALSE

/datum/nanite_program/sensor/nanites_full/check_event()
	if(nanites.nanite_volume == nanites.max_nanites)
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	else
		spent = FALSE
		return FALSE