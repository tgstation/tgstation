/// Adds crack overlays to an object when integrity gets low
/datum/element/crackable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/list/mutable_appearance/crack_appearances
	/// The level at which the object starts showing cracks, 1 being at full health and 0.5 being at half health
	var/crack_integrity = 1

/datum/element/crackable/Attach(datum/target, icon/crack_icon, list/crack_states, crack_integrity)
	. = ..()
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE
	src.crack_integrity = crack_integrity || src.crack_integrity
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
