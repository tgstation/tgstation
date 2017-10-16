/obj/structure/reflector
	name = "reflector frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	desc = "An angled mirror for reflecting lasers."
	anchored = FALSE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/finished = FALSE
	var/admin = FALSE //Can't be rotated or deconstructed
	var/framebuildstacktype = /obj/item/stack/sheet/metal
	var/framebuildstackamount = 5
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 0
	var/list/allowed_projectile_typecache = list(/obj/item/projectile/beam)
	var/rotation_angle = -1

/obj/structure/reflector/Initialize()
	. = ..()
	allowed_projectile_typecache = typecacheof(allowed_projectile_typecache)
	if(rotation_angle == -1)
		setAngle(dir2angle(dir))
	else
		setAngle(rotation_angle)

/obj/structure/reflector/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to adjust its direction.</span>")

/obj/structure/reflector/Moved()
	setAngle(dir_map_to_angle(dir))
	return ..()

/obj/structure/reflector/proc/dir_map_to_angle(dir)
	return 0

/obj/structure/reflector/bullet_act(obj/item/projectile/P)
	var/pdir = P.dir
	var/pangle = P.Angle
	var/ploc = get_turf(P)
	if(!finished || !allowed_projectile_typecache[P.type] || !(P.dir in GLOB.cardinals))
		return ..()
	if(auto_reflect(P, pdir, ploc, pangle) != -1)
		return ..()
	return -1

/obj/structure/reflector/proc/auto_reflect(obj/item/projectile/P, pdir, turf/ploc, pangle)
	P.ignore_source_check = TRUE
	return -1

/obj/structure/reflector/attackby(obj/item/W, mob/user, params)
	if(admin)
		return
	if(istype(W, /obj/item/wrench))
		if(anchored)
			to_chat(user, "Unweld [src] first!")
		if(do_after(user, 80*W.toolspeed, target = src))
			playsound(src.loc, W.usesound, 50, 1)
			to_chat(user, "You dismantle [src].")
			new framebuildstacktype(loc, framebuildstackamount)
			new buildstacktype(loc, buildstackamount)
			qdel(src)
	else if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(!anchored)
			if (WT.remove_fuel(0,user))
				playsound(src, 'sound/items/welder2.ogg', 50, 1)
				user.visible_message("[user] starts to weld [src] to the floor.", "<span class='notice'>You start to weld [src] to the floor...</span>", "<span class='italics'>You hear welding.</span>")
				if (do_after(user,20*W.toolspeed, target = src))
					if(!WT.isOn())
						return
					anchored = TRUE
					to_chat(user, "<span class='notice'>You weld [src] to the floor.</span>")
		else
			if (WT.remove_fuel(0,user))
				playsound(src, 'sound/items/welder2.ogg', 50, 1)
				user.visible_message("[user] starts to cut [src] free from the floor.", "<span class='notice'>You start to cut [src] free from the floor...</span>", "<span class='italics'>You hear welding.</span>")
				if (do_after(user,20*W.toolspeed, target = src))
					if(!WT.isOn())
						return
					anchored = FALSE
					to_chat(user, "<span class='notice'>You cut [src] free from the floor.</span>")
	//Finishing the frame
	else if(istype(W, /obj/item/stack/sheet))
		if(finished)
			return
		var/obj/item/stack/sheet/S = W
		if(istype(W, /obj/item/stack/sheet/glass))
			if(S.use(5))
				new /obj/structure/reflector/single (loc)
				qdel (src)
			else
				to_chat(user, "<span class='warning'>You need five sheets of glass to create a reflector!</span>")
				return
		if(istype(W, /obj/item/stack/sheet/rglass))
			if(S.use(10))
				new /obj/structure/reflector/double (loc)
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You need ten sheets of reinforced glass to create a double reflector!</span>")
				return
		if(istype(W, /obj/item/stack/sheet/mineral/diamond))
			if(S.use(1))
				new /obj/structure/reflector/box (loc)
				qdel(src)
	else
		return ..()

/obj/structure/reflector/proc/rotate(mob/user)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	var/new_angle = input(user, "Input a new angle for primary reflection face.", "Reflector Angle") as null|num
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	setAngle(NORM_ROT(new_angle))
	return TRUE

/obj/structure/reflector/proc/setAngle(new_angle)
	rotation_angle = new_angle
	setDir(NORTH)
	var/matrix/M = new
	M.Turn(new_angle)
	transform = M

/obj/structure/reflector/AltClick(mob/user)
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	else
		rotate(user)


//TYPES OF REFLECTORS, SINGLE, DOUBLE, BOX

//SINGLE

/obj/structure/reflector/single
	name = "reflector"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector"
	desc = "A double sided angled mirror for reflecting lasers. This one does so at a 90 degree angle."
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/glass
	buildstackamount = 5

/obj/structure/reflector/single/anchored
	anchored = TRUE

/obj/structure/reflector/single/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/single/auto_reflect(obj/item/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = get_angle_of_incidence(rotation_angle, P.Angle)
	var/incidence_norm = get_angle_of_incidence(rotation_angle, P.Angle, FALSE)
	if((incidence_norm > -90) && (incidence_norm < 90))
		return FALSE
	var/new_angle_s = rotation_angle + incidence
	while(new_angle_s > 180)	// Translate to regular projectile degrees
		new_angle_s -= 360
	while(new_angle_s < -180)
		new_angle_s += 360
	P.Angle = new_angle_s
	return ..()

//DOUBLE

/obj/structure/reflector/double
	name = "double sided reflector"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting lasers. This one does so at a 90 degree angle."
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/rglass
	buildstackamount = 10

/obj/structure/reflector/double/anchored
	anchored = TRUE

/obj/structure/reflector/double/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/double/auto_reflect(obj/item/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = get_angle_of_incidence(rotation_angle, P.Angle)
	var/incidence_norm = get_angle_of_incidence(rotation_angle, P.Angle, FALSE)
	var/invert = ((incidence_norm > -90) && (incidence_norm < 90))
	var/new_angle_s = rotation_angle + incidence
	if(invert)
		new_angle_s += 180
	while(new_angle_s > 180)	// Translate to regular projectile degrees
		new_angle_s -= 360
	while(new_angle_s < -180)
		new_angle_s += 360
	P.Angle = new_angle_s
	return ..()

//BOX

/obj/structure/reflector/box
	name = "reflector box"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser fire in a single direction."
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/mineral/diamond
	buildstackamount = 1

/obj/structure/reflector/box/anchored
	anchored = TRUE

/obj/structure/reflector/box/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/box/auto_reflect(obj/item/projectile/P)
	P.Angle = rotation_angle
	return ..()

/obj/structure/reflector/ex_act()
	if(admin)
		return
	else
		return ..()

/obj/structure/reflector/dir_map_to_angle(dir)
	return dir2angle(dir)

/obj/structure/reflector/singularity_act()
	if(admin)
		return
	else
		return ..()
