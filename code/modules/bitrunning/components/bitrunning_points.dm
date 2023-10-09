/// Attaches a component which listens for a given signal from the item.
///
/// When the signal is received, it will add points to the signaler.
/datum/component/bitrunning_points
	/// The range at which we can find the signaler
	var/max_point_range
	/// Weakref to the loot crate landmark - where we send points
	var/datum/weakref/our_spawner
	/// The amount of points per each signal
	var/points_per_signal
	/// The signal we listen for
	var/signal_type

/datum/component/bitrunning_points/Initialize(signal_type, points_per_signal = 1, max_point_range = 4)
	src.max_point_range = max_point_range
	src.points_per_signal = points_per_signal
	src.signal_type = signal_type

	locate_spawner()

/datum/component/bitrunning_points/RegisterWithParent()
	RegisterSignal(parent, signal_type, PROC_REF(on_event))

/datum/component/bitrunning_points/UnregisterFromParent()
	UnregisterSignal(parent, signal_type)

/// Finds the signaler if it hasn't been found yet.
/datum/component/bitrunning_points/proc/locate_spawner()
	var/obj/effect/landmark/bitrunning/loot_signal/spawner = our_spawner?.resolve()
	if(spawner)
		return spawner

	for(var/obj/effect/landmark/bitrunning/loot_signal/found in GLOB.landmarks_list)
		if(IN_GIVEN_RANGE(get_turf(parent), found, max_point_range))
			our_spawner = WEAKREF(found)
			return found

/// Once the specified signal is received, whisper to the spawner to add points.
/datum/component/bitrunning_points/proc/on_event(datum/source)
	SIGNAL_HANDLER

	var/obj/effect/landmark/bitrunning/loot_signal/spawner = locate_spawner()
	if(isnull(spawner))
		return

	SEND_SIGNAL(spawner, COMSIG_BITRUNNER_GOAL_POINT, points_per_signal)
