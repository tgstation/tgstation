// dopplerboop helper procs

/proc/random_voice_type()
	return pick(GLOB.dopplerboop_voice_types)

GLOBAL_LIST_INIT(dopplerboop_voice_types, sort_list(list(
	"caring",
	"peppy",
	"snobby",
	"sweet",
	"grumpy",
	"jock",
	"lazy",
	"smug",
	"mute",
)))


/// List of power prototypes to reference, assoc [type] = prototype
GLOBAL_LIST_INIT_TYPED(power_datum_instances, /datum/power, init_power_prototypes())

// list of power datums
GLOBAL_LIST_INIT(all_powers, init_all_powers())

/proc/init_power_prototypes()

	var/list/power_list = list()

	for(var/datum/power/power_type as anything in typesof(/datum/power))
		if(!initial(power_type.name))
			continue
		if(!power_type.is_accessible)
			continue

		power_list[power_type] = new power_type()

	return power_list

/// List f all powers
/proc/init_all_powers()

	var/list/powers_list = list()

	for(var/datum/power/power_type as anything in typesof(/datum/power))
		if(!initial(power_type.name))
			continue
		if(!power_type.is_accessible)
			continue

		powers_list += power_type

	return powers_list
