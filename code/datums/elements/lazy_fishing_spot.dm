/**
 * Lazy fishing spot element so fisheable turfs do not have a component each since
 * they're usually pretty common on their respective maps (lava/water/etc)
 */
/datum/element/lazy_fishing_spot
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	var/configuration

/datum/element/lazy_fishing_spot/Attach(datum/target, configuration)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!ispath(configuration, /datum/fish_source) || configuration == /datum/fish_source)
		CRASH("Lazy fishing spot has incorrect configuration passed in: [configuration].")
	src.configuration = configuration
	ADD_TRAIT(target, TRAIT_FISHING_SPOT, REF(src))
	RegisterSignal(target, COMSIG_PRE_FISHING, PROC_REF(create_fishing_spot))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examined_more))
	RegisterSignal(target, COMSIG_ATOM_EX_ACT, PROC_REF(explosive_fishing))

/datum/element/lazy_fishing_spot/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_PRE_FISHING, COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXAMINE_MORE, COMSIG_ATOM_EX_ACT))
	REMOVE_TRAIT(target, TRAIT_FISHING_SPOT, REF(src))
	return ..()

/datum/element/lazy_fishing_spot/proc/create_fishing_spot(datum/source)
	SIGNAL_HANDLER

	source.AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[configuration])
	Detach(source)

///If the fish source has fishes that are shown in the
/datum/element/lazy_fishing_spot/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		return

	var/datum/fish_source/fish_source = GLOB.preset_fish_sources[configuration]

	var/has_known_fishes = FALSE
	for(var/reward in fish_source.fish_table)
		if(!ispath(reward, /obj/item/fish))
			continue
		var/obj/item/fish/prototype = reward
		if(initial(prototype.show_in_catalog))
			has_known_fishes = TRUE
			break
	if(!has_known_fishes)
		return

	examine_text += span_tinynoticeital("This is a fishing spot. You can look again to list its fishes...")

/datum/element/lazy_fishing_spot/proc/on_examined_more(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		return

	var/datum/fish_source/fish_source = GLOB.preset_fish_sources[configuration]

	var/list/known_fishes = list()
	for(var/reward in fish_source.fish_table)
		if(!ispath(reward, /obj/item/fish))
			continue
		var/obj/item/fish/prototype = reward
		if(initial(prototype.show_in_catalog))
			known_fishes += initial(prototype.name)

	if(!length(known_fishes))
		return

	examine_text += span_info("You can catch the following fish here: [english_list(known_fishes)].")

/datum/element/lazy_fishing_spot/proc/explosive_fishing(atom/location, severity)
	SIGNAL_HANDLER
	var/datum/fish_source/fish_source = GLOB.preset_fish_sources[configuration]
	fish_source.spawn_reward_from_explosion(location, severity)
