/datum/action/cooldown/mob_cooldown/blood_worm_invade
	name = "Invade Corpse"
	desc = "Invade a humanoid corpse, taking it as your host."

	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.

/datum/action/cooldown/mob_cooldown/blood_worm_invade/IsAvailable(feedback)
	if (!istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm_invade/Activate(atom/target)
	if (!ishuman(target))
		return FALSE

	var/mob/living/basic/blood_worm/worm = owner
	var/mob/living/carbon/human/victim = target

	if (!worm.Adjacent(victim))
		victim.balloon_alert(worm, "too far away!")
		return FALSE

	unset_click_ability(worm, refund_cooldown = FALSE) // If you fail after this point, it's because your attempt got interrupted or because the victim is invalid.

	if (!invade_check(worm, victim, feedback = TRUE))
		return FALSE

	if (!do_after(worm, 5 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(invade_check), worm, victim)))
		target.balloon_alert(worm, "interrupted!")
		return FALSE

	worm.enter_host(victim)

	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm_invade/proc/invade_check(mob/living/basic/blood_worm/worm, mob/living/carbon/human/victim, feedback = FALSE)
	if (victim.stat != DEAD)
		if (feedback)
			victim.balloon_alert(worm, "still alive!")
		return FALSE
	if (HAS_TRAIT(victim, TRAIT_NOBLOOD))
		if (feedback)
			victim.balloon_alert(worm, "no blood!")
		return FALSE
	return TRUE
