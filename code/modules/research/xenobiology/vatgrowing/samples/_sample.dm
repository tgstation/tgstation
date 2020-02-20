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
/datum/biological_sample/proc/GenerateSample(list/micro_organism_weightlist = list(), var/cell_line_amount, var/virus_chance)
	//Temp list to prevent double picking
	var/list/temp_weight_list = micro_organism_weightlist
	for(var/i in temp_weight_list)

/datum/biological_sample/proc/Merge(/datum/biological_sample/other_sample)
	if(sample_layers >= 3)//No more than 3 layers, at that point you're entering danger zone.
		return FALSE
	micro_organisms += other_sample.micro_organisms
	return TRUE
