/obj/item/chromosome
	name = "blank chromosome"
	icon = 'icons/obj/science/chromosomes.dmi'
	icon_state = ""
	desc = "A tube holding chromosomal data."
	force = 0
	w_class = WEIGHT_CLASS_SMALL

	var/stabilizer_coeff = 1 //lower is better, affects genetic stability
	var/synchronizer_coeff = 1 //lower is better, affects chance to backfire
	var/power_coeff = 1 //higher is better, affects "strength"
	var/energy_coeff = 1 //lower is better. affects recharge time

	var/weight = 5

/obj/item/chromosome/proc/can_apply(datum/mutation/human/HM)
	if(!HM || !(HM.can_chromosome == CHROMOSOME_NONE))
		return FALSE
	if((stabilizer_coeff != 1) && (HM.stabilizer_coeff != -1)) //if the chromosome is 1, we don't change anything. If the mutation is -1, we can't change it. sorry
		return TRUE
	if((synchronizer_coeff != 1) && (HM.synchronizer_coeff != -1))
		return TRUE
	if((power_coeff != 1) && (HM.power_coeff != -1))
		return TRUE
	if((energy_coeff != 1) && (HM.energy_coeff != -1))
		return TRUE

/obj/item/chromosome/proc/apply(datum/mutation/human/HM)
	if(HM.stabilizer_coeff != -1)
		HM.stabilizer_coeff = stabilizer_coeff
	if(HM.synchronizer_coeff != -1)
		HM.synchronizer_coeff = synchronizer_coeff
	if(HM.power_coeff != -1)
		HM.power_coeff = power_coeff
	if(HM.energy_coeff != -1)
		HM.energy_coeff = energy_coeff
	HM.can_chromosome = CHROMOSOME_USED
	HM.chromosome_name = name

	// Do the actual modification
	if(HM.modify())
		HM.modified = TRUE

	qdel(src)

/proc/generate_chromosome()
	var/static/list/chromosomes
	if(!chromosomes)
		chromosomes = list()
		for(var/A in subtypesof(/obj/item/chromosome))
			var/obj/item/chromosome/CM = A
			if(!initial(CM.weight))
				break
			chromosomes[A] = initial(CM.weight)
	return pick_weight(chromosomes)


/obj/item/chromosome/stabilizer
	name = "stabilizer chromosome"
	desc = "A chromosome that reduces mutation instability by 20%."
	icon_state = "stabilizer"
	stabilizer_coeff = 0.8
	weight = 1

/obj/item/chromosome/synchronizer
	name = "synchronizer chromosome"
	desc = "A chromosome that reduces mutation knockback and downsides by 50%."
	icon_state = "synchronizer"
	synchronizer_coeff = 0.5

/obj/item/chromosome/power
	name = "power chromosome"
	desc = "A chromosome that increases mutation power by 50%."
	icon_state = "power"
	power_coeff = 1.5

/obj/item/chromosome/energy
	name = "energetic chromosome"
	desc = "A chromosome that reduces action based mutation cooldowns by 50%."
	icon_state = "energy"
	energy_coeff = 0.5
