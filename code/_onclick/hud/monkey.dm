/datum/hud/monkey/New(mob/living/carbon/monkey/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent()
	using.icon = ui_style
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_acti
	static_inventory += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	static_inventory += using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	static_inventory += using

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "right hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "left hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	static_inventory += inv_box

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_1_m"	//extra wide!
	using.screen_loc = ui_swaphand1
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_monkey_mask
	inv_box.slot_id = slot_wear_mask
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_monkey_head
	inv_box.slot_id = slot_head
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	static_inventory += inv_box

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = ui_style
	throw_icon.screen_loc = ui_drop_throw
	hotkeybuttons += throw_icon

	internals = new /obj/screen/internals()
	infodisplay += internals

	healths = new /obj/screen/healths()
	infodisplay += healths

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_pull_resist
	static_inventory += pull_icon

	lingchemdisplay = new /obj/screen/ling/chems()
	infodisplay += lingchemdisplay

	lingstingdisplay = new /obj/screen/ling/sting()
	infodisplay += lingstingdisplay


	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)
	static_inventory += zone_select

	mymob.client.screen = list()

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/monkey/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/monkey/M = mymob

	if(hud_shown)
		if(M.back)
			M.back.screen_loc = ui_back
			M.client.screen += M.back
		if(M.wear_mask)
			M.wear_mask.screen_loc = ui_monkey_mask
			M.client.screen += M.wear_mask
		if(M.head)
			M.head.screen_loc = ui_monkey_head
			M.client.screen += M.head
	else
		if(M.back)
			M.back.screen_loc = null
		if(M.wear_mask)
			M.wear_mask.screen_loc = null
		if(M.head)
			M.head.screen_loc = null

	if(hud_version != HUD_STYLE_NOHUD)
		if(M.r_hand)
			M.r_hand.screen_loc = ui_rhand
			M.client.screen += M.r_hand
		if(M.l_hand)
			M.l_hand.screen_loc = ui_lhand
			M.client.screen += M.l_hand
	else
		if(M.r_hand)
			M.r_hand.screen_loc = null
		if(M.l_hand)
			M.l_hand.screen_loc = null

/mob/living/carbon/monkey/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/monkey(src, ui_style2icon(client.prefs.UI_style))
