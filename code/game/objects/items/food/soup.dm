/obj/item/food/bowled
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/soupsalad.dmi'
	bite_consumption = 5
	max_volume = 80
	foodtypes = NONE
	eatverbs = list("slurp", "sip", "inhale", "drink")
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/bowled/make_germ_sensitive(mapload)
	return // It's in a bowl

/obj/item/food/bowled/wish
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	food_reagents = list(/datum/reagent/water = 10)
	tastes = list("wishes" = 1)
	trash_type = /obj/item/reagent_containers/cup/bowl

/obj/item/food/bowled/wish/Initialize(mapload)
	. = ..()
	if(prob(25))
		desc = "A wish come true!"
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 9)
		reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 1)
		
/obj/item/food/bowled/mammi
	name = "Mammi"
	desc = "A bowl of mushy bread and milk. It reminds you, not too fondly, of a bowel movement."
	icon_state = "mammi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	foodtypes = SUGAR | DAIRY | JUNKFOOD | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/bowled/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/drug/mushroomhallucinogen = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	trash_type = /obj/item/reagent_containers/cup/bowl

	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtypes = VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/bowled/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/drug/mushroomhallucinogen = 3,
		/datum/reagent/toxin/amatoxin = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	trash_type = /obj/item/reagent_containers/cup/bowl


	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtypes = VEGETABLES | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_2
