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
	RegisterSignal(target, COMSIG_NPC_FISHING, PROC_REF(return_glob_fishing_spot))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examined_more))
	RegisterSignal(target, COMSIG_ATOM_EX_ACT, PROC_REF(explosive_fishing))
	RegisterSignal(target, COMSIG_FISH_RELEASED_INTO, PROC_REF(fish_released))
	RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(link_to_fish_porter))

/datum/element/lazy_fishing_spot/Detach(datum/target)
	UnregisterSignal(target, list(
		COMSIG_FISH_RELEASED_INTO,
		COMSIG_PRE_FISHING,
		COMSIG_NPC_FISHING,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_EXAMINE_MORE,
		COMSIG_ATOM_EX_ACT,
		COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL),
	))
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

	if(!fish_source.has_known_fishes())
		return

	examine_text += span_tinynoticeital("This is a fishing spot. You can look again to list its fishes...")

/datum/element/lazy_fishing_spot/proc/on_examined_more(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		return

	var/datum/fish_source/fish_source = GLOB.preset_fish_sources[configuration]
	fish_source.get_catchable_fish_names(user, source, examine_text)

/datum/element/lazy_fishing_spot/proc/explosive_fishing(atom/location, severity)
	SIGNAL_HANDLER
	var/datum/fish_source/fish_source = GLOB.preset_fish_sources[configuration]
	fish_source.spawn_reward_from_explosion(location, severity)

/datum/element/lazy_fishing_spot/proc/return_glob_fishing_spot(datum/source, list/fish_spot_container)
	fish_spot_container[NPC_FISHING_SPOT] = GLOB.preset_fish_sources[configuration]

/datum/element/lazy_fishing_spot/proc/link_to_fish_porter(atom/source, mob/user, obj/item/multitool/tool)
	SIGNAL_HANDLER
	if(!istype(tool.buffer, /obj/machinery/fishing_portal_generator))
		return
	var/datum/fish_source/fish_source = GLOB.preset_fish_sources[configuration]
	var/obj/machinery/fishing_portal_generator/portal = tool.buffer
	return portal.link_fishing_spot(fish_source, source, user)

/datum/element/lazy_fishing_spot/proc/fish_released(datum/source, obj/item/fish/fish, mob/living/releaser)
	SIGNAL_HANDLER
	var/datum/fish_source/fish_source = GLOB.preset_fish_sources[configuration]
	fish_source.readd_fish(fish, releaser)
