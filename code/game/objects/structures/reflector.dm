/obj/structure/reflector
	name = "reflector base"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_map"
	desc = "A base for reflector assemblies."
	anchored = FALSE
	density = FALSE
	layer = BELOW_OBJ_LAYER
	var/deflector_icon_state
	var/image/deflector_overlay
	var/finished = FALSE
	var/admin = FALSE //Can't be rotated or deconstructed
	var/can_rotate = TRUE
	var/framebuildstacktype = /obj/item/stack/sheet/metal
	var/framebuildstackamount = 5
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 0
	var/list/allowed_projectile_typecache = list(/obj/item/projectile/beam)
	var/rotation_angle = -1

/obj/structure/reflector/Initialize()
	. = ..()
	icon_state = "reflector_base"
	allowed_projectile_typecache = typecacheof(allowed_projectile_typecache)
	if(deflector_icon_state)
		deflector_overlay = image(icon, deflector_icon_state)
		add_overlay(deflector_overlay)

	if(rotation_angle == -1)
		setAngle(dir2angle(dir))
	else
		setAngle(rotation_angle)

	if(admin)
		can_rotate = FALSE

/obj/structure/reflector/examine(mob/user)
	..()
	if(finished)
		to_chat(user, "It is set to [rotation_angle] degrees, and the rotation is [can_rotate ? "unlocked" : "locked"].")
		if(!admin)
			if(can_rotate)
				to_chat(user, "<span class='notice'>Alt-click to adjust its direction.</span>")
			else
				to_chat(user, "<span class='notice'>Use screwdriver to unlock the rotation.</span>")

/obj/structure/reflector/proc/setAngle(new_angle)
	if(can_rotate)
		rotation_angle = new_angle
		if(deflector_overlay)
			cut_overlay(deflector_overlay)
			deflector_overlay.transform = turn(matrix(), new_angle)
			add_overlay(deflector_overlay)


/obj/structure/reflector/setDir(new_dir)
	setAngle(dir_map_to_angle(new_dir))
	return ..(NORTH)

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

	if(istype(W, /obj/item/screwdriver))
		can_rotate = !can_rotate
		to_chat(user, "<span class='notice'>You [can_rotate ? "unlock" : "lock"] [src]'s rotation.</span>")
		playsound(src, W.usesound, 50, 1)
		return

	if(istype(W, /obj/item/wrench))
		if(anchored)
			to_chat(user, "<span class='warning'>Unweld [src] from the floor first!</span>")
			return
		user.visible_message("[user] starts to dismantle [src].", "<span class='notice'>You start to dismantle [src]...</span>")
		if(do_after(user, 80*W.toolspeed, target = src))
			playsound(src, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You dismantle [src].</span>")
			new framebuildstacktype(drop_location(), framebuildstackamount)
			if(buildstackamount)
				new buildstacktype(drop_location(), buildstackamount)
			qdel(src)
	else if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W

		if(obj_integrity < max_integrity)
			if(WT.remove_fuel(0,user))
				user.visible_message("[user] starts to repair [src].",
									"<span class='notice'>You begin repairing [src]...</span>",
									"<span class='italics'>You hear welding.</span>")
				playsound(src, W.usesound, 40, 1)
				if(do_after(user,40*WT.toolspeed, target = src))
					obj_integrity = max_integrity
					user.visible_message("[user] has repaired [src].", \
										"<span class='notice'>You finish repairing [src].</span>")

		else if(!anchored)
			if (WT.remove_fuel(0,user))
				playsound(src, W.usesound, 50, 1)
				user.visible_message("[user] starts to weld [src] to the floor.",
									"<span class='notice'>You start to weld [src] to the floor...</span>",
									"<span class='italics'>You hear welding.</span>")
				if (do_after(user,20*W.toolspeed, target = src))
					if(!WT.isOn())
						return
					anchored = TRUE
					to_chat(user, "<span class='notice'>You weld [src] to the floor.</span>")
		else
			if (WT.remove_fuel(0,user))
				playsound(src, W.usesound, 50, 1)
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
		if(istype(S, /obj/item/stack/sheet/glass))
			if(S.use(5))
				new /obj/structure/reflector/single(drop_location())
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You need five sheets of glass to create a reflector!</span>")
				return
		if(istype(S, /obj/item/stack/sheet/rglass))
			if(S.use(10))
				new /obj/structure/reflector/double(drop_location())
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You need ten sheets of reinforced glass to create a double reflector!</span>")
				return
		if(istype(S, /obj/item/stack/sheet/mineral/diamond))
			if(S.use(1))
				new /obj/structure/reflector/box(drop_location())
				qdel(src)
	else
		return ..()

/obj/structure/reflector/proc/rotate(mob/user)
	if (!can_rotate || admin)
		to_chat(user, "<span class='warning'>The rotation is locked!</span>")
		return FALSE
	var/new_angle = input(user, "Input a new angle for primary reflection face.", "Reflector Angle", rotation_angle) as null|num
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!isnull(new_angle))
		setAngle(NORM_ROT(new_angle))
	return TRUE

/obj/structure/reflector/AltClick(mob/user)
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	else if(finished)
		rotate(user)


//TYPES OF REFLECTORS, SINGLE, DOUBLE, BOX

//SINGLE

/obj/structure/reflector/single
	name = "reflector"
	deflector_icon_state = "reflector"
	desc = "An angled mirror for reflecting laser beams."
	density = TRUE
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
	deflector_icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting laser beams."
	density = TRUE
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
	deflector_icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser beams in a single direction."
	density = TRUE
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
