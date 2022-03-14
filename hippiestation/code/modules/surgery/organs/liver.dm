/obj/item/organ/liver/on_life() //hippie start, passive healing
	. = ..()
	var/mob/living/carbon/C = owner
	if(C.passiveHeal)
		passiveLiverHeal()

/obj/item/organ/liver/proc/passiveLiverHeal(var/toxinHealFactor)	//healing toxin damage and managing liver damage. parse a number or formula for toxinHealFactor if you want to override the default
	. = ..()    //hippie end, passive healing
	var/mob/living/carbon/C = owner
	if(C.getToxLoss())	//don't bother if there isn't any toxin damage?
		if((maxHealth - damage) > (maxHealth / 5))	//don't trade toxloss for organ damage if the poor liver is already hopelessly damaged
			if(!toxinHealFactor)	//allow override if toxinHealFactor is manually defined
				toxinHealFactor = ((maxHealth - damage) / maxHealth) / 4	//0.25 tox damage heal when at 100 liver health, current % of damage to heal, based on liver damage
			C.adjustToxLoss(-toxinHealFactor, FALSE, FALSE)
			C.adjustOrganLoss(ORGAN_SLOT_LIVER, toxinHealFactor)
	else
		C.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.1)	//organs only normally heal at 0.001 per tick??? wtf? too little for the liver, so this extra amount to heal added
