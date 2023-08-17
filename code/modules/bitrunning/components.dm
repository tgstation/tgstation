/// Attaches a component which listens for a given signal from the item.
///
/// When the signal is received, it will add points to the signaler.
/datum/component/bitrunning_points
	/// The range at which we can find the signaler
	var/box_range
	/// Weakref to the loot crate - where we send points
	var/datum/weakref/our_signaler
	/// The amount of points per each signal
	var/points_per_signal
	/// The signal we listen for
	var/signal_type

/datum/component/bitrunning_points/Initialize(signal_type, points_per_signal = 1, box_range = 4)
	src.box_range = box_range
	src.points_per_signal = points_per_signal
	src.signal_type = signal_type

	locate_signaler()

/datum/component/bitrunning_points/RegisterWithParent()
	RegisterSignal(parent, signal_type, PROC_REF(on_event))

/datum/component/bitrunning_points/UnregisterFromParent()
	UnregisterSignal(parent, signal_type)

/// Finds the signaler if it hasn't been found yet.
/datum/component/bitrunning_points/proc/locate_signaler()
	var/obj/effect/bitrunning/loot_signal/signaler = our_signaler?.resolve()
	if(signaler)
		return signaler

	for(var/turf/open/nearby in orange(box_range, get_turf(parent)))
		signaler = locate() in nearby
		if(signaler)
			our_signaler = WEAKREF(signaler)
			return signaler

/// Once the specified signal is received, whisper to the signaler to add points.
/datum/component/bitrunning_points/proc/on_event(datum/source)
	SIGNAL_HANDLER

	var/obj/effect/bitrunning/loot_signal/signaler = locate_signaler()
	if(isnull(signaler))
		return

	SEND_SIGNAL(signaler, COMSIG_BITRUNNER_GOAL_POINT, points_per_signal)
