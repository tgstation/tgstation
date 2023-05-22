GLOBAL_REAL_VAR(list/available_interaction_modes = list(
	IMODE_COMBAT_MODE = /datum/interaction_mode/combat_mode,
	IMODE_INTENTS = /datum/interaction_mode/intents3
))

/mob/proc/log_istate()
	if(!istate)
		return "HELP"

	. = list()

	if(istate & ISTATE_HARM)
		. += "HARM"
	if(istate & ISTATE_SECONDARY)
		. += "SECONDARY"
	if(istate & ISTATE_CONTROL)
		. += "CONTROL"
	return jointext(., ", ")
/datum/interaction_mode
	var/shift_to_open_context_menu = FALSE
	var/client/owner
	var/atom/movable/screen/UI

/datum/interaction_mode/New(client/C)
	owner = C
	if (owner?.mob?.hud_used.has_interaction_ui)
		owner.mob.hud_used.static_inventory += procure_hud(owner.mob, owner.mob.hud_used)

/datum/interaction_mode/Destroy(force, ...)
	owner = null
	if (UI)
		UI.hud.static_inventory -= UI
		QDEL_NULL(UI)
	return ..()

/datum/interaction_mode/proc/reload_hud(mob/M)
	if (UI)
		owner.mob.hud_used.static_inventory -= UI
	if (M.hud_used.has_interaction_ui)
		M.hud_used.static_inventory += procure_hud(owner.mob, owner.mob.hud_used)

/datum/interaction_mode/proc/replace(datum/interaction_mode/IM)
	IM = new IM (owner)
	if (UI)
		UI?.hud.static_inventory -= UI
	owner.imode = IM
	qdel(src)

/datum/interaction_mode/proc/update_istate(mob/M, modifiers)

/datum/interaction_mode/proc/procure_hud(mob/M, datum/hud/H)
	return list()

/datum/interaction_mode/proc/keybind_act(type)


/datum/interaction_mode/proc/set_combat_mode(new_state, silent)
	return TRUE
