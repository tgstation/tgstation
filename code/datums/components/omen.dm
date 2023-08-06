/**
 * omen.dm: For when you want someone to have a really bad day
 *
 * When you attach an omen component to someone, they start running the risk of all sorts of bad environmental injuries, like nearby vending machines randomly falling on you,
 * or hitting your head really hard when you slip and fall, or you get shocked by the tram rails at an unfortunate moment.
 *
 * Omens are removed once the victim is either maimed by one of the possible injuries, or if they receive a blessing (read: bashing with a bible) from the chaplain.
 */
/datum/component/omen
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Whatever's causing the omen, if there is one. Destroying the vessel won't stop the omen, but we destroy the vessel (if one exists) upon the omen ending
	var/obj/vessel
	/// If the omen is permanent, it will never go away
	var/permanent = FALSE
	/// Base probability of negative events. Cursed are half as unlucky.
	var/luck_mod = 1
	/// Base damage from negative events. Cursed take 25% of this damage.
	var/damage_mod = 1

/datum/component/omen/Initialize(obj/vessel, permanent, luck_mod, damage_mod)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(istype(vessel))
		src.vessel = vessel
		RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(vessel_qdeleting))
	if(!isnull(permanent))
		src.permanent = permanent
	if(!isnull(luck_mod))
		src.luck_mod = luck_mod
	if(!isnull(damage_mod))
		src.damage_mod = damage_mod

/datum/component/omen/Destroy(force)
	var/mob/living/person = parent
	to_chat(person, span_nicegreen("You feel a horrible omen lifted off your shoulders!"))

	if(vessel)
		vessel.visible_message(span_warning("[vessel] burns up in a sinister flash, taking an evil energy with it..."))
		UnregisterSignal(vessel, COMSIG_QDELETING)
		vessel.burn()
		vessel = null

	return ..()

/datum/component/omen/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_accident))
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, PROC_REF(check_slip))
	RegisterSignal(parent, COMSIG_CARBON_MOOD_UPDATE, PROC_REF(check_bless))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))

/datum/component/omen/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ON_CARBON_SLIP, COMSIG_MOVABLE_MOVED, COMSIG_CARBON_MOOD_UPDATE, COMSIG_LIVING_DEATH))

/**
 * check_accident() is called each step we take
 *
 * While we're walking around, roll to see if there's any environmental hazards on one of the adjacent tiles we can trigger.
 * We do the prob() at the beginning to A. add some tension for /when/ it will strike, and B. (more importantly) ameliorate the fact that we're checking up to 5 turfs's contents each time
 */
