#define CLICKBOX_LAYER FLOAT_LAYER-999

/**
 * This component adds a near-invisible underlay to a movable target to expand the clickable surface of its icon without
 * resorting to MOUSE_OPACITY_OPAQUE.
 * The underlay ignores the parent's color and alpha and can be offset.
 * The name is a portmanteau of "click" and "hitbox", because technically this isn't an hitbox,
 * but it helps catch clicks, and I don't want to give it a loooong name like openspace_item_click_handler
 */
/datum/component/clickbox
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// The icon state of the underlay.
	var/icon_state = "sphere"
	/// The offsets of the underlay.
	var/x_offset = 0
	var/y_offset = 0
	/// Maximum width/height of the underlay, in case the attached atom is scaled up.
	var/max_scale = 2
	/// Minimum width/height of the underlay, in case the attached atom is scaled down.
	var/min_scale = 0.5
	/// For simple animals that have different icon states when dead.
	var/dead_state
	/// the underlay that has been added to the parent.
	var/mutable_appearance/clickbox_undelay

/datum/component/clickbox/Initialize(icon_state = "sphere", x_offset = 0, y_offset = 0, max_scale = 2, min_scale = 0.5, dead_state)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.icon_state = icon_state
	src.x_offset = x_offset
	src.y_offset = y_offset
	src.max_scale = max_scale
	src.min_scale = min_scale

	RegisterSignal(parent, COMSIG_ATOM_VV_MODIFY_TRANSFORM, .proc/on_modify_or_update_transform)

	var/clickbox_icon_state = icon_state
	if(dead_state && isliving(parent))
		var/mob/living/living_parent = parent
		src.dead_state = dead_state
		RegisterSignal(living_parent, COMSIG_LIVING_POST_UPDATE_TRANSFORM, .proc/on_modify_or_update_transform)
		RegisterSignal(living_parent, COMSIG_LIVING_DEATH, .proc/on_death)
		RegisterSignal(living_parent, COMSIG_LIVING_REVIVE, .proc/on_revive)
		if(living_parent.stat == DEAD)
			clickbox_icon_state = dead_state
	update_underlay(clickbox_icon_state)

/datum/component/clickbox/UnregisterFromParent()
	var/atom/movable/mov_parent = parent
	UnregisterSignal(mov_parent, list(COMSIG_ATOM_VV_MODIFY_TRANSFORM, COMSIG_LIVING_POST_UPDATE_TRANSFORM, COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))
	mov_parent.underlays -= clickbox_undelay

/// Removes the old underlay and adds a new one if conditions are met. The underlay is scaled up/down if necessary
/datum/component/clickbox/proc/update_underlay(clickbox_icon_state)
	var/atom/movable/mov_parent = parent
	if(!clickbox_icon_state)
		clickbox_icon_state = clickbox_undelay?.icon_state || icon_state
	mov_parent.underlays -= clickbox_undelay // Remove the previous underlay.

	var/width = abs(mov_parent.transform.a) // Negative values flip the parent, so abs() is good to have here.
	var/height = abs(mov_parent.transform.e) // Idem.

	var/clickbox_width = 1
	if(width > max_scale)
		clickbox_width = max_scale/width
	else if(width < min_scale && width)
		clickbox_width = min_scale/width

	var/clickbox_height = 1
	if(height > max_scale)
		clickbox_height = max_scale/height
	else if(height < min_scale && height)
		clickbox_height = min_scale/height

	clickbox_undelay = mutable_appearance('icons/misc/clickbox.dmi', clickbox_icon_state, CLICKBOX_LAYER, alpha = 1, appearance_flags = RESET_COLOR|RESET_ALPHA)
	clickbox_undelay.transform = clickbox_undelay.transform.Scale(clickbox_width, clickbox_height)
	//Keeps the underlay more or less centered.
	clickbox_undelay.pixel_x = x_offset * 1/clickbox_width
	clickbox_undelay.pixel_y = y_offset * 1/clickbox_height
	mov_parent.underlays += clickbox_undelay

/datum/component/clickbox/proc/on_modify_or_update_transform(atom/source)
	SIGNAL_HANDLER
	update_underlay()

/datum/component/clickbox/proc/on_death(mob/living/source)
	SIGNAL_HANDLER
	update_underlay(dead_state)

/datum/component/clickbox/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER
	update_underlay(icon_state)

#undef CLICKBOX_LAYER
