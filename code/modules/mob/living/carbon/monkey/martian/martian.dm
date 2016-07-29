/mob/living/carbon/monkey/martian
	name = "mutated monkey"
	voice_name = "mutated monkey"
	held_items = list(null, null, null, null)

	canWearHats = 0
	canWearClothes = 0
	canWearGlasses = 0

/mob/living/carbon/monkey/martian/New()
	..()
	overlays_standing.len = 14

/mob/living/carbon/monkey/martian/get_held_item_ui_location(index)
	if(!is_valid_hand_index(index)) return

	switch(index)
		if(GRASP_LEFT_HAND) return "CENTER-1:16,SOUTH:5"
		if(GRASP_RIGHT_HAND)return "CENTER:16,SOUTH:5"
		if(3) return "CENTER-1:16,SOUTH+1:5"
		if(4) return "CENTER:16,SOUTH+1:5"

/mob/living/carbon/monkey/martian/get_index_limb_name(var/index)
	if(!index) index = active_hand

	switch(index)
		if(GRASP_LEFT_HAND) return "lower left hand"
		if(GRASP_RIGHT_HAND) return "lower right hand"
		if(3) return "upper left hand"
		if(4) return "upper right hand"

/mob/living/carbon/monkey/martian/get_item_offset_by_index(index)
	switch(index)
		if(3)
			return list("x"=0, "y"=18)
		if(4)
			return list("x"=0, "y"=18)

	return list()

/mob/living/carbon/monkey/martian/update_inv_l_hand(update_icons = 1)
	return update_inv_hand(GRASP_LEFT_HAND, update_icons)

/mob/living/carbon/monkey/martian/update_inv_r_hand(update_icons = 1)
	return update_inv_hand(GRASP_RIGHT_HAND, update_icons)

/mob/living/carbon/monkey/martian/update_inv_hand(index, var/update_icons=1)
	var/obj/item/I = get_held_item_by_index(index)
	var/list/offsets = get_item_offset_by_index(index)
	var/pixelx = 0
	var/pixely = 0
	if(offsets["x"])
		pixelx = offsets["x"]
	if(offsets["y"])
		pixely = offsets["y"]

	if(I)
		var/t_state = I.item_state
		var/t_inhand_states = I.inhand_states[get_direction_by_index(index)]
		if(!t_state)	t_state = I.icon_state
		overlays_standing[10 + index]	= image("icon" = t_inhand_states, "icon_state" = t_state, "pixel_x" = pixelx, "pixel_y" = pixely)
		I.screen_loc = get_held_item_ui_location(index)
		if (handcuffed)
			drop_item(I)
	else
		overlays_standing[10 + index]	= null
	if(update_icons)		update_icons()
