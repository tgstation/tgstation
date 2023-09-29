// Dairy

/datum/glass_style/has_foodtype/drinking_glass/milk
	required_drink_type = /datum/reagent/consumable/milk
	name = "glass of milk"
	desc = "White and nutritious goodness!"
	icon_state = "glass_white"
	drink_type = DAIRY | BREAKFAST

/datum/glass_style/has_foodtype/juicebox/milk
	required_drink_type = /datum/reagent/consumable/milk
	name = "carton of milk"
	desc = "An excellent source of calcium for growing space explorers."
	icon_state = "milkbox"
	drink_type = DAIRY | BREAKFAST

/datum/glass_style/has_foodtype/juicebox/chocolate_milk
	required_drink_type = /datum/reagent/consumable/milk/chocolate_milk
	name = "carton of chocolate milk"
	desc = "Milk for cool kids!"
	icon_state = "chocolatebox"
	drink_type = SUGAR | DAIRY

/datum/glass_style/drinking_glass/soymilk
	required_drink_type = /datum/reagent/consumable/soymilk
	name = "glass of soy milk"
	desc = "White and nutritious soy goodness!"
	icon_state = "glass_white"

/datum/glass_style/drinking_glass/cream
	required_drink_type = /datum/reagent/consumable/cream
	name = "glass of cream"
	desc = "Ewwww..."
	icon_state = "glass_white"

/datum/glass_style/drinking_glass/coconut_milk
	required_drink_type = /datum/reagent/consumable/coconut_milk
	name = "glass of coconut milk"
	desc = "The essence of the tropics, contained safely within a glass."
	icon = 'icons/obj/drinks/drinks.dmi'
	icon_state = "glass_white"
