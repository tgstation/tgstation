//Ai, play Sushi Tabetai by Orange Range please.

/obj/item/food/seaweedsheet
	name = "seaweed sheet"
	desc = "A dried sheet of seaweed used for making sushi."
	icon_state = "seaweedsheet"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("seaweed" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

//Gives a tooltip by examining

/obj/item/food/seaweedsheet/examine(mob/user)
	. = ..()
	. += span_notice("You could turn it into a <b>custom sushi sheet</b> with some boiled rice.")

//Makes it so you can add rice to the sheet
/obj/item/food/seaweedsheet/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/food/salad/boiledrice))
		var/obj/item/food/salad/boiledrice/boiledrice = item
		var/obj/item/food/makisheet/new_item = new(usr.loc)
		boiledrice.use(1)
		to_chat(user, span_notice("You spread the rice onto the [src]."))
		remove_item_from_storage(src)
		qdel(src)
		user.put_in_hands(new_item)
		return TRUE
	..()

/obj/item/food/makisheet
	name = "sushi sheet"
	desc = "A sheet of seaweed covered in boiled rice."
	icon_state = "sushisheet"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("seaweed" = 1, "boiled rice" = 2)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	burns_in_oven = TRUE

/obj/item/food/makisheet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/sushi/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 6)

/obj/item/food/vegetariansushiroll
	name = "vegetarian sushi roll"
	desc = "A roll of simple vegetarian sushi with rice, carrots, and potatoes. Sliceable into pieces!"
	icon_state = "vegetariansushiroll"
	food_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("boiled rice" = 4, "carrots" = 2, "potato" = 2)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/vegetariansushiroll/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/vegetariansushislice, 4, 20)

/obj/item/food/vegetariansushislice
	name = "vegetarian sushi slice"
	desc = "A slice of simple vegetarian sushi with rice, carrots, and potatoes."
	icon_state = "vegetariansushislice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("boiled rice" = 4, "carrots" = 2, "potato" = 2)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/spicyfiletsushiroll
	name = "spicy filet sushi roll"
	desc = "A roll of tasty, spicy sushi made with fish and vegetables. Sliceable into pieces!"
	icon_state = "spicyfiletroll"
	food_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/capsaicin = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtypes = VEGETABLES | SEAFOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/spicyfiletsushiroll/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/spicyfiletsushislice, 4, 20)

/obj/item/food/spicyfiletsushislice
	name = "spicy filet sushi slice"
	desc = "A slice of tasty, spicy sushi made with fish and vegetables. Don't eat it too fast!."
	icon_state = "spicyfiletslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtypes = VEGETABLES | SEAFOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself. You sure hope whoever made this is skilled."
	icon_state = "sashimi"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/capsaicin = 9, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("fish" = 1, "hot peppers" = 1)
	foodtypes = SEAFOOD
	w_class = WEIGHT_CLASS_TINY
	//total price of this dish is 20 and a small amount more for soy sauce, all of which are available at the orders console
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/sashimi/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CARP, CELL_VIRUS_TABLE_GENERIC_MOB)


//Custom sushi goes here

/obj/item/food/sushi/empty
	name = "sushi"
	desc = "It's a roll of sushi, customized to your wildest dreams."
	icon_state = "vegetariansushiroll"
	tastes = list()
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtypes = VEGETABLES

/obj/item/food/sushi/empty/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/sushislice/empty, 4, 20, table_required = TRUE)

/obj/item/food/sushislice/empty
	name = "sushi slice"
	desc = "It's a slice of sushi, customized to your wildest dreams."
	icon_state = "vegetariansushislice"
	tastes = list()
	foodtypes = VEGETABLES

//「DONT STOP THE MUSIC」
//「DONT STOP THE SUSHI」
