/obj/effect/dummy/phased_mob
	name = "water"
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | SHUTTLE_CRUSH_PROOF
	invisibility = INVISIBILITY_OBSERVER
	movement_type = FLOATING
	/// The movable which's jaunting in this dummy
	var/atom/movable/jaunter
	/// The delay between moves while jaunted
	var/movedelay = 0
	/// The speed of movement while jaunted
	var/movespeed = 0

/obj/effect/dummy/phased_mob/Initialize(mapload, atom/movable/jaunter)
	. = ..()
	if(jaunter)
		set_jaunter(jaunter)

/// Sets [new_jaunter] as our jaunter, forcemoves them into our contents
/obj/effect/dummy/phased_mob/proc/set_jaunter(atom/movable/new_jaunter)
	jaunter = new_jaunter
	jaunter.forceMove(src)
	if(ismob(jaunter))
		var/mob/mob_jaunter = jaunter
		mob_jaunter.reset_perspective(src)

/obj/effect/dummy/phased_mob/Destroy()
	jaunter = null // If a mob was left in the jaunter on qdel, they'll be dumped into nullspace
	return ..()

/// Removes [jaunter] from our phased mob
/obj/effect/dummy/phased_mob/proc/eject_jaunter()
	if(!jaunter)
		return // This is weird but it can happen if the jaunt is gibbed by an arriving shuttle
	var/turf/eject_spot = get_turf(src)
	if(!eject_spot) //You're in nullspace you clown!
		return

	var/area/destination_area = get_area(eject_spot)
	if(destination_area.area_flags & NOTELEPORT)
		// this ONLY happens if someone uses a phasing effect
		// to try to land in a NOTELEPORT zone after it is created, AKA trying to exploit.
		if(isliving(jaunter))
			var/mob/living/living_cheaterson = jaunter
			to_chat(living_cheaterson, span_userdanger("This area has a heavy universal force occupying it, and you are scattered to the cosmos!"))
			if(ishuman(living_cheaterson))
				shake_camera(living_cheaterson, 20, 1)
				addtimer(CALLBACK(living_cheaterson, TYPE_PROC_REF(/mob/living/carbon, vomit)), 2 SECONDS)
			jaunter.forceMove(find_safe_turf(z))
	else
		jaunter.forceMove(eject_spot)
	qdel(src)

/obj/effect/dummy/phased_mob/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == jaunter)
		SEND_SIGNAL(src, COMSIG_MOB_EJECTED_FROM_JAUNT, jaunter)
		jaunter = null

/obj/effect/dummy/phased_mob/ex_act()
	return FALSE

/obj/effect/dummy/phased_mob/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	SHOULD_CALL_PARENT(FALSE)
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/relaymove(mob/living/user, direction)
	var/turf/newloc = phased_check(user, direction)
	if(!newloc)
		return

	if (direction in GLOB.alldirs)
		setDir(direction)
	forceMove(newloc)

/// Checks if the conditions are valid to be able to phase. Returns a turf destination if positive.
/obj/effect/dummy/phased_mob/proc/phased_check(mob/living/user, direction)
	RETURN_TYPE(/turf)
	if (movedelay > world.time || !direction)
		return
	var/turf/newloc = get_step_multiz(src,direction)
	if(!newloc)
		return
	var/area/destination_area = newloc.loc
	movedelay = world.time + movespeed
	if(newloc.turf_flags & NOJAUNT)
		to_chat(user, span_warning("Some strange aura is blocking the way."))
		return
	if(destination_area.area_flags & NOTELEPORT || SSmapping.level_trait(newloc.z, ZTRAIT_NOPHASE))
		to_chat(user, span_danger("Some dull, universal force is blocking the way. It's overwhelmingly oppressive force feels dangerous."))
		return
	if (direction == UP || direction == DOWN)
		newloc = can_z_move(direction, get_turf(src), newloc, ZMOVE_INCAPACITATED_CHECKS | ZMOVE_FEEDBACK | ZMOVE_ALLOW_ANCHORED, user)

	return newloc