/datum/component/omen/proc/check_accident(atom/movable/our_guy)
	SIGNAL_HANDLER

	if(!isliving(our_guy))
		return

	var/mob/living/living_guy = our_guy

	if(prob(0.001) && (living_guy.stat != DEAD)) // You hit the lottery! Kinda.
		living_guy.visible_message(span_danger("[living_guy] suddenly bursts into flames!"), span_danger("You suddenly burst into flames!"))
		INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")
		living_guy.adjust_fire_stacks(20)
		living_guy.ignite_mob(silent = TRUE)
		if(!permanent)
			qdel(src)
		return

	if(!prob(8 * luck_mod))
		return

	var/our_guy_pos = get_turf(living_guy)
	for(var/obj/machinery/door/airlock/darth_airlock in our_guy_pos)
		if(darth_airlock.locked || !darth_airlock.hasPower())
			continue

		to_chat(living_guy, span_warning("A malevolent force launches your body to the floor..."))
		living_guy.Paralyze(1 SECONDS, ignore_canstun = TRUE)
		INVOKE_ASYNC(src, PROC_REF(slam_airlock), darth_airlock)
		return

	if(istype(our_guy_pos, /turf/open/floor/noslip/tram_plate/energized))
		var/turf/open/floor/noslip/tram_plate/energized/future_tram_victim = our_guy_pos
		if(future_tram_victim.toast(living_guy))
			if(!permanent)
				qdel(src)
			return

	for(var/turf/the_turf as anything in get_adjacent_open_turfs(living_guy))
		if(istype(the_turf, /turf/open/floor/glass/reinforced/tram)) // don't fall off the tram bridge, we want to hit you instead
			return
		if(the_turf.zPassOut(living_guy, DOWN) && living_guy.can_z_move(DOWN, the_turf, z_move_flags = ZMOVE_FALL_FLAGS))
			to_chat(living_guy, span_warning("A malevolent force guides you towards the edge..."))
			living_guy.throw_at(the_turf, 1, 10, force = MOVE_FORCE_EXTREMELY_STRONG)
			if(!permanent)
				qdel(src)
			return

		for(var/obj/machinery/vending/darth_vendor in the_turf)
			if(!darth_vendor.tiltable || darth_vendor.tilted)
				continue
			to_chat(living_guy, span_warning("A malevolent force tugs at the [darth_vendor]..."))
			INVOKE_ASYNC(darth_vendor, TYPE_PROC_REF(/obj/machinery/vending, tilt), living_guy)
			if(!permanent)
				qdel(src)
			return

		for(var/obj/machinery/light/evil_light in the_turf)
			if((evil_light.status == LIGHT_BURNED || evil_light.status == LIGHT_BROKEN) || (HAS_TRAIT(living_guy, TRAIT_SHOCKIMMUNE))) // we cant do anything :( // Why in the world is there no get_siemens_coeff proc???
				to_chat(living_guy, span_warning("[evil_light] sparks weakly for a second."))
				do_sparks(2, FALSE, evil_light) // hey maybe it'll ignite them
				return

			to_chat(living_guy, span_warning("[evil_light] glows ominously...")) // omenously
			evil_light.visible_message(span_boldwarning("[evil_light] suddenly flares brightly and sparks!"))
			evil_light.break_light_tube(skip_sound_and_sparks = FALSE)
			do_sparks(number = 4, cardinal_only = FALSE, source = evil_light)
			evil_light.Beam(living_guy, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
			living_guy.electrocute_act(35 * (damage_mod * 0.5), evil_light, flags = SHOCK_NOGLOVES)
			INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")
			if(!permanent && prob(33.3))
				qdel(src)

		for(var/obj/structure/mirror/evil_mirror in the_turf)
			to_chat(living_guy, span_warning("You pass by the mirror and glance at it..."))
			if(evil_mirror.broken)
				to_chat(living_guy, span_notice("You feel lucky, somehow."))
				return
			switch(rand(1, 5))
				if(1)
					to_chat(living_guy, span_warning("The mirror explodes into a million pieces! Wait, does that mean you're even more unlucky?"))
					if(prob(50 * luck_mod)) // sometimes
						luck_mod += 0.25
						damage_mod += 0.25
				if(2 to 3)
					to_chat(living_guy, span_big(span_hypnophrase("Oh god, you can't see your reflection!!")))
					if(isvampire(living_guy)) // not so living i suppose
						to_chat(living_guy, span_green("Well, obviously."))
						return
					INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")

				if(4 to 5)
					if(isvampire(living_guy))
						to_chat(living_guy, span_warning("You don't see anything of notice. Huh."))
						return
					to_chat(living_guy, span_userdanger("You see your reflection, but it is grinning malevolently and staring directly at you!"))
					INVOKE_ASYNC(living_guy, TYPE_PROC_REF(/mob, emote), "scream")

			living_guy.set_jitter_if_lower(25 SECONDS)
			if(prob(7 * luck_mod))
				to_chat(living_guy, span_warning("You are completely shocked by this turn of events!"))
				var/mob/living/carbon/carbon_guy = living_guy
				to_chat(living_guy, span_userdanger("You clutch at your heart!"))
				if(istype(carbon_guy))
					carbon_guy.set_heartattack(status = TRUE)

			if(!permanent && prob(33.3))
				qdel(src)

/datum/component/omen/proc/slam_airlock(obj/machinery/door/airlock/darth_airlock)
	. = darth_airlock.close(force_crush = TRUE)
	if(. && !permanent && !prob(66.6))
		qdel(src)

/// If we get knocked down, see if we have a really bad slip and bash our head hard
/datum/component/omen/proc/check_slip(mob/living/our_guy, amount)
	SIGNAL_HANDLER

	if(prob(30)) // AAAA
		INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob, emote), "scream")
		to_chat(our_guy, span_warning("What a horrible night... To have a curse!"))

	if(prob(30 * luck_mod)) /// Bonk!
		var/obj/item/bodypart/the_head = our_guy.get_bodypart(BODY_ZONE_HEAD)
		if(!the_head)
			return
		playsound(get_turf(our_guy), 'sound/effects/tableheadsmash.ogg', 90, TRUE)
		our_guy.visible_message(span_danger("[our_guy] hits [our_guy.p_their()] head really badly falling down!"), span_userdanger("You hit your head really badly falling down!"))
		the_head.receive_damage(75 * damage_mod, damage_source = "slipping")
		our_guy.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100 * damage_mod)
		if(!permanent)
			qdel(src)

	return

