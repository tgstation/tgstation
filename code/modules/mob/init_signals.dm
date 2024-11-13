/// Called on [/mob/Initialize(mapload)], for the mob to register to relevant signals.
/mob/proc/register_init_signals()
	SHOULD_CALL_PARENT(TRUE)
	RegisterSignal(src, COMSIG_ADMIN_DELETING, PROC_REF(ghost_before_admin_delete))

/// Signal proc for [COMSIG_ADMIN_DELETING], to ghostize a mob beforehand if an admin is manually deleting it.
/mob/proc/ghost_before_admin_delete(datum/source)
	SIGNAL_HANDLER
	ghostize(can_reenter_corpse = FALSE)
