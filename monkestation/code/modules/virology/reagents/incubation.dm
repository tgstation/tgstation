/datum/reagent/proc/disease_incubate(atom/movable/parent, datum/disease/disease, obj/machinery/disease2/incubator/machine)
	return

/datum/reagent/proc/stage_disease_incubate(datum/disease/disease, list/symptoms, obj/machinery/disease2/incubator/machine)
	return


/datum/reagent/medicine/antipathogenic/spaceacillin/disease_incubate(atom/movable/parent, datum/disease/disease, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Weakening (/datum/reagent/medicine/antipathogenic/spaceacillin in [parent])"
	var/change = rand(1,5)
	disease.strength = max(0, disease.strength - change)
	if(machine)
		machine.update_minor(parent,-change)

/datum/reagent/medicine/synaptizine/synaptizinevirusfood/disease_incubate(atom/movable/parent, datum/disease/disease, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Strengthening (Virus Plasma in [parent])"
	var/change = rand(1,5)
	disease.strength = min(100, disease.strength + change)
	if(machine)
		machine.update_minor(parent, change)

/datum/reagent/uranium/uraniumvirusfood/unstable/disease_incubate(atom/movable/parent, datum/disease/disease, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Antigen Mutation (Unstable Uranium Gel in [parent])"
	disease.antigenmutate()
	if(istype(parent, /obj/item/weapon/virusdish))
		var/obj/item/weapon/virusdish/dish = parent
		dish.analysed = FALSE
		dish.contained_virus.disease_flags &= ~DISEASE_ANALYZED
		dish.info = "OUTDATED : [dish.info]"
		dish.update_appearance()
	if(machine)
		machine.update_major(parent)

/datum/reagent/uranium/uraniumvirusfood/disease_incubate(atom/movable/parent, datum/disease/disease, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Robustness Decrease (Decaying Uranium Gel in [parent])"
	var/change = rand(1,5)
	disease.robustness = max(0, disease.robustness - change)
	if(machine)
		machine.update_minor(parent,-change)

/datum/reagent/uranium/uraniumvirusfood/stable/disease_incubate(atom/movable/parent, datum/disease/disease, obj/machinery/disease2/incubator/machine)
	disease.log += "<br />[ROUND_TIME()] Robustness Strengthening (Stable Uranium Gel in [parent])"
	var/change = rand(1,5)
	disease.robustness = min(100, disease.robustness + change)
	if(machine)
		machine.update_minor(machine, 0, change, 0.1)
