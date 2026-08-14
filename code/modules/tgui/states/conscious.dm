/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: conscious_state
 *
 * Only checks if the user is conscious.
 */

GLOBAL_DATUM_INIT(conscious_state, /datum/ui_state/conscious_state, new)

/datum/ui_state/conscious_state/can_use_topic(src_object, mob/user)
	if(!IS_UNCONSCIOUS_OR_CRIT(user))
		return UI_INTERACTIVE
	return UI_CLOSE
