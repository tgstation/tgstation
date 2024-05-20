/datum/nanite_program/sensor
	name = "Sensor Nanites"
	desc = "These nanites send a signal code when a certain condition is met."
	unique = FALSE
	can_trigger = TRUE
	trigger_cost = 0
	trigger_cooldown = 0.5 SECONDS

	var/can_rule = FALSE
	var/spent = FALSE
	var/spent_inverted = FALSE
	var/spendable = TRUE

/datum/nanite_program/sensor/register_extra_settings()
	extra_settings[NES_SENT_CODE_SIGNAL] = new /datum/nanite_extra_setting/number(0, 1, 9999)
	extra_settings[NES_SENT_CODE_SIGNAL_INVERTED] = new /datum/nanite_extra_setting/number(0, 1, 9999)

	if (can_trigger)
		extra_settings[NES_SENT_CODE_TRIGGER] = new /datum/nanite_extra_setting/number(0, 1, 9999)
		extra_settings[NES_SENT_CODE_TRIGGER_INVERTED] = new /datum/nanite_extra_setting/number(0, 1, 9999)

/datum/nanite_program/sensor/proc/check_event()
	return FALSE

/datum/nanite_program/sensor/active_effect()
	var/event_result = check_event()

	if (spendable ? check_spent(event_result) : event_result)
		send_code()

	if (spendable && check_spent_inverted(event_result))
		send_code_inverted()

/datum/nanite_program/sensor/on_trigger(comm_message)
	if (check_event())
		send_trigger_code()
	else
		send_trigger_code_inverted()

/datum/nanite_program/sensor/proc/make_rule(datum/nanite_program/target)
	return

/datum/nanite_program/sensor/proc/check_spent(event_result)
	if(check_event())
		if(!spent)
			spent = TRUE
			return TRUE
		return FALSE
	spent = FALSE
	return FALSE

/datum/nanite_program/sensor/proc/check_spent_inverted(event_result)
	if(!check_event())
		if(!spent_inverted)
			spent_inverted = TRUE
			return TRUE
		return FALSE
	spent_inverted = FALSE
	return FALSE

/datum/nanite_program/sensor/health
	name = "Health Sensor"
	desc = "The nanites receive a signal when the host's health is above/below a target percentage."
	can_rule = TRUE

/datum/nanite_program/sensor/health/register_extra_settings()
	. = ..()
	extra_settings[NES_HEALTH_PERCENT] = new /datum/nanite_extra_setting/number(50, -99, 100, "%")
	extra_settings[NES_DIRECTION] = new /datum/nanite_extra_setting/boolean(TRUE, "Above", "Below")

/datum/nanite_program/sensor/health/check_event()
	var/health_percent = host_mob.health / host_mob.maxHealth * 100
	var/datum/nanite_extra_setting/percent = extra_settings[NES_HEALTH_PERCENT]
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]

	return direction.get_value() == health_percent >= percent.get_value()

/datum/nanite_program/sensor/health/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/health/rule = new(target)
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]
	var/datum/nanite_extra_setting/percent = extra_settings[NES_HEALTH_PERCENT]
	rule.above = direction.get_value()
	rule.threshold = percent.get_value()
	return rule

/datum/nanite_program/sensor/crit
	name = "Critical Health Sensor"
	desc = "The nanites receive a signal when the host enters/leaves critical condition."
	can_rule = TRUE

/datum/nanite_program/sensor/crit/register_extra_settings()
	. = ..()
	extra_settings[NES_MODE] = new /datum/nanite_extra_setting/boolean(TRUE, "Crit", "Stable")

/datum/nanite_program/sensor/crit/check_event()
	var/datum/nanite_extra_setting/mode = extra_settings[NES_MODE]

	return mode.get_value() == HAS_TRAIT(host_mob, TRAIT_CRITICAL_CONDITION)

/datum/nanite_program/sensor/crit/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/crit/rule = new(target)
	return rule

/datum/nanite_program/sensor/death
	name = "Death Sensor"
	desc = "The nanites receive a signal when the host dies/revives."
	can_rule = TRUE

/datum/nanite_program/sensor/death/register_extra_settings()
	. = ..()

	extra_settings[NES_MODE] = new /datum/nanite_extra_setting/boolean(TRUE, "Death", "Life")

/datum/nanite_program/sensor/death/check_event()
	var/datum/nanite_extra_setting/mode = extra_settings[NES_MODE]

	return mode.get_value() == (host_mob.stat == DEAD)

/datum/nanite_program/sensor/death/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/death/rule = new(target)
	var/datum/nanite_extra_setting/mode = extra_settings[NES_MODE]
	rule.when_dead = mode.get_value()
	return rule

