/obj/effect/proc_holder/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, removing parasites, sobering us, purging toxins and radiation, and resetting our genetic code completely."
	helptext = "Can be used while unconscious."
	chemical_cost = 20
	dna_cost = 1
	req_stat = UNCONSCIOUS

//Heals the things that the other regenerative abilities don't.
/obj/effect/proc_holder/changeling/panacea/sting_action(mob/user)
	user << "<span class='notice'>We begin cleansing impurities from our form.</span>"

	var/obj/item/organ/internal/body_egg/egg = user.getorgan(/obj/item/organ/internal/body_egg)
	if(egg)
		egg.Remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(0)
		egg.loc = get_turf(user)

	user.reagents.add_reagent("mutadone", 10)
	user.reagents.add_reagent("potass_iodide", 10)
	user.reagents.add_reagent("charcoal", 20)
	user.reagents.add_reagent("antihol", 10)

	for(var/datum/disease/D in user.viruses)
		D.cure()
	feedback_add_details("changeling_powers","AP")
	return 1