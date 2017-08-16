/obj/structure/reflector
	name = "reflector frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	desc = "An angled mirror for reflecting lasers. This one does so at a 90 degree angle."
	anchored = FALSE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/finished = 0
	var/admin = 0 //Can't be rotated or deconstructed
	var/framebuildstacktype = /obj/item/stack/sheet/metal
	var/framebuildstackamount = 5
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 0

/obj/structure/reflector/bullet_act(obj/item/projectile/P)
	var/turf/reflector_turf = get_turf(src)
	var/turf/reflect_turf
	var/new_dir = get_reflection(src.dir,P.dir)
	if(!istype(P, /obj/item/projectile/beam))
		return..()
	if(new_dir)
		reflect_turf = get_step(reflect_turf, new_dir)
	else
		visible_message("<span class='notice'>[src] is hit by the [P]!</span>")
		new_dir = 0
		return ..() //Hits as normal, explodes or emps or whatever

	reflect_turf = get_step(loc,new_dir)

	P.original = reflect_turf
	P.starting = reflector_turf
	P.current = reflector_turf
	P.yo = reflect_turf.y - reflector_turf.y
	P.xo = reflect_turf.x - reflector_turf.x
	P.range = initial(P.range) //Keep the projectile healthy as long as its bouncing off things
	new_dir = 0
	return - 1


/obj/structure/reflector/attackby(obj/item/W, mob/user, params)
	if(admin)
		return
	if(istype(W, /obj/item/wrench))
		if(anchored)
			to_chat(user, "Unweld the [src] first!")
		if(do_after(user, 80*W.toolspeed, target = src))
			playsound(src.loc, W.usesound, 50, 1)
			to_chat(user, "You dismantle the [src].")
			new framebuildstacktype(loc, framebuildstackamount)
			new buildstacktype(loc, buildstackamount)
			qdel(src)
	else if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		switch(anchored)
			if(0)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
						"<span class='notice'>You start to weld \the [src] to the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if (do_after(user,20*W.toolspeed, target = src))
						if(!src || !WT.isOn())
							return
						anchored = TRUE
						to_chat(user, "<span class='notice'>You weld \the [src] to the floor.</span>")
			if(1)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
						"<span class='notice'>You start to cut \the [src] free from the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if (do_after(user,20*W.toolspeed, target = src))
						if(!src || !WT.isOn())
							return
						anchored  = 0
						to_chat(user, "<span class='notice'>You cut \the [src] free from the floor.</span>")
	//Finishing the frame
	else if(istype(W, /obj/item/stack/sheet))
		if(finished)
			return
		var/obj/item/stack/sheet/S = W
		if(istype(W, /obj/item/stack/sheet/glass))
			if(S.get_amount() < 5)
				to_chat(user, "<span class='warning'>You need five sheets of glass to create a reflector!</span>")
				return
			else
				S.use(5)
				new /obj/structure/reflector/single (src.loc)
				qdel (src)
		if(istype(W, /obj/item/stack/sheet/rglass))
			if(S.get_amount() < 10)
				to_chat(user, "<span class='warning'>You need ten sheets of reinforced glass to create a double reflector!</span>")
				return
			else
				S.use(10)
				new /obj/structure/reflector/double (src.loc)
				qdel(src)
		if(istype(W, /obj/item/stack/sheet/mineral/diamond))
			if(S.get_amount() >= 1)
				S.use(1)
				new /obj/structure/reflector/box (src.loc)
				qdel(src)
	else
		return ..()

/obj/structure/reflector/proc/get_reflection(srcdir,pdir)
	return 0


/obj/structure/reflector/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (src.anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor!</span>")
		return 0
	src.setDir(turn(src.dir, 270))
	return 1


/obj/structure/reflector/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	else
		rotate()


//TYPES OF REFLECTORS, SINGLE, DOUBLE, BOX

//SINGLE

/obj/structure/reflector/single
	name = "reflector"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector"
	desc = "A double sided angled mirror for reflecting lasers. This one does so at a 90 degree angle."
	finished = 1
	var/static/list/rotations = list("[NORTH]" = list("[SOUTH]" = WEST, "[EAST]" = NORTH),
"[EAST]" = list("[SOUTH]" = EAST, "[WEST]" = NORTH),
"[SOUTH]" = list("[NORTH]" = EAST, "[WEST]" = SOUTH),
"[WEST]" = list("[NORTH]" = WEST, "[EAST]" = SOUTH) )
	buildstacktype = /obj/item/stack/sheet/glass
	buildstackamount = 5

/obj/structure/reflector/single/anchored
	anchored = TRUE

/obj/structure/reflector/single/get_reflection(srcdir,pdir)
	var/new_dir = rotations["[srcdir]"]["[pdir]"]
	return new_dir

/obj/structure/reflector/single/mapping
	admin = 1
	anchored = TRUE

//DOUBLE

/obj/structure/reflector/double
	name = "double sided reflector"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting lasers. This one does so at a 90 degree angle."
	finished = 1
	var/static/list/double_rotations = list("[NORTH]" = list("[NORTH]" = WEST, "[EAST]" = SOUTH, "[SOUTH]" = EAST, "[WEST]" = NORTH),
"[EAST]" = list("[NORTH]" = EAST, "[WEST]" = SOUTH, "[SOUTH]" = WEST, "[EAST]" = NORTH),
"[SOUTH]" = list("[NORTH]" = EAST, "[WEST]" = SOUTH, "[SOUTH]" = WEST, "[EAST]" = NORTH),
"[WEST]" = list("[NORTH]" = WEST, "[EAST]" = SOUTH, "[SOUTH]" = EAST, "[WEST]" = NORTH) )
	buildstacktype = /obj/item/stack/sheet/rglass
	buildstackamount = 10

/obj/structure/reflector/double/anchored
	anchored = TRUE

/obj/structure/reflector/double/get_reflection(srcdir,pdir)
	var/new_dir = double_rotations["[srcdir]"]["[pdir]"]
	return new_dir

/obj/structure/reflector/double/mapping
	admin = 1
	anchored = TRUE

//BOX

/obj/structure/reflector/box
	name = "reflector box"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser fire in a single direction."
	finished = 1
	var/static/list/box_rotations = list("[NORTH]" = list("[SOUTH]" = NORTH, "[EAST]" = NORTH, "[WEST]" = NORTH, "[NORTH]" = NORTH),
"[EAST]" = list("[SOUTH]" = EAST, "[EAST]" = EAST, "[WEST]" = EAST, "[NORTH]" = EAST),
"[SOUTH]" = list("[SOUTH]" = SOUTH, "[EAST]" = SOUTH, "[WEST]" = SOUTH, "[NORTH]" = SOUTH),
"[WEST]" = list("[SOUTH]" = WEST, "[EAST]" = WEST, "[WEST]" = WEST, "[NORTH]" = WEST) )
	buildstacktype = /obj/item/stack/sheet/mineral/diamond
	buildstackamount = 1

/obj/structure/reflector/box/anchored
	anchored = TRUE

/obj/structure/reflector/box/get_reflection(srcdir,pdir)
	var/new_dir = box_rotations["[srcdir]"]["[pdir]"]
	return new_dir


/obj/structure/reflector/box/mapping
	admin = 1
	anchored = TRUE

/obj/structure/reflector/ex_act()
	if(admin)
		return
	else
		..()


/obj/structure/reflector/singularity_act()
	if(admin)
		return
	else
		..()
