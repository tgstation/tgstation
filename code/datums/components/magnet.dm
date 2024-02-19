/// Attracts items of a certain typepath
/datum/component/magnet
	/// Range at which to pull items
	var/pull_range
	/// List of things we attract
	var/list/attracted_typecache
	/// What to do when we pull something
	var/datum/callback/on_pulled
	/// What to do when something reaches us
	var/datum/callback/on_contact
	/// Are we currently working?
	var/active = TRUE

/datum/component/magnet/Initialize(
	pull_range = 5,
	attracted_typecache = list(/obj/item/kitchen/spoon, /obj/item/kitchen/fork, /obj/item/knife),
	on_pulled,
	on_contact,
)
	. = ..()
	if (!length(attracted_typecache))
		CRASH("Attempted to instantiate a [src] on [parent] which does not do anything.")
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.pull_range = pull_range
	src.attracted_typecache = typecacheof(attracted_typecache)
	src.on_pulled = on_pulled
	src.on_contact = on_contact

/datum/component/magnet/RegisterWithParent()
	. = ..()
	START_PROCESSING(SSdcs, src)
	if (!isliving(parent))
		return
	RegisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(toggle_on_stat_change))

/datum/component/magnet/UnregisterFromParent()
	. = ..()
	STOP_PROCESSING(SSdcs, src)
	UnregisterSignal(parent, COMSIG_MOB_STATCHANGE)

/datum/component/magnet/Destroy(force)
	STOP_PROCESSING(SSdcs, src)
	on_pulled = null
	on_contact = null
	return ..()

/// If a mob dies we stop attracting stuff
/datum/component/magnet/proc/toggle_on_stat_change(mob/living/source)
	SIGNAL_HANDLER
	if (source.stat == DEAD)
		STOP_PROCESSING(SSdcs, src)
	else
		START_PROCESSING(SSdcs, src)

/datum/component/magnet/process(seconds_per_tick)
	for (var/atom/movable/thing in orange(pull_range, parent))
		if (!is_type_in_typecache(thing, attracted_typecache))
			continue
		var/range = get_dist(thing, parent)
		if (range == 0)
			continue
		if (range == 1 && !isnull(on_contact))
			on_contact.Invoke(thing)
			continue
		var/moved = thing.Move(get_step_towards(thing, parent))
		if (moved && !isnull(on_pulled))
			on_pulled.Invoke(thing)
		CHECK_TICK
