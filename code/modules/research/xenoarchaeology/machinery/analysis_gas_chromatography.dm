
// This machine shows the materials that are present

/obj/machinery/anomaly/gas_chromatography
	name = "Gas Chromatography spectrometer"

/obj/machinery/anomaly/gas_chromatography/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/anom/gas,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

/obj/machinery/anomaly/gas_chromatography/ScanResults()
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

	if(num_reagents == 2 && scanned_sample)
		var/specifity = GetResultSpecifity(scanned_sample, carrier)
		results = "Chromatography partitioning analysis over carrier ([carrier]) indicates the following elements present ([100 * specifity]% accuracy):<br><br>"

		var/num_found = 0
		for(var/index=1,index <= scanned_sample.find_presence.len, index++)
			var/find = scanned_sample.find_presence[index]
			if(find && prob(100 * specifity))
				results += " - " + finds_as_strings[index] + "<br>"
				num_found++

		if(!num_found)
			results = "Chromatography partitioning results over carrier ([carrier]) to determine elemental makeup were inconclusive.<br>"

		if(!carrier)
			results += "<br>No carrier detected, scan accuracy affected.<br>"

	return results
