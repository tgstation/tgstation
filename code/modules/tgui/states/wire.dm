 /**
  * tgui state: wire_state
  *
  * Checks specifically designed for wire datums.
 **/

/var/global/datum/ui_state/wire_state/wire_state = new()

/datum/ui_state/wire_state/can_use_topic(atom/src_object, mob/user)
	var/datum/wires/W = src_object.wires
	if(istype(W) && user.Adjacent(W.holder) && W.interactable(user))
		return UI_INTERACTIVE
	return UI_CLOSE