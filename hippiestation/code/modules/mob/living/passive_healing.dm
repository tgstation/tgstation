/mob/living/carbon/human/proc/passive_healing(/mob/living/carbon/human/H)
	//ADD CALLBACK WITH RANDOM TIMER TO SIMULATE EVERYONE'S DIFFERENT RATE OF HEALING, OR TO DESYNC THE LOAD TO DIVERT LAG SPIKES
		/var/healDesyncTimer = rand(1,5)
		//clone loss will be healed at a factor of 0.1 compared to everything else, you should really get into cryo
		//link the relevant damages into their organs or just put it here? hmm




		if(blood_volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER))
			var/nutrition_ratio = 0
			switch(nutrition)
				if(0 to NUTRITION_LEVEL_STARVING)
					nutrition_ratio = 0.2
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					nutrition_ratio = 0.4
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					nutrition_ratio = 0.6
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					nutrition_ratio = 0.8
				else
					nutrition_ratio = 1
			if(satiety > 80)
				nutrition_ratio *= 1.25
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR)
			blood_volume = min(BLOOD_VOLUME_NORMAL, blood_volume + 0.5 * nutrition_ratio)



/obj/item/organ/liver/on_life()	//so this won't work if the liver is failing
	var/mob/living/carbon/C = owner
	..()
	var/toxinHealFactor = ((maxHealth - damage) / maxHealth) / 2	//0.5 tox damage heal when at 100 liver health, current % of damage to heal, based on liver damage. in theory at some point liver damage will cascade into failure, despite the heal rate
	C.adjustToxLoss(-toxinHealFactor, 0)

							((100 - 10) / 100) / 2

/obj/item/organ/brain/on_life()
	var/mob/living/carbon/C = owner
	..()
	var/brainHealFactor = ((maxHealth + damage) / ((maxHealth + 1) - damage))  1.5	//higher healing rate the more damage the brain has, so to fully heal you really should get mannitol. simulates brain
							((200 + 150) / (200 / (150 / 10)))	//26.25
							((200 + 100) / (200 / (100 / 10)))	//15
							((200 + 50) / (200 / (50 / 10)))	//6.25
							((200 + 10) / (200 / (10 / 10)))	//1.05
