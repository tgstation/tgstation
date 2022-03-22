///This datum is a simple holder for the micro_organisms in a sample.
/datum/biological_sample
	///List of all micro_organisms in the sample. These are instantiated
	var/list/micro_organisms = list()
	///Prevents someone from stacking too many layers onto a swabber
	var/sample_layers = 1
	///Picked from a specific group of colors, limited to a specific group.
	var/sample_color = COLOR_SAMPLE_YELLOW

///Generate a sample from a specific weighted list, and a specific amount of cell line with a chance for a virus
/datum/biological_sample/proc/GenerateSample(cell_line_define, virus_define, cell_line_amount, virus_chance)
	sample_color = pick(GLOB.xeno_sample_colors)

	var/list/temp_weight_list = GLOB.cell_line_tables[cell_line_define].Copy() //Temp list to prevent double picking
	for(var/i in 1 to cell_line_amount)
		var/datum/micro_organism/chosen_type = pick_weight(temp_weight_list)
		temp_weight_list -= chosen_type
		micro_organisms += new chosen_type
	if(prob(virus_chance))
		if(!GLOB.cell_virus_tables[virus_define])
			return
		var/datum/micro_organism/chosen_type = pick_weight(GLOB.cell_virus_tables[virus_define])
		micro_organisms += new chosen_type

///Takes another sample and merges it into use. This can cause one very big sample but we limit it to 3 layers.
/datum/biological_sample/proc/Merge(datum/biological_sample/other_sample)
	if(sample_layers >= 3)//No more than 3 layers, at that point you're entering danger zone.
		return FALSE
	micro_organisms += other_sample.micro_organisms
	qdel(other_sample)
	return TRUE

///Call handle_growth on all our microorganisms.
/datum/biological_sample/proc/handle_growth(obj/machinery/plumbing/growing_vat/vat)
	for(var/datum/micro_organism/cell_line/organism in micro_organisms) //Types because we don't grow viruses.
		organism.handle_growth(vat)

///resets the progress of all cell ines
/datum/biological_sample/proc/reset_sample()
	for(var/datum/micro_organism/cell_line/organism in micro_organisms) //Types because we don't grow viruses.
		organism.growth = 0
