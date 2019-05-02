



/datum/action/bloodsucker/vassal/recuperate
	name = "Sanguine Recuperation"
	desc = "Slowly heal brute damage while active. This process is exhausting, and requires some of your tainted blood."
	button_icon_state = "power_recup"
	amToggle = TRUE
	bloodcost = 10
	cooldown = 100



	// Deal STAMINA damage over time, trickle down blood, and heal wounds.

/datum/action/bloodsucker/vassal/recuperate/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE
	if (owner.stat >= DEAD)
		return FALSE
	return TRUE

/datum/action/bloodsucker/vassal/recuperate/ActivatePower()
	to_chat(owner, "<span class='notice'>Your muscles clench and your skin crawls as your master's immortal blood knits your wounds.</span>")

	var/mob/living/carbon/C = owner
	var/mob/living/carbon/human/H
	if (ishuman(owner))
		H = owner

	while (ContinueActive(owner))
		var/bruteheal = min(C.getBruteLoss(), 0.3)
		C.heal_overall_damage(bruteheal)
		C.blood_volume -= 0.3
		if (C.getStaminaLoss() < 90)
			C.adjustStaminaLoss(5, forced = TRUE)
		// Stop Bleeding
		if (istype(H) && H.bleed_rate > 0 && rand(20) == 0)
			H.bleed_rate --

		C.Jitter(5)


		sleep(20)

	// DONE!
	//DeactivatePower(owner)


/datum/action/bloodsucker/vassal/recuperate/ContinueActive(mob/living/user, mob/living/target)
	return ..() && user.stat <= DEAD && user.blood_volume > 0