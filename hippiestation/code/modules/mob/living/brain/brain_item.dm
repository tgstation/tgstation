/obj/item/organ/brain   //can move this and the applyOrganDamage proc to general organs if we want to set delays for other organs
	var/timeSinceDamaged = 0    //hippie start, passive healing

/obj/item/organ/brain/on_life()
	. = ..()
  var/mob/living/carbon/C = owner
	if(C.passiveHeal)
		passiveBrainHeal()

/obj/item/organ/brain/applyOrganDamage(d, maximum = maxHealth)  //note the time the brain has been damaged
	. = ..()
	timeSinceDamaged = world.time

/obj/item/organ/brain/proc/passiveBrainHeal(var/brainHealFactor, var/extraDelay = 0)	//healing brain damage, inverse curve so higher damage = faster healing rate. can override heal factor to give a different / faster formula. extraDelay to specify extra or less time before being healed if you were damaged recently. -50 = 0 second delay for healing if you got brain damaged
	. = ..()
	var/mob/living/carbon/C = owner
	if(world.time > timeSinceDamaged + 50 + extraDelay)	//start brain healing *only* if it has been more than 5 seconds since last damaged, plus extraDelay
		if(!brainHealFactor)	//allow override if brainHealFactor is manually defined
			brainHealFactor = (1 + (damage * (damage / (maxHealth / 2)))) / maxHealth	//higher healing rate the more damage the brain has, so to fully heal you really should get mannitol. 190 damage = 1.81 healed, 150 damage = 1.13 healed, 100 damage = 0.505 healed, 50 damage = 0.13 healed, 10 damage = 0.01 healed
		C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -brainHealFactor)   //hippie end, passive healing

/obj/item/organ/brain/transfer_identity(mob/living/L)	//hippie start, re-add cloning
	..()
	if(HAS_TRAIT(L, TRAIT_BADDNA))
		brainmob.status_traits[TRAIT_BADDNA] = L.status_traits[TRAIT_BADDNA]
		var/obj/item/organ/zombie_infection/ZI = L.getorganslot(ORGAN_SLOT_ZOMBIE)
		if(ZI)
			brainmob.set_species(ZI.old_species)	//For if the brain is cloned
