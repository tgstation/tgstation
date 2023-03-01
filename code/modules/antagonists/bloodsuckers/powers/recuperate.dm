/// Used by Vassals
/datum/action/bloodsucker/recuperate
	name = "Sanguine Recuperation"
	desc = "Slowly heals you overtime using your master's blood, in exchange for some of your own blood and effort."
	button_icon_state = "power_recup"
	power_explanation = "<b>Recuperate</b>:\n\
		Activating this Power will begin to heal your wounds.\n\
		You will heal Brute and Toxin damage, at the cost of Stamina damage, and blood from both you and your Master.\n\
		If you aren't a bloodless race, you will additionally heal Burn damage.\n\
		The power will cancel out if you are incapacitated or dead."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = NONE
	bloodcost = 1.5
	cooldown = 10 SECONDS

/datum/action/bloodsucker/recuperate/CheckCanUse(mob/living/carbon/user)
	. = ..()
	if(!.)
		return
	if(user.stat >= DEAD || user.incapacitated())
		to_chat(user, "You are incapacitated...")
		return FALSE
	return TRUE

/datum/action/bloodsucker/recuperate/ActivatePower()
	. = ..()
	to_chat(owner, span_notice("Your muscles clench as your master's immortal blood mixes with your own, knitting your wounds."))

/datum/action/bloodsucker/recuperate/UsePower(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return

	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(user)
	vassaldatum.master.AddBloodVolume(-1)
	user.Jitter(5)
	user.adjustStaminaLoss(bloodcost * 1.1)
	user.adjustBruteLoss(-2.5)
	user.adjustToxLoss(-2, forced = TRUE)
	// Plasmamen won't lose blood, they don't have any, so they don't heal from Burn.
	if(!(NOBLOOD in user.dna.species.species_traits))
		user.blood_volume -= bloodcost
		user.adjustFireLoss(-1.5)
	// Stop Bleeding
	if(istype(user) && user.is_bleeding())
		for(var/obj/item/bodypart/part in user.bodyparts)
			part.generic_bleedstacks--

/datum/action/bloodsucker/recuperate/ContinueActive(mob/living/user, mob/living/target)
	if(user.stat >= DEAD)
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/datum/action/bloodsucker/recuperate/DeactivatePower()
	. = ..()
