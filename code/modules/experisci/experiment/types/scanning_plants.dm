/datum/experiment/scanning/random/plants
	name = "Botanical Scanning Experiment"
	description = "Base experiment for scanning edible plant biomass."
	exp_tag = "Plant Biomatter Scan"
	total_requirement = 1
	possible_types = list(/obj/item/food/grown)
	traits = EXPERIMENT_TRAIT_DESTRUCTIVE
	///List of possible plant genes the experiment may ask for.
	var/list/possible_plant_genes = list()
	///List of plant genes actually required, indexed by the atom that is required.
	var/list/required_genes = list()

/datum/experiment/scanning/random/plants/New()
	. = ..()
	if(possible_plant_genes.len)
		for(var/req_atom in required_atoms)
			var/chosen_gene = pick(possible_plant_genes)
			required_genes[req_atom] = chosen_gene

/datum/experiment/scanning/random/plants/serialize_progress_stage(atom/target, list/seen_instances)
	return EXPERIMENT_PROG_INT("Scan samples of a harvested plant.", \
		traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target])

/datum/experiment/scanning/random/plants/traits/final_contributing_index_checks(atom/target, typepath)
	if(!istype(target, /obj/item/food/grown))
		return FALSE
	var/obj/item/food/grown/crop = target
	if(possible_plant_genes.len)
		return ..() && crop.seed.get_gene(required_genes[typepath])
	return ..()

/datum/experiment/scanning/random/plants/traits/serialize_progress_stage(atom/target, list/seen_instances)
	if(possible_plant_genes.len)
		var/datum/plant_gene/gene = required_genes[target]
		return EXPERIMENT_PROG_INT("Scan samples of harvested plants with the trait: [initial(gene.name)].", \
			traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target])

/datum/experiment/scanning/random/plants/wild/final_contributing_index_checks(atom/target, typepath)
	return ..() && HAS_TRAIT(target, TRAIT_PLANT_WILDMUTATE)
