//(re)builds the hand ui slots, throwing away old ones
//not really worth jugglying existing ones so we just scrap+rebuild
//9/10 this is only called once per mob and only for 2 hands
/datum/hud/living/basic/build_hand_slots()
	for(var/h in hand_slots)
		var/atom/movable/screen/inventory/hand/H = hand_slots[h]
		if(H)
			static_inventory -= H
	hand_slots = list()
	var/atom/movable/screen/inventory/hand/hand_box
	for(var/i in 1 to mymob.held_items.len)
		hand_box = new /atom/movable/screen/inventory/hand()
		hand_box.name = mymob.get_held_index_name(i)
		if(mymob.client)
			hand_box.icon = ui_style2icon(mymob.client.prefs?.read_preference(/datum/preference/choiced/ui_style))
		else
			hand_box.icon = ui_style
		hand_box.icon_state = "hand_[mymob.held_index_to_dir(i)]"
		hand_box.screen_loc = ui_hand_position(i)
		hand_box.held_index = i
		hand_slots["[i]"] = hand_box
		hand_box.hud = src
		static_inventory += hand_box
		hand_box.update_appearance()

	var/i = 1
	for(var/atom/movable/screen/swap_hand/SH in static_inventory)
		SH.screen_loc = ui_swaphand_position(mymob,!(i % 2) ? 2: 1)
		i++
	for(var/atom/movable/screen/human/equip/E in static_inventory)
		E.screen_loc = ui_equip_position(mymob)

	if(ismob(mymob) && mymob.hud_used == src)
		show_hud(hud_version)
