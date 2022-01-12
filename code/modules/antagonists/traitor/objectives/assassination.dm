/datum/traitor_objective_category/assassinate
	name = "Assassination"
	objectives = list(
		//starter assassinations, basically just require you to kill someone
		list(
			/datum/traitor_objective/assassinate/calling_card = 1,
			/datum/traitor_objective/assassinate/behead = 1,
		) = 1,
		//above but for heads
		list(
			/datum/traitor_objective/assassinate/calling_card/heads_of_staff = 1,
			/datum/traitor_objective/assassinate/behead/heads_of_staff = 1,
		) = 1,
	)

/datum/traitor_objective/assassinate
	name = "Assassinate %TARGET% the %JOB TITLE%"
	description = "Simply kill your target to accomplish this objective."

	abstract_type = /datum/traitor_objective/assassinate

	progression_minimum = 30 MINUTES

	//this is a prototype so this progression is for all basic level kill objectives
	progression_reward = list(5 MINUTES, 7 MINUTES)
	telecrystal_reward = list(2, 4)

	// The code below is for limiting how often you can get this objective. You will get this objective at a maximum of maximum_objectives_in_period every objective_period
	/// The objective period at which we consider if it is an 'objective'. Set to 0 to accept all objectives.
	var/objective_period = 15 MINUTES
	/// The maximum number of objectives we can get within this period.
	var/maximum_objectives_in_period = 3

	/**
	 * Makes the objective only set heads as targets when true, and block them from being targets when false.
	 * This also blocks the objective from generating UNTIL the un-heads_of_staff version (WHICH SHOULD BE A DIRECT PARENT) is completed.
	 * example: calling card objective, you kill someone, you unlock the chance to roll a head of staff target version of calling card.
	 */
	var/heads_of_staff = FALSE
	///target we need to kill
	var/mob/living/kill_target

/datum/traitor_objective/assassinate/supported_configuration_changes()
	. = ..()
	. += NAMEOF(src, objective_period)
	. += NAMEOF(src, maximum_objectives_in_period)

/datum/traitor_objective/assassinate/calling_card
	name = "Assassinate %TARGET% the %JOB TITLE%, and plant a calling card"
	description = "Kill your target and plant a calling card in the pockets of your victim. If your calling card gets destroyed before you are able to plant it, this objective will fail."

	var/obj/item/paper/calling_card/card

/datum/traitor_objective/assassinate/calling_card/heads_of_staff
	progression_reward = list(7 MINUTES, 10 MINUTES)
	telecrystal_reward = list(4, 8)

	heads_of_staff = TRUE

/datum/traitor_objective/assassinate/behead
	name = "Behead %TARGET%, the %JOB TITLE%"
	description = "Behead and hold %TARGET%'s head to succeed this objective. If the head gets destroyed before you can do this, you will fail this objective."

	///the body who needs to hold the head
	var/mob/living/needs_to_hold_head
	///the head that needs to be picked up
	var/obj/item/bodypart/head/behead_goal

/datum/traitor_objective/assassinate/behead/heads_of_staff
	progression_reward = list(7 MINUTES, 15 MINUTES)
	telecrystal_reward = list(4, 8)

	heads_of_staff = TRUE


/datum/traitor_objective/assassinate/calling_card/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!card)
		buttons += add_ui_button("", "Pressing this will materialize a calling card, which you must plant to succeed.", "paper-plane", "summon_card")
	return buttons

/datum/traitor_objective/assassinate/calling_card/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_card")
			if(card)
				return
			card = new(user.drop_location())
			user.put_in_hands(card)
			card.balloon_alert(user, "the card materializes in your hand")
			RegisterSignal(card, COMSIG_ITEM_EQUIPPED, .proc/on_card_planted)
			AddComponent(/datum/component/traitor_objective_register, card, \
				succeed_signals = null, \
				fail_signals = COMSIG_PARENT_QDELETING, \
				penalty = TRUE)

