/obj/item/food/tortilla
	name = "tortilla"
	desc = "The base for all your burritos."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "tortilla"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("tortilla" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/burrito
	name = "burrito"
	desc = "Tortilla wrapped goodness."
	icon_state = "burrito"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("torilla" = 2, "beans" = 3)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/cheesyburrito
	name = "cheesy burrito"
	desc = "It's a burrito filled with cheese."
	icon_state = "cheesyburrito"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("torilla" = 2, "beans" = 3, "cheese" = 1)
	foodtypes = GRAIN | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/carneburrito
	name = "carne asada burrito"
	desc = "The best burrito for meat lovers."
	icon_state = "carneburrito"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("torilla" = 2, "meat" = 4)
	foodtypes = GRAIN | MEAT
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/fuegoburrito
	name = "fuego plasma burrito"
	desc = "A super spicy burrito."
	icon_state = "fuegoburrito"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/capsaicin = 5, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("torilla" = 2, "beans" = 3, "hot peppers" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_LEGENDARY

/obj/item/food/nachos
	name = "nachos"
	desc = "Chips from Space Mexico."
	icon_state = "nachos"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("nachos" = 1)
	foodtypes = GRAIN | FRIED
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cheesynachos
	name = "cheesy nachos"
	desc = "The delicious combination of nachos and melting cheese."
	icon_state = "cheesynachos"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("nachos" = 2, "cheese" = 1)
	foodtypes = GRAIN | FRIED | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/cubannachos
	name = "Cuban nachos"
	desc = "That's some dangerously spicy nachos."
	icon_state = "cubannachos"
	food_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/capsaicin = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("nachos" = 2, "hot pepper" = 1)
	foodtypes = VEGETABLES | FRIED | DAIRY
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/taco
	name = "classic taco"
	desc = "A traditional taco with meat, cheese, and lettuce."
	icon_state = "taco"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2, "lettuce" = 1)
	foodtypes = MEAT | DAIRY | GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/taco/plain
	name = "plain taco"
	desc = "A traditional taco with meat and cheese, minus the rabbit food."
	icon_state = "taco_plain"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2)
	foodtypes = MEAT | DAIRY | GRAIN
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/capsaicin = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("hot peppers" = 1, "meat" = 3, "cheese" = 1, "sour cream" = 1)
	foodtypes = MEAT | GRAIN
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/stuffedlegion
	name = "stuffed legion"
	desc = "The former skull of a damned human, filled with goliath meat. It has a decorative lava pool made of ketchup and hotsauce."
	icon_state = "stuffed_legion"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/capsaicin = 2)
	tastes = list("death" = 2, "rock" = 1, "meat" = 1, "hot peppers" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	venue_value = FOOD_PRICE_LEGENDARY

/obj/item/food/chipsandsalsa
	name = "chips and salsa"
	desc = "Some tortilla chips with a cup of zesty salsa. Highly addictive!"
	icon_state = "chipsandsalsa"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/capsaicin = 2, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("peppers" = 1, "salsa" = 3, "tortilla chips" = 1, "onion" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
