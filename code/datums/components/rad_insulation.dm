/datum/component/rad_insulation // Yes, this really is just a component to add some vars
	var/amount					// Multiplier for radiation strength passing through
	var/protects				// Does this protect things in its contents from being affected?
	var/contamination_proof		// Can this object be contaminated?

/datum/component/rad_insulation/Initialize(_amount=RAD_MEDIUM_INSULATION, _protects=TRUE, _contamination_proof=TRUE)
	amount = _amount
	protects = _protects
	contamination_proof = _contamination_proof