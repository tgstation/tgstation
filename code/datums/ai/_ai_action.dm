///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_action
	var/datum/ai_controller/our_controller
	var/requires_processing = FALSE

/datum/ai_action/New(controller)
	. = ..()
	our_controller = controller


///When this is called, the action starts. It will not end until finish_execution is ran
/datum/ai_action/proc/start_execution()
	if(requires_processing)
		START_PROCESSING(SSai_actions, src)

///Called every 1 seconds
/datum/ai_action/process(delta_time)
	return

///Called when the action is done, succeeded is a bool that represents whether the action succeeded or failed. /If this is not called the AI will get stuck unless a new plan is generated/
/datum/ai_action/proc/finish_execution(succeeded)
	if(requires_processing)
		STOP_PROCESSING(SSai_actions, src)
	if(succeeded)
		our_controller.perform_next_step()
	else
		our_controller.cancel_plan()


///AI action that auto-shuts off after X
/datum/ai_action
