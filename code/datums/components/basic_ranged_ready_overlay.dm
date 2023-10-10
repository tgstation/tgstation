/**
 * Fade in an overlay x seconds after a basic mob makes a ranged attack
 * Indicates that it will be ready to fire again
 */
/datum/component/basic_ranged_ready_overlay
	/// Icon state for the overlay to display
	var/overlay_state
	/// Time after which to redisplay the overlay
	var/display_after
	/// Timer tracking when we can next fire
	var/waiting_timer

/datum/component/basic_ranged_ready_overlay/Initialize(overlay_state = "", display_after = 2.5 SECONDS)
	. = ..()
	if (!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE
	if (!overlay_state)
		CRASH("Attempted to assign basic ranged ready overlay with a null or empty overlay state")
	src.overlay_state = overlay_state
	src.display_after = display_after
	restore_overlay(parent)

/datum/component/basic_ranged_ready_overlay/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_BASICMOB_POST_ATTACK_RANGED, PROC_REF(on_ranged_attack))
	RegisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_changed))

/datum/component/basic_ranged_ready_overlay/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_BASICMOB_POST_ATTACK_RANGED, COMSIG_LIVING_REVIVE))
	return ..()

/datum/component/basic_ranged_ready_overlay/Destroy(force, silent)
	deltimer(waiting_timer)
	return ..()

/// When we shoot, get rid of our overlay and queue its return
/datum/component/basic_ranged_ready_overlay/proc/on_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	SIGNAL_HANDLER
	firer.cut_overlay(overlay_state)
	waiting_timer = addtimer(CALLBACK(src, PROC_REF(restore_overlay), firer), display_after, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_DELETE_ME)

/// Don't show overlay on a dead man
/datum/component/basic_ranged_ready_overlay/proc/on_stat_changed(mob/living/basic/gunman)
	SIGNAL_HANDLER
	if (gunman.stat == DEAD)
		gunman.cut_overlay(overlay_state)
		return
	if (timeleft(waiting_timer) <= 0)
		restore_overlay(parent)

/// Try putting our overlay back
/datum/component/basic_ranged_ready_overlay/proc/restore_overlay(mob/living/basic/gunman)
	if (QDELETED(gunman) || gunman.stat == DEAD)
		return
	gunman.cut_overlay(overlay_state)
	gunman.add_overlay(overlay_state)
