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
	var/obj/item/showpiece = null
	var/alert = 0
	var/open = 0
	var/obj/item/weapon/electronics/airlock/electronics
	var/start_showpiece_type = null //add type for items on display

/obj/structure/displaycase/New()
	..()
	if(start_showpiece_type)
		showpiece = new start_showpiece_type (src)
	update_icon()

/obj/structure/displaycase/Destroy()
	if(electronics)
		qdel(electronics)
		electronics = null
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

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		dump()
		if(!disassembled)
			new /obj/item/weapon/shard( src.loc )
			trigger_alarm()
	qdel(src)

/obj/structure/displaycase/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		density = 0
		broken = 1
		new /obj/item/weapon/shard( src.loc )
		playsound(src, "shatter", 70, 1)
		update_icon()
		trigger_alarm()

/obj/structure/displaycase/proc/trigger_alarm()
	//Activate Anti-theft
	if(alert)
		var/area/alarmed = get_area(src)
		alarmed.burglaralert(src)
		playsound(src, 'sound/effects/alert.ogg', 50, 1)

/*

*/

/obj/structure/displaycase/proc/is_directional(atom/A)
	try
		getFlatIcon(A,defdir=4)
	catch
		return 0
	return 1

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
	else
		I = icon('icons/obj/stationobjs.dmi',"glassbox0")
	if(broken)
		I = icon('icons/obj/stationobjs.dmi',"glassboxb0")
	if(showpiece)
		var/icon/S = get_flat_icon_directional(showpiece)
		S.Scale(17,17)
		I.Blend(S,ICON_UNDERLAY,8,8)
	src.icon = I
	return

/obj/structure/displaycase/attackby(obj/item/weapon/W, mob/user, params)
	if(W.GetID() && !broken)
		if(allowed(user))
			to_chat(user,  "<span class='notice'>You [open ? "close":"open"] the [src]</span>")
			toggle_lock(user)
		else
			to_chat(user,  "<span class='warning'>Access denied.</span>")
	else if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent == INTENT_HELP && !broken)
		var/obj/item/weapon/weldingtool/WT = W
		if(obj_integrity < max_integrity && WT.remove_fuel(5, user))
			to_chat(user, "<span class='notice'>You begin repairing [src].</span>")
			playsound(loc, WT.usesound, 40, 1)
			if(do_after(user, 40*W.toolspeed, target = src))
				obj_integrity = max_integrity
				playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
				update_icon()
				to_chat(user, "<span class='notice'>You repair [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return
	else if(!alert && istype(W,/obj/item/weapon/crowbar)) //Only applies to the lab cage and player made display cases
		if(broken)
			if(showpiece)
				to_chat(user, "<span class='notice'>Remove the displayed object first.</span>")
			else
				to_chat(user, "<span class='notice'>You remove the destroyed case</span>")
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You start to [open ? "close":"open"] the [src]</span>")
			if(do_after(user, 20*W.toolspeed, target = src))
				to_chat(user,  "<span class='notice'>You [open ? "close":"open"] the [src]</span>")
				toggle_lock(user)
	else if(open && !showpiece)
		if(user.drop_item())
			W.loc = src
			showpiece = W
			to_chat(user, "<span class='notice'>You put [W] on display</span>")
			update_icon()
	else if(istype(W, /obj/item/stack/sheet/glass) && broken)
		var/obj/item/stack/sheet/glass/G = W
		if(G.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two glass sheets to fix the case!</span>")
			return
		to_chat(user, "<span class='notice'>You start fixing [src]...</span>")
		if(do_after(user, 20, target = src))
			G.use(2)
			broken = 0
			obj_integrity = max_integrity
			update_icon()
	else
		return ..()

/obj/structure/displaycase/proc/toggle_lock(mob/user)
	open = !open
	update_icon()

/obj/structure/displaycase/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if (showpiece && (broken || open))
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



/obj/structure/displaycase_chassis
	anchored = 1
	density = 0
	name = "display case chassis"
	desc = "wooden base of display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/weapon/electronics/airlock/electronics


/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench)) //The player can only deconstruct the wooden frame
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		playsound(src.loc, I.usesound, 50, 1)
		if(do_after(user, 30*I.toolspeed, target = src))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			new /obj/item/stack/sheet/mineral/wood(get_turf(src))
			qdel(src)

	else if(istype(I, /obj/item/weapon/electronics/airlock))
		to_chat(user, "<span class='notice'>You start installing the electronics into [src]...</span>")
		playsound(src.loc, I.usesound, 50, 1)
		if(do_after(user, 30, target = src) && user.transferItemToLoc(I,src))
			electronics = I
			to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")

	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten glass sheets to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [G] to [src]...</span>")
		if(do_after(user, 20, target = src))
			G.use(10)
			var/obj/structure/displaycase/display = new(src.loc)
			if(electronics)
				electronics.loc = display
				display.electronics = electronics
				if(electronics.one_access)
					display.req_one_access = electronics.accesses
				else
					display.req_access = electronics.accesses
			qdel(src)
	else
		return ..()

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
