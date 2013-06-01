
obj/machinery/anomaly/hyperspectral
	name = "Hyperspectral Imager"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "scanner"

obj/machinery/anomaly/hyperspectral/process()
	..()
	if(scan_process)
		icon_state = "scanner_active"
	else if(prob(10))
		icon_state = "scanner"
		flick(src, "scanner_active")

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
		results = "Spectral signature over carrier ([carrier]):<br>"
		if(specifity <= 0.25)
			//results += "<img src=\"http://i.imgur.com/TAQHn.jpg\"></img><br>"
			results += "<img src=chart1.jpg>"
		else if(specifity <= 0.5)
			//results += "<img src=\"http://i.imgur.com/EwOZ7.jpg\"></img><br>"
			results += "<img src=chart2.jpg>"
		else if(specifity <= 0.75)
			//results += "<img src=\"http://i.imgur.com/1qCae.jpg\"></img><br>"
			results += "<img src=chart3.jpg>"
		else
			//results += "<img src=\"http://i.imgur.com/9T9nc.jpg\"></img><br>"
			results += "<img src=chart4.jpg>"

		results += "<br>"
		if(scanned_sample.artifact_id)
			results += "Detected energy signatures [100 * (1 - specifity)]% consistent with standard background readings.<br>"
			if(prob( (specifity + 0.5 * (1 - specifity)) * 100))
				results += "Anomalous exotic energy signature isolated: <font color='red'><b>[scanned_sample.artifact_id].</b></font>"
		else
			results += "Detected energy signatures [95 + 5 * (2 * rand() - 1) * (1 - specifity)]% consistent with standard background readings."

	return results
