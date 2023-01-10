/obj/item/food/soup
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/soupsalad.dmi'
	trash_type = /obj/item/reagent_containers/cup/bowl
	bite_consumption = 5
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("tasteless soup" = 1)
	foodtypes = VEGETABLES
	eatverbs = list("slurp", "sip", "inhale", "drink")
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/soup/wish
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	food_reagents = list(/datum/reagent/water = 10)
	tastes = list("wishes" = 1)

/obj/item/food/soup/wish/Initialize(mapload)
	. = ..()
	var/wish_true = prob(25)
	if(wish_true)
		desc = "A wish come true!"
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 9)
		reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 1)

/obj/item/food/soup/meatball
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/water = 5,
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/slime
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/slimejelly = 10,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/water = 5,
	)
	tastes = list("slime" = 1)
	foodtypes = TOXIC | SUGAR
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/blood
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/blood = 10, /datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 10,
	)
	tastes = list("iron" = 1)
	foodtypes = GROSS

/obj/item/food/soup/wingfangchu
	name = "wing fang chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash_type = /obj/item/reagent_containers/cup/bowl
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/soysauce = 10,
		/datum/reagent/consumable/nutriment/vitamin = 7,
	)
	tastes = list("soy" = 1)
	foodtypes = MEAT

/obj/item/food/soup/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/banana = 10,
		/datum/reagent/lube = 5,
		/datum/reagent/consumable/nutriment/vitamin = 16,
		/datum/reagent/consumable/clownstears = 10,
	)
	tastes = list("a bad joke" = 1)
	foodtypes = FRUIT | SUGAR

/obj/item/food/soup/vegetable
	name = "vegetable soup"
	desc = "A true vegan meal."
	icon_state = "vegetablesoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("vegetables" = 1)
	foodtypes = VEGETABLES
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/nettle
	name = "nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/medicine/omnizine = 5,
	)
	tastes = list("nettles" = 1)
	foodtypes = VEGETABLES
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/mystery
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("chaos" = 1)

/obj/item/food/soup/mystery/Initialize(mapload)
	. = ..()
	var/extra_reagent = null
	extra_reagent = pick(
		/datum/reagent/blood,
		/datum/reagent/carbon,
		/datum/reagent/consumable/banana,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/oculine,
		/datum/reagent/medicine/omnizine,
		/datum/reagent/toxin,
		/datum/reagent/toxin/slimejelly,
	)
	reagents.add_reagent(extra_reagent, 5)
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 6)

/obj/item/food/soup/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/capsaicin = 3,
		/datum/reagent/consumable/tomatojuice = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("hot peppers" = 1)
	foodtypes = VEGETABLES | MEAT
	venue_value = FOOD_PRICE_NORMAL
/obj/item/food/soup/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/frostoil = 3,
		/datum/reagent/consumable/tomatojuice = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("tomato" = 1, "mint" = 1)
	foodtypes = VEGETABLES | MEAT

/obj/item/food/soup/clownchili
	name = "chili con carnival"
	desc = "A delicious stew of meat, chiles, and salty, salty clown tears."
	icon_state = "clownchili"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/tomatojuice = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/banana = 1,
		/datum/reagent/consumable/laughter = 1,
	)
	tastes = list("tomato" = 1, "hot peppers" = 2, "clown feet" = 2, "kind of funny" = 2, "someone's parents" = 2)
	foodtypes = VEGETABLES | MEAT

/obj/item/food/soup/monkeysdelight
	name = "monkey's delight"
	desc = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	icon_state = "monkeysdelight"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 10,
	)
	tastes = list("the jungle" = 1, "banana" = 1)
	foodtypes = FRUIT
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/tomato
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("tomato" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/tomato/eyeball
	name = "eyeball soup"
	desc = "It looks back at you..."
	icon_state = "eyeballsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/liquidgibs = 3,
	)
	tastes = list("tomato" = 1, "squirming" = 1)
	foodtypes = MEAT | GORE

/obj/item/food/soup/miso
	name = "miso soup"
	desc = "The universe's best soup! Yum!!!"
	icon_state = "misosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("miso" = 1)
	foodtypes = VEGETABLES | BREAKFAST
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/mushroom
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("mushroom" = 1)
	foodtypes = VEGETABLES | DAIRY

/obj/item/food/soup/beet
	name = "beet soup"
	desc = "Wait, how do you spell it again...?"
	icon_state = "beetsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	foodtypes = VEGETABLES

