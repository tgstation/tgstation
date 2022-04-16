// Approved requisition.
/datum/export/requisition
	cost = CARGO_CRATE_VALUE * 0.4
	k_elasticity = 0
	unit_name = "approved requisition"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/requisition)

/datum/export/requisition/applies_to(obj/item/paper/fluff/jobs/cargo/requisition/paperwork)
	if(!..() || !istype(paperwork))
		return FALSE

	for(var/obj/item/stamp/stamp in paperwork.authorization_stamps)
		if(paperwork.is_approved(stamp.icon_state))
			return TRUE
	return FALSE
