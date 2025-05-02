/**
 * Basic handling for showing held items in a mob's hands
 */
/datum/component/basic_inhands
	/// Layer index we show our inhands upon
	var/display_layer
	/// Y offset to apply to inhands
	var/y_offset
	/// X offset to apply to inhands, is inverted for the left hand
	var/x_offset
	/// What overlays are we currently showing?
	var/list/cached_overlays

/datum/component/basic_inhands/Initialize(display_layer = 1, y_offset = 0, x_offset = 0)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.display_layer = display_layer
	src.y_offset = y_offset
	src.x_offset = x_offset
	cached_overlays = list()

/datum/component/basic_inhands/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_updated_overlays))
	RegisterSignal(parent, COMSIG_MOB_UPDATE_HELD_ITEMS, PROC_REF(on_updated_held_items))

/datum/component/basic_inhands/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_MOB_UPDATE_HELD_ITEMS))

/// When your overlays update, add your held overlays
/datum/component/basic_inhands/proc/on_updated_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	overlays += cached_overlays

/// When your number of held items changes, regenerate held icons
/datum/component/basic_inhands/proc/on_updated_held_items(mob/living/holding_mob)
	SIGNAL_HANDLER
	var/list/held_overlays = list()
	for(var/obj/item/held in holding_mob.held_items)
		var/is_right = IS_RIGHT_INDEX(holding_mob.get_held_index_of_item(held))
		var/icon_file = is_right ? held.righthand_file : held.lefthand_file
		var/mutable_appearance/held_overlay = held.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)
		held_overlay.pixel_z += y_offset
		held_overlay.pixel_w += x_offset * (is_right ? 1 : -1)
		held_overlays += held_overlay

	cached_overlays = held_overlays
	holding_mob.update_appearance(UPDATE_OVERLAYS)