/// Hijack the mood system to see if we get the blessing mood event to cancel the omen
/datum/component/omen/proc/check_bless(mob/living/our_guy, category)
	SIGNAL_HANDLER

	if(permanent)
		return

	if(!("blessing" in our_guy.mob_mood.mood_events))
		return

	qdel(src)

/// Severe deaths. Normally lifts the curse.
/datum/component/omen/proc/check_death(mob/living/our_guy)
	SIGNAL_HANDLER

	if(permanent)
		return

	qdel(src)

/// Creates a localized explosion that shakes the camera
/datum/component/omen/proc/death_explode(mob/living/our_guy)
	explosion(our_guy, explosion_cause = src)

	for(var/mob/witness in view(2, our_guy))
		shake_camera(witness, 1 SECONDS, 2)

/// Vessel got deleted, set it to null
/datum/component/omen/proc/vessel_qdeleting(atom/source)
	SIGNAL_HANDLER

	UnregisterSignal(vessel, COMSIG_QDELETING)
	vessel = null

/**
 * The smite omen. Permanent.
 */
/datum/component/omen/smite

/datum/component/omen/smite/check_death(mob/living/our_guy)
	if(!permanent)
		return ..()

	death_explode(our_guy)
	our_guy.gib()

/**
 * The quirk omen. Permanent.
 * Has only a 50% chance of bad things happening, and takes only 25% of normal damage.
 */
/datum/component/omen/quirk
	permanent = TRUE
	luck_mod = 0.5 // 50% chance of bad things happening
	damage_mod = 0.25 // 25% of normal damage

/datum/component/omen/quirk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_accident))
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, PROC_REF(check_slip))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))

/datum/component/omen/quirk/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ON_CARBON_SLIP, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH))

/datum/component/omen/quirk/check_death(mob/living/our_guy)
	if(!iscarbon(our_guy))
		our_guy.gib()
		return

	// Don't explode if buckled to a stasis bed
	if(our_guy.buckled)
		var/obj/machinery/stasis/stasis_bed = our_guy.buckled
		if(istype(stasis_bed))
			return

	death_explode(our_guy)
	var/mob/living/carbon/player = our_guy
	player.spread_bodyparts(skip_head = TRUE)
	player.spawn_gibs()

	return

/**
 * The bible omen.
 * While it lasts, parent gets a cursed aura filter.
 */
/datum/component/omen/bible

/datum/component/omen/bible/RegisterWithParent()
	. = ..()
	var/mob/living/living_parent = parent
	living_parent.add_filter("omen", 2, list("type" = "drop_shadow", "color" = COLOR_DARK_RED, "alpha" = 0, "size" = 2))
	var/filter = living_parent.get_filter("omen")
	animate(filter, alpha = 255, time = 2 SECONDS, loop = -1)
	animate(alpha = 0, time = 2 SECONDS)

/datum/component/omen/bible/UnregisterFromParent()
	. = ..()
	var/mob/living/living_parent = parent
	living_parent.remove_filter("omen")
