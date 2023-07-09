/**
 * Area-based godmode.
 * (area, allow_area_subtypes, gain_message, lose_message)
 */
/datum/element/area_based_godmode
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// The type of area that will trigger godmode.
	var/area_type

	/// Whether or not to allow subtypes of the area type to trigger godmode.
	var/allow_area_subtypes

	/// The message to send to the mob when they gain godmode.
	var/gain_message

	/// The message to send to the mob when they lose godmode.
	var/lose_message

/datum/element/area_based_godmode/Attach(
	datum/target,
	area_type,
	allow_area_subtypes = FALSE,
	gain_message = span_big(span_green("You are now invulnerable.")),
	lose_message = span_big(span_red("You are no longer invulnerable.")),
)
	. = ..()

	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/mob_target = target
	if(initial(mob_target.status_flags) & GODMODE)
		return ELEMENT_INCOMPATIBLE

	src.area_type = area_type
	src.allow_area_subtypes = allow_area_subtypes
	src.gain_message = gain_message
	src.lose_message = lose_message

	mob_target.become_area_sensitive(type)
	RegisterSignal(target, COMSIG_ENTER_AREA, PROC_REF(check_area))
	check_area(target)

/datum/element/area_based_godmode/Detach(datum/source, ...)
	var/mob/mob_source = source
	mob_source.lose_area_sensitivity(type)
	UnregisterSignal(source, COMSIG_ENTER_AREA)
	mob_source.status_flags &= ~GODMODE
	return ..()

/datum/element/area_based_godmode/proc/check_in_valid_area(mob/checking)
	var/area/area = get_area(checking)
	if(area.type == area_type)
		return TRUE

	if(!allow_area_subtypes)
		return FALSE
	return istype(area, area_type)

/datum/element/area_based_godmode/proc/check_area(mob/source)
	SIGNAL_HANDLER

	var/source_id = "[REF(source)]"
	var/has_godmode = source.status_flags & GODMODE

	if(!check_in_valid_area(source))
		if(has_godmode)
			to_chat(source, lose_message)
			source.status_flags ^= GODMODE
		return

	if(has_godmode)
		return

	to_chat(source, gain_message)
	source.status_flags ^= GODMODE
