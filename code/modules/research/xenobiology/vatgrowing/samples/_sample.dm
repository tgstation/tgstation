///This datum is a simple holder for the micro_organisms in a sample.
/datum/biological_sample
	///List of all micro_organisms in the sample
	var/list/micro_organisms = list()
	///Prevents someone from stacking too many layers onto a swabber
	var/sample_layers = 1

///Gets info from each of it's micro_organisms.
/datum/biological_sample/proc/GetAllDetails()
	var/info
	for(var/i in micro_organisms)
		var/datum/micro_organism/MO = i
		info += "<span class='notice'>[MO.desc]</span>"
	return info

///Generate a sample from a specific weighted list, and a specific amount of cell line with a chance for a virus
/datum/biological_sample/proc/GenerateSample(cell_line_define, virus_define, cell_line_amount, virus_chance)
	//Temp list to prevent double picking
	var/list/temp_weight_list = GLOB.cell_line_tables[cell_line_define]
	for(var/i in cell_line_amount)
		var/datum/micro_organism/chosen_type = pickweight(temp_weight_list)
		temp_weight_list -= chosen_type
		micro_organisms += new chosen_type
	if(virus_chance)
		micro_organisms += pickweight(GLOB.cell_virus_tables[virus_define])


/datum/biological_sample/proc/Merge(var/datum/biological_sample/other_sample)
	if(sample_layers >= 3)//No more than 3 layers, at that point you're entering danger zone.
		return FALSE
	micro_organisms += other_sample.micro_organisms
	qdel(other_sample)
	return TRUE
