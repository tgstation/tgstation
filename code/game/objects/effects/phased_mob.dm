/obj/effect/dummy/phased_mob
	name = "ethereal form"
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | SHUTTLE_CRUSH_PROOF
	invisibility = INVISIBILITY_OBSERVER
	movement_type = FLOATING
	/// The movable which is jaunting in this dummy
	var/atom/movable/jaunter
	/// The delay between moves while jaunted
	var/movedelay = 0
	/// The speed of movement while jaunted
	var/movespeed = 0
	/// Image we show to our jaunter so they can see where they are
	var/image/position_indicator
	/// Icon we draw our position indicator from
	var/phased_mob_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	/// Icon state we use for our position indicator
	var/phased_mob_icon_state = "ice_1"

/obj/effect/dummy/phased_mob/Initialize(mapload, atom/movable/jaunter)
	. = ..()
	if(jaunter)
		set_jaunter(jaunter)

/// Sets [new_jaunter] as our jaunter, forcemoves them into our contents
/obj/effect/dummy/phased_mob/proc/set_jaunter(atom/movable/new_jaunter)
	jaunter = new_jaunter
	jaunter.forceMove(src)
	if(!ismob(jaunter))
		return
	var/mob/mob_jaunter = jaunter
	position_indicator = image(phased_mob_icon, src, phased_mob_icon_state, ABOVE_LIGHTING_PLANE)
	position_indicator.appearance_flags |= RESET_ALPHA
	SET_PLANE_EXPLICIT(position_indicator, ABOVE_LIGHTING_PLANE, src)
	RegisterSignal(mob_jaunter, COMSIG_MOB_LOGIN, PROC_REF(show_client_image))
	RegisterSignal(mob_jaunter, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	mob_jaunter.reset_perspective(src)
	show_client_image(mob_jaunter)

/// Displays our position indicator to a client
/obj/effect/dummy/phased_mob/proc/show_client_image(mob/show_to)
	SIGNAL_HANDLER
	show_to.client?.images |= position_indicator

/obj/effect/dummy/phased_mob/Destroy()
	jaunter = null // If a mob was left in the jaunter on qdel, they'll be dumped into nullspace
	position_indicator = null
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
		UnregisterSignal(jaunter, COMSIG_MOB_STATCHANGE)
		UnregisterSignal(jaunter, COMSIG_MOB_LOGIN)
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

	if(SEND_SIGNAL(src, COMSIG_MOB_PHASED_CHECK, user, newloc) & COMPONENT_BLOCK_PHASED_MOVE)
		return null

	if(newloc.turf_flags & NOJAUNT)
		to_chat(user, span_warning("Some strange aura is blocking the way."))
		return
	if(destination_area.area_flags & NOTELEPORT || SSmapping.level_trait(newloc.z, ZTRAIT_NOPHASE))
		to_chat(user, span_danger("Some dull, universal force is blocking the way. Its overwhelmingly oppressive force feels dangerous."))
		return
	if (direction == UP || direction == DOWN)
		newloc = can_z_move(direction, get_turf(src), newloc, ZMOVE_INCAPACITATED_CHECKS | ZMOVE_FEEDBACK | ZMOVE_ALLOW_ANCHORED, user)

	return newloc

/// Signal proc for [COMSIG_MOB_STATCHANGE], to throw us out of the jaunt if we lose consciousness.
/obj/effect/dummy/phased_mob/proc/on_stat_change(mob/living/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if(source == jaunter && source.stat != CONSCIOUS)
		eject_jaunter()
