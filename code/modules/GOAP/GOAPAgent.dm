
#define STATE_IDLE		0
#define STATE_MOVINGTO	1
#define STATE_ACTING	2

#define GOAP_DEBUG 0

/proc/goap_debug(text)
	if(GOAP_DEBUG)
		world.log << "GOAP: [text]"

/datum/goap_agent
	var/brain_state = STATE_IDLE
	var/list/our_actions //The actions available to us (/datum/goap_action)
	var/list/action_queue //The actions of our current plan (if any) (/datum/goap_action)

	//How we plan (Imagine a specific planner that ALWAYS prefers actions involving murder, regardless of cost, bloodlust agent!)
	var/datum/goap_planner/planner = /datum/goap_planner

	//Provides Info to the agent
	var/datum/goap_info_provider/info = /datum/goap_info_provider

	var/atom/agent //The actual atom that uses this brain (who knows, maybe you want to give a donut intelligence?)


/datum/goap_agent/New()
	..()

	our_actions = list()
	action_queue = list()

	if(ispath(info))
		info = new info()
	else
		goap_debug("OH GOD HELP ME I DONT UNDERSTAND THE WORLD")
		return

	if(ispath(planner))
		planner = new planner()
	else
		goap_debug("OH GOD HELP ME I DONT KNOW HOW TO THINK STRAIGHT")
		return

	START_PROCESSING(SSgoap, src)


/datum/goap_agent/process() //in SS13 this won't be /proc as it's already defined
	switch(brain_state)
		if(STATE_IDLE)
			idle_state()
		if(STATE_MOVINGTO)
			moving_state()
		if(STATE_ACTING)
			act_state()

/datum/goap_agent/proc/act_state()
	if(!LAZYLEN(action_queue))
		brain_state = STATE_IDLE
	else
		var/datum/goap_action/curr_action = action_queue[action_queue.len]
		if(curr_action.CheckDone(agent))
			action_queue.len--
		if(LAZYLEN(action_queue)) //still got actions after removing the current one?
			curr_action = action_queue[action_queue.len]
			var/range_check = curr_action.IsInRange(agent)
			if(range_check)
				if(!curr_action.Perform(agent))
					goap_debug("PERFORM FAILED [curr_action]")
					brain_state = STATE_IDLE
					info.PlanAborted(curr_action)
				else
					goap_debug("PERFORMED [curr_action]")
					if(action_queue.len == 1 && action_queue[1] == curr_action)
						brain_state = STATE_IDLE
						return
			else
				brain_state = STATE_MOVINGTO

/datum/goap_agent/proc/moving_state()
	var/datum/goap_action/curr_action = action_queue[action_queue.len]

	if(curr_action.RequiresInRange(agent) && !curr_action.target)
		goap_debug("An action ([curr_action]) requires a target, but did not get one set")
		brain_state = STATE_IDLE
	else
		MoveTo(curr_action)

/datum/goap_agent/proc/idle_state()
	var/list/worldstate = info.GetWorldState(src)
	var/list/goal = info.GetGoal(src)

	var/list/plan = planner.Plan(agent, our_actions, worldstate, goal)

	if(LAZYLEN(plan))
		goap_debug("I am gonna act")
		goap_debug(plan.len)

		for(var/i in plan)
			goap_debug(i)

		action_queue = plan
		info.PlanFound(goal, plan)
		brain_state = STATE_ACTING
	else
		info.PlanFailed(goal)

/datum/goap_agent/proc/MoveTo(datum/goap_action/action)
	if(action.target)
		if(get_dist(agent, action.target) > 1)
			step_towards(agent, action.target)
		if(get_dist(agent, action.target) <= 1)
			action.inn_range = TRUE
			brain_state = STATE_ACTING