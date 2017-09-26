/datum/reagent/consumable/berryjuice/on_mob_life(mob/living/M)
	if(prob(25))
		M.reagents.add_reagent("vitamin",0.8)
	..()
	
/datum/reagent/consumable/watermelonjuice/on_mob_life(mob/living/M)
	M.adjustCloneLoss(-0.4, 0) //pretty slow, you're really better off using cryox/clonex
	. = 1
	..()
	
/datum/reagent/consumable/potato_juice/on_mob_life(mob/living/M)
	M.adjustStaminaLoss(-0.5*REM, 0)
	..()
	
/datum/reagent/consumable/cherryshake/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar",1.2)
	..()
	
/datum/reagent/consumable/bluecherryshake/reaction_mob(mob/living/M)
	M.reagents.add_reagent("sugar",2)
	..()
	
/datum/reagent/consumable/gibbfloats/on_mob_life(mob/living/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (8 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	. = 1
	
/datum/reagent/consumable/triple_citrus/on_mob_life(mob/living/M)
	if(M.getOxyLoss() && prob(75))
		M.adjustOxyLoss(-1, 0)
	if(M.getFireLoss() && prob(75))
		M.adjustFireLoss(-1, 0)
	if(M.getBruteLoss() && prob(75))
		M.adjustBruteLoss(-1, 0)
	. = 1
	..()