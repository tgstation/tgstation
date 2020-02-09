/obj/item/holobed_projector
	name = "holobed projector"
	desc = "Projects a roller bed formed from hard light."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_med"
	var/obj/structure/bed/holobed/loaded = null
	var/holo_range = 7


/obj/item/holobed_projector/Destroy()
	. = ..()
	turnoff_holobed() //Get rid of the holobed this is projecting

/obj/item/holobed_projector/attack_self(mob/user)
	. = ..()
	turnoff_holobed(user)

/obj/item/holobed_projector/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/turf/T = get_turf(target)
	var/distance = get_dist(T, src)
	if(distance > holo_range)
		to_chat(user, "<span class='warning'>[src] can't project that far! (<b>[distance - holo_range]</b> tiles beyond the maximum range of <b>[holo_range]</b>)</span>")
		return
	if(!isopenturf(T))
		return
	project_holobed(user, T)

/obj/item/holobed_projector/examine(mob/user)
	. = ..()
	. += "[src] is [loaded ? "projecting a holobed" : "isn't projecting a holobed"]."


/obj/item/holobed_projector/emp_act(severity)
	. = ..()
	if(!severity) //Even a love tap shorts out the bed.
		return

	if(!loaded)
		return

	turnoff_holobed()

/obj/item/holobed_projector/proc/turnoff_holobed(mob/user)
	if(!loaded)
		return

	if(!user)
		if(ismob(loc))
			user = loc

	if(user)
		to_chat(user, "<span class='notice'>[src] stops projecting [loaded].</span>")

	playsound(get_turf(src), 'sound/machines/chime.ogg', 30, TRUE)
	new /obj/effect/temp_visual/dir_setting/firing_effect/magic(get_turf(loaded))

	qdel(loaded)
	loaded = null


/obj/item/holobed_projector/proc/project_holobed(mob/user, atom/location)
	if(!user || !location)
		return

	if(!loaded)
		loaded = new(src)
		loaded.projector = src
		loaded.forceMove(location)
		user.visible_message("<span class='notice'>[user] projects [loaded].</span>", "<span class='notice'>You project [loaded].</span>")

	else if(location != get_turf(loaded))
		loaded.visible_message("<span class='warning'>[src] suddenly flickers and vanishes!</span>")
		new /obj/effect/temp_visual/dir_setting/firing_effect/magic(get_turf(loaded))
		loaded.handle_unbuckling()
		loaded.forceMove(location)

	new /obj/effect/temp_visual/dir_setting/firing_effect/magic(loaded.loc)
	playsound(location, 'sound/machines/chime.ogg', 30, TRUE)


/obj/item/holobed_projector/robot //cyborg version
	name = "integrated holobed projector"
	desc = "Projects a roller bed formed from hard light."


/obj/structure/bed/holobed
	name = "holo bed"
	desc = "A bed formed from hard light. Looks surprisingly comfortable."
	icon = 'icons/Fulpicons/holobed.dmi'
	icon_state = "holobed_unbuckled"
	anchored = FALSE
	buildstacktype = null
	buildstackamount = 0
	bolts = FALSE
	max_integrity = 1 // A single attack will dissipate it.
	integrity_failure = 0
	resistance_flags = ACID_PROOF | FREEZE_PROOF | UNACIDABLE | FIRE_PROOF | LAVA_PROOF //It's basically indestructible except for EMPs and physical dissipation.
	var/obj/item/holobed_projector/projector = null

/obj/structure/bed/holobed/Destroy()
	if(projector)
		projector.loaded = null //Get rid of the holobed this is projecting

	new /obj/effect/temp_visual/dir_setting/firing_effect/magic(src.loc)
	handle_unbuckling()
	visible_message("<span class='warning'>[src] suddenly flickers and vanishes!</span>")
	return ..()

/obj/structure/bed/holobed/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/empulse.ogg', 50, TRUE)

/obj/structure/bed/holobed/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1))
		to_chat("<span class='notice'>You can't dismantle this! It's made of hard light!</span>")
		return
	else
		return ..()

/obj/structure/bed/holobed/deconstruct(disassembled = TRUE)
	qdel(src)

/obj/structure/bed/holobed/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/holobed_projector))
		handle_unbuckling(user)
		return 1
	else
		return ..()

/obj/structure/bed/holobed/proc/handle_unbuckling(mob/user)
	if(has_buckled_mobs())
		if(buckled_mobs.len > 1 || !user)
			unbuckle_all_mobs()
			if(user)
				user.visible_message("<span class='notice'>[user] unbuckles all creatures from [src].</span>")
		else
			user_unbuckle_mob(buckled_mobs[1],user)

/obj/structure/bed/holobed/post_buckle_mob(mob/living/M)
	icon_state = "holobed_buckled"

/obj/structure/bed/holobed/post_unbuckle_mob(mob/living/M)
	icon_state = "holobed_unbuckled"

/* Probably not worth the resources that would need to be expended.
/obj/structure/bed/holobed/Moved()
	. = ..()
	if(validate_location()) //Check if we're out of projection range
		return
	visible_message("<span class='warning'>[src] suddenly flickers and vanishes!</span>")
	qdel(src)




/obj/structure/bed/holobed/proc/validate_location()
	if(!projector) //nothing projecting the bed so auto-fail
		return FALSE
	var/turf/T = get_turf(projector)
	if(T.z == z && get_dist(T, src) <= projector.holo_range)
		return TRUE
	else
		return FALSE*/

