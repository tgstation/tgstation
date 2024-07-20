/obj/effect/abstract/meteor_shield_proxy
	invisibility = INVISIBILITY_ABSTRACT
	/// The meteor shield sat this is proxying - it will received all our meteor_acts
	var/obj/machinery/satellite/meteor_shield/parent
	/// Our proximity monitor.
	var/datum/proximity_monitor/advanced/meteor_shield/monitor

/obj/effect/abstract/meteor_shield_proxy/Initialize(mapload, obj/machinery/satellite/meteor_shield/parent)
	. = ..()
	if(QDELETED(parent))
		return INITIALIZE_HINT_QDEL
	src.parent = parent
	src.monitor = new(src, parent.kill_range, TRUE, parent)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_deleted))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_parent_z_changed))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_moved))

/obj/effect/abstract/meteor_shield_proxy/Destroy(force)
	QDEL_NULL(monitor)
	if(!QDELETED(parent))
		if(parent.proxies["[z]"] == src)
			parent.proxies -= "[z]"
		UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED, COMSIG_QDELETING))
	parent = null
	return ..()

/obj/effect/abstract/meteor_shield_proxy/proc/on_parent_moved()
	SIGNAL_HANDLER
	var/turf/parent_loc = get_turf(parent)
	var/turf/new_loc = locate(parent_loc.x, parent_loc.y, z)
	forceMove(new_loc)

/obj/effect/abstract/meteor_shield_proxy/proc/on_parent_z_changed()
	SIGNAL_HANDLER
	if(!are_zs_connected(parent, src) || z == parent.z)
		qdel(src)

/obj/effect/abstract/meteor_shield_proxy/proc/on_parent_deleted()
	SIGNAL_HANDLER
	qdel(src)
