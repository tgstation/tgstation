/**
 * Area-based godmode.
 * (area, allow_area_subtypes, gain_message, lose_message)
 */
/datum/component/area_based_godmode
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// The type of area that will trigger godmode.
	var/area_type

	/// Whether or not to allow subtypes of the area type to trigger godmode.
	var/allow_area_subtypes

	/// The message to send to the mob when they gain godmode.
	var/gain_message

	/// The message to send to the mob when they lose godmode.
	var/lose_message

/datum/component/area_based_godmode/Initialize(
	area_type,
	allow_area_subtypes = FALSE,
	gain_message = span_big(span_green("You are now invulnerable.")),
	lose_message = span_big(span_red("You are no longer invulnerable.")),
)
	. = ..()

	var/mob/mob_target = parent
	if(!istype(mob_target))
		return COMPONENT_INCOMPATIBLE

	if(initial(mob_target.status_flags) & GODMODE)
		return COMPONENT_INCOMPATIBLE

	var/list/datum/component/area_based_godmode/others = mob_target.GetComponents(/datum/component/area_based_godmode)
	for(var/datum/component/area_based_godmode/other as anything in (others - src))
		if(other.area_type == area_type)
			stack_trace("attempted to add a duplicate [type] to [mob_target.type] for [area_type]")
			return COMPONENT_INCOMPATIBLE

	src.area_type = area_type
	src.allow_area_subtypes = allow_area_subtypes
	src.gain_message = gain_message
	src.lose_message = lose_message

	mob_target.become_area_sensitive(REF(src))
	RegisterSignal(mob_target, COMSIG_ENTER_AREA, PROC_REF(check_area))
	check_area(mob_target)

/datum/component/area_based_godmode/UnregisterFromParent()
	var/mob/mob_parent = parent
	mob_parent.lose_area_sensitivity(REF(src))
	UnregisterSignal(mob_parent, COMSIG_ENTER_AREA)
	if(check_in_valid_area(mob_parent))
		to_chat(mob_parent, lose_message)
		mob_parent.status_flags &= ~GODMODE
	return ..()

/datum/component/area_based_godmode/proc/check_in_valid_area(mob/checking)
	var/area/area = get_area(checking)
	if(area.type == area_type)
		return TRUE

	if(!allow_area_subtypes)
		return FALSE
	return istype(area, area_type)

/datum/component/area_based_godmode/proc/check_area(mob/source)
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
