<<<<<<< HEAD
/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = ABOVE_HUD_LAYER
	unacidable = 1
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.

/obj/screen/Destroy()
	master = null
	return ..()


/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/swap_hand
	layer = HUD_LAYER
	name = "swap hand"

/obj/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/obj/screen/inventory/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/inventory/craft/Click()
	var/mob/living/M = usr
	M.OpenCraftingMenu()

/obj/screen/inventory
	var/slot_id	// The indentifier for the slot. It has nothing to do with ID cards.
	var/icon_empty // Icon when empty. For now used only by humans.
	var/icon_full  // Icon when contains an item. For now used only by humans.
	layer = HUD_LAYER

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(usr.attack_ui(slot_id))
		usr.update_inv_l_hand(0)
		usr.update_inv_r_hand(0)
	return 1

/obj/screen/inventory/update_icon()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud && hud.mymob && slot_id && icon_full)
		if(hud.mymob.get_item_by_slot(slot_id))
			icon_state = icon_full
		else
			icon_state = icon_empty

/obj/screen/inventory/hand
	var/image/active_overlay
	var/image/handcuff_overlay
	var/image/blocked_overlay

/obj/screen/inventory/hand/update_icon()
	..()
	if(!active_overlay)
		active_overlay = image("icon"=icon, "icon_state"="hand_active")
	if(!handcuff_overlay)
		var/state = (slot_id == slot_r_hand) ? "markus" : "gabrielle"
		handcuff_overlay = image("icon"='icons/mob/screen_gen.dmi', "icon_state"=state)
	if(!blocked_overlay)
		blocked_overlay = image("icon"='icons/mob/screen_gen.dmi', "icon_state"="blocked")

	cut_overlays()

	if(hud && hud.mymob)
		if(iscarbon(hud.mymob))
			var/mob/living/carbon/C = hud.mymob
			if(C.handcuffed)
				add_overlay(handcuff_overlay)
			if(slot_id == slot_r_hand)
				if(!C.has_right_hand())
					add_overlay(blocked_overlay)
			else if(slot_id == slot_l_hand)
				if(!C.has_left_hand())
					add_overlay(blocked_overlay)

		if(slot_id == slot_l_hand && hud.mymob.hand)
			add_overlay(active_overlay)
		else if(slot_id == slot_r_hand && !hud.mymob.hand)
			add_overlay(active_overlay)

/obj/screen/inventory/hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated())
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1

	if(ismob(usr))
		var/mob/M = usr
		switch(name)
			if("right hand", "r_hand")
				M.activate_hand("r")
			if("left hand", "l_hand")
				M.activate_hand("l")
	return 1

/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(istype(master, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = master
		S.close(usr)
	return 1


/obj/screen/drop
	name = "drop"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_drop"
	layer = HUD_LAYER

/obj/screen/drop/Click()
	usr.drop_item_v()

/obj/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/obj/screen/act_intent/Click(location, control, params)
	if(ishuman(usr) && (usr.client.prefs.toggles & INTENT_STYLE))

		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])

		if(_x<=16 && _y<=16)
			usr.a_intent_change("harm")

		else if(_x<=16 && _y>=17)
			usr.a_intent_change("help")

		else if(_x>=17 && _y<=16)
			usr.a_intent_change("grab")

		else if(_x>=17 && _y>=17)
			usr.a_intent_change("disarm")

	else
		usr.a_intent_change("right")

/obj/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_movi

/obj/screen/act_intent/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_intents

/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal

