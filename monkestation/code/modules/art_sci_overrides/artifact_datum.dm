/// Used to maintain the acid overlay on the parent [/atom].
/datum/component/artifact/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(extra_effect)
		overlays += extra_effect
