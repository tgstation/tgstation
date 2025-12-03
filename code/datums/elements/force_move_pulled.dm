/// Click dragging (thing) will force move (thing). A good use-case example for this would be clicking on a tile with a blood decal.
/datum/element/force_move_pulled

/datum/element/force_move_pulled/Attach(datum/target)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_click), override = TRUE)

/datum/element/force_move_pulled/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_ATTACK_HAND)

/datum/element/force_move_pulled/proc/on_click(atom/moving_atom, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(isnull(user.pulling))
		return NONE

	user.Move_Pulled(moving_atom)
	return COMPONENT_CANCEL_ATTACK_CHAIN
