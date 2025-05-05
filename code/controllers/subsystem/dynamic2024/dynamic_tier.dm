/datum/dynamic_tier
	var/tier = -1
	var/name
	/// Tag the tier uses for configuring.
	/// Don't change this unless you know what you're doing.
	var/config_tag
	var/weight = 0

	var/min_pop = 0

	var/advisory_report

	var/list/ruleset_ranges = list(
		ROUNDSTART_RANGE = list(
			// Lower end of the range
			LOW_END = 0,
			// Upper end of the range
			HIGH_END = 0,
			// Below this # of players, the range is quartered.
			HALF_RANGE_POP_THRESHOLD = 25,
			// Below this # of players, the range is halved
			FULL_RANGE_POP_THRESHOLD = 50,
			// The round time threshold for which midrounds/latejoins may start (Not used for roundstart)
			TIME_THRESHOLD = 0 MINUTES,
		),
		LIGHT_MIDROUND_RANGE = list(
			LOW_END = 0,
			HIGH_END = 0,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
		),
		HEAVY_MIDROUND_RANGE = list(
			LOW_END = 0,
			HIGH_END = 0,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
		),
		LATEJOIN_RANGE = list(
			LOW_END = 0,
			HIGH_END = 0,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 0 MINUTES,
		),
	)

/datum/dynamic_tier/New(list/dynamic_config)
	for(var/nvar in dynamic_config?[config_tag])
		if(!(nvar in vars))
			continue
		set_config_value(nvar, dynamic_config[config_tag][nvar])

/// Used for parsing config entries to validate them
/datum/dynamic_tier/proc/set_config_value(nvar, nval)
	switch(nvar)
		if(NAMEOF(src, tier), NAMEOF(src, config_tag), NAMEOF(src, vars))
			return FALSE
		if(NAMEOF(src, ruleset_ranges))
			for(var/category in nval)
				for(var/rule in nval[category])
					if(rule == LOW_END || rule == HIGH_END)
						ruleset_ranges[category][rule] = max(0, nval[category][rule])
					else if(rule == TIME_THRESHOLD)
						ruleset_ranges[category][rule] = nval[category][rule] * 1 MINUTES
					else
						ruleset_ranges[category][rule] = nval[category][rule]
			return TRUE

	vars[nvar] = nval
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

	ruleset_ranges = list(
		ROUNDSTART_RANGE = list(
			LOW_END = 1,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND_RANGE = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
		),
		HEAVY_MIDROUND_RANGE = list(
			LOW_END = 0,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
		),
		LATEJOIN_RANGE = list(
			LOW_END = 0,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
	)

/datum/dynamic_tier/lowmedium
	tier = DYNAMIC_TIER_LOWMEDIUM
	config_tag = "Low-Medium Chaos"
	name = "Low-Medium Chaos"
	weight = 24

	advisory_report = "Advisory Level: <b>Red Star</b></center><BR>\
		Your sector's advisory level is Red Star. \
		The Department of Intelligence has decrypted Cybersun communications suggesting a high likelihood of attacks \
		on Nanotrasen assets within the Spinward Sector. \
		Stations in the region are advised to remain highly vigilant for signs of enemy activity and to be on high alert."

	ruleset_ranges = list(
		ROUNDSTART_RANGE = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND_RANGE = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
		),
		HEAVY_MIDROUND_RANGE = list(
			LOW_END = 0,
			HIGH_END = 1,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
		),
		LATEJOIN_RANGE = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
	)

/datum/dynamic_tier/mediumhigh
	tier = DYNAMIC_TIER_MEDIUMHIGH
	config_tag = "Medium-High Chaos"
	name = "Medium-High Chaos"
	weight = 52

	advisory_report = "Advisory Level: <b>Black Orbit</b></center><BR>\
		Your sector's advisory level is Black Orbit. \
		Your sector's local communications network is currently undergoing a blackout, \
		and we are therefore unable to accurately judge enemy movements within the region. \
		However, information passed to us by GDI suggests a high amount of enemy activity in the sector, \
		indicative of an impending attack. Remain on high alert and vigilant against any other potential threats."

	ruleset_ranges = list(
		ROUNDSTART_RANGE = list(
			LOW_END = 2,
			HIGH_END = 3,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND_RANGE = list(
			LOW_END = 2,
			HIGH_END = 3,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
		),
		HEAVY_MIDROUND_RANGE = list(
			LOW_END = 0,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 60 MINUTES,
		),
		LATEJOIN_RANGE = list(
			LOW_END = 1,
			HIGH_END = 3,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
	)

/datum/dynamic_tier/high
	tier = DYNAMIC_TIER_HIGH
	config_tag = "High Chaos"
	name = "High Chaos"
	weight = 16

	min_pop = 25

	advisory_report = "Advisory Level: <b>Midnight Sun</b></center><BR>\
		Your sector's advisory level is Midnight Sun. \
		Credible information passed to us by GDI suggests that the Syndicate \
		is preparing to mount a major concerted offensive on Nanotrasen assets in the Spinward Sector to cripple our foothold there. \
		All stations should remain on high alert and prepared to defend themselves."

	ruleset_ranges = list(
		ROUNDSTART_RANGE = list(
			LOW_END = 3,
			HIGH_END = 4,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
		LIGHT_MIDROUND_RANGE = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 20 MINUTES,
		),
		HEAVY_MIDROUND_RANGE = list(
			LOW_END = 1,
			HIGH_END = 2,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
			TIME_THRESHOLD = 30 MINUTES,
		),
		LATEJOIN_RANGE = list(
			LOW_END = 2,
			HIGH_END = 3,
			HALF_RANGE_POP_THRESHOLD = 25,
			FULL_RANGE_POP_THRESHOLD = 40,
		),
	)
