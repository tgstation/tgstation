/datum/export/paperwork
	cost = CARGO_CRATE_VALUE * 3
	unit_name = "paperwork pile"
	export_types = list(/obj/item/paperwork)
	exclude_types = list(/obj/item/paperwork/photocopy) //Has its own category
	allow_negative_cost = TRUE

/datum/export/paperwork/get_base_cost(obj/item/paperwork/sold_paperwork)
	return sold_paperwork.stamped ? ..() : -cost

/datum/export/photocopy
	cost = CARGO_CRATE_VALUE
	unit_name = "messy paperwork pile"
	export_types = list(/obj/item/paperwork/photocopy)
	allow_negative_cost = TRUE
	///Tracks the chance of losing money for trying to double-dip with photocopies. Resets every time it ruins an order.
	var/backfire_chance = 0
	///Used to track if a batch of photocopy exports has backfired
	var/backfired = FALSE

/datum/export/photocopy/get_base_cost(obj/item/paperwork/photocopy/sold_paperwork)
	if(sold_paperwork.stamped && !backfired) //Upon backfiring, no more photocopies are processed or sold until the next cargo shipment
		if(sold_paperwork.voided)
			return 0 //Voided photocopies do nothing
		else
			backfire_chance += rand(15,25)
			if(prob(backfire_chance))
				backfire_chance = 0
				backfired = TRUE
				return -cost * 4 //too high of an amount to allow for infinite money
			else
				return ..()

	else
		return -cost

/datum/export/photocopy/total_printout(datum/export_report/ex, notes)
	. = ..()

	if(backfired)
		backfired = FALSE
		. += " Counterfeit paperwork was detected in this shipment. A fine has been taken from your budget as a result."
