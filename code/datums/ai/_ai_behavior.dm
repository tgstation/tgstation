///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	///The controller that owns this action.
	var/datum/ai_controller/our_controller
	///Whether or not to add this action to the processing list
	var/requires_processing = FALSE
	///Set this to regen the plan after completing this action. If you set this on an action that finishes a lot expect shitty performance.
	var/regen_plan_after_completion = FALSE
	///What kind of behavior is this assigned as? Is set during runtime.
	var/behavior_key

/datum/ai_behavior/New(controller)
	. = ..()
	our_controller = controller

///Called to adjust the vars on the actions before execution, can be used to update actions too if relevant.area
/datum/ai_behavior/proc/set_action_state()
	return

///When this is called, the action starts. It will not end until finish_execution is ran
/datum/ai_behavior/proc/start_execution()
	if(requires_processing)
		START_PROCESSING(SSai_behaviors, src)

///Called every 1 seconds
/datum/ai_behavior/process(delta_time)
	return

///Called when the action is done, succeeded is a bool that represents whether the action succeeded or failed, which can be used for clean-up if required.
/datum/ai_behavior/proc/finish_execution(succeeded)
	STOP_PROCESSING(SSai_behaviors, src)
	if(succeeded && regen_plan_after_completion)
		our_controller.process() //Need to find an alternative to re-invoking plan checking without introducing proc overhead. oh well.
	our_controller.current_ai_behaviors[behavior_key] = null

