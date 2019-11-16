// Oh god why did I have to add this file

/datum/reagent/medicine/C2
	harmful = TRUE
	metabolization_rate = 0.2

/datum/reagent/medicine/C2/penthrite
	name = "Penthrite"
	description = "An explosive compound used to stabilize heart conditions. May interfere with stomach acid!"
	color = "#F5F5F5"
	self_consuming = TRUE
/datum/reagent/medicine/C2/penthrite/on_mob_add(mob/living/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_STABLEHEART, type)

/datum/reagent/medicine/C2/penthrite/on_mob_metabolize(mob/living/M)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH,0.5 * REM)

/datum/reagent/medicine/C2/penthrite/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_STABLEHEART, type)
	. = ..()
