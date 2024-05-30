/datum/traitor_objective/target_player/kidnapping
	name = "Kidnap %TARGET% the %JOB TITLE% and deliver them to %AREA%"
	description = "%TARGET% holds extremely important information regarding secret NT projects - and you'll need to kidnap and deliver them to %AREA%, where our transport pod will be waiting. \
		If %TARGET% is delivered alive, you will be rewarded with an additional %TC% telecrystals."

	abstract_type = /datum/traitor_objective/target_player/kidnapping

	/// The jobs that this objective is targeting.
	var/list/target_jobs
	/// Area that the target needs to be delivered to
	var/area/dropoff_area
	/// Have we called the pod yet?
	var/pod_called = FALSE
	/// How much TC do we get from sending the target alive
	var/alive_bonus = 0
	/// All stripped targets belongings (weakrefs)
	var/list/target_belongings = list()
	/// The ID of the stoppable timer for returning the captured crew
	var/list/victim_timerid

	duplicate_type = /datum/traitor_objective/target_player

/datum/traitor_objective/target_player/kidnapping/supported_configuration_changes()
	. = ..()
	. += NAMEOF(src, objective_period)
	. += NAMEOF(src, maximum_objectives_in_period)

/datum/traitor_objective/target_player/kidnapping/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/target_player, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/target_player/kidnapping/common
	progression_minimum = 0 MINUTES
	progression_maximum = 30 MINUTES
	progression_reward = list(2 MINUTES, 4 MINUTES)
	telecrystal_reward = list(1, 2)
	target_jobs = list(
		// Cargo
		/datum/job/cargo_technician,
		// Engineering
		/datum/job/atmospheric_technician,
		/datum/job/station_engineer,
		// Medical
		/datum/job/chemist,
		/datum/job/doctor,
		/datum/job/psychologist,
		/datum/job/coroner,
		// Science
		/datum/job/geneticist,
		/datum/job/roboticist,
		/datum/job/scientist,
		// Service
		/datum/job/bartender,
		/datum/job/botanist,
		/datum/job/chaplain,
		/datum/job/clown,
		/datum/job/curator,
		/datum/job/janitor,
		/datum/job/lawyer,
		/datum/job/mime,
	)
	alive_bonus = 2

/datum/traitor_objective/target_player/kidnapping/common/assistant
	progression_minimum = 0 MINUTES
	progression_maximum = 15 MINUTES
	target_jobs = list(
		/datum/job/assistant
	)

/datum/traitor_objective/target_player/kidnapping/uncommon //Hard to fish out targets
	progression_minimum = 0 MINUTES
	progression_maximum = 45 MINUTES
	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(1, 2)

	target_jobs = list(
		// Cargo
		/datum/job/bitrunner,
		/datum/job/shaft_miner,
		// Medical
		/datum/job/paramedic,
		// Service
		/datum/job/cook,
	)
	alive_bonus = 3

/datum/traitor_objective/target_player/kidnapping/rare
	progression_minimum = 15 MINUTES
	progression_maximum = 60 MINUTES
	progression_reward = list(8 MINUTES, 12 MINUTES)
	telecrystal_reward = list(2, 3)
	target_jobs = list(
		// Heads of staff
		/datum/job/chief_engineer,
		/datum/job/chief_medical_officer,
		/datum/job/head_of_personnel,
		/datum/job/research_director,
		/datum/job/quartermaster,
		// Security
		/datum/job/detective,
		/datum/job/security_officer,
		/datum/job/warden,
	)
	alive_bonus = 4

/datum/traitor_objective/target_player/kidnapping/captain
	progression_minimum = 30 MINUTES
	progression_reward = list(12 MINUTES, 16 MINUTES)
	telecrystal_reward = list(2, 3)
	target_jobs = list(
		/datum/job/captain,
		/datum/job/head_of_security,
	)
	alive_bonus = 5

/datum/traitor_objective/target_player/kidnapping/generate_objective(datum/mind/generating_for, list/possible_duplicates)

	var/list/already_targeting = list() //List of minds we're already targeting. The possible_duplicates is a list of objectives, so let's not mix things
	for(var/datum/objective/task as anything in handler.primary_objectives)
		if(!istype(task.target, /datum/mind))
			continue
		already_targeting += task.target //Removing primary objective kill targets from the list

	var/list/possible_targets = list()
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == generating_for)
			continue

		if(possible_target in already_targeting)
			continue

		if(!ishuman(possible_target.current))
			continue

		if(possible_target.current.stat == DEAD)
			continue

		if(HAS_TRAIT(possible_target, TRAIT_HAS_BEEN_KIDNAPPED))
			continue

		if(possible_target.has_antag_datum(/datum/antagonist/traitor))
			continue

		if(!(possible_target.assigned_role.type in target_jobs))
			continue

		possible_targets += possible_target

	for(var/datum/traitor_objective/target_player/objective as anything in possible_duplicates)
		if(!objective.target) //the old objective was already completed.
			continue
		possible_targets -= objective.target.mind

	if(!length(possible_targets))
		return FALSE

	var/datum/mind/target_mind = pick(possible_targets)
	set_target(target_mind.current)
	AddComponent(/datum/component/traitor_objective_register, target, fail_signals = list(COMSIG_QDELETING))
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(ispath(possible_area, /area/station/hallway) || ispath(possible_area, /area/station/security) || initial(possible_area.outdoors))
			possible_areas -= possible_area

	dropoff_area = pick(possible_areas)
	replace_in_name("%TARGET%", target_mind.name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	replace_in_name("%AREA%", initial(dropoff_area.name))
	replace_in_name("%TC%", alive_bonus)
	return TRUE

/datum/traitor_objective/target_player/kidnapping/ungenerate_objective()
	set_target(null)
	dropoff_area = null

/datum/traitor_objective/target_player/kidnapping/on_objective_taken(mob/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(generate_holding_area))

/datum/traitor_objective/target_player/kidnapping/proc/generate_holding_area()
	// Let's load in the holding facility ahead of time
	// even if they fail the objective  it's better to get done now rather than later
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY)

