// Coffees and Teas

/datum/glass_style/drinking_glass/coffee
	required_drink_type = /datum/reagent/consumable/coffee
	name = "glass of coffee"
	desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."

/datum/glass_style/drinking_glass/tea
	required_drink_type = /datum/reagent/consumable/tea
	name = "glass of tea"
	desc = "Drinking it from here would not seem right."
	icon_state = "teaglass"

/datum/glass_style/drinking_glass/icecoffee
	required_drink_type = /datum/reagent/consumable/icecoffee
	name = "iced coffee"
	desc = "A drink to perk you up and refresh you!"
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "icedcoffeeglass"

/datum/glass_style/drinking_glass/hot_ice_coffee
	required_drink_type = /datum/reagent/consumable/hot_ice_coffee
	name = "hot ice coffee"
	desc = "A sharp drink - This can't have come cheap."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "hoticecoffee"

/datum/glass_style/drinking_glass/icetea
	required_drink_type = /datum/reagent/consumable/icetea
	name = "iced tea"
	desc = "All natural, antioxidant-rich flavour sensation."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "icedteaglass"

/datum/glass_style/drinking_glass/soy_latte
	required_drink_type = /datum/reagent/consumable/soy_latte
	name = "soy latte"
	desc = "A nice and refreshing beverage while you're reading."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "soy_latte"

/datum/glass_style/drinking_glass/cafe_latte
	required_drink_type = /datum/reagent/consumable/cafe_latte
	name = "cafe latte"
	desc = "A nice, strong and refreshing beverage while you're reading."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "cafe_latte"

/datum/glass_style/drinking_glass/pumpkin_latte
	required_drink_type = /datum/reagent/consumable/pumpkin_latte
	name = "pumpkin latte"
	desc = "A mix of coffee and pumpkin juice."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "pumpkin_latte"

/datum/glass_style/has_foodtype/drinking_glass/hot_coco
	required_drink_type = /datum/reagent/consumable/hot_coco
	name = "glass of hot coco"
	desc = "A favorite winter drink to warm you up."
	drink_type = SUGAR | DAIRY

/datum/glass_style/drinking_glass/italian_coco
	required_drink_type = /datum/reagent/consumable/italian_coco
	name = "glass of italian coco"
	desc = "A spin on a winter favourite, made to please."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "italiancoco"

/datum/glass_style/drinking_glass/mushroom_tea
	required_drink_type = /datum/reagent/consumable/mushroom_tea
	name = "glass of mushroom tea"
	desc = "Oddly savoury for a drink."
	icon_state = "mushroom_tea_glass"

/datum/glass_style/drinking_glass/t_letter
	required_drink_type = /datum/reagent/consumable/t_letter
	name = "glass of T"
	desc = "The 20th."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "tletter"
