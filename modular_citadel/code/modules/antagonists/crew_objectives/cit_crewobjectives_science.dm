/*				SCIENCE OBJECTIVES				*/

/datum/objective/crew/cyborgs //Ported from old Hippie
	explanation_text = "Ensure there are at least (Yo something broke here, yell on citadel's development discussion channel about this) functioning cyborgs when the shift ends."
	jobs = "researchdirector,roboticist"

/datum/objective/crew/cyborgs/New()
	. = ..()
	target_amount = rand(3,10)
	update_explanation_text()

/datum/objective/crew/cyborgs/update_explanation_text()
	. = ..()
	explanation_text = "Ensure there are at least [target_amount] functioning cyborgs when the shift ends."

/datum/objective/crew/cyborgs/check_completion()
	var/borgcount = target_amount
	for(var/mob/living/silicon/robot/R in GLOB.alive_mob_list)
		if(!(R.stat == DEAD))
			borgcount--
	if(borgcount <= 0)
		return TRUE
	else
		return FALSE

/datum/objective/crew/research //inspired by old hippie's research level objective. should hopefully be compatible with techwebs when that gets finished. hopefully. should be easy to update in the event that it is incompatible with techwebs.
	var/datum/design/targetdesign
	explanation_text = "Make sure the research required to produce a (something broke, yell on citadel's development discussion channel about this) is available on the R&D server by the end of the shift."
	jobs = "researchdirector,scientist"

/datum/objective/crew/research/New()
	. = ..()
	targetdesign = pick(subtypesof(/datum/design))
	update_explanation_text()

/datum/objective/crew/research/update_explanation_text()
	. = ..()
	explanation_text = "Make sure the research required to produce a [initial(targetdesign.name)] is available on the R&D server by the end of the shift."

/datum/objective/crew/research/check_completion()
	for(var/obj/machinery/rnd/server/S in GLOB.machines)
		if(S && S.stored_research)
			if(S.stored_research.researched_designs[initial(targetdesign.id)])
				return TRUE
	return FALSE
