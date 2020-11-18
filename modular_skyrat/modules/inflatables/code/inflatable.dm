/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'modular_skyrat/modules/inflatables/icons/inflatable.dmi'
	icon_state = "folded_wall"
	w_class = WEIGHT_CLASS_SMALL
	var/structuretype = /obj/structure/inflatable

/obj/item/inflatable/attack_self(mob/user)
	if(locate(/obj/structure/inflatable) in user.loc)
		to_chat(user, "<span class='warning'>You cannot place inflatable walls upon eachother!</span>")
		return
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	if(do_mob(user, src, 10))
		var/obj/structure/inflatable/R = new structuretype(user.loc)
		transfer_fingerprints_to(R)
		R.add_fingerprint(user)
		qdel(src)

/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	CanAtmosPass = ATMOS_PASS_NO
	density = TRUE
	anchored = TRUE
	max_integrity = 40
	icon = 'modular_skyrat/modules/inflatables/icons/inflatable.dmi'
	icon_state = "wall"
	var/torntype = /obj/item/inflatable/torn
	var/itemtype = /obj/item/inflatable
	var/hitsound = 'sound/effects/Glasshit.ogg'

/obj/structure/inflatable/Initialize(location)
	. = ..()
	air_update_turf(1)

/obj/structure/inflatable/Destroy()
	air_update_turf(1)
	return ..()

/obj/structure/inflatable/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		deflate(TRUE)
	else
		deflate(FALSE)

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, hitsound, 75, TRUE)

/obj/structure/inflatable/CanAtmosPass(turf/T)
	return !density

/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			deflate(TRUE)
			return
		if(3)
			if(prob(50))
				deflate(TRUE)
				return

/obj/structure/inflatable/blob_act()
	deflate(TRUE)

/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)
	..()

/obj/structure/inflatable/attack_alien(mob/user)
	if(islarva(user))
		return
	attack_generic(user, 15)

/obj/structure/inflatable/attack_animal(mob/user)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/inflatable/attack_slime(mob/user)
	attack_generic(user, rand(10, 15))

/obj/structure/inflatable/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!istype(W))
		return
	if(W.sharpness)
		visible_message("<span class='danger'><b>[user] pierces [src] with [W]!</b></span>")
		deflate(TRUE)
	if(W.damtype == BRUTE || W.damtype == BURN)
		..()

/obj/structure/inflatable/AltClick()
	if(usr.stat || usr.can_interact())
		return
	if(!Adjacent(usr))
		return
	deflate()

/obj/structure/inflatable/proc/deflate(violent)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	var/obj/item/inflatable/R
	if(violent)
		visible_message("<span class='danger'>[src] rapidly deflates!</span>")
		R = new torntype(loc)
	else
		visible_message("<span class='danger'>[src] slowly deflates.</span>")
		sleep(50)
		R = new itemtype(loc)
	transfer_fingerprints_to(R)
	density = 0
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || usr.can_interact())
		return
	deflate()

/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon = 'modular_skyrat/modules/inflatables/icons/inflatable.dmi'
	icon_state = "folded_door"
	structuretype = /obj/structure/inflatable/door

/obj/structure/inflatable/door //based on mineral door code
	name = "inflatable door"
	density = TRUE
	anchored = TRUE
	CanAtmosPass = ATMOS_PASS_DENSITY
	icon = 'modular_skyrat/modules/inflatables/icons/inflatable.dmi'
	icon_state = "door_closed"
	torntype = /obj/item/inflatable/torn/door
	itemtype = /obj/item/inflatable/door
	var/state = FALSE //closed, 1 == open
	var/isSwitchingStates = FALSE

/obj/structure/inflatable/door/attack_hand(mob/user)
	return TryToSwitchState(user)
/*
/obj/structure/inflatable/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	. = ..()
	if(air_group)
		return state
	return !density
*/
/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/vehicle/sealed/mecha))
		SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()
	air_update_turf(TRUE)

/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = TRUE
	flick("door_opening",src)
	sleep(10)
	density = FALSE
	state = TRUE
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = TRUE
	flick("door_closing",src)
	sleep(10)
	density = TRUE
	state = FALSE
	update_icon()
	isSwitchingStates = FALSE

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/structure/inflatable/door/deflate(violent)
	..()
	air_update_turf(TRUE)

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon = 'modular_skyrat/modules/inflatables/icons/inflatable.dmi'
	icon_state = "folded_wall_torn"
	var/fixedtype = /obj/item/inflatable

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='warning'>The inflatable wall is too torn to be inflated, fix it with something!</span>")
	add_fingerprint(user)

/obj/item/inflatable/torn/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sticky_tape))
		var/obj/item/stack/sticky_tape/T = I
		if(T.amount < 2)
			to_chat(user, "<span class='danger'>There is not enough tape!</span>")
			return
		to_chat(user, "<span class='notice'>You begin fixing the [src]!</span>")
		playsound(user, 'modular_skyrat/modules/inflatables/sound/ducttape1.ogg', 50, 1)
		if(do_mob(user, src, 20))
			to_chat(user, "<span class='notice'>You fix the [src] using the ducttape!</span>")
			T.use(2)
			new fixedtype(user.loc)
			qdel(src)

/obj/item/inflatable/torn/door
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon = 'modular_skyrat/modules/inflatables/icons/inflatable.dmi'
	icon_state = "folded_door_torn"
	fixedtype = /obj/item/inflatable/door

/obj/item/storage/inflatable
	icon = 'modular_skyrat/modules/inflatables/icons/inflatable.dmi'
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/inflatable/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 21

/obj/item/storage/inflatable/PopulateContents()
	for(var/i = 0, i < 8, i++)
		new /obj/item/inflatable/door(src)
	for(var/i = 0, i < 16, i ++)
		new /obj/item/inflatable(src)

/obj/item/inflatable/suicide_act(mob/living/user)
	visible_message(user, "<span class='danger'>[user] starts shoving the [src] up his ass! It looks like hes going to pull the cord, oh shit!</span>")
	playsound(user.loc, 'sound/machines/hiss.ogg', 75, 1)
	new structuretype(user.loc)
	user.gib()
	return BRUTELOSS
