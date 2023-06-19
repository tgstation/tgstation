/*
TEMPLATES AND VARIABLES
GrownPlantTemplate
	REQUIRED:
		seed_name - name of the plant species
		seed_icon - name for the plant's result seed image file
	OPTIONAL:
		name - name of the plant
		icon - name for the plant's result image file
		desc - description of plant
		genes - the genes the plant has by default, amounts are not specified because they are not static
		mutations - the possible plants this plant can mutate into

TODO:
	Create metatemplate that lays out all data into one contiguous table automatically
	Seperate code into functions, make formatting smarter so we don't have a trailing <br>
	Implement content table for genes, make all plant genes reference this table
	Filter out "reagent genes" and link to appropriate area of chemistry guide for each
	Make sure the plants list is exhaustive, should contain every plant in the game
	Find out how to do as little formatting as possible, we want all UX to happen on the wiki
*/

/datum/autowiki/plants
	page = "Template:Autowiki/Content/Plants"

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

		var/genes = ""
		for(var/datum/plant_gene/gene as anything in plant_seed.genes)
			genes += "[gene.name]<br>"

		var/mutations = ""
		for(var/obj/item/seeds/mutated_seed as anything in plant_seed.mutatelist)
			mutations += "[initial(mutated_seed.plantname)]<br>"

		template_data["seed_icon"] = seed_filename
		template_data["seed_name"] = escape_value(plant_seed.name)
		if(genes != "")
			template_data["genes"] = escape_value(genes)
		if(mutations != "")
			template_data["mutations"] = escape_value(mutations)

		output += include_template("Autowiki/GrownPlantTemplate", template_data)

	return output
