/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for prized possessions."
	density = 1
	anchored = 1
	resistance_flags = ACID_PROOF
	armor = list(melee = 30, bullet = 0, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0, fire = 70, acid = 100)
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 50
	blueprint_root_only = FALSE
	var/obj/item/showpiece = null
	var/alert = 0
	var/open = 0
	var/start_showpiece_type = null //add type for items on display

/obj/structure/displaycase/Initialize()
	..()
	if(start_showpiece_type)
		showpiece = new start_showpiece_type(src)
	update_icon()

/obj/structure/displaycase/Destroy()
	if(showpiece)
		qdel(showpiece)
		showpiece = null
	return ..()

/obj/structure/displaycase/examine(mob/user)
	..()
	if(showpiece)
		to_chat(user, "<span class='notice'>There's [showpiece] inside.</span>")
	if(alert)
		to_chat(user, "<span class='notice'>Hooked up with an anti-theft system.</span>")


/obj/structure/displaycase/proc/dump()
	if (showpiece)
		showpiece.forceMove(loc)
		showpiece = null

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

CONSTRUCTION_BLUEPRINT(/obj/structure/displaycase)
	. = newlist(
		/datum/construction_state/first{
			//required_type_to_construct = /obj/item/stack/sheet/mineral/wood
			required_amount_to_construct = 5
			one_per_turf = 1
			on_floor = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/electronics/airlock
			required_amount_to_construct = 1
			stash_construction_item = 1
			required_type_to_deconstruct = /obj/item/weapon/wrench
			deconstruction_delay = 30
			construction_message = "install the electronics into"
			deconstruction_message = "disassembling"
			examine_message = "It's missing access electronics"
			icon_state = "glassbox_chassis"
		},
		/datum/construction_state{
			required_amount_to_construct = /obj/item/stack/sheet/glass
			required_amount_to_construct = 5
			construction_delay = 20
			deconstruction_message = "remove the electronics from"
			construction_message = "adding the glass to"
			examine_message = "It has no glass"
			damage_reachable = 1
		},
		/datum/construction_state/last{
			required_type_to_repair = /obj/item/weapon/weldingtool
			repair_delay = 40
		}
	)
	//This is here to work around a byond bug
	//http://www.byond.com/forum/?post=2220240
	//When its fixed clean up this copypasta across the codebase OBJ_CONS_BAD_CONST

	var/datum/construction_state/first/X = .[1]
	X.required_type_to_construct = /obj/item/stack/sheet/mineral/wood

/obj/structure/displaycase/OnConstruction(state_id, mob/user, obj/item/used)
	switch(state_id)
		if(DISPLAY_CASE_NOGLASS)
			var/obj/item/weapon/electronics/airlock/electronics = used
			if(electronics.one_access)
				req_one_access = electronics.accesses
			else
				req_access = electronics.accesses
		else
			update_icon()

/obj/structure/displaycase/OnDeconstruction(state_id, mob/user, obj/item/created, forced)
	..()
	switch(state_id)
		if(DISPLAY_CASE_NOGLASS)
			if(forced)
				new /obj/item/weapon/shard( src.loc )
				playsound(src, "shatter", 70, 1)
				trigger_alarm()
			open = FALSE
		if(0)
			dump()	
	update_icon()

/obj/structure/displaycase/proc/trigger_alarm()
	//Activate Anti-theft
	if(alert)
		var/area/alarmed = get_area(src)
		alarmed.burglaralert(src)
		playsound(src, 'sound/effects/alert.ogg', 50, 1)

/obj/structure/displaycase/proc/is_directional(atom/A)
	try
		getFlatIcon(A,defdir=4)
	catch
		return FALSE
	return TRUE

/obj/structure/displaycase/proc/get_flat_icon_directional(atom/A)
	//Get flatIcon even if dir is mismatched for directionless icons
	//SLOW
	var/icon/I
	if(is_directional(A))
		I = getFlatIcon(A)
	else
		var/old_dir = A.dir
		A.setDir(2)
		I = getFlatIcon(A)
		A.setDir(old_dir)
	return I

/obj/structure/displaycase/update_icon()
	var/icon/I
	if(open)
		I = icon('icons/obj/stationobjs.dmi',"glassbox_open")
	else if(current_construction_state.id == DISPLAY_CASE_NOGLASS)
		I = icon('icons/obj/stationobjs.dmi',"glassboxb0")
	else
		I = icon('icons/obj/stationobjs.dmi',"glassbox0")
	if(showpiece)
		var/icon/S = get_flat_icon_directional(showpiece)
		S.Scale(17,17)
		I.Blend(S,ICON_UNDERLAY,8,8)
	src.icon = I
	return

/obj/structure/displaycase/attackby(obj/item/weapon/W, mob/user, params)
	if(current_construction_state.id == DISPLAY_CASE_COMPLETE)
		if(W.GetID())
			if(allowed(user))
				to_chat(user, "<span class='notice'>You [open ? "close":"open"] the [src]</span>")
				toggle_lock(user)
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

		else if(!alert && istype(W,/obj/item/weapon/crowbar) && !(src in user.construction_tasks)) //Only applies to the lab cage and player made display cases
			to_chat(user, "<span class='notice'>You start to [open ? "close":"open"] the [src]</span>")
			LAZYADD(user.construction_tasks, src)
			if(do_after(user, 20*W.toolspeed, target = src))
				to_chat(user,  "<span class='notice'>You [open ? "close":"open"] the [src]</span>")
				toggle_lock(user)
			LAZYREMOVE(user.construction_tasks, src)
	
	else if((current_construction_state.id == DISPLAY_CASE_NOGLASS || open) && !showpiece)
		if(user.transferItemToLoc(W, src))
			showpiece = W
			to_chat(user, "<span class='notice'>You put [W] on display</span>")
			update_icon()
	else
		return ..()

/obj/structure/displaycase/proc/toggle_lock(mob/user)
	open = !open
	update_icon()

/obj/structure/displaycase/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if (showpiece && ((current_construction_state.id == DISPLAY_CASE_NOGLASS) || open))
		dump()
		to_chat(user, "<span class='notice'>You deactivate the hover field built into the case.</span>")
		src.add_fingerprint(user)
		update_icon()
		return
	else
	    //prevents remote "kicks" with TK
		if (!Adjacent(user))
			return
		user.visible_message("<span class='danger'>[user] kicks the display case.</span>", null, null, COMBAT_MESSAGE_RANGE)
		user.do_attack_animation(src, ATTACK_EFFECT_KICK)
		take_damage(2)

//The captains display case requiring specops ID access is intentional.
//The lab cage and captains display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	alert = 1
	start_showpiece_type = /obj/item/weapon/gun/energy/laser/captain
	req_access = list(access_cent_specops)

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(access_rd)
