/datum/action/changeling/adrenaline
	name = "Gene Stim"
	desc = "We concentrate our chemicals into a potent stimulant, rendering our form stupendously robust against being incapacitated. Costs 25 chemicals."
	helptext = "Doses you with Changeling Adrenaline: Restore a massive amount of stamina per tick, and no-sell stamcrit while the reagent is inside you."
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

	// Add fast reagents to go fast.
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //20 seconds

	return TRUE
