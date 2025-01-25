/obj/item/reagent_containers/chem_pack/spawns_sealed
	name = "chemical pressure bag"
	desc = "A plastic pressure bag for chemical storage, sealed to prevent contamination."

/obj/item/reagent_containers/chem_pack/spawns_sealed/Initialize(mapload, vol)
	. = ..()
	reagents.flags = NONE
	reagent_flags = DRAWABLE | INJECTABLE
	reagents.flags = reagent_flags
	spillable = FALSE
	sealed = TRUE

// The actual types

/obj/item/reagent_containers/chem_pack/spawns_sealed/organ_tissue
	name = "organic sample tissue pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a label and warning sticker for containing \
		samples of grown biological tissue. Do not eat."
	list_reagents = list(
		/datum/reagent/consumable/nutriment/organ_tissue = 40,
		/datum/reagent/consumable/nutriment/protein = 20,
		/datum/reagent/consumable/nutriment/peptides = 20,
		/datum/reagent/consumable/nutriment/fat = 20,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/purity_tester
	name = "purity tester pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a label for 'purity tester' whatever in specific that could be."
	list_reagents = list(
		/datum/reagent/reaction_agent/purity_tester = 100,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/tempomyocin
	name = "tempomyocin pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a label for 'tempomyocin'."
	list_reagents = list(
		/datum/reagent/reaction_agent/speed_agent = 100,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/palladium_catalyst
	name = "palladium synthate catalyst pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a label for 'palladium synthate catalyst'. Definitely do not eat."
	list_reagents = list(
		/datum/reagent/catalyst_agent/speed/medicine = 100,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/food_sweetener
	name = "artificial sweetener pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a labal of 'food sweetener', and strangely enough, a do not eat sticker."
	list_reagents = list(
		/datum/reagent/toxin/leadacetate = 50,
		/datum/reagent/consumable/astrotame = 50,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/i_love_corn_syrup
	name = "high fructose corn syrup pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a labal of 'high fructose corn syrup', and strangely enough, a do not eat sticker."
	list_reagents = list(
		/datum/reagent/consumable/corn_syrup = 60,
		/datum/reagent/consumable/nutriment/fat/oil/corn = 40,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/hydrogen_peroxide
	name = "hydrogen peroxide pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a labal of 'hydrogen peroxide'. Absolutely do not eat."
	list_reagents = list(
		/datum/reagent/hydrogen_peroxide = 100,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/sterilizine
	name = "sterilizine pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a labal of 'sterilizine'. Absolutely do not eat."
	list_reagents = list(
		/datum/reagent/space_cleaner/sterilizine = 100,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/stable_plasma
	name = "stable plasma pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a labal of 'stable plasma'. Absolutely do not eat."
	list_reagents = list(
		/datum/reagent/stable_plasma = 95,
		/datum/reagent/stabilizing_agent = 5,
	)

/obj/item/reagent_containers/chem_pack/spawns_sealed/acetone
	name = "acetone pressure bag"
	desc = "A plastic pressure bag for chemical storage. This one has a labal of 'acetone'. Absolutely do not eat."
	list_reagents = list(
		/datum/reagent/acetone = 100,
	)

/obj/machinery/reagentgrinder/unanchored
	anchored = FALSE
