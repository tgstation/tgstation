/obj/effect/proc_holder/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, removing parasites, toxins and radiation, and resetting our genetic code completely."
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
		user.visible_message("<span class='danger'>[user] vomits up [egg]!</span>", "<span class='userdanger'>[user] vomits up [egg]!</span>")
		playsound(user.loc, 'sound/effects/splat.ogg', 50, 1)

		var/turf/location = user.loc
		if(istype(location, /turf/simulated))
			location.add_vomit_floor(user, 1)
		egg.loc = location

	user.reagents.add_reagent("mutadone", 10)
	user.reagents.add_reagent("potass_iodide", 10)
	user.reagents.add_reagent("charcoal", 20)

	for(var/datum/disease/D in user.viruses)
		D.cure()
	feedback_add_details("changeling_powers","AP")
	return 1