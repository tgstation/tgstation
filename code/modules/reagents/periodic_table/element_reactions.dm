// Alkali metals and water. Upstream potassium explodes at strengthdiv 20; each heavier alkali metal
// is more reactive, so the explosion gets stronger (a lower strengthdiv) going down the group.
// Lithium and sodium are left alone: upstream recipes already mix them with water.

/datum/chemical_reaction/reagent_explosion/rubidium_explosion
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/element/rubidium = 1)
	strengthdiv = 14

/datum/chemical_reaction/reagent_explosion/caesium_explosion
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/element/caesium = 1)
	strengthdiv = 10

/datum/chemical_reaction/reagent_explosion/francium_explosion
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/uranium/element/francium = 1)
	strengthdiv = 7
