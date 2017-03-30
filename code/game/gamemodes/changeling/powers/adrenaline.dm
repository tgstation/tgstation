/obj/effect/proc_holder/changeling/adrenaline
	name = "Adrenaline Sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Removes all stuns instantly and adds a short-term reduction in further stuns. Can be used while unconscious. Continued use poisons the body."
	chemical_cost = 30
	dna_cost = 2
	req_human = 1
	req_stat = UNCONSCIOUS

//Recover from stuns.
/obj/effect/proc_holder/changeling/adrenaline/sting_action(mob/living/user)
	to_chat(user, "<span class='notice'>Energy rushes through us.[user.lying ? " We arise." : ""]</span>")
	user.SetSleeping(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.reagents.add_reagent("changelingAdrenaline", 10)
	user.reagents.add_reagent("changelingAdrenaline2", 2) //For a really quick burst of speed
	user.adjustStaminaLoss(-75)
	feedback_add_details("changeling_powers","UNS")
	return 1

