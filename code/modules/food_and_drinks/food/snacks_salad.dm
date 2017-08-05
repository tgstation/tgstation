//this category is very little but I think that it has great potential to grow
////////////////////////////////////////////SALAD////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/salad
	icon = 'icons/obj/food/soupsalad.dmi'
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	bitesize = 3
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	tastes = list("leaves" = 1)
	foodtype = VEGETABLES

/obj/item/weapon/reagent_containers/food/snacks/salad/New()
	..()
	eatverb = pick("crunch","devour","nibble","gnaw","gobble","chomp")

/obj/item/weapon/reagent_containers/food/snacks/salad/aesirsalad
	name = "\improper Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	bonus_reagents = list("omnizine" = 2, "vitamin" = 6)
	list_reagents = list("nutriment" = 8, "omnizine" = 8, "vitamin" = 6)
	tastes = list("leaves" = 1)
	foodtype = VEGETABLES

/obj/item/weapon/reagent_containers/food/snacks/salad/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	bonus_reagents = list("vitamin" = 4)
	list_reagents = list("nutriment" = 8, "vitamin" = 2)
	tastes = list("leaves" = 1, "apple" = 1)
	foodtype = VEGETABLES | FRUIT

/obj/item/weapon/reagent_containers/food/snacks/salad/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	bonus_reagents = list("doctorsdelight" = 5, "vitamin" = 4)
	list_reagents = list("nutriment" = 8, "doctorsdelight" = 5, "vitamin" = 2)
	tastes = list("leaves" = 1, "potato" = 1, "meat" = 1, "valids" = 1)
	foodtype = VEGETABLES | MEAT | FRIED | JUNKFOOD | FRUIT

/obj/item/weapon/reagent_containers/food/snacks/salad/oatmeal
	name = "oatmeal"
	desc = "A nice bowl of oatmeal."
	icon_state = "oatmeal"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 4)
	list_reagents = list("nutriment" = 7, "milk" = 10, "vitamin" = 2)
	tastes = list("oats" = 1, "milk" = 1)
	foodtype = DAIRY | GRAIN

/obj/item/weapon/reagent_containers/food/snacks/salad/fruit
	name = "fruit salad"
	desc = "Your standard fruit salad."
	icon_state = "fruitsalad"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 4)
	tastes = list("fruit" = 1)
	foodtype = FRUIT

/obj/item/weapon/reagent_containers/food/snacks/salad/jungle
	name = "jungle salad"
	desc = "Exotic fruits in a bowl."
	icon_state = "junglesalad"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 4)
	list_reagents = list("nutriment" = 7, "banana" = 5, "vitamin" = 4)
	tastes = list("fruit" = 1, "the jungle" = 1)
	foodtype = FRUIT

/obj/item/weapon/reagent_containers/food/snacks/salad/citrusdelight
	name = "citrus delight"
	desc = "Citrus overload!"
	icon_state = "citrusdelight"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 4)
	list_reagents = list("nutriment" = 7, "vitamin" = 5)
	tastes = list("sourness" = 1, "leaves" = 1)
	foodtype = FRUIT

/obj/item/weapon/reagent_containers/food/snacks/salad/ricebowl
	name = "ricebowl"
	desc = "A bowl of raw rice."
	icon_state = "ricebowl"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice
	list_reagents = list("nutriment" = 4)
	tastes = list("rice" = 1)
	foodtype = GRAIN | RAW

/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice
	name = "boiled rice"
	desc = "A warm bowl of rice."
	icon_state = "boiledrice"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	tastes = list("rice" = 1)
	foodtype = GRAIN

/obj/item/weapon/reagent_containers/food/snacks/salad/ricepudding
	name = "rice pudding"
	desc = "Everybody loves rice pudding!"
	icon_state = "ricepudding"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 2)
	tastes = list("rice" = 1, "sweetness" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/weapon/reagent_containers/food/snacks/salad/ricepork
	name = "rice and pork"
	desc = "Well, it looks like pork..."
	icon_state = "riceporkbowl"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 4)
	tastes = list("rice" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/weapon/reagent_containers/food/snacks/salad/eggbowl
	name = "egg bowl"
	desc = "A bowl of rice with a fried egg."
	icon_state = "eggbowl"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 4)
	tastes = list("rice" = 1, "egg" = 1)
	foodtype = GRAIN | MEAT //EGG = MEAT -NinjaNomNom 2017
