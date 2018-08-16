/*				ENGINEERING OBJECTIVES				*/

/datum/objective/crew/integrity //ported from old Hippie
	explanation_text = "Ensure the station's integrity rating is at least (Yo something broke, yell on the development discussion channel of citadels discord about this)% when the shift ends."
	jobs = "chiefengineer,stationengineer"

/datum/objective/crew/integrity/New()
	. = ..()
	target_amount = rand(60,95)
	update_explanation_text()

/datum/objective/crew/integrity/update_explanation_text()
	. = ..()
	explanation_text = "Ensure the station's integrity rating is at least [target_amount]% when the shift ends."

/datum/objective/crew/integrity/check_completion()
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	if(!SSticker.mode.station_was_nuked && station_integrity >= target_amount)
		return TRUE
	else
		return FALSE

/datum/objective/crew/poly
	explanation_text = "Make sure Poly keeps his headset, and stays alive until the end of the shift."
	jobs = "chiefengineer"

/datum/objective/crew/poly/check_completion()
	for(var/mob/living/simple_animal/parrot/Poly/dumbbird in GLOB.mob_list)
		if(!(dumbbird.stat == DEAD) && dumbbird.ears)
			if(istype(dumbbird.ears, /obj/item/radio/headset))
				return TRUE
	return FALSE
