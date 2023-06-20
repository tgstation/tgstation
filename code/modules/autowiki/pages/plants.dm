/*
VARIABLES
	template_data keys
		REQUIRED:
			name       - name of the plant
			icon       - name for the plant's result image file
			seed_name  - name of the plant species
			seed_icon  - name for the plant's result seed image file
		OPTIONAL:
			desc       - description of plant
			genes      - concatenated string seperated by <br>
			reagents   - concatenated string seperated by <br>
			plant_type - only accepts Weed Adaptation and Fungal Vitality
			mutations  - the possible plants this plant can mutate into

INFRASTRUCTURE:
	GrownPlant - template, generates a table entry
	GrownPlantTable - template, generates the table for us to put data in

TODO:
	Plant genes table
	Brewing stats
	Reagent values - try creating object instance and using watch
	Subtemplate reagents and brewing
*/

/datum/autowiki/plants
	page = "Template:Autowiki/Content/Plants"

/datum/autowiki/plants/proc/parse_genes(obj/item/seeds/seed, data)
	var/genes = ""
	var/reagents = ""
	for(var/datum/plant_gene/gene as anything in seed.genes)
		if(gene.type == /datum/plant_gene/reagent)
			reagents += "[gene.name]<br>"
			continue
		if(gene.parent_type == /datum/plant_gene/trait/plant_type)
			data["plant_type"] = escape_value("[gene.name]")
		genes += "[gene.name]<br>"

	if(genes)
		data["genes"] = escape_value(genes)
	if(reagents)
		data["reagents"] = escape_value(reagents)

	return TRUE

/datum/autowiki/plants/proc/parse_mutations(obj/item/seeds/seed, data)
	var/mutations = ""
	for(var/obj/item/seeds/mutated_seed as anything in seed.mutatelist)
		mutations += "[initial(mutated_seed.plantname)]<br>"

	if(mutations != "")
		data["mutations"] = escape_value(mutations)

	return TRUE

/datum/autowiki/plants/generate()
	var/output = ""
	var/list/template_data = list()

	for(var/seed_type in subtypesof(/obj/item/seeds))
		var/obj/item/seeds/plant_seed = new seed_type()
		if(!plant_seed.species)
			continue

		var/filename = SANITIZE_FILENAME(escape_value(plant_seed.species))
		var/seed_filename = "[filename]_seed"

		// Wanted to avoid having to hardcode an exception here but strange seeds use an illegal character in their species name
		if(plant_seed.species == "?????")
			filename = "strange_plant"
			seed_filename = "strange_seed"

		if(plant_seed.product)
			upload_icon(icon(initial(plant_seed.product.icon), initial(plant_seed.product.icon_state), frame = 1), filename)
			template_data["name"] = escape_value(plant_seed.species)
			template_data["icon"] = filename
			template_data["desc"] = escape_value(initial(plant_seed.product.desc))

		upload_icon(getFlatIcon(plant_seed, no_anim = TRUE), seed_filename)

		parse_genes(plant_seed, template_data)
		parse_mutations(plant_seed, template_data)

		template_data["seed_icon"] = seed_filename
		template_data["seed_name"] = escape_value(plant_seed.name)

		output += include_template("Autowiki/GrownPlantTemplate", template_data)

	return output
