
// This machine shows the amount of a certain material that is present

obj/machinery/anomaly/ion_mobility
	name = "Ion Mobility Spectrometer"
	desc = "A specialised, complex analysis machine."
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"

obj/machinery/anomaly/ion_mobility/ScanResults()
	var/results = "The scan was inconclusive. Check sample integrity and carrier consistency."

	var/datum/geosample/scanned_sample
	var/carrier
	var/num_reagents = 0

	for(var/datum/reagent/A in held_container.reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/analysis_sample))
			scanned_sample = R.data
		else
			carrier = R.id
		num_reagents++

	if(num_reagents == 2 && scanned_sample && carrier)
		//all necessary components are present
		results = "Kinetic analysis on sample's ionic residue in carrier ([carrier]) indicates the dissonance spread:<br><br>"
		var/found = 0
		if(scanned_sample.find_presence.Find(carrier))
			var/dis_ratio = scanned_sample.find_presence[carrier]
			var/desc_index = responsive_carriers.Find(carrier)
			results += " - [finds_as_strings[desc_index]]: [dis_ratio]<br>"
			found++
		/*
		for(var/index=1,index <= scanned_sample.find_presence.len, index++)
			var/find = scanned_sample.find_presence[index]
			//world << "index: [index], find: [find], response: [responsive_carriers[index]], carrier: [carrier]"
			if(find && responsive_carriers[index] == carrier)
				results += " - [finds_as_strings[index]] [find * 100]%<br>"
				found++
				*/
		if(!found)
			results = "Kinetic analysis on sample's ionic residue in carrier ([carrier]) to determine composition were inconclusive.<br>"
		if(carrier == scanned_sample.source_mineral)
			results += "Warning, analysis may be contaminated by high quantities of molecular carrier present throughout sample."

	return results
