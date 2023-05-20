/************************************
Dermagraphic Ovulogenesis

	Extremely Noticeable
	Increases resistance slightly.
	Not Fast, Not Slow
	Transmittable.
	High Level

BONUS
	Provides Brute Healing when Egg Sacs/Eggs are eaten, simultaneously infecting anyone who eats them

***********************************/

/datum/symptom/skineggs //Thought Exolocomotive Xenomitosis was a weird symptom? Well, this is about 10x weirder.
	name = "Dermagraphic Ovulogenesis"
	desc = "The virus causes the host to grow egg-like nodules on their skin, which periodically fall off and contain the disease and some healing chemicals."
	stealth = -3 //You are basically growing these weird Egg shits on your skin, this is not stealthy in the slightest
	resistance = 1
	stage_speed = 0
	transmittable = 2 //The symptom is in it of itself meant to spread
	level = 8
	severity = -1
	base_message_chance = 50
	symptom_delay_min = 80
	symptom_delay_max = 145
	var/big_heal
	var/all_disease
	var/eggsplosion
	var/sneaky
	threshold_descs = list(
		"Transmission 8" = "Eggs and Egg Sacs contain all diseases on the host, instead of just the disease containing the symptom.",
		"Transmission 12" = "Egg Sacs will 'explode' into eggs after a period of time, covering a larger area with infectious matter.",
		"Resistance 8" = "Eggs and Egg Sacs contain more healing chems.",
		"Stealth 5" = "Eggs and Egg Sacs become nearly transparent, making them more difficult to see.",
		"Stage Speed 8" = "Egg Sacs fall off the host more frequently."
	)

/datum/symptom/skineggs/Start(datum/disease/advance/advanced_disease)
	if(!..())
		return
	if(advanced_disease.totalResistance() >= 8)
		big_heal = TRUE
	if(advanced_disease.totalTransmittable() >= 8)
		all_disease = TRUE
		if(advanced_disease.totalTransmittable() >= 12)
			eggsplosion = TRUE //Haha get it?
	if(advanced_disease.totalStealth() >= 5)
		sneaky = TRUE
	if(advanced_disease.totalStageSpeed() >= 8)
		symptom_delay_min -= 10
		symptom_delay_max -= 20


/datum/symptom/skineggs/Activate(datum/disease/advance/advanced_disease)
	if(!..())
		return
	var/mob/living/carbon/victim = advanced_disease.affected_mob
	var/list/diseases = list(advanced_disease)
	switch(advanced_disease.stage)
		if(5)
			if(all_disease)
				//for(var/datum/disease/variable55 in victim.diseases)
					//if((variable55.spread_flags & DISEASE_SPREAD_SPECIAL) || (variable55.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
					//	continue
					//if(variable55 == advanced_disease)
					//	continue
				//diseases += variable55
				new /obj/item/food/eggsac(victim.loc, diseases, eggsplosion, sneaky, big_heal)

#define EGGSPLODE_DELAY 100 SECONDS
/obj/item/food/eggsac
	name = "Fleshy Egg Sac"
	desc = "A small Egg Sac which appears to be made out of someone's flesh!"
	icon = 'monkestation/icons/obj/food/food.dmi'
	icon_state = "eggsac"
	bite_consumption = 4
	var/list/diseases = list()
	var/sneaky_egg
	var/big_heal

//Constructor
/obj/item/food/eggsac/New(loc, var/list/disease, var/eggsplodes, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/variable55 in disease)
		diseases += variable55
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 20, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
		big_heal = TRUE
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 10, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "eggsac-sneaky"
		sneaky_egg = sneaky
	if(eggsplodes)
		addtimer(CALLBACK(src, .proc/eggsplode), EGGSPLODE_DELAY)
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)

#undef EGGSPLODE_DELAY

/obj/item/food/eggsac/proc/eggsplode()
	for(var/i = 1, i <= rand(4,8), i++)
		var/list/directions = GLOB.alldirs
		var/obj/item/eggs = new /obj/item/food/fleshegg(src.loc, diseases, sneaky_egg, big_heal)
		var/turf/thrown_at = get_ranged_target_turf(eggs, pick(directions), rand(2, 4))
		eggs.throw_at(thrown_at, rand(2,4), 4)

/obj/item/food/fleshegg
	name = "Fleshy Egg"
	desc = "An Egg which appears to be made out of someone's flesh!"
	icon = 'monkestation/icons/obj/food/food.dmi'
	icon_state = "fleshegg"
	bite_consumption = 1
	var/list/diseases = list()

/obj/item/food/fleshegg/New(loc, var/list/disease, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/variable55 in disease)
		diseases += variable55
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 20, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/c2/probital = 10, /datum/reagent/medicine/granibitaluri = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "fleshegg-sneaky"
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)
