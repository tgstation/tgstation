/datum/action/cooldown/mob_cooldown/blood_worm/leech
	name = "Leech Blood"
	desc = "Aggressively grab a target with your teeth and leech off of their blood. Also works on reagent containers like blood packs. Leeching will be canceled if you do any other actions."

	button_icon_state = "leech_blood"

	cooldown_time = 5 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.
	click_cd_override = 0 // Click cooldown is also handled explicitly.

	var/leech_rate = 0
	var/oxyloss_rate = 0

	var/leech_grab_delay = 1 SECONDS

	/// Associative list of all reagent types that are compatible for leeching from reagent containers. Format is "list[reagent_type] = TRUE"
	var/static/list/compatible_container_reagent_types = list(
		/datum/reagent/blood = TRUE, // If it's blood, then it works :D
		/datum/reagent/consumable/liquidelectricity = TRUE, // Rare enough to allow.
	)

/datum/action/cooldown/mob_cooldown/blood_worm/leech/IsAvailable(feedback)
	if (!istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/leech/InterceptClickOn(mob/living/clicker, params, atom/target)
	var/modifiers = params2list(params)

	// Don't block examines, grabs, etc.
	if (modifiers[SHIFT_CLICK] || modifiers[ALT_CLICK] || modifiers[CTRL_CLICK])
		return FALSE

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/leech/Activate(atom/target)
	owner.face_atom(target)

	if (!ismovable(target))
		return FALSE
	if (!owner.Adjacent(target))
		target.balloon_alert(owner, "too far away!")
		return FALSE
	if (!target.IsReachableBy(owner))
		target.balloon_alert(owner, "can't reach!")
		return FALSE

	// If you fail after this point, it's because your attempt got interrupted or because the victim is invalid.
	unset_click_ability(owner, refund_cooldown = FALSE)

	if (isliving(target))
		leech_living(owner, target)
	else if (is_reagent_container(target))
		leech_container(owner, target)
	else
		target.balloon_alert(owner, "can't leech from this!")

	return TRUE // Prevents biting.

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_living(mob/living/basic/blood_worm/leech, mob/living/target)
	if (!leech_living_start_check(leech, target))
		return

	leech.visible_message(
		message = span_danger("\The [leech] start[leech.p_s()] trying to bite into \the [target]!"),
		self_message = span_danger("You start trying to bite into \the [target]!"),
		ignored_mobs = list(target)
	)

	target.show_message(
		msg = span_userdanger("\The [leech] start[leech.p_s()] trying to bite into you!"),
		type = MSG_VISUAL
	)

	leech.changeNext_move(CLICK_CD_CLICK_ABILITY)

	if (!do_after(leech, leech_grab_delay, target, extra_checks = CALLBACK(src, PROC_REF(leech_living_start_check), leech, target)))
		return

	if (leech.pulling != target && !leech.grab(target))
		target.balloon_alert(leech, "unable to grab!")
		return
	if (leech.grab_state < GRAB_AGGRESSIVE)
		leech.setGrabState(GRAB_AGGRESSIVE)

	// Flooring the target makes them treat our grab state as one higher, halving their escape chance.
	// Using a neck grab would reduce their escape chance to a third, which is too low.
	ADD_TRAIT(target, TRAIT_FLOORED, REF(src))

	// Prevents NPCs from resisting out of this.
	if (!target.client)
		incapacitate_leech_living_target(target)

	// Remove incapacitation if a client logs into the target, and readd it if they log back out.
	RegisterSignal(target, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(deincapacitate_leech_living_target))
	RegisterSignal(target, COMSIG_MOB_LOGOUT, PROC_REF(incapacitate_leech_living_target))

	leech.visible_message(
		message = span_danger("\The [leech] bite[leech.p_s()] into \the [target]!"),
		self_message = span_danger("You bite into \the [target]!"),
		blind_message = span_hear("You hear a bite, followed by a sickening crunch!"),
		ignored_mobs = list(target)
	)

	target.show_message(
		msg = span_userdanger("\The [leech] bite[leech.p_s()] into you!"),
		type = MSG_VISUAL,
		alt_msg = span_userdanger("You feel something bite into you!"),
		alt_type = MSG_AUDIBLE
	)

	playsound(target, 'sound/items/weapons/bite.ogg', vol = 80, vary = TRUE, ignore_walls = FALSE)
	playsound(target, 'sound/effects/wounds/pierce3.ogg', vol = 100, vary = TRUE, ignore_walls = FALSE)

	var/synth_content = target.get_blood_synth_content()
	if (synth_content >= 1)
		target.balloon_alert(leech, "fully synthetic")
	else if (synth_content > 0)
		target.balloon_alert(leech, "[CEILING(synth_content * 100, 1)]% synthetic")

	// Because of DO_AFTER_CHECK_NEXT_MOVE
	leech.next_move = 0

	while (do_after(leech, 1 SECONDS, target, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE | DO_AFTER_CHECK_NEXT_MOVE, extra_checks = CALLBACK(src, PROC_REF(leech_living_active_check), leech, target)))
		leech.consume_blood(-target.adjust_blood_volume(-leech_rate), target.get_blood_synth_content())

		if (target.stat != DEAD)
			target.adjust_oxy_loss(oxyloss_rate) // It's really weird if they just stand there until they literally drop dead from going below BLOOD_VOLUME_SURVIVE.

		playsound(target, 'sound/effects/wounds/splatter.ogg', vol = 80, vary = TRUE, ignore_walls = FALSE)

	if (leech.pulling == target && leech.grab_state >= GRAB_AGGRESSIVE)
		leech.setGrabState(GRAB_PASSIVE)

	UnregisterSignal(target, list(COMSIG_MOB_CLIENT_LOGIN, COMSIG_MOB_LOGOUT))

	REMOVE_TRAITS_IN(target, REF(src))

	StartCooldown()

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_living_start_check(mob/living/basic/blood_worm/leech, mob/living/target)
	if (target.get_blood_volume() <= 0)
		target.balloon_alert(leech, "no blood!")
		return FALSE
	if (HAS_TRAIT(target, TRAIT_BLOOD_WORM_HOST))
		target.balloon_alert(leech, "occupied by our kin!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_living_active_check(mob/living/basic/blood_worm/leech, mob/living/target)
	if (target.get_blood_volume() <= 0)
		target.balloon_alert(leech, "no more blood!")
		return FALSE
	if (HAS_TRAIT(target, TRAIT_BLOOD_WORM_HOST))
		target.balloon_alert(leech, "occupied by our kin!")
		return FALSE
	if (!leech.Adjacent(target) || leech.pulling != target || leech.grab_state < GRAB_AGGRESSIVE)
		target.balloon_alert(leech, "grab lost!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/incapacitate_leech_living_target(mob/living/target)
	SIGNAL_HANDLER
	ADD_TRAIT(target, TRAIT_INCAPACITATED, REF(src))

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/deincapacitate_leech_living_target(mob/living/target)
	SIGNAL_HANDLER
	REMOVE_TRAIT(target, TRAIT_INCAPACITATED, REF(src))

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_container(mob/living/basic/blood_worm/leech, obj/item/reagent_containers/target)
	if (!leech_container_start_check(leech, target, feedback = TRUE))
		return

	leech.visible_message(
		message = span_danger("\The [leech] start[leech.p_s()] trying to bite into \the [target]!"),
		self_message = span_danger("You start trying to bite into \the [target]!")
	)

	leech.changeNext_move(CLICK_CD_CLICK_ABILITY)

	if (!do_after(leech, leech_grab_delay, target, extra_checks = CALLBACK(src, PROC_REF(leech_container_start_check), leech, target)))
		return

	leech.visible_message(
		message = span_danger("\The [leech] bite[leech.p_s()] into \the [target]!"),
		self_message = span_danger("You bite into \the [target]!"),
		blind_message = span_hear("You hear a bite!"),
		ignored_mobs = list(target)
	)

	playsound(target, 'sound/items/weapons/bite.ogg', vol = 80, vary = TRUE, ignore_walls = FALSE)

	leech_container_alert_synth_info(leech, target)

	// Because of DO_AFTER_CHECK_NEXT_MOVE
	leech.next_move = 0

	while (do_after(leech, 1 SECONDS, target, timed_action_flags = DO_AFTER_CHECK_NEXT_MOVE, extra_checks = CALLBACK(src, PROC_REF(leech_container_active_check), leech, target)))
		var/list/blood = get_blood_in_container(target)

		var/total_volume = 0
		for (var/datum/reagent/reagent as anything in blood)
			total_volume += reagent.volume

		for (var/datum/reagent/reagent as anything in blood)
			var/synth_content = reagent.data?[BLOOD_DATA_SYNTH_CONTENT]
			var/amount_consumed = target.reagents.remove_reagent(reagent.type, leech_rate * (reagent.volume / total_volume))

			leech.consume_blood(amount_consumed, synth_content)

		playsound(target, 'sound/effects/wounds/splatter.ogg', vol = 80, vary = TRUE, ignore_walls = FALSE)

	StartCooldown()

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_container_alert_synth_info(mob/living/basic/blood_worm/leech, obj/item/reagent_containers/target)
	var/list/blood = get_blood_in_container(target)

	var/total_volume = 0
	var/synth_content = 0

	for (var/datum/reagent/reagent as anything in blood)
		total_volume += reagent.volume
		synth_content += reagent.data?[BLOOD_DATA_SYNTH_CONTENT] * reagent.volume

	synth_content /= total_volume

	if (synth_content >= 1)
		target.balloon_alert(leech, "fully synthetic")
	else if (synth_content > 0)
		target.balloon_alert(leech, "[CEILING(synth_content * 100, 1)]% synthetic")

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_container_start_check(mob/living/basic/blood_worm/leech, obj/item/reagent_containers/target, feedback = FALSE)
	if (!length(get_blood_in_container(target)))
		if (feedback)
			target.balloon_alert(leech, "no blood!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/leech_container_active_check(mob/living/basic/blood_worm/leech, obj/item/reagent_containers/target)
	if (!length(get_blood_in_container(target)))
		target.balloon_alert(leech, "no more blood!")
		return FALSE
	return TRUE

/// Returns all of the blood in the given container. Format is "list[reagent_type] = volume"
/datum/action/cooldown/mob_cooldown/blood_worm/leech/proc/get_blood_in_container(obj/item/reagent_containers/target)
	. = list()

	if (target.reagents.total_volume <= 0)
		return

	for (var/datum/reagent/reagent as anything in target.reagents.reagent_list)
		if (reagent.volume <= 0)
			continue
		if (!compatible_container_reagent_types[reagent.type])
			continue

		. += reagent

/datum/action/cooldown/mob_cooldown/blood_worm/leech/hatchling
	leech_rate = BLOOD_VOLUME_NORMAL * 0.05 // 28 units of blood, 5 points of health, or 6.25% of a hatchling blood worm's health
	oxyloss_rate = 11 // crosses from 44 to 55 at 5 seconds (50 is unconscious)

/datum/action/cooldown/mob_cooldown/blood_worm/leech/juvenile
	leech_rate = BLOOD_VOLUME_NORMAL * 0.075 // 42 units of blood, 7.5 points of health, or 6.25% of a juvenile blood worm's health
	oxyloss_rate = 15 // crosses from 45 to 60 at 4 seconds (50 is unconscious)

/datum/action/cooldown/mob_cooldown/blood_worm/leech/adult
	leech_rate = BLOOD_VOLUME_NORMAL * 0.1 // 56 units of blood, 10 points of health, or 5.55% of an adult blood worm's health
	oxyloss_rate = 20 // crosses from 40 to 60 at 3 seconds (50 is unconscious)
