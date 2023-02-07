/datum/traitor_objective_category/kidnapping
	name = "Kidnap Personnel"
	objectives = list( //Similar weights to destroy heirloom objectives
		list(
			/datum/traitor_objective/kidnapping/common = 20,
			/datum/traitor_objective/kidnapping/less_common = 1,
		) = 4,
		/datum/traitor_objective/kidnapping/uncommon = 3,
		/datum/traitor_objective/kidnapping/rare = 2,
		/datum/traitor_objective/kidnapping/captain = 1
	)

/datum/traitor_objective/kidnapping
	name = "Kidnap %TARGET% the %JOB TITLE% and deliver them to %AREA%"
	description = "%TARGET% holds extremely important information regarding secret NT projects - and you'll need to kidnap and deliver them to %AREA%, where our transport pod will be waiting. \
		You'll get additional reward if %TARGET% is delivered alive."

	abstract_type = /datum/traitor_objective/kidnapping

	//this is a prototype so this progression is for all basic level kill objectives
	progression_reward = list(2 MINUTES, 4 MINUTES)
	telecrystal_reward = list(1, 2)

	/// The period of time until you can take another objective after taking 3 objectives.
	var/objective_period = 15 MINUTES
	/// The maximum number of objectives we can get within this period.
	var/maximum_objectives_in_period = 3

	/// The jobs that this objective is targetting.
	var/list/target_jobs
	/// The person we need to kidnap
	var/mob/living/victim
	/// Area that the victim needs to be delivered to
	var/area/dropoff_area
	/// Have we called the pod yet?
	var/pod_called = FALSE
	/// How much TC do we get from sending the target alive
	var/alive_bonus = 0
	/// All stripped victims belongings
	var/list/victim_belogings = list()

/datum/traitor_objective/kidnapping/supported_configuration_changes()
	. = ..()
	. += NAMEOF(src, objective_period)
	. += NAMEOF(src, maximum_objectives_in_period)

/datum/traitor_objective/kidnapping/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/assassinate, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/kidnapping/common
	progression_minimum = 0 MINUTES
	progression_maximum = 30 MINUTES
	target_jobs = list(
		// Medical
		/datum/job/doctor,
		/datum/job/paramedic,
		/datum/job/psychologist,
		/datum/job/chemist,
		// Service
		/datum/job/clown,
		/datum/job/botanist,
		/datum/job/janitor,
		/datum/job/mime,
		/datum/job/lawyer,
		/datum/job/chaplain,
		/datum/job/bartender,
		/datum/job/curator,
		// Cargo
		/datum/job/cargo_technician,
		// Science
		/datum/job/geneticist,
		/datum/job/roboticist,
		// Engineering
		/datum/job/station_engineer,
		/datum/job/atmospheric_technician,
	)

/datum/traitor_objective/kidnapping/less_common
	progression_minimum = 0 MINUTES
	progression_maximum = 15 MINUTES
	target_jobs = list(
		/datum/job/assistant
	)

/datum/traitor_objective/kidnapping/uncommon //Hard to fish out victims
	progression_minimum = 0 MINUTES
	progression_maximum = 45 MINUTES
	target_jobs = list(
		// Medical
		/datum/job/virologist,
		// Cargo
		/datum/job/shaft_miner,
		// Service
		/datum/job/cook,
		// Science
		/datum/job/scientist,
	)

	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(1, 2)
	alive_bonus = 1

/datum/traitor_objective/kidnapping/rare
	progression_minimum = 15 MINUTES
	progression_maximum = 60 MINUTES
	target_jobs = list(
		// Security
		/datum/job/security_officer,
		/datum/job/warden,
		/datum/job/detective,
		// Heads of staff
		/datum/job/head_of_personnel,
		/datum/job/chief_medical_officer,
		/datum/job/research_director,
		/datum/job/quartermaster,
	)

	progression_reward = list(8 MINUTES, 12 MINUTES)
	telecrystal_reward = list(1, 2)
	alive_bonus = 2

/datum/traitor_objective/kidnapping/captain
	progression_minimum = 30 MINUTES
	target_jobs = list(
		/datum/job/head_of_security,
		/datum/job/captain
	)

	progression_reward = list(12 MINUTES, 16 MINUTES)
	telecrystal_reward = list(2, 3)
	alive_bonus = 2

/datum/traitor_objective/kidnapping/generate_objective(datum/mind/generating_for, list/possible_duplicates)

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

	for(var/datum/traitor_objective/kidnapping/objective as anything in possible_duplicates)
		if(!objective.victim) //the old objective was already completed.
			continue
		possible_targets -= objective.victim.mind

	if(!length(possible_targets))
		return FALSE

	var/datum/mind/target_mind = pick(possible_targets)
	victim = target_mind.current
	AddComponent(/datum/component/traitor_objective_register, victim, fail_signals = list(COMSIG_PARENT_QDELETING))
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(istype(possible_area, /area/station/hallway) || istype(possible_area, /area/station/security) || initial(possible_area.outdoors))
			possible_areas -= possible_area

	dropoff_area = pick(possible_areas)
	replace_in_name("%TARGET%", target_mind.name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	replace_in_name("%AREA%", initial(dropoff_area.name))
	return TRUE

/datum/traitor_objective/kidnapping/ungenerate_objective()
	victim = null
	dropoff_area = null

/datum/traitor_objective/kidnapping/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!pod_called)
		buttons += add_ui_button("Call Extraction Pod", "Pressing this will call down an extraction pod.", "rocket", "call_pod")
	return buttons

