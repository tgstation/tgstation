
obj/machinery/anomaly/gas_chromatography
	name = "Gas Chromatography Spectrometer"
	desc = "A specialised, complex analysis machine."
	icon = 'virology.dmi'
	icon_state = "analyser"

obj/machinery/anomaly/gas_chromatography/ScanResults()
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
		results = "Carrier ([carrier.id]) specifity: [GetResultSpecifity(scanned_sample, carrier)]"

	return results

obj/machinery/anomaly/proc/GetResultSpecifity(var/datum/geosample/scanned_sample, var/datum/reagent/carrier)
	var/specifity = 0
	if(scanned_sample && carrier)
		var/threshold = 0.6

		if(scanned_sample.main_find == carrier.id)
			specifity += threshold + rand(0, 1 - threshold)
		if(scanned_sample.secondary_find == carrier.id)
			specifity += threshold + rand(0, 1 - threshold)

		/*
		//check the main turf
		if(scanned_sample.main_find == FIND_NOTHING)
			//nothing?
		else if(scanned_sample.main_find == FIND_PLANT || scanned_sample.main_find == FIND_BIO  || scanned_sample.main_find == FIND_SKULL)
			//preserved plant or animal
			if(carrier.id == "carbon")
				specifity += threshold + rand(0,1 - threshold)
		else if(scanned_sample.main_find == FIND_METEORIC)
			//deep space
			if(carrier.id == "neon")
				specifity += threshold + rand(0,1 - threshold)
		else if(scanned_sample.main_find == FIND_ICE)
			//solid h20
			if(carrier.id == "beryllium")
				specifity += threshold + rand(0,1 - threshold)
		else if(scanned_sample.main_find == FIND_IGNEOUS || scanned_sample.main_find == FIND_METAMORPHIC || scanned_sample.main_find == FIND_CARBONATE)
			//rock
			if(carrier.id == "calcium" || carrier.id == "chlorine")
				specifity += threshold + rand(0,1 - threshold)
		else if(scanned_sample.main_find == FIND_CRYSTALLINE)
			//some kind of refractive, crystalline matter
			if(carrier.id == "helium")
				specifity += threshold + rand(0,1 - threshold)
		else if(scanned_sample.main_find == FIND_METALLIC)
			//something metal (could be just ores, not necessarily a synthetic artifact)
			if(carrier.id == "silicon")
				specifity += threshold + rand(0,1 - threshold)
		else if(scanned_sample.main_find == FIND_SEDIMENTARY)
			//sandy rock
			if(carrier.id == "aluminium")
				specifity += threshold + rand(0,1 - threshold)
		*/

	if(specifity > 1)
		specifity = 0.9 + rand(0,0.1)
	else if(specifity <= 0)
		specifity += rand(0, threshold)

	return specifity
