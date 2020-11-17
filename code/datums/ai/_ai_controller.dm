/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/

/datum/ai_controller
	///The mob this controller is controlling
	var/atom/movable/pawn
	///Bitfield of traits for this AI to handle extra behavior
	var/ai_traits
	///Current action being performed by the AI.
	var/datum/ai_behavior/current_behavior
	///Current status of AI (OFF/ON/IDLE)
	var/ai_status
	///Current target of the AI, generally set by actions.
	var/atom/current_target
	///Delay between mob movements
	var/move_delay

/datum/ai_controller/New(mob/living/assigned_mob)
	if(CreateController(assigned_mob) & AI_BEHAVIOR_INCOMPATIBLE)
		if(!pawn) //If we're not attached to something destroy us.
			qdel(src)
		CRASH("[src] attached to [assigned_mob] but these are not compatible!")

	src.pawn = assigned_mob
	set_ai_status(AI_STATUS_ON)

	RegisterSignal(pawn, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)

///Abstract proc for initializing the controller's actions and other properties.
/datum/ai_controller/proc/CreateController(mob/living/new_mob)
	return

/// Generates a plan and see if our existing one is still valid.
/datum/ai_controller/process(delta_time)
	if(!current_behavior)
		return
	if(target && current_behavior.required_distance >= get_dist(pawn, current_target)) //Move
		if(current_behavior.move_while_performing) //Move and perform the action
			current_behavior.perform(controller,
	else //Perform the action


///Move somewhere using dumb movement (byond base)
/datum/ai_controller/proc/MoveTo(datum/ai_action/action)
	if(!action.target)
		return
	if(get_dist(pawn, action.target) > 1)
		if(!is_type_in_typecache(get_step(pawn, get_dir(pawn, action.target)), GLOB.dangerous_turfs))
			step_towards(pawn, action.target)
			action.PerformWhileMoving(src)
	if(get_dist(pawn, action.target) <= 1)
		action.is_in_range = TRUE
		brain_state = STATE_ACTING

///This is where you decide what actions are taken by the AI in parallel. By default this means AI_BEHAVIOR_MOVEMENT and AI_BEHAVIOR_ACTION.
/datum/ai_controller/proc/generate_plan()
	. = list()


///This proc handles changing ai status, and starts/stops processing if required.
/datum/ai_controller/proc/set_ai_status(new_ai_status)
	if(ai_status == new_ai_status)
		return FALSE //no change

	ai_status = new_ai_status
	switch(ai_status)
		if(AI_STATUS_ON)
			START_PROCESSING(SSai_controllers, src)
		if(AI_STATUS_OFF)
			STOP_PROCESSING(SSai_controllers, src)


/datum/ai_controller/proc/on_sentience_gained()
	UnregisterSignal(pawn, COMSIG_MOB_LOGIN)
	set_ai_status(AI_STATUS_OFF) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGOUT, .proc/on_sentience_lost)


/datum/ai_controller/proc/on_sentience_lost()
	UnregisterSignal(pawn, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_ON) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)

