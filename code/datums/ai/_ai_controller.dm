/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/

/datum/ai_controller
	///The mob this controller is controlling
	var/mob/living/controlled_mob
	///Bitfield of traits for this AI to handle extra behavior
	var/ai_traits
	///Current action being performed by the AI.
	var/datum/ai_action/current_ai_action
	///Current status of AI (OFF/ON/IDLE)
	var/ai_status

/datum/ai_controller/New(mob/living/assigned_mob)
	if(CreateController(assigned_mob) & AI_BEHAVIOR_INCOMPATIBLE)
		if(!controlled_mob) //If we're not attached to something destroy us.
			qdel(src)
		CRASH("[src] attached to [assigned_mob] but these are not compatible!")

	src.controlled_mob = assigned_mob
	set_ai_status(AI_STATUS_ON)

	RegisterSignal(controlled_mob, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)

///Abstract proc for initializing the controller's actions and other properties.
/datum/ai_controller/proc/CreateController(mob/living/new_mob)
	return

/datum/ai_controller/process(delta_time)
	var/list/new_plan = create_plan() //Create a new plan based on the environment of the AI

	///No new plan generated
	if(!new_plan?.len)
		return

	if(!current_plan?.len) //We currently have no plan, this could mean we havn't gotten one yet or we finished our last one. So just use the new one.
		current_plan = new_plan
		perform_next_step(TRUE)
		return

	if(!check_current_plan_validity(new_plan)) //We have a plan, but it is no longer ideal.
		cancel_plan()
		current_plan = new_plan //From now on, use the new plan
		perform_next_step(TRUE)
		return

///Tries to perform the next step in the current plan, if its not the first step it will also remove the previous step.
/datum/ai_controller/proc/perform_next_step(first = FALSE)
	if(!first) //Not our first step, so cut the last step we performed.
		current_plan.Cut(1,2)
	if(!current_plan.len) //Plan ran out of steps, we are done.
		return
	current_ai_action = current_plan[1]
	current_ai_action.start_execution()

///Builds a plan from actions based on checks performed in this proc.
/datum/ai_controller/proc/create_plan()
	return list()

///Tries to cancel the currently existing plan if it exists, and also the current active action
/datum/ai_controller/proc/cancel_plan()
	current_ai_action?.finish_execution(FALSE) //Fail our current action, which will automatically clear the current plan.
	current_plan.Cut() //Cancel the plan

///Checks if current plan is different from previous plan by seeing if any actions changed.
/datum/ai_controller/proc/check_current_plan_validity(list/new_plan)
	for(var/i in 1 to current_plan.len)
		var/current_action_temp = current_plan[i]
		var/new_action_temp	= new_plan[i]
		if(current_action_temp != new_action_temp)
			return FALSE
	return TRUE

///This proc handles changing ai status, and starts/stops processing if required.
/datum/ai_controller/proc/set_ai_status(new_ai_status)
	if(ai_status == new_ai_status)
		return FALSE //no change

	ai_status = new_ai_status
	switch(ai_status)
		if(AI_STATUS_ON)
			START_PROCESSING(SSai_behavior, src)
		if(AI_STATUS_OFF)
			STOP_PROCESSING(SSai_behavior, src)
			cancel_plan()

/datum/ai_controller/proc/on_sentience_gained()
	UnregisterSignal(controlled_mob, COMSIG_MOB_LOGIN)
	set_ai_status(AI_STATUS_OFF) //Can't do anything while player is connected
	RegisterSignal(controlled_mob, COMSIG_MOB_LOGOUT, .proc/on_sentience_lost)


/datum/ai_controller/proc/on_sentience_lost()
	UnregisterSignal(controlled_mob, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_ON) //Can't do anything while player is connected
	RegisterSignal(controlled_mob, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)



/*
thinkspace:addtimer
[MOVEMENT] = random_wander()
[ACTION] = fire_gun()



*/