/obj/screen/internals/Click()
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/C = usr
	if(C.incapacitated())
		return

	if(C.internal)
		C.internal = null
		C << "<span class='notice'>You are no longer running on internals.</span>"
		icon_state = "internal0"
	else
		if(!C.getorganslot("breathing_tube"))
			if(!istype(C.wear_mask, /obj/item/clothing/mask))
				C << "<span class='warning'>You are not wearing an internals mask!</span>"
				return 1
			else
				var/obj/item/clothing/mask/M = C.wear_mask
				if(M.mask_adjusted) // if mask on face but pushed down
					M.adjustmask(C) // adjust it back
				if( !(M.flags & MASKINTERNALS) )
					C << "<span class='warning'>You are not wearing an internals mask!</span>"
					return

		if(istype(C.l_hand, /obj/item/weapon/tank))
			C << "<span class='notice'>You are now running on internals from the [C.l_hand] on your left hand.</span>"
			C.internal = C.l_hand
		else if(istype(C.r_hand, /obj/item/weapon/tank))
			C << "<span class='notice'>You are now running on internals from the [C.r_hand] on your right hand.</span>"
			C.internal = C.r_hand
		else if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.s_store, /obj/item/weapon/tank))
				H << "<span class='notice'>You are now running on internals from the [H.s_store] on your [H.wear_suit].</span>"
				H.internal = H.s_store
			else if(istype(H.belt, /obj/item/weapon/tank))
				H << "<span class='notice'>You are now running on internals from the [H.belt] on your belt.</span>"
				H.internal = H.belt
			else if(istype(H.l_store, /obj/item/weapon/tank))
				H << "<span class='notice'>You are now running on internals from the [H.l_store] in your left pocket.</span>"
				H.internal = H.l_store
			else if(istype(H.r_store, /obj/item/weapon/tank))
				H << "<span class='notice'>You are now running on internals from the [H.r_store] in your right pocket.</span>"
				H.internal = H.r_store

		//Seperate so CO2 jetpacks are a little less cumbersome.
		if(!C.internal && istype(C.back, /obj/item/weapon/tank))
			C << "<span class='notice'>You are now running on internals from the [C.back] on your back.</span>"
			C.internal = C.back

		if(C.internal)
			icon_state = "internal1"
		else
			C << "<span class='warning'>You don't have an oxygen tank!</span>"
			return
	C.update_action_buttons_icon()

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "running"

/obj/screen/mov_intent/Click()
	switch(usr.m_intent)
		if("run")
			usr.m_intent = "walk"
			icon_state = "walking"
		if("walk")
			usr.m_intent = "run"
			icon_state = "running"
	usr.update_icons()

/obj/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "pull"

/obj/screen/pull/Click()
	usr.stop_pulling()

/obj/screen/pull/update_icon(mob/mymob)
	if(!mymob) return
	if(mymob.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_resist"
	layer = HUD_LAYER

/obj/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr, params)
	return 1

/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_throw_off"

/obj/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = "head"
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"

	if(old_selecting != selecting)
		update_icon(usr)
	return 1

/obj/screen/zone_sel/update_icon(mob/user)
	cut_overlays()
	add_overlay(image('icons/mob/screen_gen.dmi', "[selecting]"))
	user.zone_selected = selecting

/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/zone_sel/alien/update_icon(mob/user)
	cut_overlays()
	add_overlay(image('icons/mob/screen_alien.dmi', "[selecting]"))
	user.zone_selected = selecting

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'


/obj/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER

/obj/screen/damageoverlay
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = 0
	layer = UI_DAMAGE_LAYER

/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/obj/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_alien_health

/obj/screen/healths/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/deity
	name = "Nexus Health"
	icon_state = "deity_nexus"
	screen_loc = ui_deityhealth

/obj/screen/healths/blob
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	mouse_opacity = 0

/obj/screen/healths/blob/naut
	name = "health"
	icon = 'icons/mob/blob.dmi'
	icon_state = "nauthealth"

/obj/screen/healths/blob/naut/core
	name = "overmind health"
	screen_loc = ui_health
	icon_state = "corehealth"

/obj/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	screen_loc = ui_health
	mouse_opacity = 0

/obj/screen/healths/revenant
	name = "essence"
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_revenant"
	screen_loc = ui_health
	mouse_opacity = 0

/obj/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll
=======
/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = 20.0
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/gun_click_time = -100 //I'm lazy.
	var/globalscreen = 0 //This screen object is not unique to one screen, can be seen by many
	appearance_flags = NO_CLIENT_COLOR
	plane = PLANE_HUD

/obj/screen/Destroy()
	master = null
	..()

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/adminbus

/obj/screen/specialblob
	var/obj/effect/blob/linked_blob = null

/obj/screen/schematics
	var/datum/rcd_schematic/ourschematic

/obj/screen/schematics/New(var/atom/loc, var/datum/rcd_schematic/ourschematic)
	if(!ourschematic)
		qdel(src)
		return
	..()
	src.ourschematic = ourschematic
	icon = ourschematic.icon
	icon_state = ourschematic.icon_state
	name = ourschematic.name
	transform = transform*0.8

