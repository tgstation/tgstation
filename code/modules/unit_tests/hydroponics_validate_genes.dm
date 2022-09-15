/// Unit test to ensure plants don't have multiple of a plant type at once by default.
/datum/unit_test/hydroponics_validate_genes

/datum/unit_test/hydroponics_validate_genes/Run()
	var/list/all_seeds = subtypesof(/obj/item/seeds)

	for(var/seed in all_seeds)
		var/obj/item/seeds/instantiated_seed = new seed()

		var/all_trait_ids_we_have = NONE
		for(var/datum/plant_gene/trait/trait_gene in instantiated_seed.genes)
			// Check if our seed is blacklisted from this trait.
			for(var/blacklisted_type in trait_gene.seed_blacklist)
				if(!istype(instantiated_seed, blacklisted_type))
					continue
				TEST_FAIL("[instantiated_seed] - [instantiated_seed.type] has a gene which blacklists its type. (Bad gene: [trait_gene] - [trait_gene.type])")

			// Check if we already have a trait id from another trait.
			if(all_trait_ids_we_have & trait_gene.trait_ids)
				TEST_FAIL("[instantiated_seed] - [instantiated_seed.type] has an invalid default gene configuration. (Found on: [trait_gene] - [trait_gene.type])")

			all_trait_ids_we_have |= trait_gene.trait_ids

			// Check if we have duplicate traits.
			for(var/datum/plant_gene/trait/other_trait_gene in instantiated_seed.genes - trait_gene)
				// Have to check for type exact, since subtypes may be valid with one another.
				if(trait_gene.type != other_trait_gene.type)
					continue
				TEST_FAIL("[instantiated_seed] - [instantiated_seed.type] has a duplicate gene. (Duped gene: [trait_gene] - [trait_gene.type])")

		qdel(instantiated_seed)
