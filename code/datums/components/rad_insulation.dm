/datum/component/rad_insulation //yes, this really is just a component to add some vars
	var/amount
	var/protects

/datum/component/rad_insulation/Initialize(_amount=RAD_MEDIUM_INSULATION, _protects=TRUE)
	. = ..()
	amount = _amount
	protects = _protects