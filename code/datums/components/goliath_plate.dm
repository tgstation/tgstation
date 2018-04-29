//Actual armor modification is handled in code/modules/mining/equipment/goliath_hide.dm, this is just the tracker/examine info

/datum/component/goliath_plate
	var/amount

/datum/component/goliath_plate/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/examine)

	amount = 0

/datum/component/goliath_plate/proc/examine(mob/user)
	if(amount)
		to_chat(user, "It has been strengthened with [amount] goliath plate\s.")
	else
		to_chat(user, "It can be strengthened with goliath hide plates.")