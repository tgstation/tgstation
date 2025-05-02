#define MAP_AREA_TYPE "area_type"
#define MAP_ALLOW_AREA_SUBTYPES "allow_area_subtypes"
#define DEFAULT_GAIN_MESSAGE span_big(span_green("You are now invulnerable."))
#define DEFAULT_LOSE_MESSAGE span_big(span_red("You are no longer invulnerable."))

/**
 * Area-based godmode.
 * Gain and Lose message can only be set once, at initial component creation; adding a source will not update them.
 */
/datum/component/area_based_godmode
	dupe_mode = COMPONENT_DUPE_SOURCES

	/// The type of area that will trigger godmode.
	var/list/sources_to_area_type

	/// Whether or not to allow subtypes of the area type to trigger godmode.
	var/allow_area_subtypes

	/// The message to send to the mob when they gain godmode.
	var/gain_message

	/// The message to send to the mob when they lose godmode.
	var/lose_message

	/// Cached state of check_area, prevents recalculating on source add
	var/check_area_cached_state = FALSE

/datum/component/area_based_godmode/Initialize(
	area_type,
	allow_area_subtypes,
	gain_message = DEFAULT_GAIN_MESSAGE,
	lose_message = DEFAULT_LOSE_MESSAGE,
)
	var/mob/mob_target = parent
	if(!istype(mob_target))
		return COMPONENT_INCOMPATIBLE

	sources_to_area_type = list()
	src.gain_message = gain_message
	src.lose_message = lose_message
	RegisterSignal(mob_target, COMSIG_ENTER_AREA, PROC_REF(check_area))

/datum/component/area_based_godmode/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ENTER_AREA)

/datum/component/area_based_godmode/on_source_add(
	source,
	area_type,
	allow_area_subtypes = FALSE,
	gain_message = DEFAULT_GAIN_MESSAGE,
	lose_message = DEFAULT_LOSE_MESSAGE,
)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/list/information_map = list(
		MAP_AREA_TYPE = area_type,
		MAP_ALLOW_AREA_SUBTYPES = allow_area_subtypes,
	)
	sources_to_area_type[source] = information_map

	var/mob/mob_target = parent // no need to istype here, done at creation
	mob_target.become_area_sensitive("[REF(src)]:[source]")
	if(!check_area_cached_state)
		check_area(mob_target)

/datum/component/area_based_godmode/on_source_remove(source)
	sources_to_area_type -= source
	var/mob/mob_target = parent
	mob_target.lose_area_sensitivity("[REF(src)]:[source]")
	if(check_area_cached_state)
		check_area(mob_target)
	return ..()

/datum/component/area_based_godmode/proc/check_in_valid_area(mob/checking)
	var/list/area/allowed_areas = list()
	for(var/source in sources_to_area_type)
		var/list/source_map = sources_to_area_type[source]
		var/area/top_level = source_map[MAP_AREA_TYPE]
		if(!allowed_areas[top_level])
			allowed_areas[top_level] = source_map[MAP_ALLOW_AREA_SUBTYPES]

	if(!length(allowed_areas))
		stack_trace("called check_in_valid_area with zero sources")
		return FALSE

	var/area/area = get_area(checking)
	if(area.type in allowed_areas)
		return TRUE

	for(var/area/allowed_area as anything in allowed_areas)
		if(!allowed_areas[allowed_area])
			continue
		if(istype(area, allowed_area))
			return TRUE

	return FALSE

/datum/component/area_based_godmode/proc/check_area(mob/source)
	SIGNAL_HANDLER

	var/has_godmode = HAS_TRAIT(source, TRAIT_GODMODE)
	if(!check_in_valid_area(source))
		if(has_godmode)
			to_chat(source, lose_message)
			REMOVE_TRAIT(source, TRAIT_GODMODE, REF(src))
		check_area_cached_state = FALSE
		return

	check_area_cached_state = TRUE
	if(has_godmode)
		return

	to_chat(source, gain_message)
	ADD_TRAIT(source, TRAIT_GODMODE, REF(src))

#undef MAP_AREA_TYPE
#undef MAP_ALLOW_AREA_SUBTYPES
#undef DEFAULT_GAIN_MESSAGE
#undef DEFAULT_LOSE_MESSAGE
