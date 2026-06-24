/// An UI data list for all botany seeds. Used by the botanical encyclopedia.
GLOBAL_LIST_INIT(botany_seed_infos, generate_seed_infos())

/proc/generate_seed_infos()
	var/list/infos = list()

	for (var/obj/item/seeds/seed_type as anything in valid_subtypesof(/obj/item/seeds))
		if (ispath(seed_type, /obj/item/seeds/random))
			continue

		var/obj/item/seeds/seeds = new seed_type

		var/list/info = list()

		info["icon"] = initial(seed_type.growing_icon)
		info["icon_state"] = initial(seed_type.icon_harvest) || "[initial(seed_type.species)]-harvest"
		info["key"] = seed_type
		info["name"] = full_capitalize(initial(seed_type.plantname));
		info["lifespan"] = initial(seed_type.lifespan)
		info["endurance"] = initial(seed_type.endurance)
		info["maturation"] = initial(seed_type.maturation)
		info["production"] = initial(seed_type.production)
		info["yield"] = initial(seed_type.yield)
		info["potency"] = initial(seed_type.potency)
		info["instability"] = initial(seed_type.instability)

		info["traits"] = list()
		info["reagents"] = list()

		info["volume_mod"] = 1
		info["volume_units"] = PLANT_REAGENT_VOLUME

		for (var/datum/plant_gene/gene as anything in seeds.genes)
			if (ispath(gene, /datum/plant_gene/trait))
				info["traits"] += gene
			if (ispath(gene, /datum/plant_gene/reagent))
				var/datum/plant_gene/reagent/reagent = gene
				info["reagents"] += list(list(
					"name" = initial(reagent.name),
					"rate" = initial(reagent.rate)
				))
			if (ispath(gene, /datum/plant_gene/trait/maxchem))
				var/datum/plant_gene/trait/maxchem/volume_mod_trait = gene
				info["volume_mod"] = initial(volume_mod_trait.rate)
			if (ispath(gene, /datum/plant_gene/trait/modified_volume))
				var/datum/plant_gene/trait/modified_volume/volume_unit_trait = gene
				info["volume_units"] = initial(volume_unit_trait.new_capacity)

		for (var/datum/reagent/reagent as anything in seeds.reagents_add)
			info["reagents"] += list(list(
				"name" = initial(reagent.name),
				"rate" = seeds.reagents_add[reagent]
			))

		info["mutatelist"] = list()
		for (var/obj/item/seeds/mutant as anything in seeds.mutatelist)
			info["mutatelist"] += initial(mutant.plantname)

		var/obj/item/product_type = initial(seed_type.product)
		if (ispath(product_type, /obj/item))
			var/obj/item/product = new product_type

			if (istype(product, /obj/item/food/grown))
				var/obj/item/food/grown/grown_product = product

				var/datum/reagent/distill_reagent = grown_product.distill_reagent
				if (ispath(distill_reagent, /datum/reagent))
					info["distill_reagent"] = initial(distill_reagent.name)

				var/datum/reagent/juice_typepath = grown_product.juice_typepath()
				if (ispath(juice_typepath, /datum/reagent))
					info["juice_name"] = initial(juice_typepath.name)

			info["grind_results"] = list()
			for (var/datum/reagent/result as anything in product.grind_results())
				info["grind_results"] += initial(result.name)

			qdel(product)

		infos += list(info)
		qdel(seeds)

	return infos
