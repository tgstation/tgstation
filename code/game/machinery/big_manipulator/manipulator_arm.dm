/// Manipulator hand. Effect we animate to show that the manipulator is working and moving something.
/obj/effect/big_manipulator_arm
	name = "mechanical claw"
	desc = "Takes and drops objects."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_hand.dmi'
	icon_state = "hand"
	layer = LOW_ITEM_LAYER
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | TILE_BOUND | PIXEL_SCALE
	anchored = TRUE
	greyscale_config = /datum/greyscale_config/manipulator_arm
	pixel_x = -32
	pixel_y = -32
	/// We get item from big manipulator and takes its icon to create overlay.
	var/datum/weakref/item_in_my_claw
	/// Var to icon that used as overlay on manipulator claw to show what item it grabs.
	var/mutable_appearance/icon_overlay

/obj/effect/big_manipulator_arm/update_overlays()
	. = ..()
	. += update_item_overlay()

/obj/effect/big_manipulator_arm/proc/update_item_overlay()
	if(isnull(item_in_my_claw))
		return icon_overlay = null
	var/atom/movable/item_data = item_in_my_claw.resolve()
	icon_overlay = mutable_appearance(item_data.icon, item_data.icon_state, item_data.layer, src, item_data.plane, item_data.alpha, item_data.appearance_flags)
	icon_overlay.color = item_data.color
	icon_overlay.appearance = item_data.appearance
	icon_overlay.pixel_w = 32 + calculate_item_offset(is_x = TRUE)
	icon_overlay.pixel_z = 32 + calculate_item_offset(is_x = FALSE)
	return icon_overlay

/// Updates item that is in the claw.
/obj/effect/big_manipulator_arm/proc/update_claw(clawed_item)
	item_in_my_claw = clawed_item
	update_appearance()

/// Calculate x and y coordinates so that the item icon appears in the claw and not somewhere in the corner.
/obj/effect/big_manipulator_arm/proc/calculate_item_offset(is_x = TRUE, pixels_to_offset = 32)
	var/offset
	switch(dir)
		if(NORTH)
			offset = is_x ? 0 : pixels_to_offset
		if(SOUTH)
			offset = is_x ? 0 : -pixels_to_offset
		if(EAST)
			offset = is_x ? pixels_to_offset : 0
		if(WEST)
			offset = is_x ? -pixels_to_offset : 0
	return offset