/datum/traitor_objective/kidnapping/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("call_pod")
			if(pod_called)
				return
			var/area/user_area = get_area(user)
			var/area/victim_area = get_area(victim)

			if(user_area.type != dropoff_area)
				to_chat(user, span_warning("You must be in [initial(dropoff_area.name)] to call the extraction pod."))
				return

			if(victim_area.type != dropoff_area)
				to_chat(user, span_warning("[victim.real_name] must be in [initial(dropoff_area.name)] for you to call the extraction pod."))
				return

			call_pod(user)

/datum/traitor_objective/kidnapping/proc/call_pod(mob/living/user)
	pod_called = TRUE
	var/obj/structure/closet/supplypod/extractionpod/new_pod = new()
	RegisterSignal(new_pod, COMSIG_ATOM_ENTERED, PROC_REF(enter_check))
	new /obj/effect/pod_landingzone(get_turf(user), new_pod)

/datum/traitor_objective/kidnapping/proc/enter_check(obj/structure/closet/supplypod/extractionpod/source, entered_atom)
	if(!istype(source))
		CRASH("Kidnapping objective's enter_check called with source being not an extraction pod: [source ? source.type : "N/A"]")

	if(!ishuman(entered_atom))
		return

	var/mob/living/carbon/human/sent_mob = entered_atom

	if(sent_mob.mind)
		ADD_TRAIT(sent_mob.mind, TRAIT_HAS_BEEN_KIDNAPPED, TRAIT_GENERIC)

	for(var/obj/item/belonging in sent_mob)
		if(belonging == sent_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING) || belonging == sent_mob.get_item_by_slot(ITEM_SLOT_FEET))
			continue

		sent_mob.transferItemToLoc(belonging)
		victim_belogings.Add(belonging)

	var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)

	if(cargo_account) //Just in case
		cargo_account.adjust_money(-min(rand(1000, 3000), cargo_account.account_balance)) //Not so much, especially for competent cargo. Plus this can't be mass-triggered like it has been done with contractors

	priority_announce("One of your crew was captured by a rival organisation - we've needed to pay their ransom to bring them back. As is policy we've taken a portion of the station's funds to offset the overall cost.", "Nanotrasen Asset Protection", has_important_message = TRUE)

	addtimer(CALLBACK(src, PROC_REF(handle_victim), sent_mob), 1.5 SECONDS)

	if(sent_mob != victim)
		fail_objective(penalty_cost = telecrystal_penalty)
		source.startExitSequence(source)
		return

	if(sent_mob.stat != DEAD)
		telecrystal_reward += alive_bonus

	succeed_objective()
	source.startExitSequence(source)

/datum/traitor_objective/kidnapping/proc/handle_victim(mob/living/carbon/human/sent_mob)
	addtimer(CALLBACK(src, PROC_REF(return_victim), sent_mob), 3 MINUTES)
	if(sent_mob.stat == DEAD)
		return

	sent_mob.flash_act()
	sent_mob.adjust_confusion(10 SECONDS)
	sent_mob.adjust_dizzy(10 SECONDS)
	sent_mob.set_eye_blur_if_lower(100 SECONDS)
	to_chat(sent_mob, span_hypnophrase(span_reallybig("A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
		we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
		so it's only a matter of time before we ship you back...\"</i>")))

/datum/traitor_objective/kidnapping/proc/return_victim(mob/living/carbon/human/sent_mob)
	if(!sent_mob || QDELETED(sent_mob)) //suicided and qdeleted themselves
		return

	var/list/possible_turfs = list()
	for(var/turf/open/open_turf in dropoff_area)
		if(open_turf.is_blocked_turf() || isspaceturf(open_turf))
			continue
		possible_turfs += open_turf

	if(!LAZYLEN(possible_turfs))
		var/turf/new_turf = get_safe_random_station_turf()
		if(!new_turf) //SOMEHOW
			to_chat(sent_mob, span_hypnophrase(span_reallybig("A million voices echo in your head... <i>\"Seems where you got sent here from won't \
				be able to handle our pod... You will die here instead.\"</i></span>")))
			if (sent_mob.can_heartattack())
				sent_mob.set_heartattack(TRUE)
			return

		possible_turfs += new_turf

	var/obj/structure/closet/supplypod/return_pod = new()
	return_pod.bluespace = TRUE
	return_pod.explosionSize = list(0,0,0,0)
	return_pod.style = STYLE_SYNDICATE

	do_sparks(8, FALSE, sent_mob)
	sent_mob.visible_message(span_notice("[sent_mob] vanishes!"))
	for(var/obj/item/belonging in sent_mob)
		if(belonging == sent_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING) || belonging == sent_mob.get_item_by_slot(ITEM_SLOT_FEET))
			continue

		sent_mob.transferItemToLoc(belonging)

	for(var/obj/item/belonging in victim_belogings)
		belonging.forceMove(return_pod)

	sent_mob.forceMove(return_pod)
	sent_mob.flash_act()
	sent_mob.adjust_confusion(10 SECONDS)
	sent_mob.adjust_dizzy(10 SECONDS)
	sent_mob.set_eye_blur_if_lower(100 SECONDS)

	new /obj/effect/pod_landingzone(pick(possible_turfs), return_pod)
