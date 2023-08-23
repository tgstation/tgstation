/**
 * A simple element that spawns an atom when the bullet hits an object or reaches the end of its range
 * If the projectile has embedding and it can embed into the target, then it won't spawn the drop,
 * since embedding the embed element already handles that.
 */
/datum/element/projectile_drop
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/drop_type

/datum/element/projectile_drop/Attach(datum/target, drop_type)
	. = ..()
	if(!isprojectile(target))
		return ELEMENT_INCOMPATIBLE
	src.drop_type = drop_type
	RegisterSignal(target, COMSIG_PROJECTILE_RANGE_OUT, PROC_REF(spawn_drop))
	RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(spawn_drop_if_not_embeddable))

/datum/element/projectile_drop/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_PROJECTILE_RANGE_OUT, COMSIG_PROJECTILE_SELF_ON_HIT))
	return ..()

/datum/element/projectile_drop/proc/spawn_drop(obj/projectile/source)
	SIGNAL_HANDLER
	var/turf/turf = get_turf(source)
	var/atom/new_drop = new drop_type(turf)
	SEND_SIGNAL(source, COMSIG_PROJECTILE_ON_SPAWN_DROP, new_drop)
	//Just to be safe, knowing it won't be spawned multiple times.
	Detach(source)

/datum/element/projectile_drop/proc/spawn_drop_if_not_embeddable(obj/projectile/source, atom/movable/firer, atom/hit, angle, hit_zone)
	SIGNAL_HANDLER
	if(source.can_embed_into(hit))
		Detach(source)
		return
	spawn_drop(source)