/datum/nanite_program/sensor/nanite_volume
	name = "Nanite Volume Sensor"
	desc = "The nanites receive a signal when the nanite supply is above/below a certain percentage."
	can_rule = TRUE

/datum/nanite_program/sensor/nanite_volume/register_extra_settings()
	. = ..()
	extra_settings[NES_NANITE_PERCENT] = new /datum/nanite_extra_setting/number(50, -99, 100, "%")
	extra_settings[NES_DIRECTION] = new /datum/nanite_extra_setting/boolean(TRUE, "Above", "Below")

/datum/nanite_program/sensor/nanite_volume/check_event()
	var/nanite_percent = (nanites.nanite_volume - nanites.safety_threshold)/(nanites.max_nanites - nanites.safety_threshold)*100
	var/datum/nanite_extra_setting/percent = extra_settings[NES_NANITE_PERCENT]
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]

	return direction.get_value() == nanite_percent >= percent.get_value()

/datum/nanite_program/sensor/nanite_volume/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/nanites/rule = new(target)
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]
	var/datum/nanite_extra_setting/percent = extra_settings[NES_NANITE_PERCENT]
	rule.above = direction.get_value()
	rule.threshold = percent.get_value()
	return rule

/datum/nanite_program/sensor/damage
	name = "Damage Sensor"
	desc = "The nanites receive a signal when a host's specific damage type is above/below a target value."
	can_rule = TRUE

/datum/nanite_program/sensor/damage/register_extra_settings()
	. = ..()

	var/list/damage_list = list()

	for (var/damage_type in list(BRUTE, BURN, TOX, OXY, CLONE, BRAIN))
		damage_list += capitalize(damage_type)

	extra_settings[NES_DAMAGE_TYPE] = new /datum/nanite_extra_setting/type(damage_list[1], damage_list)
	extra_settings[NES_DAMAGE] = new /datum/nanite_extra_setting/number(50, 0, 500)
	extra_settings[NES_DIRECTION] = new /datum/nanite_extra_setting/boolean(TRUE, "Above", "Below")

/datum/nanite_program/sensor/damage/check_event()
	var/datum/nanite_extra_setting/type = extra_settings[NES_DAMAGE_TYPE]
	var/datum/nanite_extra_setting/damage = extra_settings[NES_DAMAGE]
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]
	var/check_above = direction.get_value()
	var/damage_amt = 0

	switch(lowertext(type.get_value()))
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
		if(BRAIN)
			damage_amt = host_mob.get_organ_loss(ORGAN_SLOT_BRAIN)

	return check_above == damage_amt >= damage.get_value()

/datum/nanite_program/sensor/damage/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/damage/rule = new(target)
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]
	var/datum/nanite_extra_setting/damage_type = extra_settings[NES_DAMAGE_TYPE]
	var/datum/nanite_extra_setting/damage = extra_settings[NES_DAMAGE]
	rule.above  =  direction.get_value()
	rule.threshold = damage.get_value()
	rule.damage_type = damage_type.get_value()
	return rule

/datum/nanite_program/sensor/blood
	name = "Blood Sensor"
	desc = "The nanites receive a signal when the host's blood volume is above/below a target percentage."
	can_rule = TRUE

/datum/nanite_program/sensor/blood/register_extra_settings()
	. = ..()
	extra_settings[NES_BLOOD_PERCENT] = new /datum/nanite_extra_setting/number(90, 0, 1000, "%")
	extra_settings[NES_DIRECTION] = new /datum/nanite_extra_setting/boolean(TRUE, "Above", "Below")

/datum/nanite_program/sensor/blood/check_event()
	var/datum/nanite_extra_setting/blood_percent = extra_settings[NES_BLOOD_PERCENT]
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]

	var/target_blood_percent = blood_percent.get_value()
	var/check_above = direction.get_value()
	var/host_blood_percent = host_mob.blood_volume / BLOOD_VOLUME_NORMAL * 100

	return check_above == host_blood_percent >= target_blood_percent

/datum/nanite_program/sensor/blood/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/blood/rule = new(target)

	var/datum/nanite_extra_setting/blood_percent = extra_settings[NES_BLOOD_PERCENT]
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]

	rule.threshold = blood_percent.get_value()
	rule.above = direction.get_value()

	return rule

/datum/nanite_program/sensor/nutrition
	name = "Nutrition Sensor"
	desc = "The nanites receive a signal when the host's nutrition level is above/below a target percentage."
	can_rule = TRUE

/datum/nanite_program/sensor/nutrition/register_extra_settings()
	. = ..()
	extra_settings[NES_NUTRITION_PERCENT] = new /datum/nanite_extra_setting/number(90, 0, 1000, "%")
	extra_settings[NES_DIRECTION] = new /datum/nanite_extra_setting/boolean(TRUE, "Above", "Below")

