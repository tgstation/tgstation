#define VAT_GROWTH_RATE 4

/datum/micro_organism/cell_line/mouse //nuisance cell line designed to complicate the growing of animal type cell lines.
	desc = "Murine cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
							/datum/reagent/liquidgibs = 2,
							/datum/reagent/consumable/nutriment = 1,
							/datum/reagent/consumable/nutriment/vitamin = 1,
							/datum/reagent/consumable/sugar = 1,
							/datum/reagent/consumable/cooking_oil = 1,
							)
	surpressive_reagents = list(/datum/reagent/toxin/heparin = -6)
	virus_suspectibility = 2
	growth_rate = VAT_GROWTH_RATE
	resulting_atoms = list(/mob/living/simple_animal/mouse = 2)

/datum/micro_organism/cell_line/chicken //basic cell line designed as a good source of protein and eggyolk.
	desc = "Galliform skin cells."
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
							/datum/reagent/consumable/rice = 4,
							/datum/reagent/consumable/eggyolk = 1,
							/datum/reagent/consumable/nutriment/vitamin = 2
							)
	surpressive_reagents = list(/datum/reagent/fuel/oil = -4,
							/datum/reagent/toxin = -2
							)
	virus_suspectibility = 1
	growth_rate = VAT_GROWTH_RATE
	resulting_atoms = list(/mob/living/simple_animal/chicken = 1)

/datum/micro_organism/cell_line/cockroach //nuisance cell line designed to complicate the growing of slime type cell lines.
	desc = "Blattodeoid anthropod cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
							/datum/reagent/yuck = 4,
							/datum/reagent/toxin/slimejelly = 2,
							/datum/reagent/consumable/nutriment/vitamin = 1
							)

	surpressive_reagents = list(
							/datum/reagent/toxin/pestkiller = -2,
							/datum/reagent/consumable/ethanol/bug_spray = -4
							)
	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/hostile/cockroach = 5)



#undef VAT_GROWTH_RATE
