/*Polyvitiligo
 * Slight reduction to stealth
 * Greatly increases resistance
 * Slightly increases stage speed
 * Increases transmissibility
 * Critical level
 * Bonus: Makes the mob gain a random crayon powder colorful reagent.
*/
/datum/symptom/polyvitiligo
	name = "Polyvitiligo"
	desc = "The virus replaces the melanin in the skin with reactive pigment."
	illness = "Chroma Imbalance"
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 2
	level = 5
	severity = 1
	symptom_delay_min = 7
	symptom_delay_max = 14

/datum/symptom/polyvitiligo/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(5)
			var/static/list/banned_reagents = list(/datum/reagent/colorful_reagent/powder/invisible, /datum/reagent/colorful_reagent/powder/white)
			var/color = pick(subtypesof(/datum/reagent/colorful_reagent/powder) - banned_reagents)
			if(M.reagents.total_volume <= (M.reagents.maximum_volume/10)) // no flooding humans with 1000 units of colorful reagent
				M.reagents.add_reagent(color, 5)
		else
			if (prob(50)) // spam
				M.visible_message(span_warning("[M] looks rather vibrant..."), span_notice("The colors, man, the colors..."))
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
	symptom_delay_min = 60
	symptom_delay_max = 105
	//prefixes = list("Ovi ")
	//bodies = list("Oviposition", "Nodule")
	//suffixes = list(" Mitosis")
	var/big_heal
	var/all_disease
	var/eggsplosion
	var/sneaky
	threshold_descs = list(
		"Transmission 12" = "Eggs and Egg Sacs contain all diseases on the host, instead of just the disease containing the symptom.",
		"Transmission 16" = "Transmission 16:</b> Egg Sacs will 'explode' into eggs after a period of time, covering a larger area with infectious matter.",
		"Resistance 10" = "Eggs and Egg Sacs contain more healing chems.",
		"Stealth 6" = "Eggs and Egg Sacs become nearly transparent, making them more difficult to see.",
		"Stage Speed 10" = "Egg Sacs fall off the host more frequently."
	)

/datum/symptom/skineggs/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.totalResistance() >= 10)
		big_heal = TRUE
	if(A.totalTransmittable() >= 12)
		all_disease = TRUE
		if(A.totalTransmittable() >= 16)
			eggsplosion = TRUE //Haha get it?
	if(A.totalStealth() >= 6)
		sneaky = TRUE
	if(A.totalStageSpeed() >= 10)
		symptom_delay_min -= 10
		symptom_delay_max -= 20


/datum/symptom/skineggs/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/list/diseases = list(A)
	switch(A.stage)
		if(5)
			if(all_disease)
				for(var/datum/disease/D in M.diseases)
					if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
						continue
					if(D == A)
						continue
					diseases += D
			new /obj/item/food/eggsac(M.loc, diseases, eggsplosion, sneaky, big_heal)

#define EGGSPLODE_DELAY 100 SECONDS
/obj/item/food/eggsac
	name = "Fleshy Egg Sac"
	desc = "A small Egg Sac which appears to be made out of someone's flesh!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "eggsac"
	bite_consumption = 4
	var/list/diseases = list()
	var/sneaky_egg
	var/big_heal

//Constructor
/obj/item/food/eggsac/New(loc, var/list/disease, var/eggsplodes, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/D in disease)
		diseases += D
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
		var/obj/item/I = new /obj/item/food/fleshegg(src.loc, diseases, sneaky_egg, big_heal)
		var/turf/thrown_at = get_ranged_target_turf(I, pick(directions), rand(2, 4))
		I.throw_at(thrown_at, rand(2,4), 4)

/obj/item/food/fleshegg
	name = "Fleshy Egg"
	desc = "An Egg which appears to be made out of someone's flesh!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fleshegg"
	bite_consumption = 1
	var/list/diseases = list()

/obj/item/food/fleshegg/New(loc, var/list/disease, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/D in disease)
		diseases += D
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
