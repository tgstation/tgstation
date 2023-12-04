/datum/group_planning
	///when our next queuing is done
	var/next_action = 0
	///our cooldown time of actions
	var/cooldown_time = 10 SECONDS
	///list of mobs in our group
	var/list/group_mobs = list()
	///list of mobs still executing our queued_behavior
	var/list/in_progress_mobs = list()
	///list of finished mobs
	var/list/finished_mobs = list()
	///our behaviour that we are queing
	var/queued_behavior
	///do we need to fetch a new behaviour?
	var/fetched_behaviour = FALSE
	///list of all behaviours we can do
	var/list/usable_behaviours = list()
	///our current_target
	var/atom/target

/datum/group_planning/Destroy(force, ...)
	. = ..()
	finished_mobs = null
	in_progress_mobs = null
	group_mobs = null

/datum/group_planning/proc/check_mobs()
	for(var/mob/living/mob as anything in group_mobs)
		if(!QDELETED(mob))
			continue
		group_mobs -= mob
		in_progress_mobs -= mob
		finished_mobs -= mob
	if(!length(group_mobs))
		qdel(src)

/datum/group_planning/proc/bulk_queue()
	check_mobs()
	for(var/mob/living/basic/listed as anything in group_mobs)
		if(!istype(listed) || !listed.ai_controller || listed.stat == DEAD) //cull dead members that shouldn't exist anymore
			if(isbasicmob(listed) && listed.ai_controller && (BB_GROUP_DATUM in listed.ai_controller.blackboard))
				listed.ai_controller.blackboard[BB_GROUP_DATUM] = null
			group_mobs -= listed
			continue
		listed.ai_controller.queue_behavior(queued_behavior)
		in_progress_mobs |= listed

/datum/group_planning/proc/decide_next_action()
	check_mobs()
	if(length(in_progress_mobs))
		return /// we are still doing an action
	if(!length(usable_behaviours))
		return //how did this happen
	queued_behavior = pick(usable_behaviours)
	fetched_behaviour = TRUE

/datum/group_planning/proc/add_to_current_action(datum/ai_controller/controller)
	check_mobs()
	controller.queue_behavior(queued_behavior)
	in_progress_mobs |= controller.pawn


/datum/group_planning/proc/finish_action(datum/ai_controller/controller)
	check_mobs()
	if(controller.pawn in in_progress_mobs)
		in_progress_mobs -= controller.pawn
		finished_mobs += controller.pawn
	if(!length(in_progress_mobs))
		next_action = world.time + cooldown_time
		fetched_behaviour = FALSE
		finished_mobs = list()

/datum/group_planning/fish
	cooldown_time = 25 SECONDS
	usable_behaviours = list(/datum/ai_behavior/step_towards_turf/group_movement)

/datum/group_planning/fish/decide_next_action()
	. = ..()
	var/mob/living/basic/picked_mob = pick(group_mobs)

	var/list/turfs = view(7, picked_mob)
	var/turf/picked
	var/sanity = 25

	while(!isopenturf(picked) && sanity > 0)
		sanity--
		picked = get_turf(pick(turfs))
	target = picked
