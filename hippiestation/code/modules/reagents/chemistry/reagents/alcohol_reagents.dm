/datum/reagent/consumable/ethanol/impalco
	name = "Impure Superhol"
	id = "impalco"
	description = "An impure solution of superhol, still very strong!"
	color = "#CAD15A"
	boozepwr = 100
	taste_description = "brain damage"
	glass_name = "Cloudy Superhol"
	glass_desc = "Despite being obviously impure and revolting the vapours are still intense enough to make you feel tipsy"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/consumable/ethanol/alco
	name = "Superhol"
	id = "alco"
	description = "An incredibly potent form of synthetic ethanol"
	color = "#CAD15A"
	boozepwr = 350
	taste_description = "brain death"
	taste_mult = 2
	glass_name = "Superhol"
	glass_desc = "Just looking at it is making you dizzy!"

/datum/reagent/consumable/ethanol/alco/on_mob_life(mob/living/carbon/M)
	if(istype(M))
		switch(current_cycle)
			if(1 to 15)
				M.adjustBrainLoss(3)
				if(prob(15))
					M.vomit(20)
			if(20 to INFINITY)
				M.adjustBrainLoss(5)
				if(prob(30))
					M.vomit(20, 0, 8)
					if(prob(10))
						M.spew_organ()
	..()

/datum/reagent/consumable/ethanol/isopropyl
	name = "Isopropyl alcohol"
	id = "isopropyl"
	description = "Can make you sick and drunk at the same time. Amazing!"
	color = "#C8A5DC"

/datum/reagent/consumable/ethanol/isoproyl/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	..()