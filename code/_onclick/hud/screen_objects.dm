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
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.

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


/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
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

/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"

/obj/screen/internals/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(!C.incapacitated())
			if(C.internal)
				C.internal = null
				C << "<span class='notice'>You are no longer running on internals.</span>"
				icon_state = "internal0"
			else
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

/obj/screen/mov_intent
	name = "sprint/run/walk toggle"
	desc = "Click to toggle run/walk, Double click to start a sprint."
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "running"
	var/double_clicking = 0

/obj/screen/mov_intent/Click()
	if(double_clicking) //Click always happens during a double click
		double_clicking = 0
		return
	usr.movespeed(0)

/obj/screen/mov_intent/DblClick()
	if(!ishuman(usr))
		return
	double_clicking = 1
	usr.movespeed(1)

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
		update_icon()
	return 1

/obj/screen/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/screen_gen.dmi', "[selecting]")

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(ismob(usr))
				var/mob/Mr = usr
				Mr.activate_hand("r")
		if("l_hand")
			if(ismob(usr))
				var/mob/Ml = usr
				Ml.activate_hand("l")
		if("swap")
			if(ismob(usr))
				var/mob/Ms = usr
				Ms.swap_hand()
		if("hand")
			if(ismob(usr))
				var/mob/Mh = usr
				Mh.swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
	return 1
