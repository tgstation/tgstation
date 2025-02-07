
/// Tracks the highest up human carrying this item, and loads bitrunning gear onto their avatar when they enter a virtual domain
/datum/component/loads_avatar_gear
	/// The callback called when COMSIG_BITRUNNER_STOCKING_GEAR is sent to our host human
	var/datum/callback/load_callback
	/// Weakref to the human we are currently carried by
	var/datum/weakref/tracked_human_ref

/datum/component/loads_avatar_gear/Initialize(datum/callback/load_callback)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.load_callback = load_callback

/datum/component/loads_avatar_gear/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(on_entered_loc))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERING = PROC_REF(on_entered_loc),
	)
	AddComponent(/datum/component/connect_containers, parent, loc_connections)

/datum/component/loads_avatar_gear/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ENTERING,
	))

	qdel(GetComponent(/datum/component/connect_containers))

/datum/component/loads_avatar_gear/Destroy(force)
	load_callback = null
	tracked_human_ref = null
	return ..()


/datum/component/loads_avatar_gear/proc/on_entered_loc(datum/source, atom/destination, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	// No need to do checks if we're just moving turfs
	if(isturf(destination) && isturf(old_loc))
		return

	// Iterate over list in reverse so we get the topmost human first
	// Because it's funnier if you get to use the avatar gear of the people you're carrying
	var/list/nested_locs = get_nested_locs(parent)
	for(var/i in length(nested_locs) to 1 step -1)
		var/atom/container = nested_locs[i]
		if(ishuman(container))
			switch_tracking(container)
			return

	// No humans found, stop tracking
	switch_tracking(null)

/datum/component/loads_avatar_gear/proc/switch_tracking(mob/living/carbon/human/to_track)
	var/mob/living/carbon/human/tracked_human = tracked_human_ref?.resolve()
	if(tracked_human == to_track)
		return

	if(tracked_human)
		UnregisterSignal(tracked_human, COMSIG_BITRUNNER_STOCKING_GEAR)
	tracked_human_ref = WEAKREF(to_track)
	RegisterSignal(to_track, COMSIG_BITRUNNER_STOCKING_GEAR, PROC_REF(load_onto_avatar))

/datum/component/loads_avatar_gear/proc/load_onto_avatar(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, external_load_flags)
	SIGNAL_HANDLER
	return load_callback?.Invoke(neo, avatar, external_load_flags)
