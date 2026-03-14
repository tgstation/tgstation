/datum/action/cooldown/mob_cooldown/blood_worm/invade
	name = "Invade Corpse"
	desc = "Invade a humanoid corpse, taking it as your host."

	button_icon_state = "invade_corpse"

	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.

/datum/action/cooldown/mob_cooldown/blood_worm/invade/IsAvailable(feedback)
	if (!istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/invade/Activate(atom/target)
	if (!ishuman(target))
		return FALSE

	var/mob/living/basic/blood_worm/worm = owner
	var/mob/living/carbon/human/victim = target

	if (!worm.Adjacent(victim))
		victim.balloon_alert(worm, "too far away!")
		return FALSE
	if (!victim.IsReachableBy(worm))
		victim.balloon_alert(worm, "can't reach!")
		return FALSE

	unset_click_ability(worm, refund_cooldown = FALSE) // If you fail after this point, it's because your attempt got interrupted or because the victim is invalid.

	if (!invade_check(worm, victim, feedback = TRUE))
		return TRUE // Don't bite the victim.

	worm.visible_message(
		message = span_danger("\The [worm] starts entering \the [victim]!"),
		self_message = span_notice("You start entering \the [victim]."),
		blind_message = span_hear("You hear squeezing.")
	)

	if (!do_after(worm, 5 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(invade_check), worm, victim)))
		return TRUE // Don't bite the victim.

	worm.enter_host(victim)

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/invade/proc/invade_check(mob/living/basic/blood_worm/worm, mob/living/carbon/human/victim, feedback = FALSE)
	if (HAS_TRAIT(victim, TRAIT_BLOOD_WORM_HOST))
		if (feedback)
			victim.balloon_alert(worm, "already a host!")
		return FALSE
	if (victim.stat != DEAD)
		if (feedback)
			victim.balloon_alert(worm, "still alive!")
		return FALSE
	if (!CAN_HAVE_BLOOD(victim))
		if (feedback)
			victim.balloon_alert(worm, "no blood!")
		return FALSE
	if (victim.get_blood_volume() + worm.health * BLOOD_WORM_HEALTH_TO_BLOOD <= worm.get_eject_volume_threshold())
		if (feedback)
			victim.balloon_alert(worm, "not enough blood for control!")
		return FALSE
	return TRUE
