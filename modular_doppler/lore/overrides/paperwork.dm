/obj/item/paper/pamphlet/gateway/Initialize(mapload)
	. = ..()
	if(mapload)
		qdel(src) // evil

/obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code
	name = "Port Authority-Approved Spare ID Safe Code"
