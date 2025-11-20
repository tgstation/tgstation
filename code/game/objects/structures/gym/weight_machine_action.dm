/**
 * The action button given by the weight machine's buckle.
 * This allows users to manually trigger working out.
 */
/datum/action/push_weights
	name = "Work out"
	desc = "Start working out"
	button_icon = 'icons/obj/fluff/gym_equipment.dmi'
	button_icon_state = "stacklifter"
	///Reference to the weightpress we are created inside of.
	var/obj/structure/weightmachine/weightpress

/datum/action/push_weights/IsAvailable(feedback = FALSE)
	if(DOING_INTERACTION(owner, weightpress))
		return FALSE
	return TRUE

/datum/action/push_weights/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	weightpress.perform_workout(owner)
