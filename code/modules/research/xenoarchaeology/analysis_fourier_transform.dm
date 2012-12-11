
obj/machinery/anomaly/fourier_transform
	name = "Fourier Transform spectroscope"
	desc = "A specialised, complex analysis machine."
	icon = 'virology.dmi'
	icon_state = "analyser"

obj/machinery/anomaly/fourier_transform/ScanResults()
	var/results = "The scan was inconclusive. Check sample integrity and carrier consistency."

	var/datum/geosample/scanned_sample
	var/carrier
	var/num_reagents = 0

	for(var/reagent/A in held_container.reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R,datum/reagent/density_separated_liquid))
			scanned_sample = R.data
		else if(istype(R,datum/reagent/analysis_sample))
			scanned_sample = R.data
		else
			carrier = R.type
		num_reagents++

	if(num_reagents == 2 && scanned_sample && carrier)
		//all necessary components are present
		var/specifity = GetResultSpecifity(scanned_sample, carrier)
		var/distance = scanned_sample.artifact_distance
		if(specifity > 0.6)
			artifact_distance += rand(-0.1, 0.1) * artifact_distance
		else
			var/offset = 1 - specifity
			artifact_distance += rand(-offset, offset) * artifact_distance
		results = "Anomalous energy absorption through carrier ([carrier.id]) indicates emission radius: [artifact_distance]"

	return results
