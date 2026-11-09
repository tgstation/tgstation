/**
 * omen.dm: For when you want someone to have a really bad day
 *
 * When you attach an omen component to someone, they start running the risk of all sorts of bad environmental injuries, like nearby vending machines randomly falling on you,
 * or hitting your head really hard when you slip and fall, or you get shocked by the tram rails at an unfortunate moment.
 *
 * Omens are removed once the victim is either maimed by one of the possible injuries, or if they receive a blessing (read: bashing with a bible) from the chaplain.
 */
/datum/component/omen
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Whatever's causing the omen, if there is one. Destroying the vessel won't stop the omen, but we destroy the vessel (if one exists) upon the omen ending
	var/obj/vessel
	/// How many incidents are left. If 0 exactly, it will get deleted.
	var/incidents_left = INFINITY
	/// Base probability of negative events. Cursed are half as unlucky.
	var/luck_mod = 1
	/// Base damage from negative events. Cursed take 25% of this damage.
	var/damage_mod = 1
	/// If TRUE being blessed by the chaplain can remove the omen
	var/bless_fixable = TRUE
	/// Callback invoked on death
	var/datum/callback/on_death
	/// List of light fixtures nearby - we track their state to see if they break or toggle
	VAR_FINAL/list/tracked_lights = list()

/datum/component/omen/Initialize(obj/vessel, incidents_left = INFINITY, luck_mod = 1, damage_mod = 1, bless_fixable = TRUE, datum/callback/on_death)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(istype(vessel))
		src.vessel = vessel
		RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(vessel_qdeleting))

	src.incidents_left = incidents_left
	src.luck_mod = luck_mod
	src.damage_mod = damage_mod
	src.bless_fixable = bless_fixable
	src.on_death = on_death

	ADD_TRAIT(parent, TRAIT_CURSED, REF(src))

/**
 * This is a omen eat omen world! The stronger omen survives.
 */
/datum/component/omen/InheritComponent(obj/vessel, incidents_left, luck_mod, damage_mod)
	// If we have more incidents left the new one gets deleted.
	if(src.incidents_left > incidents_left)
		return // make slimes get nurtiton from plasmer
	// Otherwise we set our incidents remaining to the higher, newer value.
	src.incidents_left = incidents_left
	// The new omen is weaker than our current omen? Let's split the difference.
	if(src.luck_mod > luck_mod)
		src.luck_mod += luck_mod * 0.5
	if(src.damage_mod > damage_mod)
		src.damage_mod += damage_mod * 0.5
	// This means that if you had a strong temporary omen and it was replaced by a weaker but permanent omen, the latter is made worse.
	// Feature!

/datum/component/omen/Destroy(force)
	var/mob/living/person = parent
	REMOVE_TRAIT(person, TRAIT_CURSED, REF(src))
	REMOVE_TRAIT(person, TRAIT_NO_MIRROR_REFLECTION, REF(src))
	to_chat(person, span_nicegreen("You feel a horrible omen lifted off your shoulders!"))

	if(vessel)
		vessel.visible_message(span_warning("[vessel] burns up in a sinister flash, taking an evil energy with it..."))
		UnregisterSignal(vessel, COMSIG_QDELETING)
		vessel.burn()
		vessel = null

	for(var/obj/machinery/light/to_untrack as anything in tracked_lights)
		untrack_light(to_untrack)

	return ..()

/datum/component/omen/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_accident))
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, PROC_REF(check_slip))
	RegisterSignal(parent, COMSIG_LIVING_BLESSED, PROC_REF(check_bless))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))
	RegisterSignal(parent, COMSIG_MOVABLE_BLOCKING_AIRLOCK, PROC_REF(check_airlock_crush))
	RegisterSignal(parent, COMSIG_MOB_VENDING_PURCHASE, PROC_REF(check_vending))
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/omen/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ON_CARBON_SLIP,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_BLESSED,
		COMSIG_LIVING_DEATH,
		COMSIG_MOVABLE_BLOCKING_AIRLOCK,
		COMSIG_MOB_VENDING_PURCHASE,
		COMSIG_LIVING_LIFE,
	))

/datum/component/omen/proc/consume_omen()
	if(incidents_left == INFINITY)
		return

	incidents_left--
	if(incidents_left < 1)
		qdel(src)

/// Roll an accident happening, factoring in a few things, based on some base change.
/datum/component/omen/proc/roll_for_accident(base_chance = 4)
	var/chance = base_chance * luck_mod
	for(var/mob/viewer in viewers(parent))
		if(!viewer.client?.is_afk())
			chance *= 2
			break

	return prob(chance)

/// When we obstruct an airlock, there's a chance it will crush us instead of stopping like it should
/datum/component/omen/proc/check_airlock_crush(mob/living/source, obj/machinery/door/airlock/darth_airlock, forced, force_crush)
	SIGNAL_HANDLER

	if(force_crush || !roll_for_accident(25))
		return NONE

	consume_omen()
	to_chat(parent, span_warning("As you stand in [darth_airlock], it doesn't stop closing like it should..."))
	return AIRLOCK_BLOCK_FORCE_CRUSH

