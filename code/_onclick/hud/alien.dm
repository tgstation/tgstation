/obj/screen/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"

/obj/screen/alien/leap/Click()
	if(istype(usr, /mob/living/carbon/alien/humanoid/hunter))
		var/mob/living/carbon/alien/humanoid/hunter/AH = usr
		AH.toggle_leap()

/obj/screen/alien/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"
	screen_loc = ui_alien_nightvision

/obj/screen/alien/nightvision/Click()
	var/mob/living/carbon/alien/A = usr
	var/obj/effect/proc_holder/alien/nightvisiontoggle/T = locate() in A.abilities
	if(T)
		T.fire(A)


/obj/screen/alien/plasma_display
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "power_display2"
	name = "plasma stored"
	screen_loc = ui_alienplasmadisplay

/datum/hud/alien/New(mob/living/carbon/alien/humanoid/owner)
	..()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

//equippable shit

//hands
	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "right hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_r"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.name = "left hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_l"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	static_inventory += inv_box

//begin buttons

	using = new /obj/screen/swap_hand()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	static_inventory += using

	using = new /obj/screen/act_intent/alien()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	if(istype(mymob, /mob/living/carbon/alien/humanoid/hunter))
		var/mob/living/carbon/alien/humanoid/hunter/H = mymob
		H.leap_icon = new /obj/screen/alien/leap()
		H.leap_icon.screen_loc = ui_alien_storage_r
		static_inventory += H.leap_icon

	using = new /obj/screen/drop()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.screen_loc = ui_drop_throw
	static_inventory += using

	using = new /obj/screen/resist()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = 'icons/mob/screen_alien.dmi'
	throw_icon.screen_loc = ui_drop_throw
	hotkeybuttons += throw_icon

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen_alien.dmi'
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_pull_resist
	static_inventory += pull_icon

//begin indicators

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	nightvisionicon = new /obj/screen/alien/nightvision()
	infodisplay += nightvisionicon

	alien_plasma_display = new /obj/screen/alien/plasma_display()
	infodisplay += alien_plasma_display

	zone_select = new /obj/screen/zone_sel/alien()
	zone_select.update_icon(mymob)
	static_inventory += zone_select

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/alien/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/alien/humanoid/H = mymob
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

/mob/living/carbon/alien/humanoid/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/alien(src)
