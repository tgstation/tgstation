/mob/living/carbon/human/Life()	//healing brute & burn damage
	. = ..()
	var/list/parts = get_damaged_bodyparts(1,1, null, BODYPART_ORGANIC)
	var/nutrition_ratio = 0
	var/sendhealmessage = TRUE	//don't want to send the message twice or more times in one go
	if(!parts.len)	//don't bother wasting cycles on this if there's nothing to even heal
		return

	switch(nutrition)	//stolen from blood.dm shamelessly, no need to adjust nutrition as blood regeneration already handles it
		if(0 to NUTRITION_LEVEL_STARVING)
			nutrition_ratio = 0.1	//lowest number that is accepted
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			nutrition_ratio = 0.11
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			nutrition_ratio = 0.13
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			nutrition_ratio = 0.16
		else
			nutrition_ratio = 0.2
	if(satiety > 80)
		nutrition_ratio *= 0.25

	for(var/obj/item/bodypart/L in parts)	//stolen from heal.dm with extra tweaks
		if(L.brute_dam > 0)
			if(L.burn_dam > 0)	//both brute and burn damage detected
				if(L.heal_damage(nutrition_ratio, nutrition_ratio, null, BODYPART_ORGANIC))	//heal both damages
					update_damage_overlays()
				if(prob(1) && sendhealmessage)
					sendhealmessage = FALSE
					to_chat(src, "<span class='notice'>You feel your [L.name]'s bruising and burns recovering slowly.</span>")
			else	//just brute damage detected
				if(L.heal_damage(nutrition_ratio, null, null, BODYPART_ORGANIC))	//heal brute only
					update_damage_overlays()
				if(prob(1) && sendhealmessage)
					sendhealmessage = FALSE
					to_chat(src, "<span class='notice'>You feel your [L.name]'s bruises slowly healing.</span>")
		else if (L.burn_dam > 0)	//just burn damage
			if(L.heal_damage(null, nutrition_ratio, null, BODYPART_ORGANIC))	//heal burn only
				update_damage_overlays()
			if(prob(1) && sendhealmessage)
				sendhealmessage = FALSE
				to_chat(src, "<span class='notice'>You feel your [L.name]'s burns improving slowly.</span>")

/obj/item/organ/liver/on_life()	//healing toxin damage
	. = ..()
	var/mob/living/carbon/C = owner
	var/toxinHealFactor = ((maxHealth - damage) / maxHealth) / 4	//0.25 tox damage heal when at 100 liver health, current % of damage to heal, based on liver damage
	C.adjustToxLoss(-toxinHealFactor, 0)

/obj/item/organ/brain/on_life()	//healing brain damage, inverse curve so higher damage = faster healing rate
	. = ..()
	var/mob/living/carbon/C = owner
	var/brainHealFactor = (1 + (damage * (damage / (maxHealth / 2)))) / maxHealth	//higher healing rate the more damage the brain has, so to fully heal you really should get mannitol. 190 damage = 1.81 healed, 150 damage = 1.13 healed, 100 damage = 0.505 healed, 50 damage = 0.13 healed, 10 damage = 0.01 healed
	C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -brainHealFactor)
