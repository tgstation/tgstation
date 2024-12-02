///A global list of fish evolutions, which are singletons.
GLOBAL_LIST_INIT(fish_evolutions, init_subtypes_w_path_keys(/datum/fish_evolution, list()))
///A list of fish evolution types, each having an associated list containing all fish types that have it.
GLOBAL_LIST_EMPTY(fishes_by_fish_evolution)

/**
 * Fish evolution datums
 *
 * If present in a fish's evolution_types list, and other conditions are met in check_conditions()
 * then there's a chance the offspring may be of a new type rather than the same as its source or mate (if any).
 */
/datum/fish_evolution
	///The name of the evolution. If not set, it'll be generated on runtime from the name of the new fish type.
	var/name
	///The probability that this evolution can happen.
	var/probability = 0
	///The obj/item/fish path of the new fish
	var/obj/item/fish/new_fish_type = /obj/item/fish
	///The minimum required temperature for the evolved fish to spawn
	var/required_temperature_min = 0
	///The maximum required temperature for the evolved fish to spawn
	var/required_temperature_max = INFINITY
	///A list of traits added to the new fish. These take priority over the parents' traits.
	var/list/new_traits
	///If set, these traits will be removed from the new fish.
	var/list/removed_traits
	///A text string shown in the catalog, containing information on conditions specific to this evolution.
	var/conditions_note
	///Is this evolution shown on the wiki?
	var/show_on_wiki = TRUE
	///Is the result of this evolution shown on the wiki?
	var/show_result_on_wiki = TRUE

/datum/fish_evolution/New()
	..()
	SHOULD_CALL_PARENT(TRUE)
	if(!ispath(new_fish_type, /obj/item/fish))
		stack_trace("[type] instantiated with a new fish type of [new_fish_type]. That's not a fish, hun, things will break.")
	if(!name)
		name = full_capitalize(initial(new_fish_type.name))
/**
 * The main proc that checks whether this can happen or not.
 * Keep in mind the mate and aquarium arguments may be null if
 * the fish is self-reproducing or this evolution is a result of a fish_growth component
 */
/datum/fish_evolution/proc/check_conditions(obj/item/fish/source, obj/item/fish/mate, atom/movable/aquarium)
	SHOULD_CALL_PARENT(TRUE)
	//the fish don't reproduce outside of aquariums but can still grow there, so we just check if the temperature is right.
	if(!aquarium)
		return source.proper_environment(required_temperature_min, required_temperature_max)
	if(SEND_SIGNAL(aquarium, COMSIG_AQUARIUM_CHECK_EVOLUTION_CONDITIONS, source, mate, src) & COMPONENT_ALLOW_EVOLUTION)
		return TRUE
	return FALSE

///This is called when the evolution is set as the result type of a fish_growth component
/datum/fish_evolution/proc/growth_checks(obj/item/fish/source, seconds_per_tick, growth)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	if(source.health < initial(source.health) * 0.5)
		return COMPONENT_DONT_GROW
	if(source.get_hunger() >= 0.5) //too hungry to grow
		return COMPONENT_DONT_GROW
	if(HAS_TRAIT(source.loc, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH)) //the aquarium has breeding disabled
		return COMPONENT_DONT_GROW
	if(!check_conditions(source))
		return COMPONENT_DONT_GROW

///Called by the fish analyzer right click function. Returns a text string used as tooltip.
/datum/fish_evolution/proc/get_evolution_tooltip()
	. = ""
	if(required_temperature_min > 0 || required_temperature_max < INFINITY)
		var/temp_reqs = ""
		if(required_temperature_min == 0)
			temp_reqs = "below [required_temperature_max]"
		else if(required_temperature_max == INFINITY)
			temp_reqs = "above [required_temperature_min]"
		else
			temp_reqs = "of [required_temperature_min] to [required_temperature_max]"
		. = "An aquarium temperature [temp_reqs]K is required."

	if(conditions_note)
		. += " [conditions_note]"
	return .

/datum/fish_evolution/lubefish
	probability = 25
	new_fish_type = /obj/item/fish/clownfish/lube
	new_traits = list(/datum/fish_trait/lubed)
	conditions_note = "The fish must be fed lube beforehand."

/datum/fish_evolution/lubefish/check_conditions(obj/item/fish/source, obj/item/fish/mate, atom/movable/aquarium)
	if(!HAS_TRAIT(source, TRAIT_FISH_FED_LUBE))
		return FALSE
	return ..()

/datum/fish_evolution/purple_sludgefish
	probability = 5
	new_fish_type = /obj/item/fish/sludgefish/purple
	new_traits = list(/datum/fish_trait/recessive)
	removed_traits = list(/datum/fish_trait/no_mating)

/datum/fish_evolution/mastodon
	name = "???" //The resulting fish is not shown on the catalog.
	probability = 40
	new_fish_type = /obj/item/fish/mastodon
	new_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/amphibious, /datum/fish_trait/predator, /datum/fish_trait/territorial)
	conditions_note = "The fish (and its mate) needs to be unusually big both in size and weight."
	show_result_on_wiki = FALSE

