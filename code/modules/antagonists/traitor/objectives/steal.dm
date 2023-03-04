/datum/traitor_objective_category/steal_item
	name = "Steal Item"
	objectives = list(
		list(
			list(
				/datum/traitor_objective/steal_item/low_risk = 1,
				/datum/traitor_objective/destroy_item/low_risk = 1,
			) = 1,
			/datum/traitor_objective/steal_item/low_risk_cap = 1,

		) = 1,
		/datum/traitor_objective/steal_item/somewhat_risky = 1,
		list(
			/datum/traitor_objective/destroy_item/very_risky = 1,
			/datum/traitor_objective/steal_item/risky = 1,
		) = 1,
		/datum/traitor_objective/steal_item/very_risky = 1,
		/datum/traitor_objective/steal_item/most_risky = 1
	)

GLOBAL_DATUM_INIT(steal_item_handler, /datum/objective_item_handler, new())

/datum/objective_item_handler
	var/list/objectives_by_path
	var/generated_items = FALSE

/datum/objective_item_handler/New()
	. = ..()
	objectives_by_path = list()
	for(var/datum/objective_item/item as anything in subtypesof(/datum/objective_item))
		objectives_by_path[initial(item.targetitem)] = list()
	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(save_items))

/datum/objective_item_handler/proc/save_items()
	for(var/obj/item/typepath as anything in objectives_by_path)
		for(var/obj/item/object as anything in objectives_by_path[typepath])
			var/turf/place = get_turf(object)
			if(!place || !is_station_level(place.z))
				objectives_by_path[typepath] -= object
				continue
			RegisterSignal(object, COMSIG_PARENT_QDELETING, PROC_REF(remove_item))
	generated_items = TRUE

/datum/objective_item_handler/proc/remove_item(atom/source)
	SIGNAL_HANDLER
	for(var/typepath in objectives_by_path)
		objectives_by_path[typepath] -= source

/datum/traitor_objective/steal_item
	name = "Steal %ITEM% and place a bug on it."
	description = "Use the button below to materialize the bug within your hand, where you'll then be able to place it on the item. Additionally, you can keep it near you for %TIME% minutes, and you will be rewarded with %PROGRESSION% reputation and %TC% telecrystals."

	progression_minimum = 20 MINUTES

	var/list/possible_items = list()
	/// The current target item that we are stealing.
	var/datum/objective_item/steal/target_item
	/// A list of 2 elements, which contain the range that the time will be in. Represented in minutes.
	var/hold_time_required = list(5, 15)
	/// The current time fulfilled around the item
	var/time_fulfilled = 0
	/// The maximum distance between the bug and the objective taker for time to count as fulfilled
	var/max_distance = 4
	/// The bug that will be put onto the item
	var/obj/item/traitor_bug/bug
	/// Any special equipment that may be needed
	var/list/special_equipment
	/// Telecrystal reward increase per unit of time.
	var/minutes_per_telecrystal = 3

	/// Extra TC given for holding the item for the required duration of time.
	var/extra_tc = 0
	/// Extra progression given for holding the item for the required duration of time.
	var/extra_progression = 0

	abstract_type = /datum/traitor_objective/steal_item

/datum/traitor_objective/steal_item/low_risk_cap
	progression_minimum = 5 MINUTES
	progression_maximum = 20 MINUTES

	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = 0
	minutes_per_telecrystal = 6
	possible_items = list(
		/datum/objective_item/steal/low_risk/aicard,
	)

/datum/traitor_objective/steal_item/low_risk
	progression_minimum = 10 MINUTES
	progression_maximum = 35 MINUTES
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = 0
	minutes_per_telecrystal = 6

	possible_items = list(
		/datum/objective_item/steal/low_risk/cargo_budget,
		/datum/objective_item/steal/low_risk/clown_shoes,
	)

/datum/traitor_objective/steal_item/somewhat_risky
	progression_minimum = 20 MINUTES
	progression_reward = 5 MINUTES
	telecrystal_reward = 1

	possible_items = list(
		/datum/objective_item/steal/magboots,
		/datum/objective_item/steal/hypo,
		/datum/objective_item/steal/reactive,
		/datum/objective_item/steal/handtele,
		/datum/objective_item/steal/blueprints,
	)

/datum/traitor_objective/steal_item/risky
	progression_minimum = 30 MINUTES
	progression_reward = 13 MINUTES
	telecrystal_reward = 2

	possible_items = list(
		/datum/objective_item/steal/reflector,
		/datum/objective_item/steal/capmedal,
		/datum/objective_item/steal/hdd_extraction,
		/datum/objective_item/steal/documents,
	)

/datum/traitor_objective/steal_item/very_risky
	progression_minimum = 40 MINUTES
	progression_reward = 17 MINUTES
	telecrystal_reward = 3

	possible_items = list(
		/datum/objective_item/steal/hoslaser,
		/datum/objective_item/steal/caplaser,
		/datum/objective_item/steal/nuke_core,
		/datum/objective_item/steal/supermatter,
	)

/datum/traitor_objective/steal_item/most_risky
	progression_minimum = 50 MINUTES
	progression_reward = 25 MINUTES
	telecrystal_reward = 5

	possible_items = list(
		/datum/objective_item/steal/nukedisc,
	)

