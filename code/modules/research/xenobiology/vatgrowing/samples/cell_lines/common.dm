/datum/micro_organism/cell_line/mouse
	desc = "Little black droppings"
	required_reagents = list(/datum/reagent/consumable/nutriment, /datum/reagent/water)
	supplementary_reagents = list(/datum/reagent/consumable/watermelonjuice = 1)
	surpressive_reagents = list(/datum/reagent/consumable/cornoil = -2)
	virus_suspectibility = 2
	growth_rate = 4
	resulting_atoms = list(/mob/living/simple_animal/mouse = 2)

/datum/micro_organism/cell_line/chicken
	desc = "Some cube shaped gelatines."
	required_reagents = list(/datum/reagent/consumable/nutriment, /datum/reagent/consumable/sugar)
	supplementary_reagents = list(/datum/reagent/water = 1)
	surpressive_reagents = list(/datum/reagent/fuel/oil = -2)
	virus_suspectibility = 1
	growth_rate = 4
	resulting_atoms = list(/mob/living/simple_animal/chicken = 1)

/datum/micro_organism/cell_line/cockroach
	desc = "A line of anthropod cells of blattodeoid appearance"
	required_reagents = list(/datum/reagent/consumable/cooking_oil)
	supplementary_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	surpressive_reagents = list(/datum/reagent/medicine/C2/instabitaluri = -2)
	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/hostile/cockroach = 3)

