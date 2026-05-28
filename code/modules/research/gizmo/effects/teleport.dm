/// Teleport... stuff...
/datum/gizmo_effect/teleport
	/// Min distance to teleport
	var/offset_min = 5
	/// Max distance to teleport
	var/offset_max = 15

/// Teleport... stuff...
/datum/gizmo_effect/teleport/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	var/list/targets = get_teleport_targets(holder)
	var/range = rand(offset_min, offset_max)
	var/dir = pick(GLOB.alldirs)

	for(var/atom/movable/target as anything in targets)
		var/turf/new_turf = get_ranged_target_turf(target, dir, range)
		do_teleport(target, new_turf, asoundin = 'sound/effects/cartoon_sfx/cartoon_pop.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/gizmo_effect/teleport/proc/get_teleport_targets(atom/movable/holder)
	return list()

/// Teleport yourself
/datum/gizmo_effect/teleport/self/get_teleport_targets(atom/movable/holder)
	return list(holder)

/// Teleport someone else
/datum/gizmo_effect/teleport/other/get_teleport_targets(atom/movable/holder)
	. = list()
	for(var/mob/living/living in view(2, holder))
		. += living

/// Teleport yourself and someone else
/datum/gizmo_effect/teleport/other/and_self/get_teleport_targets(atom/movable/holder)
	return ..() + holder

