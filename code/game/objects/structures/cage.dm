//Cages are structures that hold mobs
//If its cover is opened, the mobs can interact with their surroundings (but can't move or escape)
//If its cover is closed, the mobs inside can attempt to open it from the inside. Opening the cover takes 30 seconds

//

#define C_OPENED 0
#define C_CLOSED 1

/obj/structure/cage
	name = "cage"
	desc = "A large and heavy plasteel box, used to store dangerous animals and humans. It has two doors - the outer \"cover\", and the inner \"bars\". The cover is a thin plasteel sheet with tiny holes in the corners to let air through. The bars consist of thick plasteel rods, evenly spaced apart."

	density = 1
	anchored = 0

	icon = 'icons/obj/cage.dmi'
	icon_state = "cage_base"

	lockflags = LOCKED_CAN_LIE_AND_STAND | CANT_BE_MOVED_BY_LOCKED_MOBS

	var/cover_state = C_OPENED
	var/door_state = C_CLOSED

	var/damage_threshold_to_break = 100

/obj/structure/cage/New()
	..()

	update_icon()

/obj/structure/cage/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(src.loc)

	..()

/obj/structure/cage/update_icon()
	overlays = list()

	if(cover_state == C_CLOSED)
		var/image/cover_overlay = image('icons/obj/cage.dmi', icon_state = "cage_cover", layer = OBJ_LAYER)
		overlays += cover_overlay
	else if(door_state == C_CLOSED) //Door is only visible when the cover is open
		var/image/door_overlay = image('icons/obj/cage.dmi', icon_state = "cage_door", layer = MOB_LAYER + 0.5) //Above mobs
		overlays += door_overlay

/obj/structure/cage/attack_animal(mob/living/simple_animal/user)
	if(!istype(user)) return

	var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
	if((damage >= damage_threshold_to_break))
		if(prob(80))
			visible_message("<span class='warning'>\The [src] shakes violently!</span>")
		else
			toggle_door(user)

/obj/structure/cage/examine(mob/user)
	..()

	to_chat(user, "<span class='info'>Alt + click opens/closes the cage's cover.</span>")

/obj/structure/cage/AltClick()
	if(Adjacent(usr) && !usr.incapacitated() && !mob_is_inside(usr))
		toggle_cover(usr)

/obj/structure/cage/attackby(obj/item/W, mob/user)
	if(iswrench(W))
		if(anchored)
			to_chat(user, "<span class='info'>You start unsecuring \the [src] from \the [loc].</span>")
		else
			if(!istype(loc, /turf/simulated/floor)) //Can't secure the cage to space
				return

			to_chat(user, "<span class='info'>You start securing \the [src] to \the [loc].</span>")

		spawn()
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			if(do_after(user, src, 50))
				anchored = !anchored
				to_chat(user, "<span class='info'>[anchored ? "You successfully secure \the [src] to \the [loc]." : "You successfully unsecure \the [src] from \the [loc]."]")

		return 1
	else if(door_state == C_CLOSED)
		if(W.force >= 20 && (W.is_sharp() >= 1.0 || W.is_hot()))
			var/time = 15 SECONDS

			user.visible_message("<span class='danger'>[user] starts forcing \the [src]'s door open with \the [W]!</span>", "<span class='info'>You start forcing \the [src]'s door open with \the [W]. This will take around [(time / 10)] seconds.</span>")
			if(do_after(user, src, time))
				if(door_state == C_CLOSED) toggle_door(user)

		else
			if(W.force < 20) //Force
				to_chat(user, "<span class='info'>\The [W] won't damage \the [src]'s bars.</span>")
			else //No sharpness/hotness
				to_chat(user, "<span class='info'>\The [W] isn't sharp or hot enough to cut through \the [src]'s bars!</span>")

/obj/structure/cage/relaymove(mob/living/user)
	if(!istype(user)) return

	if(cover_state == C_CLOSED)
		var/time = 30 SECONDS
		time -= ((user.get_strength() - 1) * 12.5) //Being strong reduces the time needed, down to 5 seconds

		to_chat(user, "<span class='info'>You attempt to open \the [src]'s cover from inside. This will take around [(time / 10)] seconds.</span>")
		if(do_after(user, src, time + rand(-5 SECONDS, 5 SECONDS)))
			if(cover_state == C_CLOSED)
				toggle_cover(user)

