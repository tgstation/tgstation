/mob/living/carbon
	var/passiveHeal = TRUE	//change this to false when you want to disable or override passive healing on a mob

/mob/living/carbon/Life()
	. = ..()
	if(passiveHeal)
		passiveFleshHeal()

/obj/item/organ/liver/on_life()
	. = ..()
	var/mob/living/carbon/C = owner
	if(C.passiveHeal)
		passiveLiverHeal()

/obj/item/organ/brain/on_life()
	. = ..()
	var/mob/living/carbon/C = owner
	if(C.passiveHeal)
		passiveBrainHeal()

/obj/item/organ/brain	//can move this and the applyOrganDamage proc to general organs if we want to set delays for other organs
	var/timeSinceDamaged = 0

/obj/item/organ/brain/applyOrganDamage(d, maximum = maxHealth)	//note the time the brain has been damaged
	. = ..()
	timeSinceDamaged = world.time

/mob/living/carbon/proc/passiveFleshHeal(var/bruteHealFactor, var/burnHealFactor, var/calculateMissing = TRUE)	//healing brute & burn damage, parse in bruteHealFactor or burnHealFactor if you want to override the default formula. set calculateMissing to false if you don't want the other type of damage to get healed, e.g. you get super fast brute damage healing but cant heal burn as a resul
	. = ..()
	var/list/parts = get_damaged_bodyparts(1,1, null, BODYPART_ORGANIC)
	var/generalHealFactor = 0
	var/sendHealMessage = TRUE	//don't want to send the message more than once in one go
	if(!parts.len)	//don't bother wasting cycles on this if there's nothing to even heal
		return

	if((!bruteHealFactor && calculateMissing) || (!burnHealFactor && calculateMissing))	//if there's one override missing and we want to use the default formula, then we need to do calculations for that damage
		switch(nutrition)	//stolen from blood.dm shamelessly, no need to adjust nutrition yet in case blood regeneration already handles it
			if(0 to NUTRITION_LEVEL_STARVING)
				generalHealFactor = 0.01	//0.01 is now lowest number that will be accepted
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				generalHealFactor = 0.04
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				generalHealFactor = 0.08
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				generalHealFactor = 0.12
			else
				generalHealFactor = 0.16

		if(blood_volume > BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER))	//call adjusting nutrition for default healing formula, if blood.dm doesn't call it when creating new blood
			adjust_nutrition(-generalHealFactor * HUNGER_FACTOR)	//if you override but still want to adjust nutrition, you can copy something similar to this over to your proc where you'll call the manual formulas

		bruteHealFactor = generalHealFactor
		burnHealFactor = generalHealFactor

	for(var/obj/item/bodypart/L in parts)	//stolen from heal.dm with extra tweaks
		if(L.brute_dam > 0)
			if(L.burn_dam > 0)	//both brute and burn damage detected
				if(L.heal_damage(bruteHealFactor, burnHealFactor, null, BODYPART_ORGANIC))	//heal both damages
					update_damage_overlays()
				if(prob(1) && sendHealMessage)
					sendHealMessage = FALSE
					to_chat(src, "<span class='notice'>You feel your [L.name]'s bruising and burns recovering slowly.</span>")
			else	//just brute damage detected
				if(L.heal_damage(bruteHealFactor, null, null, BODYPART_ORGANIC))	//heal brute only
					update_damage_overlays()
				if(prob(1) && sendHealMessage)
					sendHealMessage = FALSE
					to_chat(src, "<span class='notice'>You feel your [L.name]'s bruises slowly healing.</span>")
		else if (L.burn_dam > 0)	//just burn damage
			if(L.heal_damage(null, burnHealFactor, null, BODYPART_ORGANIC))	//heal burn only
				update_damage_overlays()
			if(prob(1) && sendHealMessage)
				sendHealMessage = FALSE
				to_chat(src, "<span class='notice'>You feel your [L.name]'s burns improving slowly.</span>")

/obj/item/organ/brain/proc/passiveBrainHeal(var/brainHealFactor, var/extraDelay = 0)	//healing brain damage, inverse curve so higher damage = faster healing rate. can override heal factor to give a different / faster formula. extraDelay to specify extra or less time before being healed if you were damaged recently. -50 = 0 second delay for healing if you got brain damaged
	. = ..()
	var/mob/living/carbon/C = owner
	if(world.time > timeSinceDamaged + 50 + extraDelay)	//start brain healing *only* if it has been more than 5 seconds since last damaged, plus extraDelay
		if(!brainHealFactor)	//allow override if brainHealFactor is manually defined
			brainHealFactor = (1 + (damage * (damage / (maxHealth / 2)))) / maxHealth	//higher healing rate the more damage the brain has, so to fully heal you really should get mannitol. 190 damage = 1.81 healed, 150 damage = 1.13 healed, 100 damage = 0.505 healed, 50 damage = 0.13 healed, 10 damage = 0.01 healed
		C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -brainHealFactor)

/obj/item/organ/liver/proc/passiveLiverHeal(var/toxinHealFactor)	//healing toxin damage and managing liver damage. parse a number or formula for toxinHealFactor if you want to override the default
	. = ..()
	var/mob/living/carbon/C = owner
	if(C.getToxLoss())	//don't bother if there isn't any toxin damage?
		if((maxHealth - damage) > (maxHealth / 5))	//don't trade toxloss for organ damage if the poor liver is already hopelessly damaged
			if(!toxinHealFactor)	//allow override if toxinHealFactor is manually defined
				toxinHealFactor = ((maxHealth - damage) / maxHealth) / 4	//0.25 tox damage heal when at 100 liver health, current % of damage to heal, based on liver damage
			C.adjustToxLoss(-toxinHealFactor, FALSE, FALSE)
			C.adjustOrganLoss(ORGAN_SLOT_LIVER, toxinHealFactor)
	else
		C.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.1)	//organs only normally heal at 0.001 per tick??? wtf? too little for the liver, so this extra amount to heal added
