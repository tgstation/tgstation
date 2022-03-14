/mob/living/carbon/proc/passiveFleshHeal(var/bruteHealFactor, var/burnHealFactor, var/calculateMissing = TRUE)  //healing brute & burn damage, parse in bruteHealFactor or burnHealFactor if you want to override the default formula. set calculateMissing to false if you don't want the other type of damage to get healed, e.g. you get super fast brute damage healing but cant heal burn as a resul
	. = ..()    //hippie start, passive healing
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
