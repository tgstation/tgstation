// Approved requisition.
// +30 credits flat
/datum/export/requisition
	cost = CARGO_CRATE_VALUE * 0.15
	k_elasticity = 0
	unit_name = "approved requisition"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/requisition)

/datum/export/requisition/applies_to(obj/item/paper/fluff/jobs/cargo/requisition/paperwork)
	if(!..() || !istype(paperwork))
		return FALSE

	var/crate_not_ordered = !SSshuttle.order_history_by_id[paperwork.order_id]
	// we don't want to give points unless the crate order was approved
	if(crate_not_ordered)
		return FALSE

	for(var/stamp_icon in paperwork.authorization_stamps)
		if(paperwork.is_approved(stamp_icon))
			return TRUE
	return FALSE
