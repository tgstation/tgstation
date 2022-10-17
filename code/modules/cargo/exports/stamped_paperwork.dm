/datum/export/paperwork
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "paperwork"
	export_types = list(/obj/item/paperwork)
	exclude_types = list(/obj/item/paperwork/photocopy) //Has its own category
	allow_negative_cost = TRUE

/datum/export/paperwork/get_cost(obj/sold_object)
	var/obj/item/paperwork/sold_paperwork = sold_object
	if(!sold_paperwork.stamped)
		return -cost  //Punishment for improperly filed paperwork

/datum/export/photocopy
	cost = CARGO_CRATE_VALUE
	unit_name = "messy paperwork"
	export_types = list(/obj/item/paperwork/photocopy)
	allow_negative_cost = TRUE
	///Tracks the chance of losing money for trying to double-dip with photocopies. Resets every time it ruins an order.
	var/backfire_chance = 0

/datum/export/photocopy/get_cost(obj/sold_object)
	var/obj/item/paperwork/photocopy/sold_paperwork = sold_object
	if(sold_paperwork.stamped)
		if(sold_paperwork.voided)
			return 0 //Voided photocopies do nothing
		else
			backfire_chance += 25
			if(prob(backfire_chance))
				backfire_chance = 0
				return -CARGO_CRATE_VALUE * 4
			else
				return cost

	else
		return -CARGO_CRATE_VALUE //Tempted to just make it return 0 to stop people from maliciously tanking the budget


