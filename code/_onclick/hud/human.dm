/obj/screen/human
	icon = 'icons/mob/screen_midnight.dmi'

/obj/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/obj/screen/human/toggle/Click()

	var/mob/targetmob = usr

	if(isobserver(usr))
		if(ishuman(usr.client.eye) && (usr.client.eye != usr))
			var/mob/M = usr.client.eye
			targetmob = M

	if(usr.hud_used.inventory_shown && targetmob.hud_used)
		usr.hud_used.inventory_shown = 0
		usr.client.screen -= targetmob.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = 1
		usr.client.screen += targetmob.hud_used.toggleable_inventory

	targetmob.hud_used.hidden_inventory_update(usr)

/obj/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/obj/screen/human/equip/Click()
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/obj/screen/devil
	invisibility = INVISIBILITY_ABSTRACT

/obj/screen/devil/soul_counter
	icon = 'icons/mob/screen_gen.dmi'
	name = "souls owned"
	icon_state = "Devil-6"
	screen_loc = ui_devilsouldisplay

/obj/screen/devil/soul_counter/proc/update_counter(souls = 0)
	invisibility = 0
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#FF0000'>[souls]</font></div>"
	switch(souls)
		if(0,null)
			icon_state = "Devil-1"
		if(1,2)
			icon_state = "Devil-2"
		if(3 to 5)
			icon_state = "Devil-3"
		if(6 to 8)
			icon_state = "Devil-4"
		if(9 to INFINITY)
			icon_state = "Devil-5"
		else
			icon_state = "Devil-6"

/obj/screen/devil/soul_counter/proc/clear()
	invisibility = INVISIBILITY_ABSTRACT

/obj/screen/ling
	invisibility = INVISIBILITY_ABSTRACT

/obj/screen/ling/sting
	name = "current sting"
	screen_loc = ui_lingstingdisplay

/obj/screen/ling/sting/Click()
	if(isobserver(usr))
		return
	var/mob/living/carbon/U = usr
	U.unset_sting()

/obj/screen/ling/chems
	name = "chemical storage"
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay

/mob/living/carbon/human/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/human(src, ui_style2icon(client.prefs.UI_style))


/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/inventory/craft
	using.icon = ui_style
	static_inventory += using

	using = new/obj/screen/wheel/talk
	using.icon = ui_style
	wheels += using
	static_inventory += using

	using = new /obj/screen/inventory/area_creator
	using.icon = ui_style
	static_inventory += using

	using = new /obj/screen/act_intent()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	using.screen_loc = ui_movi
	static_inventory += using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = slot_w_uniform
	inv_box.icon_state = "uniform"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_iclothing
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = slot_wear_suit
	inv_box.icon_state = "suit"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_oclothing
	toggleable_inventory += inv_box

	build_hand_slots(ui_style)

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand_position(owner,1)
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "id"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
//	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = slot_wear_id
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = slot_wear_mask
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "neck"
	inv_box.icon = ui_style
	inv_box.icon_state = "neck"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_neck
	inv_box.slot_id = slot_neck
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
//	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
//	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = slot_l_store
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
//	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = slot_r_store
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = slot_s_store
	static_inventory += inv_box

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	using = new /obj/screen/human/toggle()
	using.icon = ui_style
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/human/equip()
	using.icon = ui_style
	using.screen_loc = ui_equip_position(mymob)
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = slot_gloves
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = slot_glasses
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "ears"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_ears
	inv_box.slot_id = slot_ears
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = slot_head
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
//	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = slot_shoes
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
//	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = slot_belt
	static_inventory += inv_box

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = ui_style
	throw_icon.screen_loc = ui_drop_throw
	hotkeybuttons += throw_icon

	internals = new /obj/screen/internals()
	infodisplay += internals

	healths = new /obj/screen/healths()
	infodisplay += healths

	healthdoll = new /obj/screen/healthdoll()
	infodisplay += healthdoll

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_pull_resist
	static_inventory += pull_icon

	lingchemdisplay = new /obj/screen/ling/chems()
	infodisplay += lingchemdisplay

	lingstingdisplay = new /obj/screen/ling/sting()
	infodisplay += lingstingdisplay

	devilsouldisplay = new /obj/screen/devil/soul_counter
	infodisplay += devilsouldisplay

	zone_select =  new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)
	static_inventory += zone_select

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/human/hidden_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H

	if(screenmob.hud_used.inventory_shown && screenmob.hud_used.hud_shown)
		if(H.shoes)
			H.shoes.screen_loc = ui_shoes
			screenmob.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = ui_gloves
			screenmob.client.screen += H.gloves
		if(H.ears)
			H.ears.screen_loc = ui_ears
			screenmob.client.screen += H.ears
		if(H.glasses)
			H.glasses.screen_loc = ui_glasses
			screenmob.client.screen += H.glasses
		if(H.w_uniform)
			H.w_uniform.screen_loc = ui_iclothing
			screenmob.client.screen += H.w_uniform
		if(H.wear_suit)
			H.wear_suit.screen_loc = ui_oclothing
			screenmob.client.screen += H.wear_suit
		if(H.wear_mask)
			H.wear_mask.screen_loc = ui_mask
			screenmob.client.screen += H.wear_mask
		if(H.wear_neck)
			H.wear_neck.screen_loc = ui_neck
			screenmob.client.screen += H.wear_neck
		if(H.head)
			H.head.screen_loc = ui_head
			screenmob.client.screen += H.head
	else
		if(H.shoes)		screenmob.client.screen -= H.shoes
		if(H.gloves)	screenmob.client.screen -= H.gloves
		if(H.ears)		screenmob.client.screen -= H.ears
		if(H.glasses)	screenmob.client.screen -= H.glasses
		if(H.w_uniform)	screenmob.client.screen -= H.w_uniform
		if(H.wear_suit)	screenmob.client.screen -= H.wear_suit
		if(H.wear_mask)	screenmob.client.screen -= H.wear_mask
		if(H.wear_neck)	screenmob.client.screen -= H.wear_neck
		if(H.head)		screenmob.client.screen -= H.head



/datum/hud/human/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	..()
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H

	if(screenmob.hud_used)
		if(screenmob.hud_used.hud_shown)
			if(H.s_store)
				H.s_store.screen_loc = ui_sstore1
				screenmob.client.screen += H.s_store
			if(H.wear_id)
				H.wear_id.screen_loc = ui_id
				screenmob.client.screen += H.wear_id
			if(H.belt)
				H.belt.screen_loc = ui_belt
				screenmob.client.screen += H.belt
			if(H.back)
				H.back.screen_loc = ui_back
				screenmob.client.screen += H.back
			if(H.l_store)
				H.l_store.screen_loc = ui_storage1
				screenmob.client.screen += H.l_store
			if(H.r_store)
				H.r_store.screen_loc = ui_storage2
				screenmob.client.screen += H.r_store
		else
			if(H.s_store)
				screenmob.client.screen -= H.s_store
			if(H.wear_id)
				screenmob.client.screen -= H.wear_id
			if(H.belt)
				screenmob.client.screen -= H.belt
			if(H.back)
				screenmob.client.screen -= H.back
			if(H.l_store)
				screenmob.client.screen -= H.l_store
			if(H.r_store)
				screenmob.client.screen -= H.r_store

	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in H.held_items)
			I.screen_loc = ui_hand_position(H.get_held_index_of_item(I))
			screenmob.client.screen += I
	else
		for(var/obj/item/I in H.held_items)
			I.screen_loc = null
			screenmob.client.screen -= I


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1
