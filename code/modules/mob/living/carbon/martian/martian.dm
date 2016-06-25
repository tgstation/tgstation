//WORK IN PROGRESS - Martians (name may be changed)
//Like octopuses but with 6 hands
//In current state they don't inherit anything from monkeys or humans. Might be better if they did
//

/mob/living/carbon/martian
	name = "martian"
	desc = "An alien creature resembling an octopus."
	voice_name = "martian"

	icon = 'icons/mob/martian.dmi'
	icon_state = "martian"

	species_type = /mob/living/carbon/martian

	held_items = list(null, null, null, null, null, null) //6 hands

	var/obj/item/head //Item worn on head

/mob/living/carbon/martian/New()
	create_reagents(200)

	..()

/mob/living/carbon/martian/get_item_offset_by_index(index)
	switch(index)
		if(1,6)
			return list("x"=0, "y"=0)
		if(2,5)
			return list("x"=0, "y"=10)
		if(3,4)
			return list("x"=0, "y"=18)

	return list()

/mob/living/carbon/martian/get_held_item_ui_location(index)
	if(!is_valid_hand_index(index)) return

	switch(index)
		if(1) return "CENTER-3:16,SOUTH:5"
		if(2) return "CENTER-2:16,SOUTH:5:4"
		if(3) return "CENTER-1:16,SOUTH:5:10"
		if(4) return "CENTER+1:16,SOUTH:5:10"
		if(5) return "CENTER+2:16,SOUTH:5:4"
		if(6) return "CENTER+3:16,SOUTH:5"
		else return ..()

/mob/living/carbon/martian/get_index_limb_name(index)
	if(!index) index = active_hand

	switch(index)
		if(1) return "right lower tentacle"
		if(2) return "right middle tentacle"
		if(3) return "right upper tentacle"
		if(4) return "left upper tentacle"
		if(5) return "left middle tentacle"
		if(6) return "left lower tentacle"
		else return "tentacle"

/mob/living/carbon/martian/get_direction_by_index(index)
	if(index <= 3)
		return "right_hand"
	else
		return "left_hand"


/mob/living/carbon/martian/IsAdvancedToolUser()
	return 1

/mob/living/carbon/martian/GetAccess()
	var/list/ACL=list()

	for(var/obj/item/I in held_items)
		ACL |= I.GetAccess()

	return ACL

/mob/living/carbon/martian/can_wield()
	return 1

/mob/living/carbon/martian/u_equip(obj/item/W as obj, dropped = 1)
	var/success = 0

	if(!W)	return 0

	if (W == head)
		head = null
		success = 1
		update_inv_head()
	else
		..()

	if(success)
		if (W)
			if(client)
				client.screen -= W
			W.forceMove(loc)
			W.unequipped()
			if(dropped)
				W.dropped(src)
			if(W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)

	return

/mob/living/carbon/martian/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!istype(W)) return

	if(src.is_holding_item(W))
		src.u_equip(W)

	if(slot == slot_head)
		head = W
		update_inv_head(redraw_mob)

	W.layer = 20
	W.plane = PLANE_HUD
	W.equipped(src, slot)
	W.forceMove(src)
	if(client) client.screen |= W
