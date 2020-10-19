/**
 * tgui state: not_incapacitated_state
 *
 * Checks that the user isn't incapacitated
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

GLOBAL_DATUM_INIT(not_incapacitated_state, /datum/ui_state/not_incapacitated_state, new)

/**
 * tgui state: not_incapacitated_turf_state
 *
 * Checks that the user isn't incapacitated and that their loc is a turf
 */

GLOBAL_DATUM_INIT(not_incapacitated_turf_state, /datum/ui_state/not_incapacitated_state, new(no_turfs = TRUE))

/datum/ui_state/not_incapacitated_state
	var/turf_check = FALSE

/datum/ui_state/not_incapacitated_state/New(loc, no_turfs = FALSE)
	..()
	turf_check = no_turfs

/datum/ui_state/not_incapacitated_state/can_use_topic(src_object, mob/user)
	if(user.stat != CONSCIOUS)
		return UI_CLOSE
	if(HAS_TRAIT(src, TRAIT_UI_BLOCKED) || user.incapacitated() || (turf_check && !isturf(user.loc)))
		return UI_DISABLED
	return UI_INTERACTIVE
