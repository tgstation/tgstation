#define CLICKBOX_LAYER FLOAT_LAYER-999

/**
 * This element adds a near-invisible underlay to the movable target to expand the surface of its icon without
 * resorting to MOUSE_OPACITY_OPAQUE.
 * The underlay ignores the parent's color and alpha and can be offset.
 * The name is a portmanteau of "click" and "hitbox", because technically this isn't an hitbox,
 * but it helps catch clicks, and I don't want to give it a loooong name like openspace_item_click_handler
 */
/datum/element/clickbox
	element_flags = ELEMENT_DETACH|ELEMENT_BESPOKE
	id_arg_index = 2
	var/image/reference_clickbox
	var/list/mutable_appearances_by_mov = list()
	/// maximum width/height of the underlay, in case the attached atom is scaled up.
	var/max_scale = 2
	/// minimum width/height of the underlay, in case the attached atom is scaled down.
	var/min_scale = 0.5
	/// For simple animals that have different sprites when dead.
	var/dead_state

/datum/element/clickbox/Attach(datum/target, icon_state = "sphere", x_offset = 0, y_offset = 0, max_scale = 2, min_scale = 0.5, dead_state)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!reference_clickbox)
		reference_clickbox = image(icon = 'icons/misc/clickbox.dmi', icon_state = icon_state, layer = CLICKBOX_LAYER)
		reference_clickbox.pixel_x = x_offset
		reference_clickbox.pixel_y = y_offset
		reference_clickbox.alpha = 1 // Basic
		reference_clickbox.appearance_flags = RESET_COLOR|RESET_ALPHA
	if(max_scale)
		src.max_scale = max_scale
	if(min_scale)
		src.min_scale = min_scale
	RegisterSignal(target, list(COMSIG_ATOM_VV_MODIFY_TRANSFORM, COMSIG_MOB_UPDATE_TRANSFORM), .proc/on_modify_or_update_transform)
	var/clickbox_icon_state = icon_state
	if(dead_state && isliving(target))
		var/mob/living/living_target
		src.dead_state = dead_state
		RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)
		RegisterSignal(target, COMSIG_LIVING_REVIVE, .proc/on_revive)
		if(living_target.stat == DEAD)
			clickbox_icon_state = dead_state
	update_underlay(target, clickbox_icon_state)

/datum/element/clickbox/Detach(atom/movable/source)
	UnregisterSignal(source, list(COMSIG_ATOM_VV_MODIFY_TRANSFORM, COMSIG_MOB_UPDATE_TRANSFORM, COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))
	var/mutable_appearance/clickbox = mutable_appearances_by_mov[source]
	source.underlays -= clickbox
	mutable_appearances_by_mov -= source

	return ..()

/// Removes the old underlay and adds a new one if conditions are met. The underlay is scaled up/down if necessary
/datum/element/clickbox/proc/update_underlay(atom/target, clickbox_icon_state)
	var/mutable_appearance/old_clickbox = mutable_appearances_by_mov[target]
	if(!clickbox_icon_state)
		clickbox_icon_state = old_clickbox?.icon_state || reference_clickbox.icon_state
	target.underlays -= old_clickbox // Remove the previous underlay.

	var/width = abs(target.transform.a) // Negative values flip the target, so abs() is good to have here.
	var/height = abs(target.transform.e) // Idem.

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

	var/mutable_appearance/clickbox = new
	clickbox.appearance = reference_clickbox.appearance
	clickbox.icon_state = clickbox_icon_state
	clickbox.transform = clickbox.transform.Scale(clickbox_width, clickbox_height)
	//Keeps the underlay more or less centered.
	clickbox.pixel_x *= width
	clickbox.pixel_y *= height
	target.underlays += clickbox
	mutable_appearances_by_mov[target] = clickbox

/datum/element/clickbox/proc/on_modify_or_update_transform(atom/source)
	SIGNAL_HANDLER
	update_underlay(source)

/datum/element/clickbox/proc/on_death(mob/living/source)
	SIGNAL_HANDLER
	update_underlay(source, dead_state)

/datum/element/clickbox/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER
	update_underlay(source, reference_clickbox.icon_state)

#undef CLICKBOX_LAYER
