/datum/component/lasertag
	///What team the mob that this component is attached to is part of. This should be all lowercase and either a color or "neutral"
	var/team_color = "neutral"
	///Anything that makes a human a valid lasertag target should be added to this
	var/list/lasertag_granters = list()

/datum/component/lasertag/Initialize(...)
	. = ..()
	var/mob/living/carbon/human/H = parent
	if (!H)
		return COMPONENT_INCOMPATIBLE

///call this proc before removing the component.
/datum/component/lasertag/proc/should_delete(var/source)
	lasertag_granters -= source
	if(LAZYLEN(lasertag_granters))
		return FALSE
	return TRUE
