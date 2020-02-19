///This datum is a simple holder for the micro_organisms in a sample.
/datum/biological_sample
	var/list/micro_organisms = list()

///Gets info from each of it's micro_organisms.
/datum/biological_sample/proc/GetAllDetails()
	var/info
	for(var/i in micro_organisms)
		var/datum/micro_organism/MO = i
		info += "<span class='notice'>[MO.desc]</span>"
	return info

/datum/biological_sample/proc/Merge(/datum/biological_sample/other_sample)
	micro_organisms += other_sample.micro_organisms
