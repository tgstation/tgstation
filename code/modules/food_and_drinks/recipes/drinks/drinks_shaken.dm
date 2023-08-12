/*	Shake shake shake!
	Shaken drinks are made in, believe it or not, the shaker.
*/
/datum/chemical_reaction/drink/shaken
	required_other = TRUE
	required_container_accepts_subtypes = TRUE
	required_container = /obj/item/reagent_containers/cup/glass/shaker

/datum/chemical_reaction/drink/shaken/pre_reaction_other_checks(datum/reagents/holder)
	var/obj/item/reagent_containers/cup/glass/shaker/shaker = holder.my_atom
	if(!istype(shaker))
		return FALSE
	return shaker.shaken
