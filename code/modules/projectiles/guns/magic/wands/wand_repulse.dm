#define REPULSE_RANGE 5

/**
 * Repulsion wand throws things backwards, might hurt them if they ram something
 */
/obj/item/gun/magic/wand/repulse
	name = "rod of repulsion"
	desc = "A wand which blasts things away from you."
	school = SCHOOL_TRANSLOCATION
	ammo_type = /obj/item/ammo_casing/magic/repulse
	icon_state = "repulsionwand"
	base_icon_state = "repulsionwand"
	fire_sound = 'sound/effects/magic/repulse.ogg'
	max_charges = 12

/obj/item/gun/magic/wand/repulse/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	user.visible_message(span_warning("[user] blasts [user.p_themselves()] into the ground!"))
	user.adjust_brute_loss(30)
	user.Paralyze(10 SECONDS)

/obj/item/gun/magic/wand/repulse/suicide_act(mob/living/user)
	if (!iscarbon(user))
		. = ..()
		return BRUTELOSS

	playsound(user, fire_sound, 50, TRUE)
	var/mob/living/carbon/suicider = user

	var/throw_dir = pick(GLOB.alldirs)
	var/atom/start_location = user.drop_location()
	var/turf/target_turf = get_edge_target_turf(start_location, throw_dir)

	user.Stun(2 SECONDS, ignore_canstun = TRUE)
	for (var/obj/item/organ/water_balloon as anything in suicider.organs)
		if (QDELETED(user))
			break // They might get dusted when one of these is pulled out or something
		var/turf/throw_at = get_ranged_target_turf_direct(start_location, target_turf, range = REPULSE_RANGE, offset = rand(-20, 20))
		water_balloon.Remove(user)
		water_balloon.forceMove(start_location)
		water_balloon.safe_throw_at(throw_at, REPULSE_RANGE, 3, force = MOVE_FORCE_STRONG)
		sleep(0.1 SECONDS)
	return BRUTELOSS

/obj/item/ammo_casing/magic/repulse
	projectile_type = /obj/projectile/magic/repulse

/obj/projectile/magic/repulse
	name = "bolt of repulsion"
	icon_state = "blastwave"

/obj/projectile/magic/repulse/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/atom/movable/victim = target
	if (!istype(victim))
		return
	var/turf/throw_target = get_ranged_target_turf_direct(src, get_edge_target_turf(src, NORTH), REPULSE_RANGE, -angle)
	victim.safe_throw_at(throw_target, REPULSE_RANGE, 3, force = MOVE_FORCE_STRONG)
	var/mob/living/living_target = target
	if (!istype(living_target))
		return
	living_target.Paralyze(2 SECONDS)

#undef REPULSE_RANGE
