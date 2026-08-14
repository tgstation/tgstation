/// Always reports SUCCESS to the parent, even if the child fails. Lets a sequence continue past a step that's allowed to fail. RUNNING still passes through unchanged.
/datum/bt_node/decorator/optional

/datum/bt_node/decorator/optional/tick(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(. == BT_FAILURE)
		return BT_SUCCESS
