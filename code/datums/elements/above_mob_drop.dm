/// Element that makes mob drops appear above their corpses until moved or picked up
/datum/element/above_mob_drop
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Layer to which items are initially changed
	var/target_layer = ABOVE_LYING_MOB_LAYER

/datum/element/above_mob_drop/Attach(datum/target, target_layer = ABOVE_LYING_MOB_LAYER)
	. = ..()
	if (!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.target_layer = target_layer
	var/atom/movable/owner = target
	owner.layer = target_layer
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/element/above_mob_drop/proc/on_moved(atom/movable/source)
	SIGNAL_HANDLER
	if (source.layer == target_layer)
		source.layer = initial(source.layer)
	Detach(source)
