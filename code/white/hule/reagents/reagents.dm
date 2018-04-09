
////////////////////////////////////////HYPERPSY/////////////////////////////////////////////////////

/datum/reagent/toxin/hyperpsy
	name = "Hyperpsychotic drug"
	id = "hyperpsy"
	description = "A powerful psychotic toxin. Can cause a personality split."
	color = "#00FF00"
	toxpwr = 0
	taste_description = "sourness"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/toxin/hyperpsy/on_mob_add(mob/M)
	..()
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.gain_trauma(/datum/brain_trauma/severe/split_personality)

/obj/item/reagent_containers/pill/hyperpsy
	name = "Hyperpsychotic drug pill"
	desc = "A powerful psychotic toxin. Can cause a personality split."
	icon_state = "pill17"
	list_reagents = list("hyperpsy" = 1)
	roundstart = 1

/datum/chemical_reaction/hyperpsy
	name = "Hyperpsychotic drug"
	id = "hyperpsy"
	results = list("hyperpsy" = 1)
	required_reagents = list("neurotoxin2" = 1, "strange_reagent" = 1, "mannitol" = 1)

/datum/supply_pack/medical/hyperpsy
	name = "Hyperpsychotic drug crate"
	cost = 5000
	contains = list(/obj/item/reagent_containers/pill/hyperpsy)
	crate_name = "hyperpsy crate"