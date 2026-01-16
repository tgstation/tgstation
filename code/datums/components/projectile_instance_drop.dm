/// Similar to the projectile drop element but holds an instance of an atom instead
/datum/component/projectile_instance_drop
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/atom/movable/dropped_atom

/datum/component/projectile_instance_drop/Initialize(atom/movable/dropped_atom)
	if(!isprojectile(parent))
		return COMPONENT_INCOMPATIBLE
	if (!dropped_atom)
		stack_trace("[type] created with no atom to drop.")
		return COMPONENT_INCOMPATIBLE
	src.dropped_atom = dropped_atom

/datum/component/projectile_instance_drop/RegisterWithParent()
	dropped_atom.forceMove(parent)
	RegisterSignal(parent, COMSIG_PROJECTILE_RANGE_OUT, PROC_REF(drop_item))
	RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))
	RegisterSignals(dropped_atom, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_instance_left))

/datum/component/projectile_instance_drop/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PROJECTILE_RANGE_OUT, COMSIG_PROJECTILE_SELF_ON_HIT))
	if (dropped_atom)
		UnregisterSignal(dropped_atom, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
		QDEL_NULL(dropped_atom) // If it left our atom's contents then this is a null reference, if it didn't then it's fucked I guess

/datum/component/projectile_instance_drop/Destroy(force)
	dropped_atom = null
	return ..()

/// When we hit something check if we should hit the floor
/datum/component/projectile_instance_drop/proc/on_projectile_hit(obj/projectile/source, atom/movable/firer, atom/target, angle, hit_limb_zone, blocked, pierce_hit)
	SIGNAL_HANDLER
	if (blocked < 100 && !pierce_hit)
		drop_item(source)

/// Drop item to ground
/datum/component/projectile_instance_drop/proc/drop_item(obj/projectile/source)
	SIGNAL_HANDLER
	var/turf/drop_turf = source.drop_location()
	var/atom/movable/dropping = dropped_atom
	dropping.forceMove(drop_turf)
	if (isitem(dropping))
		var/obj/item/item_dropped = dropping
		item_dropped.do_drop_animation(drop_turf)

/// If our projectile exits our contents then remove the component
/datum/component/projectile_instance_drop/proc/on_instance_left()
	SIGNAL_HANDLER
	dropped_atom = null
	qdel(src)