/// When we vend an item from a vending machine, there's a chance the machine will tip
/datum/component/omen/proc/check_vending(mob/living/source, obj/machinery/vending/darth_vendor, obj/item/vended_item)
	SIGNAL_HANDLER

	if(!source.Adjacent(darth_vendor) || !roll_for_accident(10))
		return NONE

	consume_omen()
	to_chat(source, span_warning("As you grab [vended_item] from the slot, [darth_vendor] wobbles ominously..."))
	INVOKE_ASYNC(darth_vendor, TYPE_PROC_REF(/obj/machinery/vending, tilt), source)
	return VENDING_NO_PICKUP

/// On life tick, run a few generic checks for accidents, and track nearby lights
/datum/component/omen/proc/on_life(mob/living/source)
	SIGNAL_HANDLER

	if(source.stat == DEAD || HAS_TRAIT(source, TRAIT_STASIS))
		return

	if(roll_for_accident(0.001))
		spontaneous_combustion(source)
		return

	if(HAS_TRAIT(source, TRAIT_SHOCKIMMUNE))
		for(var/obj/machinery/light/to_untrack as anything in tracked_lights)
			untrack_light(to_untrack)
		return

	var/list/light_list = list()
	for(var/obj/machinery/light/evil_light in view(2, source))
		if(evil_light.status == LIGHT_OK)
			light_list += evil_light
	for(var/obj/machinery/light/to_track as anything in light_list - tracked_lights)
		track_light(to_track)
	for(var/obj/machinery/light/to_untrack as anything in tracked_lights - light_list)
		untrack_light(to_untrack)

/// Start tracking a light, because it's near us and could be a threat
/datum/component/omen/proc/track_light(obj/machinery/light/evil_light)
	tracked_lights += evil_light
	RegisterSignal(evil_light, COMSIG_LIGHT_FIXTURE_BROKEN, PROC_REF(check_break_zap))
	RegisterSignal(evil_light, COMSIG_LIGHT_FIXTURE_TOGGLED, PROC_REF(check_toggle_zap))
	RegisterSignal(evil_light, COMSIG_QDELETING, PROC_REF(untrack_light))

/// Stop tracking a light, either because it broke or we moved away from it
/datum/component/omen/proc/untrack_light(obj/machinery/light/evil_light)
	SIGNAL_HANDLER

	tracked_lights -= evil_light
	UnregisterSignal(evil_light, list(COMSIG_LIGHT_FIXTURE_BROKEN, COMSIG_LIGHT_FIXTURE_TOGGLED, COMSIG_QDELETING))

/// When a light we track breaks, there's a chance of zapping us
/datum/component/omen/proc/check_break_zap(obj/machinery/light/evil_light, was_ok)
	SIGNAL_HANDLER

	if(was_ok && !HAS_TRAIT(parent, TRAIT_SHOCKIMMUNE) && roll_for_accident(25))
		evil_light.visible_message(span_boldwarning("A bolt of electricity jumps from [evil_light] to [parent] as it breaks!"))
		light_zap(evil_light)
		consume_omen()
	// always untrack because it's broken now
	untrack_light(evil_light)

/// When a light we track is toggled on or off, there's a chance of zapping us
/datum/component/omen/proc/check_toggle_zap(obj/machinery/light/evil_light, new_status)
	SIGNAL_HANDLER

	if(HAS_TRAIT(parent, TRAIT_SHOCKIMMUNE) || !roll_for_accident(10))
		return

	evil_light.visible_message(span_boldwarning("A bolt of electricity jumps from [evil_light] to [parent] as it turns [new_status ? "on" : "off"]!"))
	light_zap(evil_light)
	consume_omen()
	// we're about to break it, so untrack to avoid a double zap
	untrack_light(evil_light)
	// and then actually break the thing
	evil_light.break_light_tube()

/// Zap the target with electricity from a light fixture
/datum/component/omen/proc/light_zap(obj/machinery/light/evil_light)
	PRIVATE_PROC(TRUE)

	var/mob/living/target = parent
	evil_light.Beam(target, icon_state = "lightning[rand(1, 12)]", time = 0.5 SECONDS)
	target.electrocute_act(35 * damage_mod, evil_light, flags = SHOCK_NOGLOVES)
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	consume_omen()

/// Randomly burst into flames
/datum/component/omen/proc/spontaneous_combustion()
	var/mob/living/target = parent
	target.adjust_fire_stacks(20)
	if(!target.ignite_mob(silent = TRUE))
		return FALSE

	target.visible_message(
		span_danger("[target] suddenly bursts into flames!"),
		span_userdanger("You suddenly burst into flames!"),
	)
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	consume_omen()
	return TRUE

/// Every time we move we need to check a few things for potential incidents
/datum/component/omen/proc/check_accident(mob/living/source)
	SIGNAL_HANDLER

	if(mirror_interaction())
		return

	if(fall_down())
		return

