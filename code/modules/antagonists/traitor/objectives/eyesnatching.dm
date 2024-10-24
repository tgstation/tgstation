/datum/traitor_objective_category/eyesnatching
	name = "Eyesnatching"
	objectives = list(
		/datum/traitor_objective/target_player/eyesnatching = 1,
		/datum/traitor_objective/target_player/eyesnatching/heads = 1,
	)
	weight = OBJECTIVE_WEIGHT_UNLIKELY

/datum/traitor_objective/target_player/eyesnatching
	name = "Steal the eyes of %TARGET% the %JOB TITLE%"
	description = "%TARGET% messed with the wrong people. Steal their eyes to teach them a lesson. You will be provided an experimental eyesnatcher device to aid you in your mission."

	progression_minimum = 10 MINUTES

	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(1, 2)

	/// If we're targeting heads of staff or not
	var/heads_of_staff = FALSE
	/// Have we already spawned an eyesnatcher
	var/spawned_eyesnatcher = FALSE

	duplicate_type = /datum/traitor_objective/target_player

/datum/traitor_objective/target_player/eyesnatching/supported_configuration_changes()
	. = ..()
	. += NAMEOF(src, objective_period)
	. += NAMEOF(src, maximum_objectives_in_period)

/datum/traitor_objective/target_player/eyesnatching/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/target_player, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/target_player/eyesnatching/heads
	progression_reward = list(6 MINUTES, 12 MINUTES)
	telecrystal_reward = list(2, 3)

	heads_of_staff = TRUE

/datum/traitor_objective/target_player/eyesnatching/generate_objective(datum/mind/generating_for, list/possible_duplicates)

	var/list/already_targeting = list() //List of minds we're already targeting. The possible_duplicates is a list of objectives, so let's not mix things
	for(var/datum/objective/task as anything in handler.primary_objectives)
		if(!istype(task.target, /datum/mind))
			continue
		already_targeting += task.target //Removing primary objective kill targets from the list

	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	if(generating_for.late_joiner)
		try_target_late_joiners = TRUE

	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == generating_for)
			continue

		if(possible_target in already_targeting)
			continue

		if(!ishuman(possible_target.current))
			continue

		if(possible_target.current.stat == DEAD)
			continue

		if(possible_target.has_antag_datum(/datum/antagonist/traitor))
			continue

		if(!possible_target.assigned_role)
			continue

		if(heads_of_staff)
			if(!(possible_target.assigned_role.job_flags & JOB_HEAD_OF_STAFF))
				continue
		else
			if(possible_target.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
				continue

		var/mob/living/carbon/human/targets_current = possible_target.current
		if(!targets_current.get_organ_by_type(/obj/item/organ/eyes))
			continue

		possible_targets += possible_target

	for(var/datum/traitor_objective/target_player/objective as anything in possible_duplicates)
		possible_targets -= objective.target?.mind

	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/datum/mind/possible_target as anything in all_possible_targets)
			if(!possible_target.late_joiner)
				possible_targets -= possible_target

		if(!possible_targets.len)
			possible_targets = all_possible_targets

	if(!possible_targets.len)
		return FALSE //MISSION FAILED, WE'LL GET EM NEXT TIME

	var/datum/mind/target_mind = pick(possible_targets)
	set_target(target_mind.current)

	replace_in_name("%TARGET%", target_mind.name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	RegisterSignal(target, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(check_eye_removal))
	AddComponent(/datum/component/traitor_objective_register, target, fail_signals = list(COMSIG_QDELETING))
	return TRUE

/datum/traitor_objective/target_player/eyesnatching/proc/check_eye_removal(datum/source, obj/item/organ/eyes/removed)
	SIGNAL_HANDLER

	if(!istype(removed))
		return

	succeed_objective()

/datum/traitor_objective/target_player/eyesnatching/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!spawned_eyesnatcher)
		buttons += add_ui_button("", "Pressing this will materialize an eyesnatcher, which can be used on incapacitaded or restrained targets to forcefully remove their eyes.", "syringe", "eyesnatcher")
	return buttons

/datum/traitor_objective/target_player/eyesnatching/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("eyesnatcher")
			if(spawned_eyesnatcher)
				return
			spawned_eyesnatcher = TRUE
			var/obj/item/eyesnatcher/eyesnatcher = new(user.drop_location())
			user.put_in_hands(eyesnatcher)
			eyesnatcher.balloon_alert(user, "the snatcher materializes in your hand")

