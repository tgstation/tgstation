/datum/action/changeling/adrenaline
	name = "Adrenaline Sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body. Costs 30 chemicals."
	helptext = "Removes all stuns and heals a large amount of stamina damage instantly, then synthesizes a small amount of the changeling haste reagent, which will give us a short burst of speed to escape with. Can be used while unconscious. The changeling haste reagent produced by this ability can cause jittering and dizziness."
	button_icon_state = "adrenaline"
	chemical_cost = 30
	dna_cost = 2
	req_human = 1
	req_stat = UNCONSCIOUS

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>Energy rushes through us.</span>")
	user.SetAllImmobility(0)
	user.adjustStaminaLoss(-60)
	user.set_resting(FALSE)
	user.reagents.add_reagent(/datum/reagent/medicine/changelinghaste, 3) //6 seconds, for a short-duration burst of speed
	return TRUE