/datum/traitor_objective/steal_item/most_risky/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!handler.get_completion_count(/datum/traitor_objective/steal_item/very_risky))
		return FALSE
	return ..()

/datum/traitor_objective/steal_item/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/role = generating_for.assigned_role
	for(var/datum/traitor_objective/steal_item/objective as anything in possible_duplicates)
		possible_items -= objective.target_item.type
	while(length(possible_items))
		var/datum/objective_item/steal/target = pick_n_take(possible_items)
		target = new target()
		if(!target.TargetExists())
			qdel(target)
			continue
		if(role.title in target.excludefromjob)
			qdel(target)
			continue
		if(target.exists_on_map)
			var/list/items = GLOB.steal_item_handler.objectives_by_path[target.targetitem]
			if(!length(items))
				continue
		target_item = target
		break
	if(!target_item)
		return FALSE
	if(length(target_item.special_equipment))
		special_equipment = target_item.special_equipment
	hold_time_required = rand(hold_time_required[1], hold_time_required[2])
	extra_progression += hold_time_required * (1 MINUTES)
	extra_tc += round(hold_time_required / max(minutes_per_telecrystal, 0.1))
	replace_in_name("%ITEM%", target_item.name)
	replace_in_name("%TIME%", hold_time_required)
	replace_in_name("%TC%", extra_tc)
	replace_in_name("%PROGRESSION%", DISPLAY_PROGRESSION(extra_progression))
	return TRUE

/datum/traitor_objective/steal_item/ungenerate_objective()
	STOP_PROCESSING(SSprocessing, src)
	if(bug)
		UnregisterSignal(bug, list(COMSIG_TRAITOR_BUG_PLANTED_OBJECT, COMSIG_TRAITOR_BUG_PRE_PLANTED_OBJECT))
	bug = null

/datum/traitor_objective/steal_item/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(special_equipment)
		buttons += add_ui_button("", "Pressing this will summon any extra special equipment you may need for the mission.", "tools", "summon_gear")
	if(!bug)
		buttons += add_ui_button("", "Pressing this will materialize a bug in your hand, which you can place on the target item", "wifi", "summon_bug")
	else if(bug.planted_on)
		buttons += add_ui_button("[DisplayTimeText(time_fulfilled)]", "This tells you how much time you have spent around the target item after the bug has been planted.", "clock", "none")
		buttons += add_ui_button("Skip Time", "Pressing this will succeed the mission. You will not get the extra TC and progression.", "forward", "cash_out")
	return buttons

/datum/traitor_objective/steal_item/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_bug")
			if(bug)
				return
			bug = new(user.drop_location())
			user.put_in_hands(bug)
			bug.balloon_alert(user, "the bug materializes in your hand")
			bug.target_object_type = target_item.targetitem
			AddComponent(/datum/component/traitor_objective_register, bug, \
				fail_signals = list(COMSIG_PARENT_QDELETING), \
				penalty = telecrystal_penalty)
			RegisterSignal(bug, COMSIG_TRAITOR_BUG_PLANTED_OBJECT, PROC_REF(on_bug_planted))
			RegisterSignal(bug, COMSIG_TRAITOR_BUG_PRE_PLANTED_OBJECT, PROC_REF(handle_special_case))
		if("summon_gear")
			if(!special_equipment)
				return
			for(var/item in special_equipment)
				var/obj/item/new_item = new item(user.drop_location())
				user.put_in_hands(new_item)
			user.balloon_alert(user, "the equipment materializes in your hand")
			special_equipment = null
		if("cash_out")
			if(!bug.planted_on)
				return
			succeed_objective()

/datum/traitor_objective/steal_item/process(delta_time)
	var/mob/owner = handler.owner?.current
	if(objective_state != OBJECTIVE_STATE_ACTIVE || !bug.planted_on)
		return PROCESS_KILL
	if(!owner)
		fail_objective()
		return PROCESS_KILL
	if(get_dist(get_turf(owner), get_turf(bug)) > max_distance)
		return
	time_fulfilled += delta_time * (1 SECONDS)
	if(time_fulfilled >= hold_time_required * (1 MINUTES))
		progression_reward += extra_progression
		telecrystal_reward += extra_tc
		succeed_objective()
		return PROCESS_KILL
	handler.on_update()

/datum/traitor_objective/steal_item/proc/handle_special_case(obj/item/source, obj/item/target)
	SIGNAL_HANDLER
	if(istype(target, target_item.targetitem))
		if(!target_item.check_special_completion(target))
			return COMPONENT_FORCE_FAIL_PLACEMENT
		return

	var/found = FALSE
	for(var/typepath in target_item.valid_containers)
		if(istype(target, typepath))
			found = TRUE
			break

	if(!found)
		return

	var/found_item = locate(target_item.targetitem) in target
	if(!found_item || !target_item.check_special_completion(found_item))
		return COMPONENT_FORCE_FAIL_PLACEMENT
	return COMPONENT_FORCE_PLACEMENT

/datum/traitor_objective/steal_item/proc/on_bug_planted(obj/item/source, obj/item/location)
	SIGNAL_HANDLER
	if(objective_state == OBJECTIVE_STATE_ACTIVE)
		START_PROCESSING(SSprocessing, src)
