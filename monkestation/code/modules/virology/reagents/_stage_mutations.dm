/datum/reagent/toxin/mutagen/mutagenvirusfood/stage_disease_incubate(atom/movable/parent, datum/disease/disease, list/symptoms, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Effect Mutation (Mutagenic Agar)"
	for(var/datum/symptom/listed as anything in symptoms)
		disease.effectmutate(isliving(parent), listed)
		if(istype(parent, /obj/item/weapon/virusdish))
			var/obj/item/weapon/virusdish/dish = parent
			dish.analysed = FALSE
			dish.contained_virus.disease_flags &= ~DISEASE_ANALYZED
			dish.info = "OUTDATED : [dish.info]"
			dish.update_appearance()
			if(machine)
				machine.update_major(parent)

/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar/stage_disease_incubate(atom/movable/parent, datum/disease/disease, list/symptoms, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Effect Chance Strengthing (Sucrose Agar)"
	for(var/datum/symptom/listed as anything in symptoms)
		if((listed.chance == listed.max_chance) && prob(5))
			listed.max_chance = min(listed.max_chance++, 100)
		listed.chance = min(listed.chance + rand(2, 3), listed.max_chance)
		if(istype(parent, /obj/item/weapon/virusdish))
			var/obj/item/weapon/virusdish/dish = parent
			dish.analysed = FALSE
			dish.contained_virus.disease_flags &= ~DISEASE_ANALYZED
			dish.info = "OUTDATED : [dish.info]"
			dish.update_appearance()

/datum/reagent/toxin/plasma/plasmavirusfood/stage_disease_incubate(datum/disease/disease, list/symptoms, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Symptom Multiplier Increase (Virus Rations)"
	for(var/datum/symptom/symptom as anything in symptoms)
		symptom.multiplier_tweak(0.1)

/datum/reagent/medicine/antipathogenic/spaceacillin/stage_disease_incubate(datum/disease/disease, list/symptoms, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Symptom Multiplier Decrease (Spaceacillin)"
	for(var/datum/symptom/symptom as anything in symptoms)
		symptom.multiplier_tweak(-0.1)
