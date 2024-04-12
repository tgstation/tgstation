/datum/traitor_objective_category/infect
	name = "Infect with Disease"
	objectives = list(
		/datum/traitor_objective/target_player/infect = 1,
	)

/datum/traitor_objective/target_player/infect
	name = "Infect %TARGET% the %JOB TITLE%"
	description = "Infect your target with the experimental Hereditary Manifold Sickness."

	progression_minimum = 30 MINUTES

	progression_reward = list(8 MINUTES, 14 MINUTES)
	telecrystal_reward = 1

	duplicate_type = /datum/traitor_objective/target_player/infect

	/// if TRUE, can only target heads of staff
	/// if FALSE, CANNOT target heads of staff
	var/heads_of_staff = FALSE
	/// if TRUE, the injector item has been bestowed upon the player
	var/injector_given = FALSE

/datum/traitor_objective/target_player/infect/supported_configuration_changes()
	. = ..()
	. += NAMEOF(src, objective_period)
	. += NAMEOF(src, maximum_objectives_in_period)

/datum/traitor_objective/target_player/infect/can_generate_objective(generating_for, list/possible_duplicates)
	if(length(possible_duplicates) > 0)
		return FALSE
	return ..()

/datum/traitor_objective/target_player/infect/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!injector_given)
		buttons += add_ui_button("", "Pressing this will materialize a EHMS autoinjector into your hand, which you must inject into the target to succeed.", "syringe", "summon_pen")
	return buttons

/datum/traitor_objective/target_player/infect/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_pen")
			if(injector_given)
				return
			injector_given = TRUE
			var/obj/item/reagent_containers/hypospray/medipen/manifoldinjector/ehms = new(user.drop_location())
			user.put_in_hands(ehms)
			ehms.balloon_alert(user, "the injector materializes in your hand")
			RegisterSignal(ehms, COMSIG_EHMS_INJECTOR_INJECTED, PROC_REF(on_injected))
			AddComponent(/datum/component/traitor_objective_register, ehms, \
				succeed_signals = null, \
				fail_signals = list(COMSIG_QDELETING), \
				penalty = TRUE)

/datum/traitor_objective/target_player/infect/proc/on_injected(datum/source, mob/living/user, mob/living/injected)
	SIGNAL_HANDLER
	if(injected != target)
		fail_objective()
		return
	if(injected == target)
		succeed_objective()
		return

/datum/traitor_objective/target_player/infect/generate_objective(datum/mind/generating_for, list/possible_duplicates)

	var/list/already_targeting = list() //List of minds we're already targeting. The possible_duplicates is a list of objectives, so let's not mix things
	for(var/datum/objective/task as anything in handler.primary_objectives)
		if(!istype(task.target, /datum/mind))
			continue
		already_targeting += task.target //Removing primary objective kill targets from the list

	var/parent_type = type2parent(type)
	//don't roll head of staff types if you haven't completed the normal version
	if(heads_of_staff && !handler.get_completion_count(parent_type))
		// Locked if they don't have any of the risky bug room objective completed
		return FALSE

	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	if(generating_for.late_joiner)
		try_target_late_joiners = TRUE
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target in already_targeting)
			continue
		var/target_area = get_area(possible_target.current)
		if(possible_target == generating_for)
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue
		var/datum/antagonist/traitor/traitor = possible_target.has_antag_datum(/datum/antagonist/traitor)
		if(traitor && traitor.uplink_handler.telecrystals >= 0)
			continue
		var/mob/living/carbon/human/targets_current = possible_target.current
		var/datum/disease/chronic_illness/illness = locate() in targets_current.diseases
		if(illness)
			continue
		if(!HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) && istype(target_area, /area/shuttle/arrival))
			continue
		//removes heads of staff from being targets from non heads of staff assassinations, and vice versa
		if(heads_of_staff)
			if(!(possible_target.assigned_role.job_flags & JOB_HEAD_OF_STAFF))
				continue
		else
			if((possible_target.assigned_role.job_flags & JOB_HEAD_OF_STAFF))
				continue
		possible_targets += possible_target
	for(var/datum/traitor_objective/target_player/objective as anything in possible_duplicates)
		possible_targets -= objective.target
	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/datum/mind/possible_target as anything in all_possible_targets)
			if(!possible_target.late_joiner)
				possible_targets -= possible_target
		if(!possible_targets.len)
			possible_targets = all_possible_targets
	special_target_filter(possible_targets)
	if(!possible_targets.len)
		return FALSE //MISSION FAILED, WE'LL GET EM NEXT TIME

	var/datum/mind/target_mind = pick(possible_targets)
	set_target(target_mind.current)
	replace_in_name("%TARGET%", target.real_name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	return TRUE

/datum/traitor_objective/target_player/infect/ungenerate_objective()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	set_target(null)

///proc for checking for special states that invalidate a target
/datum/traitor_objective/target_player/infect/proc/special_target_filter(list/possible_targets)
	return

/datum/traitor_objective/target_player/infect/target_deleted()
	if(objective_state == OBJECTIVE_STATE_INACTIVE)
		//don't take an objective target of someone who is already obliterated
		fail_objective()
	return ..()

/datum/traitor_objective/target_player/infect/proc/on_target_death()
	SIGNAL_HANDLER
	if(objective_state == OBJECTIVE_STATE_INACTIVE)
		//don't take an objective target of someone who is already dead
		fail_objective()

/obj/item/reagent_containers/hypospray/medipen/manifoldinjector
	name = "EHMS autoinjector"
	desc = "Experimental Hereditary Manifold Sickness autoinjector."
	icon_state = "tbpen"
	inhand_icon_state = "tbpen"
	base_icon_state = "tbpen"
	volume = 30
	amount_per_transfer_from_this = 30
	list_reagents = list(/datum/reagent/medicine/sansufentanyl = 20)
	stealthy = TRUE
	//Was the injector used on someone yet?
	var/used = FALSE

/obj/item/reagent_containers/hypospray/medipen/manifoldinjector/attack(mob/living/affected_mob, mob/living/carbon/human/user)
	if(used)
		return ..()
	to_chat(affected_mob, span_warning("You feel someone try to inject you with something."))
	balloon_alert(user, "injecting...")
	log_combat(user, affected_mob, "attempted to inject", src)
	if(!do_after(user, 1.5 SECONDS, hidden = TRUE))
		balloon_alert(user, "interrupted!")
		return
	var/datum/disease/chronic_illness/hms = new /datum/disease/chronic_illness()
	affected_mob.ForceContractDisease(hms)
	used = TRUE
	inject(affected_mob, user)
	SEND_SIGNAL(src, COMSIG_EHMS_INJECTOR_INJECTED, user, affected_mob)
