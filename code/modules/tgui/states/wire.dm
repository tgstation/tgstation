/var/global/datum/ui_state/wire_state/wire_state = new()

/datum/ui_state/wire_state/can_use_topic(src_object, mob/user)
	var/datum/wires/W = src_object
	if(!istype(W))
		return UI_CLOSE
	if(!user.Adjacent(W.holder))
		return UI_CLOSE
	return W.CanUse(user) ? UI_INTERACTIVE : UI_CLOSE