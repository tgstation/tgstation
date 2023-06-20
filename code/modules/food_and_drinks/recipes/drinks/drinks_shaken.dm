/datum/chemical_reaction/drink/shaken
	require_other = TRUE
	required_container_accepts_subtypes = TRUE
	required_container = /obj/item/reagent_container/cup/shaker
	mix_message = "The drink shakes into something new."

/datum/chemical_reaction/drink/shaken/proc/pre_reaction_other_checks(datum/reagents/holder)
	var/obj/item/reagent_container/cup/shaker/shaker = holder.my_atom
	if(!istype(shaker))
		return FALSE
	return shaker.shaken