/datum/nanite_program/sensor/nutrition/check_event()
	var/datum/nanite_extra_setting/nutrition_percent = extra_settings[NES_NUTRITION_PERCENT]
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]

	var/target_nutrition_percent = nutrition_percent.get_value()
	var/check_above = direction.get_value()
	var/host_nutrition_percent = host_mob.nutrition / NUTRITION_LEVEL_FED * 100

	return check_above == host_nutrition_percent >= target_nutrition_percent

/datum/nanite_program/sensor/nutrition/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/nutrition/rule = new(target)

	var/datum/nanite_extra_setting/nutrition_percent = extra_settings[NES_NUTRITION_PERCENT]
	var/datum/nanite_extra_setting/direction = extra_settings[NES_DIRECTION]

	rule.threshold = nutrition_percent.get_value()
	rule.above = direction.get_value()

	return rule

/datum/nanite_program/sensor/voice
	name = "Voice Sensor"
	desc = "The nanites receive a signal when they detect a specific, preprogrammed word or phrase being said."
	spendable = FALSE
	can_trigger = FALSE

/datum/nanite_program/sensor/voice/register_extra_settings()
	. = ..()
	extra_settings[NES_SENTENCE] = new /datum/nanite_extra_setting/text("")
	extra_settings[NES_MATCH_MODE] = new /datum/nanite_extra_setting/boolean(TRUE, "Includes", "Equals")

/datum/nanite_program/sensor/voice/on_mob_add()
	. = ..()
	RegisterSignal(host_mob, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

/datum/nanite_program/sensor/voice/on_mob_remove()
	UnregisterSignal(host_mob, COMSIG_MOVABLE_HEAR)

/datum/nanite_program/sensor/voice/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/datum/nanite_extra_setting/sentence = extra_settings[NES_SENTENCE]
	var/datum/nanite_extra_setting/match = extra_settings[NES_MATCH_MODE]
	if(!sentence.get_value())
		return
	if(match.get_value())
		if(findtext(hearing_args[HEARING_RAW_MESSAGE], sentence.get_value()))
			send_code()
		else
			send_code_inverted()
	else
		if(lowertext(hearing_args[HEARING_RAW_MESSAGE]) == lowertext(sentence.get_value()))
			send_code()
		else
			send_code_inverted()

/datum/nanite_program/sensor/species
	name = "Species Sensor"
	desc = "The nanites receive a singal when they detect that the host is/isn't the target species."
	can_rule = TRUE

	var/static/list/species_list = list(
		"Human" = /datum/species/human,
		"Lizard" = /datum/species/lizard,
		"Moth" = /datum/species/moth,
		"Ethereal" = /datum/species/ethereal,
		"Pod" = /datum/species/pod,
		"Floran" = /datum/species/floran,
		"Fly" = /datum/species/fly,
		"Arachnid" = /datum/species/arachnid,
		"Jelly" = /datum/species/jelly,
		"Oozeling" = /datum/species/oozeling,
		"IPC" = /datum/species/ipc,
		"Monkey" = /datum/species/monkey,
		"Simian" = /datum/species/simian,
		"Zombie" = /datum/species/zombie,
		"Shadow" = /datum/species/shadow,
	)

/datum/nanite_program/sensor/species/register_extra_settings()
	. = ..()

	var/list/species_names = list()

	for(var/name in species_list)
		species_names += name

	species_names += "Other"

	extra_settings[NES_RACE] = new /datum/nanite_extra_setting/type("Human", species_names)
	extra_settings[NES_MODE] = new /datum/nanite_extra_setting/boolean(TRUE, "Is", "Is Not")

/datum/nanite_program/sensor/species/check_event()
	var/datum/nanite_extra_setting/race = extra_settings[NES_RACE]
	var/datum/nanite_extra_setting/mode = extra_settings[NES_MODE]

	var/species_type = species_list[race.get_value()]
	var/match_species = mode.get_value()

	if (!species_type) // "Other" check
		for (var/name in species_list)
			if (is_species(host_mob, species_type))
				return !match_species
		return match_species

	return match_species == is_species(host_mob, species_type)

/datum/nanite_program/sensor/species/make_rule(datum/nanite_program/target)
	var/datum/nanite_rule/species/rule = new(target)

	var/datum/nanite_extra_setting/race = extra_settings[NES_RACE]
	var/datum/nanite_extra_setting/mode = extra_settings[NES_MODE]

	rule.when_is_species = mode.get_value()
	rule.species_list = species_list
	rule.species_name = race.get_value()
