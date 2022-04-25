/obj/item/inflatable
	name = "inflatable"
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'modular_pariah/master_files/icons/obj/inflatable.dmi'
	max_integrity = 10
	var/deploy_path = null

/obj/item/inflatable/attack_self(mob/user, modifiers)
	if(!deploy_path)
		return
	var/turf/T = get_turf(src)
	if (isspaceturf(T))
		to_chat(user, span_warning("You cannot use \the [src] in open space."))
		return

	user.visible_message(
		span_notice("\The [user] starts inflating \an [src]."),
		span_notice("You start inflating \the [src]."),
		span_notice("You can hear rushing air."),
		vision_distance = 5
	)
	if (!do_after(user, 1 SECONDS))
		return

	user.visible_message(
		span_notice("\The [user] finishes inflating \an [src]."),
		span_notice("You inflate \the [src]."),
		vision_distance = 5
	)
	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	var/obj/structure/inflatable/R = new deploy_path(T)
	transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	update_integrity(R.get_integrity())
	qdel(src)

/obj/item/inflatable/wall
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon_state = "folded_wall"
	deploy_path = /obj/structure/inflatable/wall

/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon_state = "folded_door"
	deploy_path = /obj/structure/inflatable/door

/obj/structure/inflatable
	name = "inflatable"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = 0
	icon = 'modular_pariah/master_files/icons/obj/inflatable.dmi'
	icon_state = "wall"
	can_atmos_pass = CANPASS_DENSITY
	max_integrity = 10


	var/undeploy_path = null
	var/taped

	var/max_pressure_diff = 50 * ONE_ATMOSPHERE // In Baystation this is a Rigsuit level of protection
	var/max_temp = 5000 //In Baystation this is the heat protection value of a space suit.

/obj/structure/inflatable/wall
	name = "inflatable wall"
	undeploy_path = /obj/item/inflatable/wall
	can_atmos_pass = CANPASS_NEVER

/obj/structure/inflatable/New(location)
	..()
	update_nearby_tiles(need_rebuild=1)

/obj/structure/inflatable/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/inflatable/Destroy()
	update_nearby_tiles()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/inflatable/process()
	check_environment()

/obj/structure/inflatable/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/glasshit.ogg', 75, TRUE)

/obj/structure/inflatable/proc/check_environment()
	var/min_pressure = INFINITY
	var/max_pressure = 0
	var/max_local_temp = 0

	for(var/check_dir in GLOB.cardinals)
		var/turf/T = get_step(src, check_dir)
		var/datum/gas_mixture/env = T.return_air()
		var/pressure = env.return_pressure()
		min_pressure = min(min_pressure, pressure)
		max_pressure = max(max_pressure, pressure)
		max_local_temp = max(max_local_temp, env.temperature)

	if(prob(50) && (max_pressure - min_pressure > max_pressure_diff || max_local_temp > max_temp))
		var/initial_damage_percentage = round(atom_integrity / max_integrity * 100)
		take_damage(1)
		var/damage_percentage = round(atom_integrity / max_integrity * 100)
		if (damage_percentage >= 70 && initial_damage_percentage < 70)
			visible_message(span_warning("\The [src] is barely holding up!"))
		else if (damage_percentage >= 30 && initial_damage_percentage < 30)
			visible_message(span_warning("\The [src] is taking damage!"))

/obj/structure/inflatable/examine(mob/user)
	. = ..()
	if (taped)
		to_chat(user, span_notice("It's being held together by duct tape."))

/obj/structure/inflatable/attackby(obj/item/W, mob/user, params)
	if(!istype(W)) //|| istype(W, /obj/item/inflatable_dispenser))
		return

	if(!isturf(user.loc))
		return //can't do this stuff whilst inside objects and such
	if(isliving(user))
		var/mob/living/living_user = user
		if(living_user.combat_mode)
			if (W.sharpness & SHARP_POINTY || W.force > 10)
				attack_generic(user, W.force, BRUTE)
			return

	if(istype(W, /obj/item/stack/sticky_tape) && (max_integrity - atom_integrity) >= 3)
		if(taped)
			to_chat(user, span_notice("\The [src] can't be patched any more with \the [W]!"))
			return TRUE
		else
			taped = TRUE
			to_chat(user, span_notice("You patch some damage in \the [src] with \the [W]!"))
			repair_damage(3)
			return TRUE

	..()