/// Attempts to throw us down a nearby open space
/datum/component/omen/proc/fall_down()
	var/mob/living/our_guy = parent
	var/turf/open/mob_turf = get_turf(our_guy)
	if(isgroundlessturf(mob_turf) || istype(mob_turf, /turf/open/floor/glass/reinforced/tram)) // snowflake check is to increase likelihood of being hit with the tram
		return FALSE

	for(var/turf/adjacent_turf as anything in get_adjacent_open_turfs(mob_turf))
		if(!our_guy.can_z_move(DOWN, adjacent_turf, z_move_flags = ZMOVE_FALL_FLAGS))
			continue
		if(!roll_for_accident(4))
			return FALSE

		var/obj/structure/railing/rail = locate() in mob_turf
		to_chat(our_guy, span_warning("As you step on [mob_turf], you lose footing and fall[rail ? " over the railing and" : ""] off the edge!"))
		our_guy.throw_at(adjacent_turf, 1, 10, force = MOVE_FORCE_EXTREMELY_STRONG)
		consume_omen()
		return TRUE

	return FALSE

/// Gaze into a mirror and see if something bad happens
/datum/component/omen/proc/mirror_interaction()
	var/mob/living/our_guy = parent
	var/obj/structure/mirror/evil_mirror = locate() in get_turf(our_guy)
	if(isnull(evil_mirror) || !roll_for_accident(10))
		REMOVE_TRAIT(our_guy, TRAIT_NO_MIRROR_REFLECTION, REF(src))
		return FALSE

	to_chat(our_guy, span_warning("You pass by the mirror and glance at it..."))
	if(evil_mirror.broken)
		to_chat(our_guy, span_notice("...You feel lucky, somehow."))
		return TRUE

	switch(rand(1, 5))
		if(1)
			to_chat(our_guy, span_warning("...The mirror explodes into a million pieces! Wait, does that mean you're even more unlucky?"))
			evil_mirror.take_damage(evil_mirror.max_integrity, BRUTE, MELEE, FALSE)
			if(roll_for_accident(20))
				luck_mod += 0.25
				damage_mod += 0.25

		if(2 to 3)
			if(HAS_TRAIT(our_guy, TRAIT_NO_MIRROR_REFLECTION)) // not so living i suppose
				to_chat(our_guy, span_green("...Oh god, you can't see your reflection - wait, that's normal."))
				return TRUE
			to_chat(our_guy, span_big(span_hypnophrase("...Oh god, you can't see your reflection!!")))
			INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob, emote), "scream")
			ADD_TRAIT(our_guy, TRAIT_NO_MIRROR_REFLECTION, REF(src))

		if(4 to 5)
			if(HAS_TRAIT(our_guy, TRAIT_NO_MIRROR_REFLECTION))
				to_chat(our_guy, span_warning("...but you don't see anything of notice."))
				return TRUE
			to_chat(our_guy, span_userdanger("You see your reflection, but it is grinning malevolently and staring directly at you!"))
			INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob, emote), "scream")

	our_guy.set_jitter_if_lower(25 SECONDS)
	if(roll_for_accident(2))
		to_chat(our_guy, span_warning("You are completely shocked by this turn of events!"))
		to_chat(our_guy, span_userdanger("You clutch at your heart!"))
		if(iscarbon(our_guy))
			var/mob/living/carbon/carbon_guy = our_guy
			carbon_guy.set_heartattack(status = TRUE)

	consume_omen()
	return TRUE

/// If we get knocked down, see if we have a really bad slip and bash our head hard
/datum/component/omen/proc/check_slip(mob/living/our_guy, amount)
	SIGNAL_HANDLER

	if(!our_guy.get_bodypart(BODY_ZONE_HEAD) || !roll_for_accident(15)) // Bonk!
		return

	playsound(our_guy, 'sound/effects/tableheadsmash.ogg', 90, TRUE)
	our_guy.visible_message(
		span_danger("[our_guy] hits [our_guy.p_their()] head really badly falling down!"),
		span_userdanger("You hit your head really badly falling down!"),
	)
	our_guy.apply_damage(75 * damage_mod, BRUTE, BODY_ZONE_HEAD, attacking_item = "slipping")
	our_guy.apply_damage(100 * damage_mod, BRAIN)
	consume_omen()

/// Hijack the mood system to see if we get the blessing mood event to cancel the omen
/datum/component/omen/proc/check_bless(mob/living/our_guy, mob/living/priest, obj/item/book/bible/bible, bless_result)
	SIGNAL_HANDLER

	if(incidents_left == INFINITY || bless_result != BLESSING_SUCCESS || !bless_fixable)
		return

	playsound(our_guy, 'sound/effects/pray_chaplain.ogg', 40, TRUE)
	to_chat(our_guy, span_green("You feel fantastic!"))
	qdel(src)

/// Severe deaths. Normally lifts the curse.
/datum/component/omen/proc/check_death(mob/living/our_guy)
	SIGNAL_HANDLER

	on_death?.Invoke(src)
	if(incidents_left == INFINITY)
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
 * The bible omen.
 * While it lasts, parent gets a cursed aura filter.
 */
/datum/component/omen/bible
	incidents_left = 1

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
