
/datum/micro_organism/cell_line/organs
	desc = "dense tissue"
	growth_rate = 1
	consumption_rate = REAGENTS_METABOLISM

/datum/micro_organism/cell_line/organs/mutate_color(atom/beautiful_mutant)
	. = ..()

	if(isorgan(beautiful_mutant))
		var/obj/item/organ/organ = beautiful_mutant
		// Rare affix organs get more health
		organ.maxHealth *= .

/datum/micro_organism/cell_line/organs/heart
	desc = "dense heart tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/love = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/heart

/datum/micro_organism/cell_line/organs/lungs
	desc = "dense lung tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/medicine/salbutamol = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/lungs

/datum/micro_organism/cell_line/organs/liver
	desc = "dense liver tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/liver

/datum/micro_organism/cell_line/organs/stomach
	desc = "dense stomach tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue/stomach_lining)

	supplementary_reagents = list(
		/datum/reagent/consumable/nutriment/organ_tissue = 3,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/stomach
