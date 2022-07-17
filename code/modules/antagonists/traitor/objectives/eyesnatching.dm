/datum/traitor_objective_category/eyesnatching
	name = "Eyesnatching"
	objectives = list(
		/datum/traitor_objective/eyesnatching = 1,
		/datum/traitor_objective/eyesnatching/heads = 1,
	)
	weight = OBJECTIVE_WEIGHT_TINY

/datum/traitor_objective/eyesnatching
	name = "Steal %TARGET%'s (%JOB TITLE%) eyes"
	description = "%TARGET% messed with the wrong people. Steal their eyes to teach them a lesson. You will be provided an experimental eyesnatcher device to aid you in your mission."

	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(1, 2)

	// The code below is for limiting how often you can get this objective. You will get this objective at a maximum of maximum_objectives_in_period every objective_period
	/// The objective period at which we consider if it is an 'objective'. Set to 0 to accept all objectives.
	var/objective_period = 15 MINUTES
	/// The maximum number of objectives we can get within this period.
	var/maximum_objectives_in_period = 3

	/// Who we're stealing eyes from
	var/mob/living/victim
	/// If we're targeting heads of staff or not
	var/heads_of_staff = FALSE
	/// Have we already spawned an eyesnatcher
	var/spawned_eyesnatcher = FALSE

/datum/traitor_objective/eyesnatching/supported_configuration_changes()
	. = ..()
	. += NAMEOF(src, objective_period)
	. += NAMEOF(src, maximum_objectives_in_period)

/datum/traitor_objective/eyesnatching/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/eyesnatching, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/eyesnatching/heads
	progression_reward = list(6 MINUTES, 12 MINUTES)
	telecrystal_reward = list(2, 3)

	heads_of_staff = TRUE

/datum/traitor_objective/eyesnatching/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	if(generating_for.late_joiner)
		try_target_late_joiners = TRUE

	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == generating_for)
			continue

		if(!ishuman(possible_target.current))
			continue

		if(possible_target.current.stat == DEAD)
			continue

		if(possible_target.has_antag_datum(/datum/antagonist/traitor))
			continue

		if(heads_of_staff)
			if(!(possible_target.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue
		else
			if(possible_target.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
				continue

		var/mob/living/carbon/human/targets_current = possible_target.current
		if(!targets_current.getorgan(/obj/item/organ/internal/eyes))
			continue

		possible_targets += possible_target

	for(var/datum/traitor_objective/eyesnatching/objective as anything in possible_duplicates)
		possible_targets -= objective.victim?.mind

	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/datum/mind/possible_target as anything in all_possible_targets)
			if(!possible_target.late_joiner)
				possible_targets -= possible_target

		if(!possible_targets.len)
			possible_targets = all_possible_targets

	if(!possible_targets.len)
		return FALSE //MISSION FAILED, WE'LL GET EM NEXT TIME

	var/datum/mind/victim_mind = pick(possible_targets)
	victim = victim_mind.current

	replace_in_name("%TARGET%", victim_mind.name)
	replace_in_name("%JOB TITLE%", victim_mind.assigned_role.title)
	RegisterSignal(victim, COMSIG_CARBON_LOSE_ORGAN, .proc/check_eye_removal)
	AddComponent(/datum/component/traitor_objective_register, victim, fail_signals = COMSIG_PARENT_QDELETING)

/datum/traitor_objective/eyesnatching/proc/check_eye_removal(datum/source, obj/item/organ/internal/eyes/removed)
	SIGNAL_HANDLER

	if(!istype(removed))
		return

	succeed_objective()

/datum/traitor_objective/eyesnatching/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!spawned_eyesnatcher)
		buttons += add_ui_button("", "Pressing this will materialize an eyesnatcher, which can be used on incapacitaded or restrained targets to forcefully remove their eyes.", "syringe", "eyesnatcher")
	return buttons

/datum/traitor_objective/eyesnatching/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("eyesnatcher")
			if(spawned_eyesnatcher)
				return
			spawned_eyesnatcher = TRUE
			var/obj/item/eyesnatcher/eyesnatcher = new(user.drop_location())
			user.put_in_hands(eyesnatcher)
			eyesnatcher.balloon_alert(user, "the eyesnatcher materializes in your hand")

/obj/item/eyesnatcher
	name = "portable eyeball extractor"
	desc = "An overly complicated device that can pierce target's skull and extract their eyeballs if enough brute force is applied."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "eyesnatcher"
	base_icon_state = "eyesnatcher"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/used = FALSE

/obj/item/eyesnatcher/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][used ? "-used" : ""]"

