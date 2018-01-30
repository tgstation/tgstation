/datum/preference_entry
	//As it appears to the user
	//Lack thereof will treat it as unmodifiable by the user
	var/name
	//Default value
	var/value

	var/legacy_root_slot = FALSE

	var/abstract_type = /datum/preference_entry
	var/default
	var/version = 0

/datum/preference_entry/New()
	default = value

/datum/preference_entry/Topic(href, list/href_list)
	CRASH("TODO")

/datum/preference_entry/proc/ApplyToMob(mob/living/carbon/human/character)
	return

//Generate the options selection for the preference entry
/datum/preference_entry/proc/GenerateHTML()
	CRASH("No GenerateHTML implementation for [type]")

//called version - old_version times, should migrate from one version to the next PER CALL
/datum/preference_entry/proc/Migrate(old_version)
	CRASH("No Migrate implementation for [type] from v[old_version]")

//The savefile is already in the correct directory for the slot
/datum/preference_entry/proc/LegacyLoad(savefile/S)
	return

/datum/preference_entry/select
	abstract_type = /datum/preference_entry/select

/datum/preference_entry/select/proc/ListOptions()
	return list()

/datum/preference_entry/select/multi
	value = list()
	abstract_type = /datum/preference_entry/select/multi

/datum/preference_entry/select/multi/GenerateHTML()
	CRASH("TODO")

/datum/preference_entry/select/single
	abstract_type = /datum/preference_entry/select/single

/datum/preference_entry/select/single/GenerateHTML()
	CRASH("TODO")

/datum/preference_entry/number
	abstract_type = /datum/preference_entry/number
	var/max_val = INFINITY
	var/min_val = -INFINITY
	var/integer = TRUE

/datum/preference_entry/number/GenerateHTML()
	CRASH("TODO")

/datum/preference_entry/flag
	value = FALSE
	abstract_type = /datum/preference_entry/flag

/datum/preference_entry/flag/GenerateHTML()
	CRASH("TODO")

/datum/preference_entry/string
	value = ""
	abstract_type = /datum/preference_entry/string

/datum/preference_entry/flag/GenerateHTML()
	CRASH("TODO")
