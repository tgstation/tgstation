// Approved manifest.
// +80 credits flat.
/datum/export/manifest_correct
	cost =  CARGO_CRATE_VALUE * 0.4
	k_elasticity = 0
	unit_name = "approved manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_correct/applies_to(obj/item/paper/fluff/jobs/cargo/manifest/manifest)
	if(!..())
		return FALSE
	if(manifest.signature_status == SIGNATURE_INCORRECT)
		return FALSE
	if(manifest.is_approved() && !manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_correct/sell_object(obj/item/paper/fluff/jobs/cargo/manifest/manifest, datum/export_report/report, dry_run, apply_elastic)
	. = ..()
	if(manifest.signature_status == SIGNATURE_CORRECT)
		SSshuttle.correct_signatures++

/datum/export/manifest_correct/get_cost(obj/item/paper/fluff/jobs/cargo/manifest/manifest)
	return ..() + (manifest.signature_status == SIGNATURE_CORRECT && 40)

// Correctly denied manifest.
// Refunds the package cost minus the cost of crate.
/datum/export/manifest_error_denied
	cost = -CARGO_CRATE_VALUE
	k_elasticity = 0
	unit_name = "correctly denied manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_error_denied/applies_to(obj/item/paper/fluff/jobs/cargo/manifest/manifest)
	if(!..())
		return FALSE


	if(manifest.signature_status == SIGNATURE_INCORRECT)
		return FALSE
	if(manifest.is_denied() && manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error_denied/get_cost(obj/item/paper/fluff/jobs/cargo/manifest/manifest)

	return ..() + manifest.order_cost


// Erroneously approved manifest.
// Substracts the package cost.
/datum/export/manifest_error
	unit_name = "erroneously approved manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_error/applies_to(obj/item/paper/fluff/jobs/cargo/manifest/manifest)
	if(!..())
		return FALSE


	if(manifest.signature_status == SIGNATURE_INCORRECT)
		return FALSE
	if(manifest.is_approved() && manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error/get_cost(obj/item/paper/fluff/jobs/cargo/manifest/manifest)

	return -manifest.order_cost


// Erroneously denied manifest.
// Substracts the package cost minus the cost of crate.
/datum/export/manifest_correct_denied
	cost = CARGO_CRATE_VALUE
	unit_name = "erroneously denied manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_correct_denied/applies_to(obj/item/paper/fluff/jobs/cargo/manifest/manifest)
	if(!..())
		return FALSE


	if(manifest.signature_status == SIGNATURE_INCORRECT)
		return FALSE
	if(manifest.is_denied() && !manifest.errors)
		return TRUE
	return FALSE

/datum/export/manifest_correct_denied/get_cost(obj/item/paper/fluff/jobs/cargo/manifest/manifest)

	return ..() - manifest.order_cost

// Someone who wasn't the recipient signed the manifest, ruining it entirely.
// -80 credits flat.
/datum/export/manifest_fucked_signature
	cost =  CARGO_CRATE_VALUE * 0.4
	k_elasticity = 0
	unit_name = "ruined signature manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest_fucked_signature/applies_to(obj/item/paper/fluff/jobs/cargo/manifest/manifest)

	if(manifest.signature_status == SIGNATURE_INCORRECT)
		return TRUE
	return FALSE
