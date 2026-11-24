/**
 * Adds crack overlays to an object when it sustains integrity damage
 *
 * You can provide an icon and a list of icon states for the cracks
 * If no icon is provided, a generic icon and list of icon states will be used
 *
 * You can also decide at what percentage of integrity the cracks start to appear
 * (1.0 meaning it starts appearing cracked upon taking any damage, 0.5 meaning it starts appearing cracked only at half integrity)
 */
/datum/element/crackable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Cached crack appearances
	VAR_FINAL/list/mutable_appearance/crack_appearances
	/// The level at which the object starts showing cracks, 1 being at full health and 0.5 being at half health
	var/crack_integrity = 1

/datum/element/crackable/Attach(datum/target, icon/crack_icon, list/crack_states, crack_integrity = 1)
	. = ..()
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE

	if(isnull(crack_icon))
		if(length(crack_states))
			stack_trace("Attaching [type] to [target.type] with crack states, but without a crack icon")
			return ELEMENT_INCOMPATIBLE

		crack_icon = 'icons/effects/cracks.dmi'
		crack_states = list()
		for(var/i in 1 to 10)
			crack_states += "crack[i]"

	src.crack_integrity = crack_integrity
	if(!crack_appearances) // This is the first attachment and we need to do first time setup
		crack_appearances = list()
		for(var/state in crack_states)
			for(var/i in 1 to 35)
				var/mutable_appearance/crack = mutable_appearance(crack_icon, state)
				crack.transform.Turn(i * 10)
				crack_appearances += crack
	RegisterSignal(target, COMSIG_ATOM_INTEGRITY_CHANGED, PROC_REF(IntegrityChanged))

/datum/element/crackable/proc/IntegrityChanged(obj/source, old_value, new_value)
	SIGNAL_HANDLER
	if(new_value >= source.max_integrity * crack_integrity)
		return
	source.AddComponent(/datum/component/cracked, crack_appearances, crack_integrity)
