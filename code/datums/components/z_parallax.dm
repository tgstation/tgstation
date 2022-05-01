/**
 * Component that hooks into the client, listens for COMSIG_MOVABLE_Z_CHANGED, and depending on whether or not the
 * Z-level has ZTRAIT_NOPARALLAX enabled, disable or reenable parallax.
 */

/datum/component/zparallax
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// If TRUE, disable parallax checking alltogether until we change Z-levels again.
	var/caching = FALSE

	var/client/tracked
	var/mob/client_mob

/datum/component/zparallax/Initialize(client/tracked)
	. = ..()
	if(!istype(tracked))
		stack_trace("Component zparallax has been initialized outside of a client. Deleting.")
		return COMPONENT_INCOMPATIBLE

	src.tracked = tracked
	client_mob = tracked.mob

/datum/component/zparallax/RegisterWithParent()
	RegisterSignal(client_mob, COMSIG_MOB_LOGOUT, .proc/mob_change)
	RegisterSignal(client_mob, COMSIG_MOVABLE_Z_CHANGED, .proc/ztrait_checks)

/datum/component/zparallax/UnregisterFromParent()
	unregister_signals()

/datum/component/zparallax/proc/unregister_signals()
	if(!client_mob)
		return

	UnregisterSignal(client_mob, list(COMSIG_MOB_LOGOUT, COMSIG_MOVABLE_Z_CHANGED))

/datum/component/zparallax/proc/mob_change()
	SIGNAL_HANDLER

	unregister_signals()

	client_mob = tracked.mob

	RegisterSignal(client_mob, COMSIG_MOB_LOGOUT, .proc/mob_change)
	RegisterSignal(client_mob, COMSIG_MOVABLE_Z_CHANGED, .proc/ztrait_checks)

/datum/component/zparallax/proc/ztrait_checks()
	SIGNAL_HANDLER

	client_mob = tracked.movingmob
	var/parallax = SSmapping.level_trait(client_mob.z, ZTRAIT_NOPARALLAX)
	var/datum/hud/hud = client_mob.hud_used

	if(tracked.prefs.read_preference(/datum/preference/choiced/parallax) == PARALLAX_DISABLE)
		return

	if(!parallax)
		hud.create_parallax(client_mob)
		return
	else
		hud.remove_parallax(client_mob)
		return