/obj/screen/schematics/Click()
	if(ourschematic)
		ourschematic.clicked(usr)

/obj/screen/schematics/Destroy()
	ourschematic = null
	..()

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.
	var/hand_index

/obj/screen/close
	name = "close"
	globalscreen = 1

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			S.close(usr)
		else if(istype(master,/obj/item/clothing/suit/storage))
			var/obj/item/clothing/suit/storage/S = master
			S.close(usr)
		else if(istype(master, /obj/item/device/rcd))
			var/obj/item/device/rcd/rcd = master
			rcd.show_default(usr)
	return 1


/obj/screen/item_action
	icon_state = "template"
	var/obj/item/owner
	var/image/overlay

/obj/screen/item_action/New(var/atom/loc, var/obj/item/I)
	..()
	owner = I
	name = I.action_button_name
	overlay = image(loc = src, layer=src.layer+1)
	overlay.appearance = I.appearance
	overlay.name = I.action_button_name
	overlay.dir = SOUTH

/obj/screen/item_action/Destroy()
	..()
	owner = null
	if(overlay != null)
		overlay.loc = null
		overlay = null

/obj/screen/item_action/Click()
	if(!usr || !owner)
		return 1
	if(usr.attack_delayer.blocked())
		return
	//usr.next_move = world.time + 6

	if(usr.stat || usr.restrained() || usr.stunned || usr.lying)
		return 1

	if(!(owner in usr))
		return 1

	owner.ui_action_click()
	return 1

//This is the proc used to update all the action buttons. It just returns for all mob types except humans.
/mob/proc/update_action_buttons()
	return


/obj/screen/grab
	name = "grab"

/obj/screen/grab/Click()
	var/obj/item/weapon/grab/G = master
	G.s_click(src)
	return 1

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/obj/screen/storage
	name = "storage"
	globalscreen = 1

/obj/screen/storage/Click(location, control, params)
	if(usr.attack_delayer.blocked())
		return
	if(usr.incapacitated())
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr, params)
			//usr.next_move = world.time+2
	return 1

/obj/screen/gun
	name = "gun"
	icon = 'icons/mob/screen1.dmi'
	master = null
	dir = 2

	move
		name = "Allow Walking"
		icon_state = "no_walk0"
		screen_loc = ui_gun2

	run
		name = "Allow Running"
		icon_state = "no_run0"
		screen_loc = ui_gun3

	item
		name = "Allow Item Use"
		icon_state = "no_item0"
		screen_loc = ui_gun1

	mode
		name = "Toggle Gun Mode"
		icon_state = "gun0"
		screen_loc = ui_gun_select
		//dir = 1

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = LIMB_CHEST

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = LIMB_RIGHT_FOOT
				if(17 to 22)
					selecting = LIMB_LEFT_FOOT
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = LIMB_RIGHT_LEG
				if(17 to 22)
					selecting = LIMB_LEFT_LEG
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = LIMB_RIGHT_HAND
				if(12 to 20)
					selecting = LIMB_GROIN
				if(21 to 24)
					selecting = LIMB_LEFT_HAND
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = LIMB_RIGHT_ARM
				if(12 to 20)
					selecting = LIMB_CHEST
				if(21 to 24)
					selecting = LIMB_LEFT_ARM
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = LIMB_HEAD
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"

	if(old_selecting != selecting)
		update_icon()
	return 1

/obj/screen/zone_sel/update_icon()
	overlays.len = 0
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")

/obj/screen/clicker
	icon = 'icons/mob/screen1.dmi'
	icon_state = "blank"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = 2
	globalscreen = 1
	screen_loc = ui_entire_screen

/obj/screen/clicker/Click(location, control, params)
	var/list/modifiers = params2list(params)
	var/turf/T = screen_loc2turf(modifiers["screen-loc"], get_turf(usr), usr)
	T.Click(location, control, params)
	return 1

