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
	plane = ABOVE_HUD_PLANE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.

/obj/screen/take_damage()
	return

/obj/screen/Destroy()
	master = null
	hud = null
	return ..()

/obj/screen/examine(mob/user)
	return

/obj/screen/orbit()
	return

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/swap_hand
	layer = HUD_LAYER
	plane = HUD_PLANE
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

/obj/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/craft/Click()
	var/mob/living/M = usr
	if(isobserver(usr))
		return
	M.OpenCraftingMenu()

/obj/screen/area_creator
	name = "create new area"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building

/obj/screen/area_creator/Click()
	if(usr.incapacitated())
		return 1
	var/area/A = get_area(usr)
	if(!A.outdoors)
		to_chat(usr, "<span class='warning'>There is already a defined structure here.</span>")
		return 1
	create_area(usr)

/obj/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/obj/screen/language_menu/Click()
	var/mob/M = usr
	var/datum/language_holder/H = M.get_language_holder()
	H.open_language_menu(usr)

/obj/screen/inventory
	var/slot_id	// The indentifier for the slot. It has nothing to do with ID cards.
	var/icon_empty // Icon when empty. For now used only by humans.
	var/icon_full  // Icon when contains an item. For now used only by humans.
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated())
		return 1
	if(istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1

	if(hud && hud.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id))
		usr.update_inv_hands()
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
	var/mutable_appearance/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")
	var/held_index = 0

/obj/screen/inventory/hand/update_icon()
	..()

	if(!handcuff_overlay)
		var/state = (!(held_index % 2)) ? "markus" : "gabrielle"
		handcuff_overlay = mutable_appearance('icons/mob/screen_gen.dmi', state)

	cut_overlays()

	if(hud && hud.mymob)
		if(iscarbon(hud.mymob))
			var/mob/living/carbon/C = hud.mymob
			if(C.handcuffed)
				add_overlay(handcuff_overlay)

			if(held_index)
				if(!C.has_hand_for_held_index(held_index))
					add_overlay(blocked_overlay)

		if(held_index == hud.mymob.active_hand_index)
			add_overlay("hand_active")


/obj/screen/inventory/hand/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.incapacitated() || isobserver(usr))
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1

	if(hud.mymob.active_hand_index == held_index)
		var/obj/item/I = hud.mymob.get_active_held_item()
		if(I)
			I.Click(location, control, params)
	else
		hud.mymob.swap_hand(held_index)
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
	plane = HUD_PLANE

/obj/screen/drop/Click()
	usr.drop_item_v()

/obj/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/obj/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)

/obj/screen/act_intent/segmented/Click(location, control, params)
	if(usr.client.prefs.toggles & INTENT_STYLE)
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])

		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)

		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)

		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)

		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		return ..()

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
		to_chat(C, "<span class='notice'>You are no longer running on internals.</span>")
		icon_state = "internal0"
	else
		if(!C.getorganslot("breathing_tube"))
			if(!istype(C.wear_mask, /obj/item/clothing/mask))
				to_chat(C, "<span class='warning'>You are not wearing an internals mask!</span>")
				return 1
			else
				var/obj/item/clothing/mask/M = C.wear_mask
				if(M.mask_adjusted) // if mask on face but pushed down
					M.adjustmask(C) // adjust it back
				if( !(M.flags & MASKINTERNALS) )
					to_chat(C, "<span class='warning'>You are not wearing an internals mask!</span>")
					return

		var/obj/item/I = C.is_holding_item_of_type(/obj/item/weapon/tank)
		if(I)
			to_chat(C, "<span class='notice'>You are now running on internals from the [I] on your [C.get_held_index_name(C.get_held_index_of_item(I))].</span>")
			C.internal = I
		else if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.s_store, /obj/item/weapon/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from the [H.s_store] on your [H.wear_suit].</span>")
				H.internal = H.s_store
			else if(istype(H.belt, /obj/item/weapon/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from the [H.belt] on your belt.</span>")
				H.internal = H.belt
			else if(istype(H.l_store, /obj/item/weapon/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from the [H.l_store] in your left pocket.</span>")
				H.internal = H.l_store
			else if(istype(H.r_store, /obj/item/weapon/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from the [H.r_store] in your right pocket.</span>")
				H.internal = H.r_store

		//Seperate so CO2 jetpacks are a little less cumbersome.
		if(!C.internal && istype(C.back, /obj/item/weapon/tank))
			to_chat(C, "<span class='notice'>You are now running on internals from the [C.back] on your back.</span>")
			C.internal = C.back

		if(C.internal)
			icon_state = "internal1"
		else
			to_chat(C, "<span class='warning'>You don't have an oxygen tank!</span>")
			return
	C.update_action_buttons_icon()

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "running"

/obj/screen/mov_intent/Click()
	toggle(usr)

/obj/screen/mov_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	switch(user.m_intent)
		if("run")
			user.m_intent = MOVE_INTENT_WALK
			icon_state = "walking"
		if("walk")
			user.m_intent = MOVE_INTENT_RUN
			icon_state = "running"
	user.update_icons()

/obj/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "pull"

/obj/screen/pull/Click()
	if(isobserver(usr))
		return
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
	plane = HUD_PLANE

/obj/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return 1
	if(usr.stat || usr.IsUnconscious() || usr.IsKnockdown() || usr.IsStun())
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_held_item()
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
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice

	switch(icon_y)
		if(1 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					choice = "r_leg"
				if(17 to 22)
					choice = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					choice = "r_arm"
				if(12 to 20)
					choice = "groin"
				if(21 to 24)
					choice = "l_arm"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					choice = "r_arm"
				if(12 to 20)
					choice = "chest"
				if(21 to 24)
					choice = "l_arm"
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				choice = "head"
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							choice = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							choice = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							choice = "eyes"

	return set_selected_zone(choice, usr)

/obj/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(isobserver(user))
		return

	if(choice != selecting)
		selecting = choice
		update_icon(usr)
	return 1

/obj/screen/zone_sel/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[selecting]"))
	user.zone_selected = selecting

/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/zone_sel/alien/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen_alien.dmi', "[selecting]"))
	user.zone_selected = selecting

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'


/obj/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/damageoverlay
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = 0
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

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

/obj/screen/healths/clock
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_clock"
	screen_loc = ui_health
	mouse_opacity = 0

/obj/screen/healths/clock/gear
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "bg_gear"
	screen_loc = ui_internal

/obj/screen/healths/revenant
	name = "essence"
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_revenant"
	screen_loc = ui_health
	mouse_opacity = 0

/obj/screen/healths/construct
	icon = 'icons/mob/screen_construct.dmi'
	icon_state = "artificer_health0"
	screen_loc = ui_construct_health
	mouse_opacity = 0

/obj/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll

/obj/screen/splash
	icon = 'config/title_screens/images/blank.png'
	icon_state = ""
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER
	plane = SPLASHSCREEN_PLANE
	var/client/holder

/obj/screen/splash/New(client/C, visible, use_previous_title) //TODO: Make this use INITIALIZE_IMMEDIATE
	holder = C

	if(!visible)
		alpha = 0

	if(!use_previous_title)
		if(SStitle.icon)
			icon = SStitle.icon
	else
		if(!SStitle.previous_icon)
			qdel(src)
			return
		icon = SStitle.previous_icon

	holder.screen += src

	..()

/obj/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/obj/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()