/obj/item/eyesnatcher/attack(mob/living/carbon/human/victim, mob/living/user, params)
	if(!istype(victim) || !victim.Adjacent(user)) //No TK use
		return ..()

	var/obj/item/organ/internal/eyes/eyeballies = victim.getorganslot(ORGAN_SLOT_EYES)
	var/obj/item/bodypart/head/head = victim.get_bodypart(BODY_ZONE_HEAD)

	if(!eyeballies || victim.is_eyes_covered())
		return ..()

	if((head && head.eyes != eyeballies) || eyeballies.zone != BODY_ZONE_HEAD)
		to_chat(user, span_warning("You don't know how to apply [src] to the abomination that [victim] is!"))
		return ..()

	if(!head || !istype(head))
		return ..()

	user.do_attack_animation(victim, used_item = src)
	victim.visible_message(span_warning("[user] presses [src] against [victim]'s skull!"), span_userdanger("[user] presses [src] against your skull!"))
	if(!do_after(user, 5 SECONDS, target = victim, extra_checks = CALLBACK(src, .proc/eyeballs_exist, eyeballies, head, victim)))
		return

	to_chat(victim, span_userdanger("You feel [src] pushing at your skull!"))
	to_chat(user, span_notice("You apply more pressure to [src]."))
	if(!do_after(user, 5 SECONDS, target = victim, extra_checks = CALLBACK(src, .proc/eyeballs_exist, eyeballies, head, victim)))
		return

	var/datum/wound/blunt/severe/severe_wound_type = /datum/wound/blunt/severe
	var/datum/wound/blunt/critical/critical_wound_type = /datum/wound/blunt/critical
	victim.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = rand(initial(severe_wound_type.threshold_minimum), initial(critical_wound_type.threshold_minimum) + 10))
	victim.visible_message(
		span_danger("[src] pierces through [victim]'s skull, horribly mutilating their eyes!"),
		span_userdanger("Something penetrates your skull, horribly mutilating your eyes! Holy fuck!"),
		span_hear("You hear a sickening sound of metal piercing flesh!")
	)
	eyeballies.applyOrganDamage(eyeballies.maxHealth)
	victim.emote("scream")
	playsound(victim, "sound/effects/wounds/crackandbleed.ogg", 100)
	log_combat(user, victim, "pierced skull of", src)

	if(!do_after(user, 5 SECONDS, target = victim, extra_checks = CALLBACK(src, .proc/eyeballs_exist, eyeballies, head, victim)))
		return

	if(!HAS_TRAIT(victim, TRAIT_BLIND))
		to_chat(victim, span_userdanger("You suddenly go blind!"))

	to_chat(user, span_notice("You successfully extract [victim]'s eyeballs using [src]."))
	victim.emote("scream")
	playsound(victim, 'sound/surgery/retractor2.ogg', 100, TRUE)
	playsound(victim, 'sound/effects/pop.ogg', 100, TRAIT_MUTE)
	eyeballies.Remove(victim)
	eyeballies.forceMove(get_turf(victim))
	used = TRUE
	desc += " It has been used up."
	update_icon()

/obj/item/eyesnatcher/proc/eyeballs_exist(obj/item/organ/internal/eyes/eyeballies, obj/item/bodypart/head/head, mob/living/carbon/human/victim)
	if(!eyeballies || QDELETED(eyeballies))
		return FALSE

	if(!head || QDELETED(head))
		return FALSE

	if(!victim || QDELETED(victim))
		return FALSE

	if(eyeballies.owner != victim)
		return FALSE

	if(head.owner != victim || head.eyes != eyeballies)
		return FALSE

	return TRUE