/proc/screen_loc2turf(scr_loc, turf/origin, mob/user)
	var/list/screenxy = splittext(scr_loc, ",")
	var/list/screenx = splittext(screenxy[1], ":")
	var/list/screeny = splittext(screenxy[2], ":")
	var/X = screenx[1]
	var/Y = screeny[1]
	var/view = world.view
	if(user && user.client)
		view = user.client.view
	X = Clamp((origin.x + text2num(X) - (view + 1)), 1, world.maxx)
	Y = Clamp((origin.y + text2num(Y) - (view + 1)), 1, world.maxy)
	return locate(X, Y, origin.z)

/obj/screen/Click(location, control, params)
	if(!usr)	return 1

	switch(name)
		if("toggle")
			if(usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()

		if("equip")
			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()

		if("mov_intent")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(C.legcuffed)
					to_chat(C, "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>")
					C.m_intent = "walk"	//Just incase
					C.hud_used.move_intent.icon_state = "walking"
					return 1
				switch(usr.m_intent)
					if("run")
						usr.m_intent = "walk"
						usr.hud_used.move_intent.icon_state = "walking"
					if("walk")
						usr.m_intent = "run"
						usr.hud_used.move_intent.icon_state = "running"
				if(istype(usr,/mob/living/carbon/alien/humanoid))
					usr.update_icons()
		if("m_intent")
			if(!usr.m_int)
				switch(usr.m_intent)
					if("run")
						usr.m_int = "13,14"
					if("walk")
						usr.m_int = "14,14"
					if("face")
						usr.m_int = "15,14"
			else
				usr.m_int = null
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "14,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "15,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "13,14"
		if("Reset Machine")
			usr.unset_machine()
		if("internal")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.toggle_internals(usr)
		if("act_intent")
			usr.a_intent_change("right")
		if("help")
			usr.a_intent = I_HELP
			usr.hud_used.action_intent.icon_state = "intent_help"
		if("harm")
			usr.a_intent = I_HURT
			usr.hud_used.action_intent.icon_state = "intent_hurt"
		if("grab")
			usr.a_intent = I_GRAB
			usr.hud_used.action_intent.icon_state = "intent_grab"
		if("disarm")
			usr.a_intent = I_DISARM
			usr.hud_used.action_intent.icon_state = "intent_disarm"

		if("pull")
			usr.stop_pulling()
		if("throw")
			if(!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()

		if("kick")
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr

				var/list/modifiers = params2list(params)
				if(modifiers["middle"] || modifiers["right"] || modifiers["ctrl"] || modifiers["shift"] || modifiers["alt"])
					H.set_attack_type() //Reset
				else
					H.set_attack_type(ATTACK_KICK)
		if("bite")
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr

				var/list/modifiers = params2list(params)
				if(modifiers["middle"] || modifiers["right"] || modifiers["ctrl"] || modifiers["shift"] || modifiers["alt"])
					H.set_attack_type() //Reset
				else
					H.set_attack_type(ATTACK_BITE)

		if("drop")
			usr.drop_item_v()

		if("module")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.hud_used.toggle_show_robot_modules()
					return 1
				R:pick_module()

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.uneq_active()

		if(INV_SLOT_TOOL)
			if(istype(usr, /mob/living/silicon/robot/mommi))
				usr:toggle_module(INV_SLOT_TOOL)

		if(INV_SLOT_SIGHT)
			if(isrobot(usr))
				var/mob/living/silicon/robot/person = usr
				person.sensor_mode()
				person.update_sight_hud()

		if("module1")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(1)

		if("module2")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(2)

		if("module3")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(3)

		if("AI Core")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.view_core()

		if("Show Camera List")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/camera = input(AI, "Choose which camera you want to view", "Cameras") as null|anything in AI.get_camera_list()
				AI.ai_camera_list(camera)

		if("Track With Camera")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/target_name = input(AI, "Choose who you want to track", "Tracking") as null|anything in AI.trackable_mobs()
				AI.ai_camera_track(target_name)

		if("Toggle Camera Light")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.toggle_camera_light()

		if("Show Crew Manifest")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_roster()

		if("Show Alerts")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_alerts()

		if("Announcement")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.announcement()

		if("Call Emergency Shuttle")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_call_shuttle()

		if("State Laws")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.checklaws()

		if("PDA - Send Message")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.cmd_send_pdamesg()

		if("PDA - Show Message Log")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.cmd_show_message_log()

		if("Take Image")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.aicamera.toggle_camera_mode()

		if("View Images")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.aicamera.viewpictures()

		if("Configure Radio")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.radio_interact()

		if("Allow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Disallow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Allow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Disallow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Allow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time


		if("Disallow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time

		if("Toggle Gun Mode")
			usr.client.ToggleGunMode()

		else
			return 0
	return 1

/obj/screen/adminbus/Click()
	switch(name)
		if("Delete Bus")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Adminbus_Deletion(usr)
		if("Delete Mobs")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.remove_mobs(usr)
		if("Spawn Clowns")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.spawn_mob(usr,1,5)
		if("Spawn Carps")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.spawn_mob(usr,2,5)
		if("Spawn Bears")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.spawn_mob(usr,3,5)
		if("Spawn Trees")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.spawn_mob(usr,4,5)
		if("Spawn Spiders")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.spawn_mob(usr,5,5)
		if("Spawn Large Alien Queen")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.spawn_mob(usr,6,1)
		if("Spawn Loads of Captain Spare IDs")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.loadsa_goodies(usr,1)
		if("Spawn Loads of Money")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.loadsa_goodies(usr,2)
		if("Repair Surroundings")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Mass_Repair(usr)
		if("Mass Rejuvination")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.mass_rejuvinate(usr)
		if("Singularity Hook")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.throw_hookshot(usr)
		if("Adminbus-mounted Jukebox")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Mounted_Jukebox(usr)
		if("Teleportation")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Teleportation(usr)
		if("Release Passengers")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.release_passengers(usr)
		if("Send Passengers Back Home")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Send_Home(usr)
		if("Antag Madness!")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Make_Antag(usr)
		if("Give Infinite Laser Guns to the Passengers")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.give_lasers(usr)
		if("Delete the given Infinite Laser Guns")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.delete_lasers(usr)
		if("Give Fuse-Bombs to the Passengers")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.give_bombs(usr)
		if("Delete the given Fuse-Bombs")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.delete_bombs(usr)
		if("Send Passengers to the Thunderdome's Red Team")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Sendto_Thunderdome_Arena_Red(usr)
		if("Split the Passengers between the two Thunderdome Teams")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Sendto_Thunderdome_Arena(usr)
		if("Send Passengers to the Thunderdome's Green Team")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Sendto_Thunderdome_Arena_Green(usr)
		if("Send Passengers to the Thunderdome's Observers' Lodge")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.Sendto_Thunderdome_Obs(usr)
		if("Capture Mobs")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_bumpers(usr,1)
		if("Hit Mobs")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_bumpers(usr,2)
		if("Gib Mobs")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_bumpers(usr,3)
		if("Close Door")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_door(usr,0)
		if("Open Door")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_door(usr,1)
		if("Turn Off Headlights")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_lights(usr,0)
		if("Dipped Headlights")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_lights(usr,1)
		if("Main Headlights")
			if(usr.locked_to && istype(usr.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
				var/obj/structure/bed/chair/vehicle/adminbus/A = usr.locked_to
				A.toggle_lights(usr,2)

/obj/screen/specialblob/Click()
	switch(name)
		if("Spawn Blob")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.expand_blob_power()
		if("Spawn Strong Blob")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.create_shield_power()
		if("Spawn Resource Blob")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.create_resource()
		if("Spawn Factory Blob")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.create_factory()
		if("Spawn Node Blob")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.create_node()
		if("Spawn Blob Core")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.create_core()
		if("Call Overminds")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.callblobs()
		if("Rally Spores")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				overmind.rally_spores_power()
		if("Psionic Message")
			if(isovermind(usr))
				var/mob/camera/blob/overmind = usr
				var/message = input(overmind,"Send a message to the crew.","Psionic Message") as null|text
				if(message)
					overmind.telepathy(message)
		if("Jump to Blob")
			if(isovermind(usr) && linked_blob)
				var/mob/camera/blob/overmind = usr
				overmind.loc = linked_blob.loc
	return 1

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(usr.attack_delayer.blocked())
		return
	if(usr.incapacitated())
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1

	if(hand_index)
		usr.activate_hand(hand_index)

	switch(name)
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_hands()
				usr.delayNextAttack(6)
	return 1

/client/proc/reset_screen()
	for(var/obj/screen/objects in src.screen)
		if(!objects.globalscreen)
			returnToPool(objects)
	src.screen = null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
