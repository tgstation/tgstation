/**
 * Component that hooks into the client, listens for COMSIG_MOVABLE_Z_CHANGED, and depending on whether or not the
 * Z-level has ZTRAIT_NOPARALLAX enabled, disable or reenable parallax.
 */

/datum/component/zparallax
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// If TRUE, disable parallax checking alltogether until we change Z-levels again.
	var/caching = FALSE

	var/client/tracked
	var/mob/atomic

/datum/component/zparallax/Initialize(client/tracked)
	. = ..()
	if(!istype(tracked))
		stack_trace("Component zparallax has been initialized outside of a client. Deleting.")
		return COMPONENT_INCOMPATIBLE

	src.tracked = tracked
	atomic = tracked.mob

	RegisterSignal(atomic, COMSIG_MOB_LOGOUT, .proc/mob_change)
	RegisterSignal(atomic, COMSIG_MOVABLE_Z_CHANGED, .proc/ztrait_checks)

/datum/component/zparallax/proc/unregister_signals()
	if(!atomic)
		return

	UnregisterSignal(atomic, COMSIG_MOB_LOGOUT)
	UnregisterSignal(atomic, COMSIG_MOVABLE_Z_CHANGED)

/datum/component/zparallax/proc/mob_change()
	unregister_signals()

	atomic = tracked.mob

	RegisterSignal(atomic, COMSIG_MOB_LOGOUT, .proc/mob_change)
	RegisterSignal(atomic, COMSIG_MOVABLE_Z_CHANGED, .proc/ztrait_checks)

/datum/component/zparallax/proc/ztrait_checks()
	atomic = tracked.movingmob
	var/parallax = SSmapping.level_trait(atomic.z, ZTRAIT_NOPARALLAX)
	var/datum/hud/chud = atomic.hud_used

	if(tracked.prefs.read_preference(/datum/preference/choiced/parallax) == PARALLAX_DISABLE)
		return

	if(!parallax)
		chud.create_parallax(atomic)
		return
	else
		chud.remove_parallax(atomic)
		return
