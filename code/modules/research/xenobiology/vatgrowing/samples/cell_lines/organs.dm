/// Cell lines for organ cytology, letting you duplicate or grow new mutant strains!
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

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/heart

/datum/micro_organism/cell_line/organs/heart/evolved
	desc = "dense evolved heart tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/love = 6,
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/heart/evolved

/datum/micro_organism/cell_line/organs/heart/sacred
	desc = "dense sacred heart tissue"
	growth_rate = parent_type::growth_rate * 0.5

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue, /datum/reagent/water/holywater)

	supplementary_reagents = list(
		/datum/reagent/love = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/heart/evolved/sacred

/datum/micro_organism/cell_line/organs/heart/corrupt
	desc = "dense corrupted heart tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/hellwater = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/water/holywater = -3,
	)

	resulting_atom = /obj/item/organ/heart/corrupt

/datum/micro_organism/cell_line/organs/lungs
	desc = "dense lung tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/medicine/salbutamol = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/lungs

/datum/micro_organism/cell_line/organs/lungs/evolved
	desc = "dense evolved lung tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/medicine/salbutamol = 6,
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/lungs/evolved

/datum/micro_organism/cell_line/organs/liver
	desc = "dense liver tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/liver

/datum/micro_organism/cell_line/organs/liver/evolved
	desc = "dense evolved liver tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/liver/evolved

/datum/micro_organism/cell_line/organs/liver/bloody
	desc = "spongy liver tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue, /datum/reagent/blood)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	resulting_atom = /obj/item/organ/liver/bloody

/datum/micro_organism/cell_line/organs/liver/distillery
	desc = "alcoholic liver tissue"
	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue, /datum/reagent/consumable/ethanol)

	supplementary_reagents = list(
		/datum/reagent/iron = 6,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/water = -6, //are you trying to poison me or something?
	)

	resulting_atom = /obj/item/organ/liver/distillery

/datum/micro_organism/cell_line/organs/stomach
	desc = "dense stomach tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue/stomach_lining)

	supplementary_reagents = list(
		/datum/reagent/consumable/nutriment/organ_tissue = 3,
		/datum/reagent/blood = 3,
		/datum/reagent/consumable/nutriment = 1,
	)

	suppressive_reagents = list(
		/datum/reagent/toxin/mutagen = -2,
	)

	resulting_atom = /obj/item/organ/stomach

/datum/micro_organism/cell_line/organs/stomach/evolved
	desc = "dense evolved stomach tissue"

	required_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue/stomach_lining)

	supplementary_reagents = list(
		/datum/reagent/toxin/mutagen = 4,
		/datum/reagent/consumable/nutriment/organ_tissue = 3,
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/blood = 3,
	)

	resulting_atom = /obj/item/organ/stomach/evolved
