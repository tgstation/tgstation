/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a atom. What this means is that these datums
have ways of interacting with a specific atom and control it. They posses a blackboard with the information the AI knows and has, and will plan behaviors it will try to execute.
*/

/datum/ai_controller
	///The atom this controller is controlling
	var/atom/pawn
	///Bitfield of traits for this AI to handle extra behavior
	var/ai_traits
	///Current actions being performed by the AI.
	var/list/current_behaviors = list()
	///Current actions and their respective last time ran as an assoc list.
	var/list/behavior_cooldowns = list()
	///Current status of AI (OFF/ON)
	var/ai_status
	///Current movement target of the AI, generally set by decision making.
	var/atom/current_movement_target
	///This is a list of variables the AI uses and can be mutated by actions. When an action is performed you pass this list and any relevant keys for the variables it can mutate.
	var/list/blackboard = list()
	///Stored arguments for behaviors given during their initial creation
	var/list/behavior_args = list()
	///Tracks recent pathing attempts, if we fail too many in a row we fail our current plans.
	var/pathing_attempts
	///Can the AI remain in control if there is a client?
	var/continue_processing_when_client = FALSE
	///distance to give up on target
	var/max_target_distance = 14
	///Reference to the movement datum we use. Is a type on initialize but becomes a ref afterwards.
	var/datum/ai_movement/ai_movement = /datum/ai_movement/dumb
	///Cooldown until next movement
	COOLDOWN_DECLARE(movement_cooldown)
	///Delay between movements. This is on the controller so we can keep the movement datum singleton
	var/movement_delay = 0.1 SECONDS
	///A list for the path we're currently following, if we're using JPS pathing
	var/list/movement_path
	///Cooldown for JPS movement, how often we're allowed to try making a new path
	COOLDOWN_DECLARE(repath_cooldown)
	///AI paused time
	var/paused_until = 0

/datum/ai_controller/New(atom/new_pawn)
	ai_movement = SSai_movement.movement_types[ai_movement]
	PossessPawn(new_pawn)

/datum/ai_controller/Destroy(force, ...)
	set_ai_status(AI_STATUS_OFF)
	UnpossessPawn(FALSE)
	return ..()

///Proc to move from one pawn to another, this will destroy the target's existing controller.
/datum/ai_controller/proc/PossessPawn(atom/new_pawn)
	if(pawn) //Reset any old signals
		UnpossessPawn(FALSE)

	if(istype(new_pawn.ai_controller)) //Existing AI, kill it.
		QDEL_NULL(new_pawn.ai_controller)

	if(TryPossessPawn(new_pawn) & AI_CONTROLLER_INCOMPATIBLE)
		qdel(src)
		CRASH("[src] attached to [new_pawn] but these are not compatible!")

	pawn = new_pawn
	pawn.ai_controller = src

	if(!continue_processing_when_client && istype(new_pawn, /mob))
		var/mob/possible_client_holder = new_pawn
		if(possible_client_holder.client)
			set_ai_status(AI_STATUS_OFF)
		else
			set_ai_status(AI_STATUS_ON)
	else
		set_ai_status(AI_STATUS_ON)

	RegisterSignal(pawn, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)

///Abstract proc for initializing the pawn to the new controller
/datum/ai_controller/proc/TryPossessPawn(atom/new_pawn)
	return

///Proc for deinitializing the pawn to the old controller
/datum/ai_controller/proc/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT))
	pawn.ai_controller = null
	pawn = null
	if(destroy)
		qdel(src)
	return

///Returns TRUE if the ai controller can actually run at the moment.
/datum/ai_controller/proc/able_to_run()
	if(world.time < paused_until)
		return FALSE
	return TRUE

