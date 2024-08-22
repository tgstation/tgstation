GLOBAL_LIST_INIT(fish_evolutions, init_subtypes_w_path_keys(/datum/fish_evolution, list()))

/**
 * Fish evolution datums
 *
 * If present in a fish's evolution_types list, and other conditions are met in check_conditions()
 * then there's a chance the offspring may be of a new type rather than the same as its source or mate (if any).
 */
/datum/fish_evolution
	var/name
	var/probability = 0
	///The obj/item/fish path of the new fish
	var/obj/item/fish/new_fish_type = /obj/item/fish
	///The minimum required temperature for the evolved fish to spawn
	var/required_temperature_min = MIN_AQUARIUM_TEMP
	///The maximum required temperature for the evolved fish to spawn
	var/required_temperature_max = MAX_AQUARIUM_TEMP
	///A list of traits added to the new fish. These take priority over the parents' traits.
	var/list/new_traits
	///If set, these traits will be removed from the new fish.
	var/list/removed_traits
	///A text string shown in the catalog, containing information on conditions specific to this evolution.
	var/conditions_note

/datum/fish_evolution/New()
	if(!ispath(new_fish_type, /obj/item/fish))
		stack_trace("[type] instantiated with a new fish type of [new_fish_type]. That's not a fish, hun, things will break.")
	if(!name)
		name = full_capitalize(initial(new_fish_type.name))
/**
 * The main proc that checks whether this can happen or not.
 * Please do keep in mind a mate may not be present for fish with the
 * self-reproductive trait.
 */
/datum/fish_evolution/proc/check_conditions(obj/item/fish/source, obj/item/fish/mate, obj/structure/aquarium/aquarium)
	SHOULD_CALL_PARENT(TRUE)
	//chances are halved if only one parent has this evolution.
	var/real_probability = (mate && (type in mate.evolution_types)) ? probability : probability/2
	if(!prob(real_probability))
		return FALSE
	if(!ISINRANGE(aquarium.fluid_temp, required_temperature_min, required_temperature_max))
		return FALSE
	return TRUE

///Called by the fish analyzer right click function. Returns a text string used as tooltip.
/datum/fish_evolution/proc/get_evolution_tooltip()
	. = ""
	if(required_temperature_min != MIN_AQUARIUM_TEMP || required_temperature_max != MAX_AQUARIUM_TEMP)
		. = "An aquarium temperature between [required_temperature_min] and [required_temperature_max] is required."
	if(conditions_note)
		. += " [conditions_note]"
	return .

///Proc called to let evolution register signals that are needed for various conditions.
/datum/fish_evolution/proc/register_fish(obj/item/fish/fish)
	return

/datum/fish_evolution/lubefish
	probability = 25
	new_fish_type = /obj/item/fish/clownfish/lube
	new_traits = list(/datum/fish_trait/lubed)
	conditions_note = "The fish must be fed lube beforehand."

/datum/fish_evolution/lubefish/register_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_FISH_FED, PROC_REF(check_for_lube))

/datum/fish_evolution/lubefish/proc/check_for_lube(obj/item/fish/source, datum/reagents/fed_reagents, wrong_reagent_type)
	SIGNAL_HANDLER
	if((wrong_reagent_type == /datum/reagent/lube) || fed_reagents.remove_reagent(/datum/reagent/lube, 0.1))
		ADD_TRAIT(source, TRAIT_FISH_FED_LUBE, FISH_EVOLUTION)
		addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_FISH_FED_LUBE, FISH_EVOLUTION), source.feeding_frequency)

/datum/fish_evolution/lubefish/check_conditions(obj/item/fish/source, obj/item/fish/mate, obj/structure/aquarium/aquarium)
	if(!HAS_TRAIT(source, TRAIT_FISH_FED_LUBE))
		return FALSE
	return ..()

/datum/fish_evolution/purple_sludgefish
	probability = 5
	new_fish_type = /obj/item/fish/sludgefish/purple
	removed_traits = list(/datum/fish_trait/no_mating)

/datum/fish_evolution/mastodon
	name = "???" //The resulting fish is not shown on the catalog.
	probability = 40
	new_fish_type = /obj/item/fish/mastodon
	new_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/amphibious, /datum/fish_trait/predator, /datum/fish_trait/aggressive)
	conditions_note = "The fish (and its mate) need to be unusually big both in size and weight."

/datum/fish_evolution/mastodon/check_conditions(obj/item/fish/source, obj/item/fish/mate, obj/structure/aquarium/aquarium)
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
