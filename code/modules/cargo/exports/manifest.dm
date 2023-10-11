// Base manifest datum, only for code organization
/datum/export/manifest
	unscannable = TRUE
	k_elasticity = 0
	unit_name = "manifest"
	export_types = list(/obj/item/paper/fluff/jobs/cargo/manifest)

/datum/export/manifest/applies_to(obj/O)
	return FALSE

// Approved manifest.
// +80 credits flat.
/datum/export/manifest/correct
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "approved manifest"


/datum/export/manifest/correct/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_approved() && !M.errors)
		return TRUE
	return FALSE

// Correctly denied manifest.
// Refunds the package cost minus the cost of crate.
/datum/export/manifest/error_denied
	cost = -CARGO_CRATE_VALUE
	unit_name = "correctly denied manifest"

/datum/export/manifest/error_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_denied() && M.errors)
		return TRUE
	return FALSE

/datum/export/manifest/error_denied/get_cost(obj/O)
	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	return ..() + M.order_cost


// Erroneously approved manifest.
// Substracts the package cost.
/datum/export/manifest/error
	unit_name = "erroneously approved manifest"
	allow_negative_cost = TRUE

/datum/export/manifest/error/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_approved() && M.errors)
		return TRUE
	return FALSE

/datum/export/manifest/error/get_cost(obj/O)
	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	return -M.order_cost


// Erroneously denied manifest.
// Substracts the package cost minus the cost of crate.
/datum/export/manifest/correct_denied
	cost = -CARGO_CRATE_VALUE
	unit_name = "erroneously denied manifest"
	allow_negative_cost = TRUE

/datum/export/manifest/correct_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	if(M.is_denied() && !M.errors)
		return TRUE
	return FALSE

/datum/export/manifest/correct_denied/get_cost(obj/O)
	var/obj/item/paper/fluff/jobs/cargo/manifest/M = O
	return ..() - M.order_cost