/// Generates a plan and see if our existing one is still valid.
/datum/ai_controller/process(delta_time)
	if(!able_to_run())
		walk(pawn, 0) //stop moving
		return //this should remove them from processing in the future through event-based stuff.

	if(!current_behaviors?.len)
		SelectBehaviors(delta_time)
		if(!current_behaviors?.len)
			PerformIdleBehavior(delta_time) //Do some stupid shit while we have nothing to do
			return

	if(current_movement_target && get_dist(pawn, current_movement_target) > max_target_distance) //The distance is out of range
		CancelActions()
		return

	for(var/i in current_behaviors)
		var/datum/ai_behavior/current_behavior = i

		if(behavior_cooldowns[current_behavior] > world.time) //Still on cooldown
			continue

		// Convert the current behaviour action cooldown to realtime seconds from deciseconds.current_behavior
		// Then pick the max of this and the delta_time passed to ai_controller.process()
		// Action cooldowns cannot happen faster than delta_time, so delta_time should be the value used in this scenario.
		var/action_delta_time = max(current_behavior.action_cooldown * 0.1, delta_time)

		if(current_behavior.behavior_flags & AI_BEHAVIOR_REQUIRE_MOVEMENT && current_movement_target) //Might need to move closer
			if(current_behavior.required_distance >= get_dist(pawn, current_movement_target)) ///Are we close enough to engage?
				if(ai_movement.moving_controllers[src] == current_movement_target) //We are close enough, if we're moving stop.else
					ai_movement.stop_moving_towards(src)
				ProcessBehavior(action_delta_time, current_behavior)
				return

			else if(ai_movement.moving_controllers[src] != current_movement_target) //We're too far, if we're not already moving start doing it.
				ai_movement.start_moving_towards(src, current_movement_target, current_behavior.required_distance) //Then start moving

			if(current_behavior.behavior_flags & AI_BEHAVIOR_MOVE_AND_PERFORM) //If we can move and perform then do so.
				ProcessBehavior(action_delta_time, current_behavior)
				return
		else //No movement required
			ProcessBehavior(action_delta_time, current_behavior)
			return

///Perform some dumb idle behavior.
/datum/ai_controller/proc/PerformIdleBehavior(delta_time)
	return

///This is where you decide what actions are taken by the AI.
/datum/ai_controller/proc/SelectBehaviors(delta_time)
	SHOULD_NOT_SLEEP(TRUE) //Fuck you don't sleep in procs like this.
	return

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
			CancelActions()

/datum/ai_controller/proc/PauseAi(time)
	paused_until = world.time + time

/datum/ai_controller/proc/AddBehavior(behavior_type, ...)
	var/datum/ai_behavior/behavior = GET_AI_BEHAVIOR(behavior_type)
	if(!behavior)
		CRASH("Behavior [behavior_type] not found.")
	var/list/arguments = args.Copy()
	arguments[1] = src
	if(!behavior.setup(arglist(arguments)))
		return
	current_behaviors += behavior
	arguments.Cut(1, 2)
	if(length(arguments))
		behavior_args[behavior_type] = arguments

/datum/ai_controller/proc/ProcessBehavior(delta_time, datum/ai_behavior/behavior)
	var/list/arguments = list(delta_time, src)
	var/list/stored_arguments = behavior_args[behavior.type]
	if(stored_arguments)
		arguments += stored_arguments
	behavior.perform(arglist(arguments))

/datum/ai_controller/proc/CancelActions()
	for(var/i in current_behaviors)
		var/datum/ai_behavior/current_behavior = i
		current_behavior.finish_action(src, FALSE)

/datum/ai_controller/proc/on_sentience_gained()
	SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_MOB_LOGIN)
	if(!continue_processing_when_client)
		set_ai_status(AI_STATUS_OFF) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGOUT, .proc/on_sentience_lost)

/datum/ai_controller/proc/on_sentience_lost()
	SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_ON) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)

/// Use this proc to define how your controller defines what access the pawn has for the sake of pathfinding, likely pointing to whatever ID slot is relevant
/datum/ai_controller/proc/get_access()
	return
