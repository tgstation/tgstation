/* SKYRAT PORT Ghost Cafe -- Needs to be completely rewritten
GLOBAL_LIST_EMPTY(ghost_eligible_mobs)

GLOBAL_LIST_EMPTY(client_ghost_timeouts)

/datum/element/ghost_role_eligibility
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	var/penalizing = FALSE
	var/free_ghost = FALSE

/datum/element/ghost_role_eligibility/Attach(datum/target,free_ghosting = FALSE, penalize_on_ghost = FALSE)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE
	penalizing = penalize_on_ghost
	free_ghost = free_ghosting
	var/mob/M = target
	if(!(M in GLOB.ghost_eligible_mobs))
		GLOB.ghost_eligible_mobs += M
		RegisterSignal(M, COMSIG_MOB_GHOSTIZE, .proc/get_ghost_flags)

/datum/element/ghost_role_eligibility/Detach(mob/M)
	. = ..()
	if(M in GLOB.ghost_eligible_mobs)
		GLOB.ghost_eligible_mobs -= M
		UnregisterSignal(M, COMSIG_MOB_GHOSTIZE)

/proc/get_all_ghost_role_eligible(silent = FALSE)
	var/list/candidates = list()
	for(var/m in GLOB.ghost_eligible_mobs)
		var/mob/M = m
		if(M.can_reenter_round(TRUE))
			candidates += M
	return candidates

/mob/proc/can_reenter_round(silent = FALSE)
	if(!(src in GLOB.ghost_eligible_mobs))
		return FALSE
	if(!(ckey in GLOB.client_ghost_timeouts))
		return TRUE
	var/timeout = GLOB.client_ghost_timeouts[ckey]
	if(timeout != CANT_REENTER_ROUND && timeout <= world.realtime)
		return TRUE
	if(!silent && client)
		to_chat(src, "<span class='warning'>You are unable to reenter the round[timeout != CANT_REENTER_ROUND ? " yet. Your ghost role blacklist will expire in [DisplayTimeText(timeout - world.realtime)]" : ""].</span>")
	return FALSE

/datum/element/ghost_role_eligibility/proc/get_ghost_flags()
	. = 0
	if(!penalizing)
		. |= COMPONENT_DO_NOT_PENALIZE_GHOSTING
	if(free_ghost)
		. |= COMPONENT_FREE_GHOSTING
	return .
*/