/datum/fish_evolution/mastodon/check_conditions(obj/item/fish/source, obj/item/fish/mate, atom/movable/aquarium)
	if((source.size < 120 || source.weight < 3000) || (mate && (mate.size < 120 || mate.weight < 3000)))
		return FALSE
	return ..()

/datum/fish_evolution/chasm_chrab
	probability = 50
	new_fish_type = /obj/item/fish/chasm_crab
	required_temperature_min = MIN_AQUARIUM_TEMP+14
	required_temperature_max = MIN_AQUARIUM_TEMP+15

/datum/fish_evolution/ice_chrab
	probability = 50
	new_fish_type = /obj/item/fish/chasm_crab/ice
	required_temperature_min = MIN_AQUARIUM_TEMP+9
	required_temperature_max = MIN_AQUARIUM_TEMP+10

/datum/fish_evolution/three_eyes
	probability = 3
	new_fish_type = /obj/item/fish/goldfish/three_eyes
	new_traits = list(/datum/fish_trait/recessive)

/datum/fish_evolution/chainsawfish
	probability = 30
	new_fish_type = /obj/item/fish/chainsawfish
	new_traits = list(/datum/fish_trait/predator, /datum/fish_trait/territorial)
	conditions_note = "The fish needs to be unusually big and territorial"

/datum/fish_evolution/chainsawfish/check_conditions(obj/item/fish/source, obj/item/fish/mate, atom/movable/aquarium)
	var/double_avg_size = /obj/item/fish/goldfish::average_size * 2
	var/double_avg_weight = /obj/item/fish/goldfish::average_weight * 2
	if(source.size >= double_avg_size && source.weight >= double_avg_weight && (/datum/fish_trait/territorial in source.fish_traits))
		return ..()
	return FALSE

/datum/fish_evolution/armored_pike
	probability = 75
	new_fish_type = /obj/item/fish/pike/armored
	conditions_note = "The fish needs to have the stinger trait"

/datum/fish_evolution/armored_pike/check_conditions(obj/item/fish/source, obj/item/fish/mate, atom/movable/aquarium)
	if(HAS_TRAIT(source, TRAIT_FISH_STINGER))
		return ..()
	return FALSE

/datum/fish_evolution/fritterish
	new_fish_type = /obj/item/fish/fryish/fritterish
	removed_traits = list(/datum/fish_trait/no_mating)
	conditions_note = "Fryish will grow into it over time."

/datum/fish_evolution/nessie
	name = "???"
	new_fish_type = /obj/item/fish/fryish/nessie
	conditions_note = "The final stage of fritterfish growth. It gotta be big!"
	show_result_on_wiki = FALSE

/datum/fish_evolution/nessiefish/check_conditions(obj/item/fish/source, obj/item/fish/mate, atom/movable/aquarium)
	if(source.size >= (/obj/item/fish/fryish/fritterish::average_size * 1.5) && source.size >= (/obj/item/fish/fryish/fritterish::average_weight * 1.5))
		return ..()
	return FALSE

/datum/fish_evolution/moonfish
	probability = 200 //guaranteed if the conditions are met
	new_fish_type = /obj/item/fish/moonfish
	conditions_note = "Requires the dwarf moonfish to be big enough."

/datum/fish_evolution/moonfish/check_conditions(obj/item/fish/source, obj/item/fish/mate, obj/structure/aquarium/aquarium)
	if(source.size < (/obj/item/fish/moonfish/dwarf::average_size * 1.5) && source.size < (/obj/item/fish/moonfish/dwarf::average_weight * 1.5))
		return FALSE
	if(mate && (mate.size < (/obj/item/fish/moonfish::average_size * 1.3) && mate.size < (/obj/item/fish/moonfish::average_weight * 1.3)))
		return FALSE
	return ..()

/datum/fish_evolution/dwarf_moonfish
	probability = 200 //guaranteed if the conditions are met
	new_fish_type = /obj/item/fish/moonfish/dwarf
	conditions_note = "Requires the moonfish to be small enough."

/datum/fish_evolution/dwarf_moonfish/check_conditions(obj/item/fish/source, obj/item/fish/mate, obj/structure/aquarium/aquarium)
	if(source.size > (/obj/item/fish/moonfish::average_size * 0.66) && source.size > (/obj/item/fish/moonfish::average_weight * 0.66))
		return FALSE
	if(mate && (mate.size > (/obj/item/fish/moonfish::average_size * 0.7) && mate.size > (/obj/item/fish/moonfish::average_weight * 0.7)))
		return FALSE
	return ..()

/datum/fish_evolution/lavaloop
	probability = 85
	new_fish_type = /obj/item/fish/lavaloop
	required_temperature_min = MIN_AQUARIUM_TEMP + 60

/datum/fish_evolution/plasmaloop
	probability = 85
	new_fish_type = /obj/item/fish/lavaloop/plasma_river
	required_temperature_max = MIN_AQUARIUM_TEMP + 60
