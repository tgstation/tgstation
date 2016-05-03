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
	layer = 20
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
	layer = 19
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


/obj/screen/inventory
	var/slot_id	// The indentifier for the slot. It has nothing to do with ID cards.
	var/icon_empty // Icon when empty. For now used only by humans.
	var/icon_full  // Icon when contains an item. For now used only by humans.
	layer = 19

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

/obj/screen/inventory/hand/update_icon()
	..()
	if(!active_overlay)
		active_overlay = image("icon"=icon, "icon_state"="hand_active")
	if(!handcuff_overlay)
		var/state = (slot_id == slot_r_hand) ? "markus" : "gabrielle"
		handcuff_overlay = image("icon"='icons/mob/screen_gen.dmi', "icon_state"=state)

	overlays.Cut()

	if(hud && hud.mymob)
		if(iscarbon(hud.mymob))
			var/mob/living/carbon/C = hud.mymob
			if(C.handcuffed)
				overlays += handcuff_overlay

		if(slot_id == slot_l_hand && hud.mymob.hand)
			overlays += active_overlay
		else if(slot_id == slot_r_hand && !hud.mymob.hand)
			overlays += active_overlay

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
	layer = 19

/obj/screen/drop/Click()
	usr.drop_item_v()

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
	layer = 19

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
	overlays.Cut()
	overlays += image('icons/mob/screen_gen.dmi', "[selecting]")
	user.zone_selected = selecting

/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/zone_sel/alien/update_icon(mob/user)
	overlays.Cut()
	overlays += image('icons/mob/screen_alien.dmi', "[selecting]")
	user.zone_selected = selecting

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'


/obj/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = 17

/obj/screen/damageoverlay
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = 0
	layer = 18.1 //The black screen overlay sets layer to 18 to display it, this one has to be just on top.

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
