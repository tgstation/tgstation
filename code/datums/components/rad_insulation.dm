/datum/component/rad_insulation //yes, this really is just a component to add a var
	var/amount = 5

/datum/component/rad_insulation/Initialize(insulation_amount)
	. = ..()
	amount = insulation_amount