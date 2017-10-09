/datum/component/rad_insulation //yes, this really is just a component to add some vars
	var/amount
	var/protects
	var/contamination_proof

/datum/component/rad_insulation/Initialize(_amount=RAD_MEDIUM_INSULATION, _protects=TRUE, _contamination_proof=TRUE)
	. = ..()
	amount = _amount
	protects = _protects
	contamination_proof = _contamination_proof