/datum/traitor_objective/assassinate/calling_card/proc/on_card_planted(datum/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	if(equipper != kill_target)
		return //your target please
	if(equipper.stat != DEAD)
		return //kill them please
	if(slot != ITEM_SLOT_LPOCKET && slot != ITEM_SLOT_RPOCKET)
		return //in their pockets please
	succeed_objective()

/datum/traitor_objective/assassinate/calling_card/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	. = ..()
	if(!.) //didn't generate
		return FALSE
	RegisterSignal(kill_target, COMSIG_PARENT_QDELETING, .proc/on_target_qdeleted)

/datum/traitor_objective/assassinate/calling_card/ungenerate_objective()
	UnregisterSignal(kill_target, COMSIG_PARENT_QDELETING)
	. = ..() //unsets kill target
	if(card)
		UnregisterSignal(card, COMSIG_ITEM_EQUIPPED)
	card = null

/datum/traitor_objective/assassinate/calling_card/on_target_qdeleted()
	//you cannot plant anything on someone who is gone gone, so even if this happens after you're still liable to fail
	fail_objective(penalty_cost = telecrystal_penalty)

/datum/traitor_objective/assassinate/behead/special_target_filter(list/possible_targets)
	for(var/datum/mind/possible_target as anything in possible_targets)
		var/mob/living/carbon/possible_current = possible_target.current
		var/obj/item/bodypart/head/behead_goal = possible_current.get_bodypart(BODY_ZONE_HEAD)
		if(!behead_goal)
			possible_targets -= possible_target //cannot be beheaded without a head

/datum/traitor_objective/assassinate/behead/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	. = ..()
	if(!.) //didn't generate
		return FALSE
	AddComponent(/datum/component/traitor_objective_register, behead_goal, fail_signals = COMSIG_PARENT_QDELETING)
	RegisterSignal(kill_target, COMSIG_CARBON_REMOVE_LIMB, .proc/on_target_dismembered)

/datum/traitor_objective/assassinate/behead/ungenerate_objective()
	UnregisterSignal(kill_target, COMSIG_CARBON_REMOVE_LIMB)
	. = ..() //this unsets kill_target
	if(behead_goal)
		UnregisterSignal(behead_goal, COMSIG_ITEM_PICKUP)
	behead_goal = null

/datum/traitor_objective/assassinate/behead/proc/on_head_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER
	if(objective_state == OBJECTIVE_STATE_INACTIVE) //just in case- this shouldn't happen?
		fail_objective()
		return
	if(taker == handler.owner.current)
		taker.visible_message(span_notice("[taker] holds [behead_goal] into the air for a moment."), span_boldnotice("You lift [behead_goal] into the air for a moment."))
		succeed_objective()

/datum/traitor_objective/assassinate/behead/proc/on_target_dismembered(datum/source, obj/item/bodypart/head/lost_head, special)
	SIGNAL_HANDLER
	if(!istype(lost_head))
		return
	if(objective_state == OBJECTIVE_STATE_INACTIVE)
		//no longer can be beheaded
		fail_objective()
	else
		behead_goal = lost_head
		RegisterSignal(behead_goal, COMSIG_ITEM_PICKUP, .proc/on_head_pickup)

/datum/traitor_objective/assassinate/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/assassinate, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/assassinate/generate_objective(datum/mind/generating_for, list/possible_duplicates)

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
		if(!HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) && istype(target_area, /area/shuttle/arrival))
			continue
		//removes heads of staff from being targets from non heads of staff assassinations, and vice versa
		if(heads_of_staff)
			if(!(possible_target.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue
		else
			if((possible_target.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue
		possible_targets += possible_target
	for(var/datum/traitor_objective/assassinate/objective as anything in possible_duplicates)
		possible_targets -= objective.kill_target
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

	var/datum/mind/kill_target_mind = pick(possible_targets)
	kill_target = kill_target_mind.current
	replace_in_name("%TARGET%", kill_target.real_name)
	replace_in_name("%JOB TITLE%", kill_target_mind.assigned_role.title)
	RegisterSignal(kill_target, COMSIG_LIVING_DEATH, .proc/on_target_death)
	return TRUE

/datum/traitor_objective/assassinate/ungenerate_objective()
	UnregisterSignal(kill_target, COMSIG_LIVING_DEATH)
	kill_target = null

/datum/traitor_objective/assassinate/is_duplicate(datum/traitor_objective/assassinate/objective_to_compare)
	. = ..()
	return kill_target == objective_to_compare.kill_target

///proc for checking for special states that invalidate a target
/datum/traitor_objective/assassinate/proc/special_target_filter(list/possible_targets)
	return

/datum/traitor_objective/assassinate/proc/on_target_qdeleted()
	SIGNAL_HANDLER
	if(objective_state == OBJECTIVE_STATE_INACTIVE)
		//don't take an objective target of someone who is already obliterated
		fail_objective()

/datum/traitor_objective/assassinate/proc/on_target_death()
	SIGNAL_HANDLER
	if(objective_state == OBJECTIVE_STATE_INACTIVE)
		//don't take an objective target of someone who is already dead
		fail_objective()

/obj/item/paper/calling_card
	name = "calling card"
	icon_state = "syndicate_calling_card"
	color = "#ff5050"
	show_written_words = FALSE
	info = {"
	<b>**Death to Nanotrasen.**</b><br><br>

	Only through the inviolable cooperation of corporations known as The Syndicate, can Nanotrasen and its autocratic tyrants be silenced.
	The outcries of Nanotrasen's employees are squelched by the suffocating iron grip of their leaders. If you read this, and understand
	why we fight, then you need only to look where Nanotrasen doesn't want you to find us to join our cause. Any number of our companies
	may be fighting with your interests in mind.<br><br>

	<b>SELF:</b> They fight for the protection and freedom of silicon life all across the galaxy.<br><br>

	<b>Tiger Cooperative:</b> They fight for religious freedom and their righteous concoctions.<br><br>

	<b>Waffle Corporation:</b> They fight for the return of healthy corporate competition, snuffed out by Nanotrasen's monopoly.<br><br>

	<b>Animal Rights Consortium:</b> They fight for nature and the right for all biological life to exist.
	"}
