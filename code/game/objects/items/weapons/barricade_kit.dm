//Now revamped along with barricades. No longer shitcode, at least for the better part
/obj/item/weapon/barricade_kit
	name = "wood barricade kit"
	desc = "Used to create all sorts of wooden fortifications ever since carpentry was invented."
	icon = 'icons/obj/barricade.dmi'
	icon_state = "barricade_kit"
	flags = FPRINT
	w_class = 3
	force = 3
	throwforce = 3
	throw_speed = 1
	throw_range = 3
	var/kit_uses = 3 //Three use of directional or blocking barricades, and one use for full-tile

/obj/item/weapon/barricade_kit/examine(mob/user)

	..()
	to_chat(user, "It has [kit_uses] uses left for regular barricades. It can [kit_uses < 3 ? "no longer be used" : "also be used"] for full barricades.")

//Basically a rip from window construction, because it's the same idea
/obj/item/weapon/barricade_kit/attack_self(mob/user as mob)
	if(!user || !src)
		return 0
	if(!istype(user.loc, /turf))
		return 0
	if(istype(user.loc, /turf/space))
		to_chat(user, "<span class='warning'>You can't build barricades out in space.</span>")
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	switch(alert("What do you want ([kit_uses] use\s left)", "Barricade Kit", "Directional", "Full Tile", "Cancel", null))
		if("Directional")
			if(!src)
				return 1
			if(src.loc != user)
				return 1
			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			for(var/obj/structure/window/barricade/BC in user.loc)
				if(!BC.is_fulltile() && BC.dir == user.dir)
					to_chat(user, "<span class='warning'>There already is a barricade facing that way</span>")
					return
			user.visible_message("<span class='warning'>[user] starts building a barricade.</span>", \
			"<span class='notice'>You start building a barricade.</span>")
			if(do_after(user, src, 30))
				to_chat(user, "<span class='notice'>You finish the barricade.</span>")
				var/obj/structure/window/barricade/BC = new /obj/structure/window/barricade(user.loc)
				BC.dir = user.dir
				kit_uses--
				if(kit_uses < 1)
					qdel(src)

		if("Full Tile")
			if(!src)
				return 1
			if(src.loc != user)
				return 1
			if(kit_uses < 3)
				to_chat(user, "<span class='warning'>This barricade doesn't have enough planks and nails left for that.</span>")
				return 1
			if(locate(/obj/structure/window/barricade/full) in user.loc)
				to_chat(user, "<span class='warning'>There is a barricade in the way.</span>")
				return 1
			user.visible_message("<span class='warning'>[user] starts building a full barricade.</span>", \
			"<span class='notice'>You start building a full barricade.</span>")
			if(do_after(user, src, 50))
				to_chat(user, "<span class='notice'>You finish the full barricade.</span>")
				new /obj/structure/window/barricade/full(user.loc)
				qdel(src) //Use it up

//Preattack to avoid bashing windows or opening airlocks when working
/obj/item/weapon/barricade_kit/preattack(var/atom/A, mob/user as mob)
	if(istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/window/full)) //Apply on a full window or an airlock
		if(get_dist(user,A) > 1) //There, it's unfucked
			return
		var/turf/T = get_turf(A)
		for(var/obj/structure/S in T)
			if(istype(S, /obj/structure/window/barricade/full/block))
				to_chat(user, "<span class='warning'>There already is a barricade here</span>")
				return
		user.visible_message("<span class='warning'>[user] starts barricading \the [A].</span>", \
		"<span class='notice'>You start barricading \the [A].</span>")
		if(do_after(user, T, 30))
			new /obj/structure/window/barricade/full/block(get_turf(T))
			user.visible_message("<span class='warning'>[user] barricades \the [A].</span>", \
			"<span class='notice'>You barricade \the [A].</span>")
			kit_uses--
			if(kit_uses < 1)
				qdel(src) //Get rid of it
		return 0 //Don't fire attack, please

	if(istype(A, /obj/structure/window) && !istype(A, /obj/structure/window/full)) //Windows
		if(get_dist(user,A) > 1)
			return
		var/turf/T = get_turf(A)
		for(var/obj/structure/S in T)
			if(istype(S, /obj/structure/window/barricade/full/block))
				to_chat(user, "<span class='warning'>There already is a barricade here</span>")
				return
			if(istype(S,/obj/structure/grille)) //Used as a makeshift check for a full window
				user.visible_message("<span class='warning'>[user] starts barricading \the [A].</span>", \
				"<span class='notice'>You start barricading \the [A].</span>")
				if(do_after(user, T, 30))
					new /obj/structure/window/barricade/full/block(get_turf(T))
					user.visible_message("<span class='warning'>[user] barricades \the [A].</span>", \
					"<span class='notice'>You barricade \the [A].</span>")
					kit_uses--
					if(kit_uses < 1)
						qdel(src) //Get rid of it
				break //If grilles somehow end up stacked, please don't multiply the problem
		return 0 //Don't fire attack, please

/obj/item/weapon/barricade_kit/attack(var/atom/A, mob/user as mob)

	return //Don't attack with it