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

/// List of all Brain Traumas for the Quirk. NOT every Trauma in the game
/// Many are left out because they're covered by other quirks or are strictly beneficial
GLOBAL_LIST_INIT(quirk_trauma_choice, list(
	"Expressive Aphasia" = /datum/brain_trauma/mild/expressive_aphasia,
	"Mind Echo" = /datum/brain_trauma/mild/mind_echo,
	"Possessive" = /datum/brain_trauma/mild/possessive,
	"Aphasia" = /datum/brain_trauma/severe/aphasia,
	"Existential Crisis" = /datum/brain_trauma/special/existential_crisis,
	"Monophobia" = /datum/brain_trauma/severe/monophobia,
	"Discoordination" = /datum/brain_trauma/severe/discoordination,
	"Kleptomania" = /datum/brain_trauma/severe/kleptomaniac,
	"Lumiphobia" = /datum/brain_trauma/magic/lumiphobia,
	"Poltergeist" = /datum/brain_trauma/magic/poltergeist,
	"Stalking Phantom" = /datum/brain_trauma/magic/stalker,
	"Stuttering" = /datum/brain_trauma/mild/stuttering,
	"Dumbness" = /datum/brain_trauma/mild/dumbness,
	"Concussion" = /datum/brain_trauma/mild/concussion,
	"Muscle Weakness" = /datum/brain_trauma/mild/muscle_weakness,
	"Muscle Spasms" = /datum/brain_trauma/mild/muscle_spasms,
	"Nervous cough" = /datum/brain_trauma/mild/nervous_cough,
))
