



/datum/action/bloodsucker/fortitude
	name = "Fortitude"//"Cellular Emporium"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	bloodcost = 10
	cooldown = 100
	bloodsucker_can_buy = TRUE
	amToggle = TRUE
	warn_constant_cost = TRUE

	var/this_brute_resist // So we can raise and lower your brute resist based on what your level_current WAS.

/datum/action/bloodsucker/fortitude/ActivatePower()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	var/mob/living/user = owner

	to_chat(user, "<span class='notice'>Your flesh, skin, and muscles become as steel.</span>")

	// Traits & Effects
	ADD_TRAIT(user, TRAIT_PIERCEIMMUNE, "bloodsucker")
	ADD_TRAIT(user, TRAIT_NODISMEMBER, "bloodsucker")
	ADD_TRAIT(user, TRAIT_STUNIMMUNE, "bloodsucker")
	if (ishuman(owner))
		var/mob/living/carbon/human/H = owner
		this_brute_resist = max(0.3, 0.7 - level_current * 0.1)
		H.physiology.brute_mod *= this_brute_resist//0.5

	while(bloodsuckerdatum && ContinueActive(user))

		// Pay Blood Toll (if awake)
		if (user.stat == CONSCIOUS)
			bloodsuckerdatum.AddBloodVolume(-0.3)

		sleep(20) // Check every few ticks that we haven't disabled this power

/datum/action/bloodsucker/fortitude/DeactivatePower(mob/living/user = owner, mob/living/target)
	..()

	// Restore Traits & Effects
	REMOVE_TRAIT(user, TRAIT_PIERCEIMMUNE, "bloodsucker")
	REMOVE_TRAIT(user, TRAIT_NODISMEMBER, "bloodsucker")
	REMOVE_TRAIT(user, TRAIT_STUNIMMUNE, "bloodsucker")
	if (ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod /= this_brute_resist//0.5
