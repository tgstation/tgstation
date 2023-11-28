/// Simple element that makes a PDA immune to being PDA bombed.
/datum/element/pda_bomb_proof

/datum/element/pda_bomb_proof/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/modular_computer/pda))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(block_pda_bomb))

/datum/element/pda_bomb_proof/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_TABLET_CHECK_DETONATE)

/datum/element/pda_bomb_proof/proc/block_pda_bomb()
	SIGNAL_HANDLER
	return COMPONENT_TABLET_NO_DETONATE
