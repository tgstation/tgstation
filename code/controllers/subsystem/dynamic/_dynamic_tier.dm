/**
 * ## Dynamic tier datum
 *
 * These datums are essentially used to configure the dynamic system
 * They serve as a very simple way to see at a glance what dynamic is doing and what it is going to do
 *
 * For example, a tier will say "we will spawn 1-2 roundstart antags"
 */
/datum/dynamic_tier
	/// Tier number - A number which determines the severity of the tier - the higher the number, the more antags
	var/tier = -1
	/// The human readable name of the tier
	var/name
	/// Tag the tier uses for configuring.
	/// Don't change this unless you know what you're doing.
	var/config_tag
	/// The chance this tier will be selected from all tiers
	/// Keep all tiers added up to 100 weight, keeps things readable
	var/weight = 0
	/// This tier will not be selected if the population is below this number
	var/min_pop = 0

	/// String which is sent to the players reporting which tier is active
	var/advisory_report

	/**
	 * How Dynamic will select rulesets based on the tier
	 *
	 * Every tier configures each of the ruleset types - ie, roundstart, light midround, heavy midround, latejoin
	 *
	 * Every type can be configured with the following:
	 * - LOW_END: The lower for how many of this ruleset type can be selected
	 * - HIGH_END: The upper for how many of this ruleset type can be selected
	 * - HALF_RANGE_POP_THRESHOLD: Below this population range, the high end is quartered
	 * - FULL_RANGE_POP_THRESHOLD: Below this population range, the high end is halved
	 *
	 * Non-roundstart ruleset types also have:
	 * - TIME_THRESHOLD: World time must pass this threshold before dynamic starts running this ruleset type
	 * - EXECUTION_COOLDOWN_LOW: The lower end for how long to wait before running this ruleset type again
	 * - EXECUTION_COOLDOWN_HIGH: The upper end for how long to wait before running this ruleset type again
	 */
	var/list/ruleset_type_settings = list(
		ROUNDSTART = list(
			LOW_END = 0,
			HIGH_END = 0,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 50,
			TIME_THRESHOLD = 0 MINUTES,
			EXECUTION_COOLDOWN_LOW = 0 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 0 MINUTES,
		),
		LIGHT_MIDROUND = list(
			LOW_END = 0,
			HIGH_END = 0,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		HEAVY_MIDROUND = list(
			LOW_END = 0,
			HIGH_END = 0,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		LATEJOIN = list(
			LOW_END = 0,
			HIGH_END = 0,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 0 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
	)

/datum/dynamic_tier/New(list/dynamic_config)
	for(var/new_var in dynamic_config?[config_tag])
		if(!(new_var in vars))
			continue
		set_config_value(new_var, dynamic_config[config_tag][new_var])

/// Used for parsing config entries to validate them
/datum/dynamic_tier/proc/set_config_value(new_var, new_val)
	switch(new_var)
		if(NAMEOF(src, tier), NAMEOF(src, config_tag), NAMEOF(src, vars))
			return FALSE
		if(NAMEOF(src, ruleset_type_settings))
			for(var/category in new_val)
				for(var/rule in new_val[category])
					if(rule == LOW_END || rule == HIGH_END)
						ruleset_type_settings[category][rule] = max(0, new_val[category][rule])
					else if(rule == TIME_THRESHOLD || rule == EXECUTION_COOLDOWN_LOW || rule == EXECUTION_COOLDOWN_HIGH)
						ruleset_type_settings[category][rule] = new_val[category][rule] * 1 MINUTES
					else
						ruleset_type_settings[category][rule] = new_val[category][rule]
			return TRUE

	vars[new_var] = new_val
	return TRUE

/datum/dynamic_tier/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, tier))
			return FALSE

	return ..()

/datum/dynamic_tier/greenshift
	tier = DYNAMIC_TIER_GREEN
	config_tag = "Greenshift"
	name = "Greenshift"
	weight = 2

	advisory_report = "Advisory Level: <b>Green Star</b></center><BR>\
		Your sector's advisory level is Green Star. \
		Surveillance information shows no credible threats to Nanotrasen assets within the Spinward Sector at this time. \
		As always, the Department advises maintaining vigilance against potential threats, regardless of a lack of known threats."

/datum/dynamic_tier/low
	tier = DYNAMIC_TIER_LOW
	config_tag = "Low Chaos"
	name = "Low Chaos"
	weight = 8

	advisory_report = "Advisory Level: <b>Yellow Star</b></center><BR>\
		Your sector's advisory level is Yellow Star. \
		Surveillance shows a credible risk of enemy attack against our assets in the Spinward Sector. \
		We advise a heightened level of security alongside maintaining vigilance against potential threats."

	ruleset_type_settings = list(
		ROUNDSTART = list(
			LOW_END = 1,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND = list(
			LOW_END = 0,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		HEAVY_MIDROUND = list(
			LOW_END = 0,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		LATEJOIN = list(
			LOW_END = 0,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 5 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
	)

/datum/dynamic_tier/lowmedium
	tier = DYNAMIC_TIER_LOWMEDIUM
	config_tag = "Low-Medium Chaos"
	name = "Low-Medium Chaos"
	weight = 46

	advisory_report = "Advisory Level: <b>Red Star</b></center><BR>\
		Your sector's advisory level is Red Star. \
		The Department of Intelligence has decrypted Cybersun communications suggesting a high likelihood of attacks \
		on Nanotrasen assets within the Spinward Sector. \
		Stations in the region are advised to remain highly vigilant for signs of enemy activity and to be on high alert."

	ruleset_type_settings = list(
		ROUNDSTART = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND = list(
			LOW_END = 0,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		HEAVY_MIDROUND = list(
			LOW_END = 0,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		LATEJOIN = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 5 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
	)

/datum/dynamic_tier/mediumhigh
	tier = DYNAMIC_TIER_MEDIUMHIGH
	config_tag = "Medium-High Chaos"
	name = "Medium-High Chaos"
	weight = 36

	advisory_report = "Advisory Level: <b>Black Orbit</b></center><BR>\
		Your sector's advisory level is Black Orbit. \
		Your sector's local communications network is currently undergoing a blackout, \
		and we are therefore unable to accurately judge enemy movements within the region. \
		However, information passed to us by GDI suggests a high amount of enemy activity in the sector, \
		indicative of an impending attack. Remain on high alert and vigilant against any other potential threats."

	ruleset_type_settings = list(
		ROUNDSTART = list(
			LOW_END = 2,
			HIGH_END = 3,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		HEAVY_MIDROUND = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		LATEJOIN = list(
			LOW_END = 1,
			HIGH_END = 3,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 5 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
	)

/datum/dynamic_tier/high
	tier = DYNAMIC_TIER_HIGH
	config_tag = "High Chaos"
	name = "High Chaos"
	weight = 10

	min_pop = 25

	advisory_report = "Advisory Level: <b>Midnight Sun</b></center><BR>\
		Your sector's advisory level is Midnight Sun. \
		Credible information passed to us by GDI suggests that the Syndicate \
		is preparing to mount a major concerted offensive on Nanotrasen assets in the Spinward Sector to cripple our foothold there. \
		All stations should remain on high alert and prepared to defend themselves."

	ruleset_type_settings = list(
		ROUNDSTART = list(
			LOW_END = 3,
			HIGH_END = 4,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 20 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		HEAVY_MIDROUND = list(
			LOW_END = 2,
			HIGH_END = 4,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
		LATEJOIN = list(
			LOW_END = 2,
			HIGH_END = 3,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 5 MINUTES,
			EXECUTION_COOLDOWN_LOW = 10 MINUTES,
			EXECUTION_COOLDOWN_HIGH = 20 MINUTES,
		),
	)
