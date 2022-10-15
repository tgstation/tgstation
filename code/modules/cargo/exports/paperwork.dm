/datum/export/paperwork
	cost = CARGO_CRATE_VALUE * 4
	unit_name = "paperwork"
	export_types = list(/obj/item/paperwork) //make one of these for every paperwork subtype please

/datum/export/paperwork/get_cost(obj/sold_object)
	var/obj/item/paperwork/sold_paperwork = sold_object
	if(!sold_paperwork.stamped)
		return -500 //PAPERWORK DISASTER

/datum/export/paperwork/low_value //Used for non-command or cargo stamps
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "cargo paperwork"
	export_types = list(/obj/item/paperwork/cargo)

