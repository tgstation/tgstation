/**
 * tgui state: camera_state
 *
 * Cameras work a bit differently than standard TGUI
 * windows - they do not use UI_DATA the same way to
 * update. That is, you can watch cameras at huge ranges
 * regardless. camera_state disables long range viewing
 * and observers (they can just go there!) but leaves it
 * interactive for silicons.
 *
 */

GLOBAL_DATUM_INIT(camera_state, /datum/ui_state/camera_state, new)

/datum/ui_state/camera_state/can_use_topic(src_object, mob/user)
	if(isobserver(user))
		return UI_CLOSE;
	if(in_range(src_object, user))
		return UI_INTERACTIVE;
	if(!issilicon(user))
		if(IN_GIVEN_RANGE(src_object, user, 2))
			return UI_UPDATE;
		if(IN_GIVEN_RANGE(src_object, user, 3))
			return UI_DISABLED; /// just for looks, cams still update
	if(issilicon(user) && IN_GIVEN_RANGE(src_object, user, 5))
		return UI_INTERACTIVE;
	return UI_CLOSE;


