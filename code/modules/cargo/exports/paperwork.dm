/datum/export/paperwork
	cost = CARGO_CRATE_VALUE*10
	unit_name = "paperwork"
	export_types = list(/obj/item/paperwork) //make one of these for every paperwork subtype please

/datum/export/paperwork/get_cost(obj/sold_object)
	var/obj/item/paperwork/sold_paperwork = sold_object
	if(!sold_paperwork.stamped)
		return -500 //PAPERWORK DISASTER
	else
		return cost

/datum/export/paperwork/cargo
	cost = CARGO_CRATE_VALUE * 7.5
	unit_name = "cargo paperwork"
	export_types = list(/obj/item/paperwork/cargo)
