/// A component that, when given to a mob, allows ghosts to talk directly to them while orbiting.
/datum/component/ghost_court
	/// A list of weakrefs to the ghosts currently orbiting the datum
	var/list/ghosts

	/// A callback that is fired when a ghost talks.
	/// Receives the talking ghost, the message, and the list of ghosts in the court.
	var/datum/callback/talk_callback

/datum/component/ghost_court/Initialize(var/ghost_alarm, var/datum/callback/talk_callback)
	if (!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.talk_callback = talk_callback

	notify_ghosts(ghost_alarm, 'sound/effects/ghost2.ogg', source = parent, action = NOTIFY_ORBIT)

/datum/component/ghost_court/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, .proc/orbit_begin)
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, .proc/orbit_stop)

/datum/component/ghost_court/proc/orbit_begin(datum/source, atom/orbiter)
	SIGNAL_HANDLER

	var/mob/dead/observer/ghost = orbiter
	if (!istype(ghost))
		return

	LAZYADD(ghosts, WEAKREF(orbiter))

	RegisterSignal(ghost, COMSIG_MOB_DEADSAY, .proc/ghost_talked)

/datum/component/ghost_court/proc/orbit_stop(datum/source, atom/orbiter)
	SIGNAL_HANDLER

	deregister_orbiter(orbiter)

/datum/component/ghost_court/proc/ghost_talked(datum/source, message)
	SIGNAL_HANDLER

	var/list/ghosts_unreffed = list()

	for (var/_ghost_ref in ghosts)
		var/datum/weakref/ghost_ref = _ghost_ref
		var/other_ghost = ghost_ref.resolve()
		if (isnull(other_ghost))
			ghosts -= ghost_ref
		else
			ghosts_unreffed += other_ghost

	talk_callback.Invoke(source, message, ghosts_unreffed)

	return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/ghost_court/proc/deregister_orbiter(atom/orbiter)
	var/orbiter_ref = WEAKREF(orbiter)
	if (!(orbiter_ref in ghosts))
		return

	LAZYREMOVE(ghosts, orbiter_ref)
	UnregisterSignal(orbiter, COMSIG_MOB_DEADSAY)

/datum/component/ghost_court/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ORBIT_BEGIN,
		COMSIG_ATOM_ORBIT_STOP,
	))

	for (var/_ghost_ref in ghosts)
		var/datum/weakref/ghost_ref = _ghost_ref
		deregister_orbiter(ghost_ref.resolve())
