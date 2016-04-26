
// This machine shows the age for extremely old finds

/obj/machinery/anomaly/accelerator
	name = "Accelerator spectrometer"

/obj/machinery/anomaly/accelerator/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/anom/accelerator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

/obj/machinery/anomaly/accelerator/ScanResults()
	var/results = "The scan was inconclusive. Check sample integrity and carrier consistency."

	var/datum/geosample/scanned_sample
	var/carrier_name
	var/num_reagents = 0

	for(var/datum/reagent/A in held_container.reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/analysis_sample))
			scanned_sample = R.data
		else
			carrier_name = R.id
		num_reagents++

	if(num_reagents == 2 && scanned_sample && carrier_name)
		var/specifity = GetResultSpecifity(scanned_sample, carrier_name)
		results = "Kinetic acceleration  of carrier ([carrier_name]) indicates age ([100 * specifity]% accuracy): <br><br>"

		if(scanned_sample.age_billion)
			var/displayed_age_millions = scanned_sample.age_million + max(scanned_sample.age_million * ((1 - specifity) * (2 * rand() - 1)), 0)
			var/displayed_age_billions = scanned_sample.age_billion + max(scanned_sample.age_billion * ((1 - specifity) * (2 * rand() - 1)), 0)
			results += "[displayed_age_billions + displayed_age_millions / 1000] billion years.<br>"
		else if(scanned_sample.age_million)
			var/displayed_age_thousands = scanned_sample.age_thousand + max(scanned_sample.age_thousand * ((1 - specifity) * (4 * rand() - 2)), 0)
			var/displayed_age_millions = scanned_sample.age_million + max(scanned_sample.age_million * ((1 - specifity) * (2 * rand() - 1)), 0)
			results += "[displayed_age_millions + displayed_age_thousands / 1000] million years.<br>"
		else if(scanned_sample.age_thousand)
			var/displayed_age = scanned_sample.age + max(scanned_sample.age * ((1 - specifity) * (8 * rand() - 4)), 0)
			var/displayed_age_thousands = scanned_sample.age_thousand + max(scanned_sample.age * ((1 - specifity) * (4 * rand() - 2)), 0)
			results += "[displayed_age_thousands + displayed_age / 1000] thousand years.<br>"
		else
			var/displayed_age = scanned_sample.age + max(scanned_sample.age * ((1 - specifity) * (8 * rand() - 4)), 0)
			results += "[displayed_age] years.<br>"

		results += "<br>Warning, results only valid for ages on the scale of billions of years."

	return results