/obj/item/food/soup/beet/Initialize(mapload)
	. = ..()
	name = pick("borsch", "bortsch", "borstch", "borsh", "borshch", "borscht")
	tastes = list(name = 1)

/obj/item/food/soup/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/drug/mushroomhallucinogen = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/amanitajelly
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
	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtypes = VEGETABLES | TOXIC

/obj/item/food/soup/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	bite_consumption = 7
	max_volume = 100
	tastes = list("tomato" = 1, "carrot" = 1)
	foodtypes = VEGETABLES | MEAT
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/sweetpotato
	name = "sweet potato soup"
	desc = "Delicious sweet potato in soup form."
	icon_state = "sweetpotatosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("sweet potato" = 1)
	foodtypes = VEGETABLES | SUGAR
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/beet/red
	name = "red beet soup"
	desc = "Quite a delicacy."
	icon_state = "redbeetsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("beet" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/onion
	name = "french onion soup"
	desc = "Good enough to make a grown mime cry."
	icon_state = "onionsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 8,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("caramelized onions" = 1)
	foodtypes = VEGETABLES | DAIRY

/obj/item/food/soup/bisque
	name = "bisque"
	desc = "A classic entree from Space-France."
	icon_state = "bisque"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("creamy texture" = 1, "crab" = 4)
	foodtypes = MEAT
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/soup/electron
	name = "electron soup"
	desc = "A gastronomic curiosity of ethereal origin. It is famed for the minature weather system formed over a properly prepared soup."
	icon_state = "electronsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/liquidelectricity/enriched = 12,
	)
	tastes = list("mushroom" = 1, "electrons" = 4)
	foodtypes = VEGETABLES | TOXIC

/obj/item/food/soup/bungocurry
	name = "bungo curry"
	desc = "A spicy vegetable curry made with the humble bungo fruit, Exotic!"
	icon_state = "bungocurry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/bungojuice = 9,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("bungo" = 2, "hot curry" = 4, "tropical sweetness" = 1)
	foodtypes = VEGETABLES | FRUIT | DAIRY

/obj/item/food/soup/mammi
	name = "Mammi"
	desc = "A bowl of mushy bread and milk. It reminds you, not too fondly, of a bowel movement."
	icon_state = "mammi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)

/obj/item/food/soup/peasoup
	name = "pea soup"
	desc = "A humble split pea soup."
	icon_state = "peasoup"
	food_reagents = list (
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("creamy peas"= 2, "parsnip" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/indian_curry
	name = "indian chicken curry"
	desc = "A mild, creamy curry from the old subcontinent. Liked by the Space-British, because it reminds them of the Raj."
	icon_state = "indian_curry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("chicken" = 2, "creamy curry" = 4, "earthy heat" = 1)
	foodtypes = VEGETABLES | MEAT | DAIRY
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/soup/oatmeal
	name = "oatmeal"
	desc = "A nice bowl of oatmeal."
	icon_state = "oatmeal"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/milk = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("oats" = 1, "milk" = 1)
	foodtypes = DAIRY | GRAIN | BREAKFAST

/obj/item/food/soup/zurek
	name = "zurek"
	desc = "A traditional Polish soup composed of vegetables, meat, and an egg. Goes great with bread."
	icon_state = "zurek"
	food_reagents = list (
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("creamy vegetables"= 2, "sausage" = 1)
	foodtypes = VEGETABLES | MEAT | GRAIN | BREAKFAST

/obj/item/food/soup/cullen_skink
	name = "cullen skink"
	desc = "A thick Scottish soup made of smoked fish, potatoes and onions."
	icon_state = "cullen_skink"
	food_reagents = list (
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("creamy broth" = 1, "fish" = 1, "vegetables" = 1)
	foodtypes = VEGETABLES | SEAFOOD | DAIRY

/obj/item/food/soup/chicken_noodle_soup
	name = "chicken noodle soup"
	desc = "A hearty bowl of chicken noodle soup, perfect for when you're stuck at home and sick."
	icon_state = "chicken_noodle_soup"
	food_reagents = list (
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("broth" = 1, "chicken" = 1, "noodles" = 1, "carrots" = 1)
	foodtypes = VEGETABLES | MEAT | GRAIN

/obj/item/food/soup/corn_chowder
	name = "corn chowder"
	desc = "A creamy bowl of corn chowder, with bacon bits and mixed vegetables. One bowl is never enough."
	icon_state = "corn_chowder"
	food_reagents = list (
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("creamy broth" = 1, "bacon" = 1, "mixed vegetables" = 1)
	foodtypes = VEGETABLES | MEAT
