
obj/machinery/anomaly/hyperspectral
	name = "Hyperspectral Imager"
	desc = "A specialised, complex analysis machine."
	icon = 'icons/obj/computer.dmi'
	icon_state = "rdcomp"

obj/machinery/anomaly/hyperspectral/ScanResults()
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
		var/specifity = GetResultSpecifity(scanned_sample, carrier)
		results = "Spectral signature over carrier ([carrier], [specifity]):<br>"
		results += "<img src=\"http://i.imgur.com/YAcOE.jpg\"></img><br>"
		if(scanned_sample.artifact_id && prob(specifity * 100))
			results += "Anomalous exotic energy signature detected: [scanned_sample.artifact_id]."

	return results
