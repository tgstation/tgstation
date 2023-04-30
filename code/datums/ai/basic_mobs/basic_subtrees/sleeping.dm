#define COMSIG_BASIC_AI_WAKE_UP "comsig_basic_ai_wake_up"

//When the controller's pawn finds something, trigger a proc that'll usually change the vision range and icon sprite to indicate thaat the pawn was woken up
/datum/ai_planning_subtree/simple_find_target/sleeping
	var/is_awake = FALSE
	///The sound file to play upon waking up

/datum/ai_planning_subtree/simple_find_target/sleeping/SelectBehaviors(datum/ai_controller/controller, delta_time)
	//. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!QDELETED(target))
		if(!is_awake)
			//Could modify this to implement hostile mob's ability to rally surrounding mobs to itself
			for(var/mob/living/mob in view(controller.pawn, 5))
				SEND_SIGNAL(mob, COMSIG_BASIC_AI_WAKE_UP)
		wake_up()
		return
	else
		go_sleep(controller)
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, BB_VISION_RANGE)

/datum/ai_planning_subtree/simple_find_target/sleeping/Setup(datum/ai_controller/controller, wakeup_sound_effect)
	..()
	RegisterSignal(controller.pawn, COMSIG_BASIC_AI_WAKE_UP, PROC_REF(wake_up), controller)

/datum/ai_planning_subtree/simple_find_target/sleeping/proc/wake_up(datum/source, datum/ai_controller/controller)
	if(!is_awake)
		is_awake = TRUE
	controller.set_blackboard_key(BB_VISION_RANGE, controller.blackboard[BB_VISION_RANGE_AGGRO])
	if(controller.blackboard[BB_AGGRO_SOUND_FILE])
		playsound(controller.pawn, controller.blackboard[BB_AGGRO_SOUND_FILE], 50, FALSE)

/datum/ai_planning_subtree/simple_find_target/sleeping/proc/go_sleep(datum/ai_controller/controller)
	is_awake = FALSE
	controller.set_blackboard_key(BB_VISION_RANGE, controller.blackboard[BB_VISION_RANGE_SLEEP])
	controller.pawn.icon_state = "[initial(controller.pawn.icon_state)]_sleeping"
