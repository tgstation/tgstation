/// Returns a list of seed data generated from the given seeds.
/// Filling the "name", "icon" and "icon_state" fields of the data is the caller's responsibility.
/proc/generate_seed_data_from(obj/item/seeds/seeds)
	var/list/seed_data = list()

	seed_data["lifespan"] = seeds.lifespan
	seed_data["endurance"] = seeds.endurance
	seed_data["maturation"] = seeds.maturation
	seed_data["production"] = seeds.production
	seed_data["yield"] = seeds.yield
	seed_data["potency"] = seeds.potency
	seed_data["instability"] = seeds.instability

	seed_data["traits"] = list()
	for(var/datum/plant_gene/trait/trait in seeds.genes)
		seed_data["traits"] += trait.type

	seed_data["reagents"] = list()
	for(var/datum/plant_gene/reagent/reagent in seeds.genes)
		seed_data["reagents"] += list(list(
			"name" = reagent.name,
			"rate" = reagent.rate
		))

	var/datum/plant_gene/trait/maxchem/volume_mod_trait = locate(/datum/plant_gene/trait/maxchem) in seeds.genes
	seed_data["volume_mod"] = volume_mod_trait ? volume_mod_trait.rate : 1

	var/datum/plant_gene/trait/modified_volume/volume_unit_trait = locate(/datum/plant_gene/trait/modified_volume) in seeds.genes
	seed_data["volume_units"] = volume_unit_trait ? volume_unit_trait.new_capacity : PLANT_REAGENT_VOLUME

	seed_data["mutatelist"] = list()
	for(var/obj/item/seeds/mutant as anything in seeds.mutatelist)
		seed_data["mutatelist"] += initial(mutant.plantname)

	if(ispath(seeds.product, /obj/item))
		var/obj/item/product = new seeds.product

		seed_data["grind_results"] = list()
		for(var/datum/reagent/reagent as anything in product.grind_results())
			seed_data["grind_results"] += initial(reagent.name)

		if(istype(product, /obj/item/food/grown))
			var/obj/item/food/grown/grown_product = product

			var/datum/reagent/distill_reagent = grown_product.distill_reagent
			if (ispath(distill_reagent, /datum/reagent))
				seed_data["distill_reagent"] = initial(distill_reagent.name)

			var/datum/reagent/juice_reagent = grown_product.juice_typepath()
			if (ispath(juice_reagent, /datum/reagent))
				seed_data["juice_name"] = initial(juice_reagent.name)

		qdel(product)

	return seed_data
