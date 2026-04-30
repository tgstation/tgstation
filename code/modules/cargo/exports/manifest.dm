#define MANIFEST_HANDLING_RATE 0.12
#define MANIFEST_CORRECT_RATE MANIFEST_HANDLING_RATE * 2
#define MANIFEST_ERRONEOUS_RATE MANIFEST_HANDLING_RATE * 4
#define MAX_HANDLING_CHARGE CARGO_CRATE_VALUE * 0.6
#define MAX_CORRECT_CHARGE MAX_HANDLING_CHARGE * 2
#define MAX_ERRONEOUS_CHARGE MAX_HANDLING_CHARGE * 4

// Approved manifest. 12% handling payment, up to a maximum of the max handling charge
/datum/export/manifest_correct
	k_elasticity = 0
	unit_name = "approved manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)
	scannable = FALSE

/datum/export/manifest_correct/applies_to(obj/exported_item)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/export_manifest = exported_item
	if(export_manifest.is_approved() && !export_manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_correct/get_base_cost(obj/item/paper/fluff/jobs/cargo/manifest/exported_item)
	return min(exported_item.order_cost * MANIFEST_HANDLING_RATE, MAX_HANDLING_CHARGE)

// Correctly denied manifest. Refunds package cost plus double handling payment, up to a maximum of 2x max handling charge
/datum/export/manifest_error_denied
	k_elasticity = 0
	unit_name = "correctly denied manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)
	scannable = FALSE

/datum/export/manifest_error_denied/applies_to(obj/exported_item)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/export_manifest = exported_item
	if(export_manifest.is_denied() && export_manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error_denied/get_base_cost(obj/item/paper/fluff/jobs/cargo/manifest/exported_item)
	return exported_item.order_cost + min(exported_item.order_cost * MANIFEST_CORRECT_RATE, MAX_CORRECT_CHARGE)

// Erroneously approved manifest. Penalty charged quadruple handling payment, up to a maximum of 4x max handling charge
/datum/export/manifest_error
	unit_name = "erroneously approved manifest"
	k_elasticity = 0
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)
	allow_negative_cost = TRUE
	scannable = FALSE

/datum/export/manifest_error/applies_to(obj/exported_item)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/export_manifest = exported_item
	if(export_manifest.is_approved() && export_manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error/get_base_cost(obj/item/paper/fluff/jobs/cargo/manifest/exported_item)
	return -min(exported_item.order_cost * MANIFEST_ERRONEOUS_RATE, MAX_ERRONEOUS_CHARGE)

// Erroneously denied manifest. Penalty charged quadruple handling payment, up to a maximum of 4x max handling charge
/datum/export/manifest_correct_denied
	k_elasticity = 0
	unit_name = "erroneously denied manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)
	allow_negative_cost = TRUE
	scannable = FALSE

/datum/export/manifest_correct_denied/applies_to(obj/exported_item)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/export_manifest = exported_item
	if(export_manifest.is_denied() && !export_manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_correct_denied/get_base_cost(obj/item/paper/fluff/jobs/cargo/manifest/exported_item)
	return -min(exported_item.order_cost * MANIFEST_ERRONEOUS_RATE, MAX_ERRONEOUS_CHARGE)

#undef MANIFEST_HANDLING_RATE
#undef MANIFEST_CORRECT_RATE
#undef MANIFEST_ERRONEOUS_RATE
#undef MAX_HANDLING_CHARGE
#undef MAX_CORRECT_CHARGE
#undef MAX_ERRONEOUS_CHARGE
