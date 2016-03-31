/obj/screen/human
	icon = 'icons/mob/screen_midnight.dmi'

/obj/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/obj/screen/human/toggle/Click()
	if(usr.hud_used.inventory_shown)
		usr.hud_used.inventory_shown = 0
		usr.client.screen -= usr.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = 1
		usr.client.screen += usr.hud_used.toggleable_inventory

	usr.hud_used.hidden_inventory_update()

/obj/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/obj/screen/human/equip/Click()
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/obj/screen/ling
	invisibility = 101

/obj/screen/ling/sting
	name = "current sting"
	screen_loc = ui_lingstingdisplay

/obj/screen/ling/sting/Click()
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

	using = new /obj/screen/act_intent()
	using.icon_state = mymob.a_intent
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
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
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
	using.screen_loc = ui_equip
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


	zone_select =  new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)
	static_inventory += zone_select

	inventory_shown = 0

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/human/hidden_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(inventory_shown && hud_shown)
		if(H.shoes)
			H.shoes.screen_loc = ui_shoes
			H.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = ui_gloves
			H.client.screen += H.gloves
		if(H.ears)
			H.ears.screen_loc = ui_ears
			H.client.screen += H.ears
		if(H.glasses)
			H.glasses.screen_loc = ui_glasses
			H.client.screen += H.glasses
		if(H.w_uniform)
			H.w_uniform.screen_loc = ui_iclothing
			H.client.screen += H.w_uniform
		if(H.wear_suit)
			H.wear_suit.screen_loc = ui_oclothing
			H.client.screen += H.wear_suit
		if(H.wear_mask)
			H.wear_mask.screen_loc = ui_mask
			H.client.screen += H.wear_mask
		if(H.head)
			H.head.screen_loc = ui_head
			H.client.screen += H.head
	else
		if(H.shoes)		H.shoes.screen_loc = null
		if(H.gloves)	H.gloves.screen_loc = null
		if(H.ears)		H.ears.screen_loc = null
		if(H.glasses)	H.glasses.screen_loc = null
		if(H.w_uniform)	H.w_uniform.screen_loc = null
		if(H.wear_suit)	H.wear_suit.screen_loc = null
		if(H.wear_mask)	H.wear_mask.screen_loc = null
		if(H.head)		H.head.screen_loc = null

/datum/hud/human/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(hud_shown)
		if(H.s_store)
			H.s_store.screen_loc = ui_sstore1
			H.client.screen += H.s_store
		if(H.wear_id)
			H.wear_id.screen_loc = ui_id
			H.client.screen += H.wear_id
		if(H.belt)
			H.belt.screen_loc = ui_belt
			H.client.screen += H.belt
		if(H.back)
			H.back.screen_loc = ui_back
			H.client.screen += H.back
		if(H.l_store)
			H.l_store.screen_loc = ui_storage1
			H.client.screen += H.l_store
		if(H.r_store)
			H.r_store.screen_loc = ui_storage2
			H.client.screen += H.r_store
	else
		if(H.s_store)
			H.s_store.screen_loc = null
		if(H.wear_id)
			H.wear_id.screen_loc = null
		if(H.belt)
			H.belt.screen_loc = null
		if(H.back)
			H.back.screen_loc = null
		if(H.l_store)
			H.l_store.screen_loc = null
		if(H.r_store)
			H.r_store.screen_loc = null

	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = ui_rhand
			H.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = ui_lhand
			H.client.screen += H.l_hand
	else
		if(H.r_hand)
			H.r_hand.screen_loc = null
		if(H.l_hand)
			H.l_hand.screen_loc = null

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
