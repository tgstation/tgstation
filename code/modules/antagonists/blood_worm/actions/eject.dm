/datum/action/blood_worm_eject
	name = "Eject"
	desc = "Leave your host, taking their blood with you."

/datum/action/blood_worm_eject/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	return ..()

/datum/action/blood_worm_eject/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if (!.)
		return

	var/mob/living/basic/blood_worm/worm = target

	if (!do_after(owner, 5 SECONDS, worm.host, timed_action_flags = IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_LOC_CHANGE | IGNORE_INCAPACITATED, extra_checks = CALLBACK(src, PROC_REF(make_sure_shit_doesnt_go_wack), worm)))
		worm.host.balloon_alert(owner, "interrupted!")
		return FALSE

	worm.leave_host()
	return TRUE

/datum/action/blood_worm_eject/proc/make_sure_shit_doesnt_go_wack(mob/living/basic/blood_worm/worm)
	return worm.host // Basically, if the worm is somehow removed midway through, the do_after will continue because it ignores the loc change of the worm. This check prevents that.