/obj/structure/inflatable/atom_break(damage_flag)
	. = ..()
	deflate(TRUE)

/obj/structure/inflatable/proc/deflate(violent)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new /obj/item/inflatable/torn(loc)
		src.transfer_fingerprints_to(R)
		qdel(src)
	else
		if(!undeploy_path)
			return
		visible_message("\The [src] slowly deflates.")
		addtimer(CALLBACK(src, .proc/after_deflate), 5 SECONDS, TIMER_STOPPABLE)

/obj/structure/inflatable/proc/after_deflate()
	if(QDELETED(src))
		return
	var/obj/item/inflatable/R = new undeploy_path(src.loc)
	src.transfer_fingerprints_to(R)
	R.update_integrity(src.get_integrity())
	qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(!usr.Adjacent(src))
		return FALSE
	if(!usr.Adjacent(src))
		return FALSE
	if(!iscarbon(usr))
		return FALSE

	var/mob/living/carbon/user = usr
	if(user.handcuffed || user.stat != CONSCIOUS || user.incapacitated())
		return FALSE

	verbs -= /obj/structure/inflatable/verb/hand_deflate
	deflate()
	return TRUE

/obj/structure/inflatable/attack_generic(mob/user, damage, attack_verb)
	. = ..()
	if(.)
		user.visible_message("<span class='danger'>[user] [attack_verb] open the [src]!</span>")
	else
		user.visible_message("<span class='danger'>[user] [attack_verb] at [src]!</span>")


/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"
	density = TRUE
	anchored = TRUE
	opacity = 0

	icon_state = "door_closed"
	undeploy_path = /obj/item/inflatable/door

	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0

/obj/structure/inflatable/door/attack_ai(mob/user as mob) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return

/obj/structure/inflatable/door/attack_robot(mob/living/user)
	if(get_dist(user,src) <= 1) //not remotely though
		return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	return TryToSwitchState(user)

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates) return
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()

/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = 1
	flick("door_opening",src)
	addtimer(CALLBACK(src, .proc/FinishOpen), 1 SECONDS, TIMER_STOPPABLE)

/obj/structure/inflatable/door/proc/FinishOpen()
	set_density(0)
	set_opacity(0)
	state = 1
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/inflatable/door/proc/Close()
	// If the inflatable is blocked, don't close
	for(var/turf/T in locs)
		for(var/atom/movable/AM as anything in T)
			if(AM.density)
				return

	isSwitchingStates = 1
	flick("door_closing",src)
	addtimer(CALLBACK(src, .proc/FinishClose), 1 SECONDS, TIMER_STOPPABLE)

/obj/structure/inflatable/door/proc/FinishClose()
	set_density(1)
	set_opacity(0)
	state = 0
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/inflatable/door/update_icon()
	. = ..()
	if(state)
		icon_state = "door_open"
	else
		icon_state = "door_closed"


/obj/structure/inflatable/door/deflate(violent=0)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/door/torn/R = new /obj/item/inflatable/door/torn(loc)
		src.transfer_fingerprints_to(R)
		qdel(src)
	else
		visible_message("[src] slowly deflates.")
		spawn(50)
			var/obj/item/inflatable/door/R = new /obj/item/inflatable/door(loc)
			src.transfer_fingerprints_to(R)
			qdel(src)

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon = 'modular_pariah/master_files/icons/obj/inflatable.dmi'
	icon_state = "folded_wall_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The inflatable wall is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/inflatable/door/torn
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon = 'modular_pariah/master_files/icons/obj/inflatable.dmi'
	icon_state = "folded_door_torn"

/obj/item/inflatable/door/torn/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The inflatable door is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors. THE SPRITE IS A PLACEHOLDER, OKAY?"
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 150
	force = 8
	hitsound = SFX_SWING_HIT
	throw_speed = 2
	throw_range = 4
	var/startswith = list(/obj/item/inflatable/door = 2, /obj/item/inflatable/wall = 3)

/obj/item/storage/briefcase/inflatable/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.set_holdable(list(/obj/item/inflatable))

/obj/item/storage/briefcase/inflatable/PopulateContents()
	for(var/path in startswith)
		for(var/i in 1 to startswith[path])
			new path(src)
