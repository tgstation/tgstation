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
	var/mob/living/carbon/human/host = worm.host

	host.visible_message(
		message = span_danger("\The [host] collapse[host.p_s()] and start[host.p_s()] shaking violently!"),
		ignored_mobs = owner
	)

	to_chat(owner, span_danger("You begin leaving your host..."))

	host.add_traits(list(TRAIT_FLOORED, TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED), REF(src))

	do_jitter_effect(worm)

	for (var/i in 1 to 2)
		addtimer(CALLBACK(src, PROC_REF(do_jitter_effect), worm), i SECONDS, TIMER_DELETE_ME)

	if (!do_after(owner, 3 SECONDS, worm.host, timed_action_flags = IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_LOC_CHANGE | IGNORE_INCAPACITATED, extra_checks = CALLBACK(src, PROC_REF(make_sure_shit_doesnt_go_wack), worm)))
		REMOVE_TRAITS_IN(host, REF(src))
		return

	REMOVE_TRAITS_IN(host, REF(src))

	worm.leave_host()

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/eject/proc/make_sure_shit_doesnt_go_wack(mob/living/basic/blood_worm/worm)
	return worm.host // Basically, if the worm is somehow removed midway through, the do_after will continue because it ignores the loc change of the worm. This check prevents that.

/datum/action/cooldown/mob_cooldown/blood_worm/eject/proc/do_jitter_effect(mob/living/basic/blood_worm/worm)
	worm.host?.do_jitter_animation(100)