/obj/structure/cage/attack_hand(mob/living/user)
	if(!istype(user)) return

	if(mob_is_inside(user)) //Inside the cage
		if(door_state == C_CLOSED)
			var/time = 180 SECONDS
			time -= ((user.get_strength() - 1) * 60) //Being strong reduces the time needed, down to 60 seconds

			to_chat(user, "<span class='info'>You attempt to open \the [src]'s door from inside. This will take around [(time / 10)] seconds.</span>")
			if(do_after(user, src, time + rand(-5 SECONDS, 5 SECONDS)))
				if(door_state == C_CLOSED)
					toggle_door(user)

	else

		user.visible_message("<span class='notice'>\The [user] attempts to [door_state == C_OPENED ? "close" : "open"] \the [src]!</span>")

		spawn()
			var/current_door_state = door_state

			if(do_after(user, src, 3 SECONDS)) //Closing / opening the cage takes 3 seconds
				if(door_state == current_door_state)
					toggle_door(user)
					user.visible_message("<span class='notice'>\The [user] [door_state == C_OPENED ? "opens" : "closes"] \the [src]!</span>", \
						"<span class='info'>You [door_state == C_OPENED ? "open" : "close"] \the [src].</span>", \
						self_drugged_message = "<span class='info'>You [door_state == C_OPENED ? "open the magic wardrobe. The world of Narnia awaits!" : "close the magic wardrobe. Goodbye, Narnia."]")

		return 1

/obj/structure/cage/attack_robot(mob/living/user)
	if(Adjacent(user))
		attack_hand(user)

//How the cage cover is implemented
//When it's closed, mobs are stored in the cage's contents. This causes them to be unable to interact with the outside world or move
//When it's opened, mobs are atom locked to the cage. This causes them to be able to interact with the outside world, but they still can't move
/obj/structure/cage/proc/toggle_cover(mob/user)
	if(door_state == C_OPENED) //Only when door is opened
		return

	if(cover_state == C_OPENED)
		cover_state = C_CLOSED
		if(user) user.visible_message("<span class='info'>\The [user] closes \the [src]'s cover.</span>")

		for(var/mob/living/L in locked_atoms) //Move atom locked mobs inside
			unlock_atom(L)
			L.forceMove(src)

	else
		cover_state = C_OPENED
		if(user) user.visible_message("<span class='info'>\The [user] opens \the [src]'s cover.</span>")

		for(var/mob/living/L in contents) //Move hidden mobs to the outside
			L.forceMove(get_turf(src))
			lock_atom(L)

	update_icon()

/obj/structure/cage/proc/toggle_door(mob/user)
	switch(door_state)
		if(C_OPENED) //Close the door
			if(cover_state == C_OPENED) toggle_cover() //Close the cover, too

			door_state = C_CLOSED
			density = 1

			for(var/mob/living/L in get_turf(src))
				add_mob(L)

		if(C_CLOSED) //Open the door
			if(cover_state == C_CLOSED) toggle_cover() //Open the cover, too

			for(var/mob/living/L in (contents + locked_atoms))
				unlock_atom(L)
				L.forceMove(get_turf(src))

			door_state = C_OPENED
			density = 0

	playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
	update_icon()

/obj/structure/cage/proc/add_mob(mob/victim)
	switch(cover_state)
		if(C_OPENED) //Cover is opened - mob is atom locked to the cage
			victim.forceMove(get_turf(src))
			lock_atom(victim)
			to_chat(victim, "<span class='notice'>You suddenly find yourself locked in a cage!</span>")
		if(C_CLOSED) //Cover is closed - mob is stored inside the cage
			victim.forceMove(src)
			to_chat(victim, "<span class='notice'>You suddenly find yourself locked in a cage!</span>")

/obj/structure/cage/proc/mob_is_inside(mob/checked)
	return ((contents.Find(checked)) || (locked_atoms.Find(checked)))

#undef C_OPENED
#undef C_CLOSED
