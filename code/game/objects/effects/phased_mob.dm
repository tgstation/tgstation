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
	for(var/a in contents)
		var/atom/movable/AM = a
		AM.forceMove(drop_location())
	return ..()

/obj/effect/dummy/phased_mob/ex_act()
	return

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
	movedelay = world.time + movespeed
	if(newloc.flags_1 & NOJAUNT_1)
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way.</span>")
		return
	return newloc

/// React to signals by deleting the effect. Used for bloodcrawl.
/obj/effect/dummy/phased_mob/proc/deleteself(mob/living/source, obj/effect/decal/cleanable/phase_in_decal)
	SIGNAL_HANDLER
	qdel(src)
