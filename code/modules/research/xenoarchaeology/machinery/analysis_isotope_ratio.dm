
// This machine shows the age for newer finds

obj/machinery/anomaly/isotope_ratio
	name = "Isotope ratio spectrometer"
	desc = "A specialised, complex analysis machine."
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"

obj/machinery/anomaly/isotope_ratio/ScanResults()
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
		var/accuracy = GetResultSpecifity(scanned_sample, carrier_name)
		accuracy += 0.5 * (1 - accuracy) / scanned_sample.total_spread
		if(!accuracy)
			accuracy = rand(0.01, 0.5)
		results = "Isotope decay analysis in carrier ([carrier_name]) indicates age ([100 * accuracy]% accuracy): <br><br>"

		if(scanned_sample.age_billion)
			//scramble the results
			var/displayed_age_thousands = rand(0, 999)
			var/displayed_age_millions = rand(0, 999)
			results += "[displayed_age_millions + displayed_age_thousands / 1000] million years.<br>"
		else if(scanned_sample.age_million)
			var/displayed_age_thousands = scanned_sample.age_thousand + max(scanned_sample.age_thousand * ((1 - accuracy) * (2 * rand() - 1)), 0)
			var/displayed_age_millions = scanned_sample.age_million + max(scanned_sample.age_million * ((1 - accuracy) * (4 * rand() - 2)), 0)
			results += "[displayed_age_millions + displayed_age_thousands / 1000] million years.<br>"
		else if(scanned_sample.age_thousand)
			var/displayed_age = scanned_sample.age + scanned_sample.age * ((1 - accuracy) * (2 * rand() - 1))
			var/displayed_age_thousands = scanned_sample.age_thousand + max(scanned_sample.age_thousand * ((1 - accuracy) * (2 * rand() - 1)), 0)
			results += "[displayed_age_thousands + displayed_age / 1000] thousand years.<br>"
		else
			var/displayed_age = scanned_sample.age + max(scanned_sample.age * ((1 - accuracy) * (2 * rand() - 1)), 0)
			results += "[displayed_age] years.<br>"

		results += "<br>Warning, results only valid up to ages of one billion years."

	return results
