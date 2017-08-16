/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list(melee = 30, bullet = 0, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0, fire = 70, acid = 100)
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/showpiece = null
	var/alert = TRUE
	var/open = FALSE
	var/openable = TRUE
	var/obj/item/electronics/airlock/electronics
	var/start_showpiece_type = null //add type for items on display

/obj/structure/displaycase/Initialize()
	. = ..()
	if(start_showpiece_type)
		showpiece = new start_showpiece_type (src)
	update_icon()

/obj/structure/displaycase/Destroy()
	if(electronics)
		QDEL_NULL(electronics)
	if(showpiece)
		QDEL_NULL(showpiece)
	return ..()

/obj/structure/displaycase/examine(mob/user)
	..()
	if(alert)
		to_chat(user, "<span class='notice'>Hooked up with an anti-theft system.</span>")
	if(showpiece)
		to_chat(user, "<span class='notice'>There's [showpiece] inside.</span>")


/obj/structure/displaycase/proc/dump()
	if (showpiece)
		showpiece.forceMove(loc)
		showpiece = null

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		dump()
		if(!disassembled)
			new /obj/item/shard( src.loc )
			trigger_alarm()
	qdel(src)

/obj/structure/displaycase/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		density = FALSE
		broken = 1
		new /obj/item/shard( src.loc )
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

/obj/structure/displaycase/attackby(obj/item/W, mob/user, params)
	if(W.GetID() && !broken && openable)
		if(allowed(user))
			to_chat(user,  "<span class='notice'>You [open ? "close":"open"] the [src]</span>")
			toggle_lock(user)
		else
			to_chat(user,  "<span class='warning'>Access denied.</span>")
	else if(istype(W, /obj/item/weldingtool) && user.a_intent == INTENT_HELP && !broken)
		var/obj/item/weldingtool/WT = W
		if(obj_integrity < max_integrity && WT.remove_fuel(5, user))
			to_chat(user, "<span class='notice'>You begin repairing [src].</span>")
			playsound(loc, WT.usesound, 40, 1)
			if(do_after(user, 40*W.toolspeed, target = src))
				obj_integrity = max_integrity
				playsound(loc, 'sound/items/welder2.ogg', 50, 1)
				update_icon()
				to_chat(user, "<span class='notice'>You repair [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return
	else if(!alert && istype(W, /obj/item/crowbar) && openable) //Only applies to the lab cage and player made display cases
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
		if(user.transferItemToLoc(W, src))
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
		to_chat(user, "<span class='notice'>You deactivate the hover field built into the case.</span>")
		dump()
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
	anchored = TRUE
	density = FALSE
	name = "display case chassis"
	desc = "wooden base of display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/electronics/airlock/electronics


/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wrench)) //The player can only deconstruct the wooden frame
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		playsound(src.loc, I.usesound, 50, 1)
		if(do_after(user, 30*I.toolspeed, target = src))
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			new /obj/item/stack/sheet/mineral/wood(get_turf(src), 5)
			qdel(src)

	else if(istype(I, /obj/item/electronics/airlock))
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
	start_showpiece_type = /obj/item/gun/energy/laser/captain
	req_access = list(ACCESS_CENT_SPECOPS)

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(ACCESS_RD)



/obj/structure/displaycase/trophy
	name = "trophy display case"
	desc = "Store your trophies of accomplishment in here, and they will stay forever."
	var/trophy_message = ""
	var/placer_key = ""
	var/added_roundstart = TRUE
	var/is_locked = TRUE

	alert = TRUE
	integrity_failure = 0
	openable = FALSE

/obj/structure/displaycase/trophy/Initialize()
	. = ..()
	GLOB.trophy_cases += src

/obj/structure/displaycase/trophy/Destroy()
	GLOB.trophy_cases -= src
	return ..()

/obj/structure/displaycase/trophy/examine(mob/user)
	..()
	if(trophy_message)
		to_chat(user, "The plaque reads:")
		to_chat(user, trophy_message)

/obj/structure/displaycase/trophy/attackby(obj/item/W, mob/user, params)

	if(!user.Adjacent(src)) //no TK museology
		return
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(user.is_holding_item_of_type(/obj/item/key/displaycase))
		if(added_roundstart)
			is_locked = !is_locked
			to_chat(user, "You [!is_locked ? "un" : ""]lock the case.")
		else
			to_chat(user, "<span class='danger'>The lock is stuck shut!</span>")
		return

	if(is_locked)
		to_chat(user, "<span class='danger'>The case is shut tight with an old fashioned physical lock. Maybe you should ask the curator for the key?</span>")
		return

	if(!added_roundstart)
		to_chat(user, "You've already put something new in this case.")
		return

	if(is_type_in_typecache(W, GLOB.blacklisted_cargo_types))
		to_chat(user, "<span class='danger'>The case rejects the [W].</span>")
		return

	for(var/a in W.GetAllContents())
		if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types))
			to_chat(user, "<span class='danger'>The case rejects the [W].</span>")
			return

	if(user.transferItemToLoc(W, src))

		if(showpiece)
			to_chat(user, "You press a button, and [showpiece] descends into the floor of the case.")
			QDEL_NULL(showpiece)

		to_chat(user, "You insert [W] into the case.")
		showpiece = W
		added_roundstart = FALSE
		update_icon()

		placer_key = user.ckey

		trophy_message = W.desc //default value

		var/chosen_plaque = stripped_input(user, "What would you like the plaque to say? Default value is item's description.", "Trophy Plaque")
		if(chosen_plaque)
			if(user.Adjacent(src))
				trophy_message = chosen_plaque
				to_chat(user, "You set the plaque's text.")
			else
				to_chat(user, "You are too far to set the plaque's text.")

		SSpersistence.SaveTrophy(src)
		return TRUE

	else
		to_chat(user, "<span class='warning'>\The [W] is stuck to your hand, you can't put it in the [src.name]!</span>")

	return

/obj/structure/displaycase/trophy/dump()
	if (showpiece)
		if(added_roundstart)
			visible_message("<span class='danger'>The [showpiece] crumbles to dust!</span>")
			new /obj/effect/decal/cleanable/ash(loc)
			QDEL_NULL(showpiece)
		else
			..()

/obj/item/key/displaycase
	name = "display case key"
	desc = "The key to the curator's display cases."

/obj/item/showpiece_dummy
	name = "Cheap replica"

/obj/item/showpiece_dummy/Initialize(mapload, path)
	. = ..()
	var/obj/item/I = path
	name = initial(I.name)
	icon = initial(I.icon)
	icon_state = initial(I.icon_state)
