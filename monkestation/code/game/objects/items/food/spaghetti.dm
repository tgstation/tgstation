/obj/item/food/spaghetti/raw/Initialize(mapload)
	. = ..()
	var random_names = list("spagti", "spagooter", "spaghetti", "spaget", "sgetti", "spagotti", "spugetti", "spacegetti", "bisgetti")
	name = pick(random_names)


/obj/item/food/spaghetti/security
	name = "Robust pasta"
	desc = "Only the truly robust can eat this safely."
	icon_state = "spesslaw"
	bite_consumption = 5
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 20,
		/datum/reagent/liquid_justice = 10,
	)
	tastes = list("justice" = 1, "robustness" = 1)
	foodtypes = GRAIN | MEAT
