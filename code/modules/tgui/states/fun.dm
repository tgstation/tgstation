/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui state: fun_state
 *
 * Checks that the user has the fun privilige.
 */

GLOBAL_DATUM_INIT(fun_state, /datum/ui_state/fun_state, new)

/datum/ui_state/fun_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, R_FUN))
		return UI_INTERACTIVE
	return UI_CLOSE
