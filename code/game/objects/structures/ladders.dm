var/list/ladders = list()

/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	anchored = 1
	var/id = null
	var/height = 0							//the 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//the ladder below this one
	var/obj/structure/ladder/up = null		//the ladder above this one

/obj/structure/ladder/New()
	..()

	ladders.Add(src)

	spawn(10)
		update_links()

/obj/structure/ladder/Destroy()
	..()

	for(var/obj/structure/ladder/L in ladders)
		L.update_links()

	ladders.Remove(src)

/obj/structure/ladder/proc/update_links()

	for(var/obj/structure/ladder/L in ladders)
		if(L == src)
			continue
		if(!isturf(L.loc))
			continue //Only link to existing ladders

		if(L.id == id)
			if(L.height == (height - 1))
				down = L
			else if(L.height == (height + 1))
				up = L

		if(up && down)	//if both our connections are filled
			break

	if(down && !isturf(down.loc)) //Remove connections to ladders that no longer exist
		down = null
	if(up && !isturf(up.loc))
		up = null

	update_icon()

/obj/structure/ladder/update_icon()
	if(up && down)
		icon_state = "ladder11"

	else if(up)
		icon_state = "ladder10"

	else if(down)
		icon_state = "ladder01"

	else	//wtf make your ladders properly assholes
		icon_state = "ladder00"

/obj/structure/ladder/attack_hand(mob/user as mob)
	if(up && down)
		switch( alert("Go up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
			if("Up")
				user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
									 "<span class='notice'>You climb up \the [src]!</span>")
				climb(user, get_turf(up))
				up.add_fingerprint(user)
			if("Down")
				user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
									 "<span class='notice'>You climb down \the [src]!</span>")
				climb(user, get_turf(down))
				down.add_fingerprint(user)
			if("Cancel")
				return

	else if(up)
		user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
							 "<span class='notice'>You climb up \the [src]!</span>")
		climb(user, get_turf(up))
		up.add_fingerprint(user)

	else if(down)
		user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
							 "<span class='notice'>You climb down \the [src]!</span>")
		climb(user, get_turf(down))
		down.add_fingerprint(user)

	else
		to_chat(user, "<span class='notice'>This ladder is broken!</span>")

	add_fingerprint(user)

/obj/structure/ladder/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/ladder/attackby(obj/item/weapon/W, mob/user as mob)
	if(isrobot(user))
		return

	return attack_hand(user)

/obj/structure/ladder/attack_slime(mob/user)
	return attack_hand(user)

/obj/structure/ladder/proc/climb(mob/user, turf/destination)
	user.forceMove(destination)

	for(var/obj/item/weapon/grab/G in user.held_items)
		if(G.affecting)
			G.affecting.forceMove(destination)

/obj/structure/ladder/attack_ghost(mob/user)
	return attack_hand(user)
