/datum/traitor_objective_category/harvest_liver
	name = "Harvest Liver"
	objectives = list(
		/datum/traitor_objective/target_player/harvest_liver = 1,
		/datum/traitor_objective/target_player/harvest_liver/everybody = 1,
	)
	weight = OBJECTIVE_WEIGHT_VERY_UNLIKELY

/datum/traitor_objective/target_player/harvest_liver
	name = "Steal the liver of %TARGET% the %JOB TITLE%"
	description = "%TARGET% has a very healthy and valuable liver. Steal it so it can be sold to %CUSTOMER%. You will be provided a container to hold the liver in."

	progression_minimum = 0 MINUTES

	progression_reward = list(6 MINUTES, 10 MINUTES)
	telecrystal_reward = list(2, 3)

	duplicate_type = /datum/traitor_objective/target_player

	var/static/list/possible_customers = list(
		"a wealthy CEO",
		"an old politician",
		"a shady surgeon",
		"an amoral patient",
		"a team of medical researchers",
		"the black market",
	)

	var/list/limited_to = list(
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_MEDICAL_DOCTOR,
		JOB_PARAMEDIC,
		JOB_VIROLOGIST,
		JOB_ROBOTICIST,
	)

	var/inverted_limitation = FALSE

	var/require_liver_trait = FALSE

	var/spawned_container = FALSE

	var/obj/item/organ/target_liver

/datum/traitor_objective/target_player/harvest_liver/everybody
	progression_minimum = 30 MINUTES

	inverted_limitation = TRUE

/datum/traitor_objective/target_player/harvest_liver/supported_configuration_changes()
	. = ..()
	. += NAMEOF(src, objective_period)
	. += NAMEOF(src, maximum_objectives_in_period)

/datum/traitor_objective/target_player/harvest_liver/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/target_player, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/target_player/harvest_liver/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/job = generating_for.assigned_role
	if(!(job.title in limited_to) && !inverted_limitation)
		return FALSE
	if((job.title in limited_to) && inverted_limitation)
		return FALSE
	if(length(possible_duplicates) > 0)
		return FALSE
	return TRUE

/datum/traitor_objective/target_player/harvest_liver/generate_objective(datum/mind/generating_for, list/possible_duplicates)
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

		if(require_liver_trait)
			if(!length(possible_target.assigned_role.liver_traits))
				continue

		var/mob/living/carbon/human/targets_current = possible_target.current
		if(!targets_current.get_organ_slot(ORGAN_SLOT_LIVER))
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
	target = target_mind.current
	target_liver = target.get_organ_slot(ORGAN_SLOT_LIVER)

	replace_in_name("%TARGET%", target_mind.name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	replace_in_name("%CUSTOMER%", pick(possible_customers))
	AddComponent(/datum/component/traitor_objective_register, target_liver, fail_signals = list(COMSIG_PARENT_QDELETING))
	return TRUE

/datum/traitor_objective/target_player/harvest_liver/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!spawned_container)
		buttons += add_ui_button("Call Container", "Pressing this will materialize the liver bag into your hands. This is the only valid container to hold the target's liver. There will be no replacements.", "bag-shopping", "container")
	return buttons

/datum/traitor_objective/target_player/harvest_liver/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("container")
			if(spawned_container)
				return
			spawned_container = TRUE
			var/obj/item/evidencebag/liverbag/liverbag = new(user.drop_location())
			user.put_in_hands(liverbag)
			AddComponent(/datum/component/traitor_objective_register, liverbag, fail_signals = list(COMSIG_PARENT_QDELETING))
			RegisterSignal(liverbag, COMSIG_ATOM_ENTERED, PROC_REF(on_liverbag_entered))
			liverbag.balloon_alert(user, "the liver bag materializes in your hand")

/datum/traitor_objective/target_player/harvest_liver/proc/on_liverbag_entered(obj/item/evidencebag/liverbag/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(target_liver && (arrived == target_liver))
		succeed_objective()
		INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item/evidencebag/liverbag, start_teliverport))

/obj/item/evidencebag/liverbag
	name = "liver bag"
	desc = "A plastic bag for holding... livers. And literally nothing else."
	can_take_items_out = FALSE

/obj/item/evidencebag/liverbag/evidencebagEquip(obj/item/stored, mob/user)
	if(!istype(stored) || stored.anchored)
		return

	if(loc.atom_storage && stored.atom_storage)
		to_chat(user, span_warning("No matter what way you try, you can't get [stored] to fit inside [src]."))
		return TRUE //begone infinite storage ghosts, begone from me

	if(loc in stored.get_all_contents())
		to_chat(user, span_warning("You find putting [stored] in [src] while it's still inside it quite difficult!"))
		return

	if(!istype(stored, /obj/item/organ/internal/liver))
		to_chat(user, span_warning("[src] smartly refuses anything that doesn't happen to be a liver."))
		return

	if(contents.len)
		to_chat(user, span_warning("[src] already has something inside it!"))
		return

	if(!isturf(stored.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(stored.loc.atom_storage) //in a container.
			stored.loc.atom_storage.remove_single(user, stored, src)
		if(!user.dropItemToGround(stored))
			return

	user.visible_message(span_notice("[user] puts [stored] into [src]."), span_notice("You put [stored] inside [src]."),\
		span_hear("You hear a rustle as someone puts something into a plastic bag."))

	icon_state = "evidence"

	var/mutable_appearance/in_evidence = new(stored)
	in_evidence.plane = FLOAT_PLANE
	in_evidence.layer = FLOAT_LAYER
	in_evidence.pixel_x = 0
	in_evidence.pixel_y = 0
	add_overlay(in_evidence)
	add_overlay("evidence") //should look nicer for transparent stuff. not really that important, but hey.

	desc = "A plastic bag containing [stored]. [stored.desc]"
	stored.forceMove(src)
	w_class = stored.w_class
	return TRUE

/obj/item/evidencebag/liverbag/proc/start_teliverport()
	var/filter = add_filter("teliverport_glow", 2, list("type" = "outline", "color" = "#00fbffff", "size" = 2))
	animate(filter, alpha = 100, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)
	visible_message(span_warning("[src] starts glowing menacingly!"))
	addtimer(CALLBACK(src, PROC_REF(end_teliverport)), 5 SECONDS)

/obj/item/evidencebag/liverbag/proc/end_teliverport()
	do_sparks(number = 3, cardinal_only = FALSE, source = src)
	playsound(loc, 'sound/effects/phasein.ogg', 60, TRUE)
	visible_message(span_warning("[src] disappears into thin air!"))
	qdel(src)
