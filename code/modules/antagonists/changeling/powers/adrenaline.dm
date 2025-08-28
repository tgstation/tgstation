/datum/action/changeling/adrenaline
	name = "Gene Stim"
	desc = "We concentrate our chemicals into a potent stimulant, rendering our form stupendously robust against being incapacitated. Costs 25 chemicals."
	helptext = "Disregard any condition that has stunned us and suffuse our form with FOUR units of Changeling Adrenaline; our form recovers massive stamina and simply disregards any pain or fatigue during its effects."
	button_icon_state = "adrenaline"
	chemical_cost = 25 // similar cost to biodegrade, as they serve similar purposes
	dna_cost = 2
	req_human = FALSE
	req_stat = CONSCIOUS
	disabled_by_fire = TRUE

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/carbon/user)
	..()

	// Get us standing up.
	user.SetAllImmobility(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)

	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //Tank 5 consecutive baton hits

	to_chat(user, span_changeling("The staggering rush of a stimulant honed precisely to our biology is INVIGORATING. We will not be subdued."))

	return TRUE
