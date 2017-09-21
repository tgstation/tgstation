/datum/component/rad_insulation //yes, this really is just a component to add a var
	var/amount

/datum/component/rad_insulation/Initialize(insulation_amount=RAD_MEDIUM_INSULATION)
	. = ..()
	amount = insulation_amount