/datum/action/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our burns, bruises, and shortness of breath, as well as hiding all of our scars. Costs 20 chemicals."
	helptext = "If we are on fire, the healing effect will not function. Does not regrow limbs or restore lost blood. Functions while unconscious."
	button_icon_state = "fleshmend"
	chemical_cost = 20
	dna_cost = 2
	req_stat = HARD_CRIT

//Starts healing you every second for 10 seconds.
//Can be used whilst unconscious.
/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	if(user.has_status_effect(/datum/status_effect/fleshmend))
		to_chat(user, span_warning("We are already fleshmending!"))
		return
	..()
	to_chat(user, span_notice("We begin to heal rapidly."))
	user.apply_status_effect(/datum/status_effect/fleshmend)
	return TRUE

//Check buffs.dm for the fleshmend status effect code
