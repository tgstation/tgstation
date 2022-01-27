/obj/effect/dummy/phased_mob
	name = "water"
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	movement_type = FLOATING
	var/movedelay = 0
	var/movespeed = 0

/obj/effect/dummy/phased_mob/Destroy()
	// Eject contents if deleted somehow
	var/atom/dest = drop_location()
	if(!dest) //You're in nullspace you clown
		return ..()
	var/area/destination_area = get_area(dest)
	var/failed_areacheck = FALSE
	if(destination_area.area_flags & NOTELEPORT)
		failed_areacheck = TRUE
	for(var/_phasing_in in contents)
		var/atom/movable/phasing_in = _phasing_in
		if(!failed_areacheck)
			phasing_in.forceMove(drop_location())
		else //this ONLY happens if someone uses a phasing effect to try to land in a NOTELEPORT zone after it is created, AKA trying to exploit.
			if(isliving(phasing_in))
				var/mob/living/living_cheaterson = phasing_in
				to_chat(living_cheaterson, span_userdanger("This area has a heavy universal force occupying it, and you are scattered to the cosmos!"))
				if(ishuman(living_cheaterson))
					shake_camera(living_cheaterson, 20, 1)
					addtimer(CALLBACK(living_cheaterson, /mob/living/carbon.proc/vomit), 2 SECONDS)
			phasing_in.forceMove(find_safe_turf(z))
	return ..()

/obj/effect/dummy/phased_mob/ex_act()
	return FALSE

/obj/effect/dummy/phased_mob/bullet_act(blah)
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/relaymove(mob/living/user, direction)
	var/turf/newloc = phased_check(user, direction)
	if(!newloc)
		return
	setDir(direction)
	forceMove(newloc)

/// Checks if the conditions are valid to be able to phase. Returns a turf destination if positive.
/obj/effect/dummy/phased_mob/proc/phased_check(mob/living/user, direction)
	RETURN_TYPE(/turf)
	if (movedelay > world.time || !direction)
		return
	var/turf/newloc = get_step(src,direction)
	if(!newloc)
		return
	var/area/destination_area = newloc.loc
	movedelay = world.time + movespeed
	if(newloc.flags_1 & NOJAUNT)
		to_chat(user, span_warning("Some strange aura is blocking the way."))
		return
	if(destination_area.area_flags & NOTELEPORT || SSmapping.level_trait(newloc.z, ZTRAIT_NOPHASE))
		to_chat(user, span_danger("Some dull, universal force is blocking the way. It's overwhelmingly oppressive force feels dangerous."))
		return
	return newloc

/// React to signals by deleting the effect. Used for bloodcrawl.
/obj/effect/dummy/phased_mob/proc/deleteself(mob/living/source, obj/effect/decal/cleanable/phase_in_decal)
	SIGNAL_HANDLER
	qdel(src)
