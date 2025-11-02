/datum/action/cooldown/mob_cooldown/blood_worm/eject
	name = "Leave Host"
	desc = "Leave your host, taking their blood with you."

	button_icon_state = "leave_host"

	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

	click_to_activate = FALSE

	check_flags = NONE

/datum/action/cooldown/mob_cooldown/blood_worm/eject/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/eject/Activate(atom/target)
	var/mob/living/basic/blood_worm/worm = src.target

	to_chat(worm, span_notice("You begin leaving your host..."))

	if (!do_after(owner, 5 SECONDS, worm.host, timed_action_flags = IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_LOC_CHANGE | IGNORE_INCAPACITATED, extra_checks = CALLBACK(src, PROC_REF(make_sure_shit_doesnt_go_wack), worm)))
		worm.host.balloon_alert(owner, "interrupted!")
		return

	to_chat(worm, span_notice("You leave your host behind, taking [worm.host.p_their()] blood with you."))

	worm.leave_host()

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/eject/proc/make_sure_shit_doesnt_go_wack(mob/living/basic/blood_worm/worm)
	return worm.host // Basically, if the worm is somehow removed midway through, the do_after will continue because it ignores the loc change of the worm. This check prevents that.
