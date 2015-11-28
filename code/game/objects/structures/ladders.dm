/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	var/id = null
	var/height = 0							//the 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//the ladder below this one
	var/obj/structure/ladder/up = null		//the ladder above this one

/obj/structure/ladder/unbreakable //mostly useful for awaymissions to prevent halting progress in a mission
	name = "sturdy ladder"
	desc = "An extremely sturdy metal ladder."


/obj/structure/ladder/New()
	spawn(8)
		for(var/obj/structure/ladder/L in world)
			if(L.id == id)
				if(L.height == (height - 1))
					down = L
					continue
				if(L.height == (height + 1))
					up = L
					continue

			if(up && down)	//if both our connections are filled
				break
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

/obj/structure/ladder/proc/use(mob/user,is_ghost=0)
	if(up && down)
		switch( alert("Go up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
			if("Up")
				if(!is_ghost)
					user.visible_message("[user] climbs up \the [src].", \
									 "<span class='notice'>You climb up \the [src].</span>")
					up.add_fingerprint(user)
				user.loc = get_turf(up)
			if("Down")
				if(!is_ghost)
					user.visible_message("[user] climbs down \the [src].", \
									 "<span class='notice'>You climb down \the [src].</span>")
					down.add_fingerprint(user)
				user.loc = get_turf(down)
			if("Cancel")
				return

	else if(up)
		if(!is_ghost)
			user.visible_message("[user] climbs up \the [src].", \
								 "<span class='notice'>You climb up \the [src].</span>")
			up.add_fingerprint(user)
		user.loc = get_turf(up)

	else if(down)
		if(!is_ghost)
			user.visible_message("[user] climbs down \the [src].", \
								 "<span class='notice'>You climb down \the [src].</span>")
			down.add_fingerprint(user)
		user.loc = get_turf(down)
		
	if(!is_ghost)
		add_fingerprint(user)

/obj/structure/ladder/attack_hand(mob/user)
	use(user)

/obj/structure/ladder/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/ladder/attackby(obj/item/weapon/W, mob/user, params)
	return attack_hand(user)

/obj/structure/ladder/attack_ghost(mob/dead/observer/user)
	use(user,1)

/obj/structure/ladder/unbreakable/Destroy()
	return QDEL_HINT_LETMELIVE

