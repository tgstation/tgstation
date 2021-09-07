/datum/element/aggro_icon
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/aggro_icon = 0

/datum/element/aggro_icon/Attach(datum/target, icon_state)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	src.aggro_icon = icon_state
	RegisterSignal(target, COMSIG_ATOM_AI_PLAN_SELECTED, .proc/on_plan_generated)
	RegisterSignal(target, COMSIG_ATOM_UPDATE_ICON, .proc/on_update_icon)

/datum/element/aggro_icon/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_AI_PLAN_SELECTED)
	return ..()

/datum/element/aggro_icon/proc/on_plan_generated(atom/pawn)
	SIGNAL_HANDLER
	pawn.update_icon()

/datum/element/aggro_icon/proc/on_update_icon(atom/pawn)
	if(!pawn.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		pawn.icon_state = aggro_icon
		return COMSIG_ATOM_NO_UPDATE_ICON_STATE
