/// Teleports itself and/or others
/datum/gizmodes/teleporter
	possible_active_modes = list(
		/datum/gizpulse/teleport/self = 1,
		/datum/gizpulse/teleport/other = 1,
		/datum/gizpulse/teleport/other/and_self = 1,

	)

	min_modes = 2
	max_modes = 3

/// Teleport... stuff...
/datum/gizpulse/teleport
	/// Min distance to teleport
	var/offset_min = 5
	/// Max distance to teleport
	var/offset_max = 15

/// Teleport... stuff...
/datum/gizpulse/teleport/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/list/targets = get_teleport_targets(holder)
	var/range = rand(offset_min, offset_max)
	var/dir = pick(GLOB.alldirs)

	for(var/atom/movable/target as anything in targets)
		var/turf/new_turf = get_ranged_target_turf(target, dir, range)
		do_teleport(target, new_turf, asoundin = 'sound/effects/cartoon_sfx/cartoon_pop.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/gizpulse/teleport/proc/get_teleport_targets(atom/movable/holder)
	return list()

/// Teleport yourself
/datum/gizpulse/teleport/self/get_teleport_targets(atom/movable/holder)
	return list(holder)

/// Teleport someone else
/datum/gizpulse/teleport/other/get_teleport_targets(atom/movable/holder)
	. = list()
	for(var/mob/living/liver in view(2, holder))
		. += liver

/// Teleport yourself and someone else
/datum/gizpulse/teleport/other/and_self/get_teleport_targets(atom/movable/holder)
	. = ..() + holder

