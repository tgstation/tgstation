/datum/action/cooldown/mob_cooldown/blood_worm/leech
	name = "Leech Blood"
	desc = "Aggressively grab a target with your teeth and leech off of their blood. Also works on inorganic targets like blood bags."

	button_icon_state = "leech_blood"

	cooldown_time = 5 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.

	var/leech_rate = 0

/datum/action/cooldown/mob_cooldown/blood_worm/leech/IsAvailable(feedback)
	if (!istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/leech/InterceptClickOn(mob/living/clicker, params, atom/target)
	..()
	return TRUE // Necessary to intercept the attack chain.

/datum/action/cooldown/mob_cooldown/blood_worm/leech/Activate(atom/target)
	if (!ismovable(target))
		return FALSE
	if (!owner.Adjacent(target))
		target.balloon_alert(owner, "too far away!")
		return FALSE
	if (!target.IsReachableBy(owner))
		target.balloon_alert(owner, "can't reach!")
		return FALSE
	if (isliving(target))
		return leech_living(owner, target)

	target.balloon_alert(owner, "can't bite this!")

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_living(mob/living/basic/blood_worm/leech, mob/living/target)
	unset_click_ability(leech, refund_cooldown = FALSE) // If you fail after this point, it's because your attempt got interrupted or because the victim is invalid.

	if (!leech_living_start_check(leech, target, feedback = TRUE))
		return FALSE

	leech.visible_message(
		message = span_danger("\The [leech] start[leech.p_s()] trying to bite into \the [target]!"),
		self_message = span_danger("You start trying to bite into \the [target]!"),
		ignored_mobs = list(target)
	)

	target.show_message(
		msg = span_userdanger("\The [leech] start[leech.p_s()] trying to bite into you!"),
		type = MSG_VISUAL
	)

	if (!do_after(leech, 1 SECONDS, target, extra_checks = CALLBACK(src, PROC_REF(leech_living_start_check), leech, target)))
		target.balloon_alert(leech, "interrupted!")
		return FALSE

	if (leech.pulling != target && !leech.grab(target))
		target.balloon_alert(leech, "unable to grab!")
		return FALSE
	if (leech.grab_state < GRAB_AGGRESSIVE)
		leech.setGrabState(GRAB_AGGRESSIVE)

	leech.visible_message(
		message = span_danger("\The [leech] bite[leech.p_s()] into \the [target]!"),
		self_message = span_danger("You bite into \the [target]!"),
		blind_message = span_hear("You hear a sickening crunch!"),
		ignored_mobs = list(target)
	)

	target.show_message(
		msg = span_userdanger("\The [leech] bite[leech.p_s()] into you!"),
		type = MSG_VISUAL,
		alt_msg = span_userdanger("You feel something bite into you!"),
		alt_type = MSG_AUDIBLE
	)

	playsound(target, 'sound/effects/wounds/pierce3.ogg', vol = 100, vary = TRUE, ignore_walls = FALSE)

	var/start_time = world.time
	while (do_after(leech, 1 SECONDS, target, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(leech_living_active_check), leech, target)))
		var/delta_time = (world.time - start_time) * 0.1
		var/leech_amount = leech_rate * delta_time
		var/original_volume = target.blood_volume

		target.blood_volume = max(0, target.blood_volume - leech_amount)
		leech.ingest_blood(original_volume - target.blood_volume, target.get_bloodtype())

		playsound(target, 'sound/effects/wounds/splatter.ogg', vol = 80, vary = TRUE, ignore_walls = FALSE)

		start_time = world.time

	if (leech.pulling == target && leech.grab_state >= GRAB_AGGRESSIVE)
		leech.setGrabState(GRAB_PASSIVE)

	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_living_start_check(mob/living/basic/blood_worm/leech, mob/living/target, feedback = FALSE)
	if (HAS_TRAIT(target, TRAIT_NOBLOOD) || target.blood_volume <= 0 || !target.get_bloodtype())
		if (feedback)
			target.balloon_alert(leech, "no blood!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_living_active_check(mob/living/basic/blood_worm/leech, mob/living/target, feedback = FALSE)
	if (HAS_TRAIT(target, TRAIT_NOBLOOD) || target.blood_volume <= 0 || !target.get_bloodtype())
		if (feedback)
			target.balloon_alert(leech, "no more blood!")
		return FALSE
	if (!leech.Adjacent(target) || leech.pulling != target || leech.grab_state < GRAB_AGGRESSIVE)
		if (feedback)
			target.balloon_alert(leech, "interrupted!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/leech/hatchling
	leech_rate = BLOOD_VOLUME_NORMAL * 0.05 // 28 units of blood, 5 points of health, or 10% of a hatchling blood worm's health

/datum/action/cooldown/mob_cooldown/blood_worm/leech/juvenile
	leech_rate = BLOOD_VOLUME_NORMAL * 0.075 // 42 units of blood, 7.5 points of health, or 7.5% of a juvenile blood worm's health

/datum/action/cooldown/mob_cooldown/blood_worm/leech/adult
	leech_rate = BLOOD_VOLUME_NORMAL * 0.1 // 56 units of blood, 10 points of health, or 6.67% of an adult blood worm's health
