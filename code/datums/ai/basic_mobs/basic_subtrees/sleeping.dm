#define COMSIG_BASIC_AI_WAKE_UP "comsig_basic_ai_wake_up"

//When the controller's pawn finds something, triggers a proc to cause some things to happen, this can be used for implementing feature parity with hostile mobs such as aggro sounds and icon state changes
/datum/ai_planning_subtree/simple_find_target/sleeping
	///Determines if we already swapped some blackboard variables to a different value, ex. vision range
	var/is_awake = FALSE


/datum/ai_planning_subtree/simple_find_target/sleeping/Setup(datum/ai_controller/controller)
	..()
	RegisterSignal(controller.pawn, COMSIG_BASIC_AI_WAKE_UP, PROC_REF(WakeUp), controller)

/datum/ai_planning_subtree/simple_find_target/sleeping/SelectBehaviors(datum/ai_controller/controller, delta_time)
	//. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!QDELETED(target))
		if(!is_awake)
			//Could modify this to implement hostile mob's ability to rally surrounding mobs around itself
			for(var/mob/mob in view(controller.pawn, controller.blackboard[BB_VISION_RANGE_AGGRO]))
				SEND_SIGNAL(mob, COMSIG_BASIC_AI_WAKE_UP)
		WakeUp(source = controller.pawn, controller = controller)
	else
		GoSleep(controller)
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, BB_VISION_RANGE)

/datum/ai_planning_subtree/simple_find_target/sleeping/proc/WakeUp(datum/source, datum/ai_controller/controller)

	if(!is_awake && controller.blackboard[BB_AGGRO_SOUND_FILE])
		playsound(controller.pawn, controller.blackboard[BB_AGGRO_SOUND_FILE], 50, FALSE)
		is_awake = TRUE
	controller.set_blackboard_key(BB_VISION_RANGE, controller.blackboard[BB_VISION_RANGE_AGGRO])

/datum/ai_planning_subtree/simple_find_target/sleeping/proc/GoSleep(datum/ai_controller/controller)
	is_awake = FALSE
	controller.set_blackboard_key(BB_VISION_RANGE, controller.blackboard[BB_VISION_RANGE_SLEEP])
