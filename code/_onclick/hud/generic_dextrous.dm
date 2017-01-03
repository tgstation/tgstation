//Used for normal mobs that have hands.
/datum/hud/dextrous/New(mob/living/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	static_inventory += using

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_drone_pull
	static_inventory += pull_icon

	build_hand_slots(ui_style)

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_1_m"
	using.screen_loc = ui_swaphand_position(owner,1)
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	static_inventory += using

	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)

	using = new /obj/screen/inventory/craft
	using.icon = ui_style
	static_inventory += using

	using = new /obj/screen/inventory/area_creator
	using.icon = ui_style
	static_inventory += using

	mymob.client.screen = list()

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/dextrous/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/D = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in D.held_items)
			I.screen_loc = ui_hand_position(D.get_held_index_of_item(I))
			D.client.screen += I
	else
		for(var/obj/item/I in D.held_items)
			I.screen_loc = null
			D.client.screen -= I


//Dextrous simple mobs can use hands!
/mob/living/simple_animal/create_mob_hud()
	if(client && !hud_used)
		if(dextrous)
			hud_used = new dextrous_hud_type(src, ui_style2icon(client.prefs.UI_style))
		else
			..()
