/datum/component/pda_protection
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/pda_protection/Initialize()
	if(!istype(parent, /obj/item/pda))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_PDA_CHECK_DETONATE), .proc/check)

/datum/component/pda_protection/proc/check()
	return COMPONENT_PDA_NO_DETONATE
