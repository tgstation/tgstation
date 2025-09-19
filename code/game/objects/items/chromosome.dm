/obj/item/chromosome
	name = "blank chromosome"
	icon = 'icons/obj/science/chromosomes.dmi'
	icon_state = ""
	abstract_type = /obj/item/chromosome
	desc = "A tube holding chromosomal data."
	force = 0
	w_class = WEIGHT_CLASS_SMALL

	///If set, this will affect the stability of the mutation, lower is better.
	var/stabilizer_coeff
	///If set, this will affect the chance of backfire, lower is better.
	var/synchronizer_coeff
	///If set, this will affect the overall strength of the mutation, higher is better.
	var/power_coeff //higher is better, affects "strength"
	///If set, this will affect the cooldowns of actions specific to a mutation, lower is better.
	var/energy_coeff

	///The chance of a specific mutation of being generated compared to others when generate_chromosome() is called.
	var/weight = 5

/obj/item/chromosome/proc/can_apply(datum/mutation/mutation)
	if(!mutation || QDELETED(mutation.owner) || mutation.can_chromosome != CHROMOSOME_NONE)
		return FALSE
	if(!isnull(stabilizer_coeff) && (mutation.stabilizer_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE))
		return TRUE
	if(!isnull(synchronizer_coeff) && (mutation.synchronizer_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE))
		return TRUE
	if(!isnull(power_coeff) && (mutation.power_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE))
		return TRUE
	if(!isnull(energy_coeff) && (mutation.energy_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE))
		return TRUE

/obj/item/chromosome/proc/apply(datum/mutation/mutation)
	if(mutation.stabilizer_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE && stabilizer_coeff)
		mutation.stabilizer_coeff = stabilizer_coeff
	if(mutation.synchronizer_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE && synchronizer_coeff)
		mutation.synchronizer_coeff = synchronizer_coeff
	if(mutation.power_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE && power_coeff)
		mutation.power_coeff = power_coeff
	if(mutation.energy_coeff != MUTATION_COEFFICIENT_UNMODIFIABLE && energy_coeff)
		mutation.energy_coeff = energy_coeff
	mutation.can_chromosome = CHROMOSOME_USED
	mutation.chromosome_name = name
	mutation.setup()
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
