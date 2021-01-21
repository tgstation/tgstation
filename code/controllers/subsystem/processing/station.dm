PROCESSING_SUBSYSTEM_DEF(station)
	name = "Station"
	init_order = INIT_ORDER_STATION
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 5 SECONDS

	///A list of currently active station traits
	var/list/station_traits = list()
	///Assoc list of trait type || assoc list of traits with weighted value. Used for picking traits from a specific category.
	var/list/traits_by_types = list()

/datum/controller/subsystem/processing/station/Initialize(timeofday)
	SetupTraits()
	return ..()

///Rolls for the amount of traits and adds them to the traits list
/datum/controller/subsystem/processing/station/proc/SetupTraits()
	for(var/i in subtypesof(/datum/station_trait))
		var/datum/station_trait/trait_typepath = i
		traits_by_types[initial(trait_typepath.trait_type)] += list(trait_typepath = initial(trait_typepath.weight))

	var/positive_trait_count = pick(10;0, 5;1, 1;2)
	var/neutral_trait_count = pick(5;0, 10;1, 3;2)
	var/negative_trait_count = pick(10;0, 5;1, 1;2)

	pick_traits(STATION_TRAIT_GOOD, positive_trait_count)
	pick_traits(STATION_TRAIT_NEUTRAL, neutral_trait_count)
	pick_traits(STATION_TRAIT_BAD, negative_trait_count)

///Picks traits of a specific category (e.g. bad or good) and a specified amount, then initializes them and adds them to the list of traits.
/datum/controller/subsystem/processing/station/proc/pick_traits(trait_type, amount)
	if(!amount)
		return
	var/datum/station_trait/picked_trait = pickweight(traits_by_types[trait_type]) //Rolls from the table for the specific trait type
	station_traits += new picked_trait()