/datum/traitor_objective/target_player/kidnapping/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!pod_called)
		buttons += add_ui_button("Call Extraction Pod", "Pressing this will call down an extraction pod.", "rocket", "call_pod")
	return buttons

/datum/traitor_objective/target_player/kidnapping/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("call_pod")
			if(pod_called)
				return
			var/area/user_area = get_area(user)
			var/area/target_area = get_area(target)

			if(user_area.type != dropoff_area)
				to_chat(user, span_warning("You must be in [initial(dropoff_area.name)] to call the extraction pod."))
				return

			if(target_area.type != dropoff_area)
				to_chat(user, span_warning("[target.real_name] must be in [initial(dropoff_area.name)] for you to call the extraction pod."))
				return

			call_pod(user)

/datum/traitor_objective/target_player/kidnapping/proc/call_pod(mob/living/user)
	pod_called = TRUE
	var/obj/structure/closet/supplypod/extractionpod/new_pod = new()
	RegisterSignal(new_pod, COMSIG_ATOM_ENTERED, PROC_REF(enter_check))
	new /obj/effect/pod_landingzone(get_turf(user), new_pod)

/datum/traitor_objective/target_player/kidnapping/proc/enter_check(obj/structure/closet/supplypod/extractionpod/source, entered_atom)
	SIGNAL_HANDLER
	if(!istype(source))
		CRASH("Kidnapping objective's enter_check called with source being not an extraction pod: [source ? source.type : "N/A"]")

	if(!ishuman(entered_atom))
		return

	var/mob/living/carbon/human/sent_mob = entered_atom

	for(var/obj/item/belonging in sent_mob.gather_belongings())
		if(belonging == sent_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING) || belonging == sent_mob.get_item_by_slot(ITEM_SLOT_FEET))
			continue

		var/unequipped = sent_mob.transferItemToLoc(belonging)
		if (!unequipped)
			continue
		target_belongings.Add(WEAKREF(belonging))

	var/datum/market_item/hostage/market_item = sent_mob.process_capture(rand(1000, 3000))
	RegisterSignal(market_item, COMSIG_MARKET_ITEM_SPAWNED, PROC_REF(on_victim_shipped))

	addtimer(CALLBACK(src, PROC_REF(handle_target), sent_mob), 1.5 SECONDS)

	if(sent_mob != target)
		fail_objective(penalty_cost = telecrystal_penalty)
		source.startExitSequence(source)
		return

	if(sent_mob.stat != DEAD)
		telecrystal_reward += alive_bonus

	succeed_objective()
	source.startExitSequence(source)

/datum/traitor_objective/target_player/kidnapping/proc/handle_target(mob/living/carbon/human/sent_mob)
	victim_timerid = addtimer(CALLBACK(src, PROC_REF(return_target), sent_mob), COME_BACK_FROM_CAPTURE_TIME, TIMER_STOPPABLE)
	if(sent_mob.stat == DEAD)
		return

	sent_mob.flash_act()
	sent_mob.adjust_confusion(10 SECONDS)
	sent_mob.adjust_dizzy(10 SECONDS)
	sent_mob.set_eye_blur_if_lower(100 SECONDS)
	sent_mob.dna.species.give_important_for_life(sent_mob) // so plasmamen do not get left for dead
	to_chat(sent_mob, span_hypnophrase("A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
		we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
		so it's only a matter of time before we ship you back...\"</i>"))

/datum/traitor_objective/target_player/kidnapping/proc/return_target(mob/living/carbon/human/sent_mob)
	if(!sent_mob || QDELETED(sent_mob)) //suicided and qdeleted themselves
		return

	var/obj/structure/closet/supplypod/back_to_station/return_pod = new()
	return_pod.return_from_capture(sent_mob)
	returnal_side_effects(return_pod, sent_mob)

/datum/traitor_objective/target_player/kidnapping/proc/on_victim_shipped(datum/market_item/source, obj/item/market_uplink/uplink, shipping_method, turf/shipping_loc)
	SIGNAL_HANDLER
	deltimer(victim_timerid)
	returnal_side_effects(shipping_loc, source.item)

/datum/traitor_objective/target_player/kidnapping/proc/returnal_side_effects(atom/dropoff_location, mob/living/carbon/human/sent_mob)
	for(var/obj/item/belonging in sent_mob.gather_belongings())
		if(belonging == sent_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING) || belonging == sent_mob.get_item_by_slot(ITEM_SLOT_FEET))
			continue
		sent_mob.dropItemToGround(belonging) // No souvenirs, except shoes and t-shirts

	for(var/datum/weakref/belonging_ref in target_belongings)
		var/obj/item/belonging = belonging_ref.resolve()
		if(!belonging)
			continue
		belonging.forceMove(dropoff_location)

	sent_mob.flash_act()
	sent_mob.adjust_confusion(10 SECONDS)
	sent_mob.adjust_dizzy(10 SECONDS)
	sent_mob.set_eye_blur_if_lower(100 SECONDS)
	sent_mob.dna.species.give_important_for_life(sent_mob) // so plasmamen do not get left for dead
