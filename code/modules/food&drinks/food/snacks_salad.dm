//this category is very little but I think that it has great potential to grow
////////////////////////////////////////////SALAD////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	name = "\improper Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad/New()
	..()
	eatverb = pick("crunch","devour","nibble","gnaw","gobble","chomp")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("tricordrazine", 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/herbsalad/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/validsalad/New()
	..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("doctorsdelight", 5)
	bitesize = 3