/obj/item/eyesnatcher
	name = "portable eyeball extractor"
	desc = "An overly complicated device that can pierce target's skull and extract their eyeballs if enough brute force is applied."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "eyesnatcher"
	base_icon_state = "eyesnatcher"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	///Whether it's been used to steal a pair of eyes already.
	var/used = FALSE

/obj/item/eyesnatcher/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][used ? "-used" : ""]"

/obj/item/eyesnatcher/attack(mob/living/carbon/human/target, mob/living/user, params)
	if(used || !istype(target) || !target.Adjacent(user)) //Works only once, no TK use
		return ..()

	var/obj/item/organ/eyes/eyeballies = target.get_organ_slot(ORGAN_SLOT_EYES)
	var/obj/item/bodypart/head/head = target.get_bodypart(BODY_ZONE_HEAD)

	if(!head || !eyeballies || target.is_eyes_covered())
		return ..()
	var/eye_snatch_enthusiasm = 5 SECONDS
	if(HAS_MIND_TRAIT(user, TRAIT_MORBID))
		eye_snatch_enthusiasm *= 0.7
	user.do_attack_animation(target, used_item = src)
	target.visible_message(
		span_warning("[user] presses [src] against [target]'s skull!"),
		span_userdanger("[user] presses [src] against your skull!"))
	if(!do_after(user, eye_snatch_enthusiasm, target = target, extra_checks = CALLBACK(src, PROC_REF(eyeballs_exist), eyeballies, head, target)))
		return

	to_chat(target, span_userdanger("You feel something forcing its way into your skull!"))
	balloon_alert(user, "applying pressure...")
	if(!do_after(user, eye_snatch_enthusiasm, target = target, extra_checks = CALLBACK(src, PROC_REF(eyeballs_exist), eyeballies, head, target)))
		return

	var/min_wound = head.get_wound_threshold_of_wound_type(WOUND_BLUNT, WOUND_SEVERITY_SEVERE, return_value_if_no_wound = 30, wound_source = src)
	var/max_wound = head.get_wound_threshold_of_wound_type(WOUND_BLUNT, WOUND_SEVERITY_CRITICAL, return_value_if_no_wound = 50, wound_source = src)

	target.apply_damage(20, BRUTE, BODY_ZONE_HEAD, wound_bonus = rand(min_wound, max_wound + 10), attacking_item = src)
	target.visible_message(
		span_danger("[src] pierces through [target]'s skull, horribly mutilating their eyes!"),
		span_userdanger("Something penetrates your skull, horribly mutilating your eyes! Holy fuck!"),
		span_hear("You hear a sickening sound of metal piercing flesh!")
	)
	eyeballies.apply_organ_damage(eyeballies.maxHealth)
	target.emote("scream")
	playsound(target, 'sound/effects/wounds/crackandbleed.ogg', 100)
	log_combat(user, target, "cracked the skull of (eye snatching)", src)

	if(!do_after(user, eye_snatch_enthusiasm, target = target, extra_checks = CALLBACK(src, PROC_REF(eyeballs_exist), eyeballies, head, target)))
		return

	if(!target.is_blind())
		to_chat(target, span_userdanger("You suddenly go blind!"))
	if(prob(1))
		to_chat(target, span_notice("At least you got a new pirate-y look out of it..."))
		var/obj/item/clothing/glasses/eyepatch/new_patch = new(target.loc)
		target.equip_to_slot_if_possible(new_patch, ITEM_SLOT_EYES, disable_warning = TRUE)

	to_chat(user, span_notice("You successfully extract [target]'s eyeballs."))
	playsound(target, 'sound/items/handling/surgery/retractor2.ogg', 100, TRUE)
	playsound(target, 'sound/effects/pop.ogg', 100, TRAIT_MUTE)
	eyeballies.Remove(target)
	eyeballies.forceMove(get_turf(target))
	notify_ghosts(
		"[target] has just had their eyes snatched!",
		source = target,
		header = "Ouch!",
	)
	target.emote("scream")
	if(prob(20))
		target.emote("cry")
	used = TRUE
	update_appearance(UPDATE_ICON)

/obj/item/eyesnatcher/examine(mob/user)
	. = ..()
	if(used)
		. += span_notice("It has been used up.")

/obj/item/eyesnatcher/proc/eyeballs_exist(obj/item/organ/eyes/eyeballies, obj/item/bodypart/head/head, mob/living/carbon/human/target)
	if(!eyeballies || QDELETED(eyeballies))
		return FALSE
	if(!head || QDELETED(head))
		return FALSE

	if(eyeballies.owner != target)
		return FALSE
	var/obj/item/organ/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	//got different eyes or doesn't own the head... somehow
	if(head.owner != target || eyes != eyeballies)
		return FALSE

	return TRUE
