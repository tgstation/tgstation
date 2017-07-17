/obj/structure/plasticflaps
	name = "plastic flaps"
	desc = "Definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	armor = list(melee = 100, bullet = 80, laser = 80, energy = 100, bomb = 50, bio = 100, rad = 100, fire = 50, acid = 50)
	density = FALSE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	var/state = PLASTIC_FLAPS_NORMAL

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	switch(state)
		if(PLASTIC_FLAPS_NORMAL)
			to_chat(user, "<span class='notice'>[src] are <b>screwed</b> to the floor.</span>")
		if(PLASTIC_FLAPS_DETACHED)
			to_chat(user, "<span class='notice'>[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>cut</b> apart.</span>")

/obj/structure/plasticflaps/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(state == PLASTIC_FLAPS_NORMAL)
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] unscrews [src] from the floor.</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 100*W.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_NORMAL)
					return
				state = PLASTIC_FLAPS_DETACHED
				anchored = FALSE
				to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
		else if(state == PLASTIC_FLAPS_DETACHED)
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] screws [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 40*W.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_DETACHED)
					return
				state = PLASTIC_FLAPS_NORMAL
				anchored = TRUE
				to_chat(user, "<span class='notice'>You screw [src] from the floor.</span>")
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(state == PLASTIC_FLAPS_DETACHED)
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] cuts apart [src].</span>", "<span class='notice'>You start to cut apart [src].</span>", "You hear cutting.")
			if(do_after(user, 50*W.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_DETACHED)
					return
				to_chat(user, "<span class='notice'>You cut apart [src].</span>")
				var/obj/item/stack/sheet/plastic/five/P = new(loc)
				P.add_fingerprint(user)
				qdel(src)
	else
		. = ..()

/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller)
	if(isliving(caller))
		if(isbot(caller))
			return 1

		var/mob/living/M = caller
		if(!M.ventcrawler && M.mob_size != MOB_SIZE_TINY)
			return 0

	return 1 //diseases, stings, etc can pass

/obj/structure/plasticflaps/CanPass(atom/movable/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && (B.has_buckled_mobs() || B.density))//if it's a bed/chair and is dense or someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return 0

	if(istype(A, /obj/mecha))
		return 0


	else if(isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if(isbot(A)) //Bots understand the secrets
			return 1
		if(M.buckled && istype(M.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return 1
		if(!M.lying && !M.ventcrawler && M.mob_size != MOB_SIZE_TINY)	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return 0
	return ..()

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/plasticflaps/mining/New()
	air_update_turf(1)
	. = ..()

/obj/structure/plasticflaps/mining/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf(1)
