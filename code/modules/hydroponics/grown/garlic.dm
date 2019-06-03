/obj/item/seeds/garlic
	name = "pack of garlic seeds"
	desc = "A packet of extremely pungent seeds."
	icon_state = "seed-garlic"
	species = "garlic"
	plantname = "Garlic Sprouts"
	product = /obj/item/reagent_containers/food/snacks/grown/garlic
	yield = 6
	potency = 25
	growthstages = 3
	mutatelist = list(/obj/item/seeds/garlic/awful,/obj/item/seeds/garlic/plasma)
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_add = list(/datum/reagent/consumable/garlic = 0.15, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/garlic
	seed = /obj/item/seeds/garlic
	name = "garlic"
	desc = "Delicious, but with a potentially overwhelming odor."
	icon_state = "garlic"
	filling_color = "#C0C9A0"
	bitesize_mod = 2
	tastes = list("garlic" = 1)
	wine_power = 10

//awful garlic

/obj/item/seeds/garlic/awful
	name = "pack of awful garlic seeds"
	desc = "A packet of the worst decisions that have ever been made."
	icon_state = "seed-awfulgarlic"
	species = "awfulgarlic"
	plantname = "Awful Garlic Mistakes"
	product = /obj/item/reagent_containers/food/snacks/grown/awfulgarlic
	yield = 3
	potency = 20
	rarity = 30
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_add = list(/datum/reagent/consumable/garlic = 0.15, /datum/reagent/toxin/spewium = 0.05)

/obj/item/reagent_containers/food/snacks/grown/awfulgarlic
	seed = /obj/item/seeds/garlic/awful
	name = "awful garlic"
	desc = "Almighty Space Jesus please banish this awful thing."
	icon_state = "awfulgarlic"
	filling_color = "#B9BC85"
	bitesize_mod = 2
	tastes = list("awful" = 1)
	wine_power = 10

//plasma garlic

/obj/item/seeds/garlic/plasma
	name = "pack of plasma garlic seeds"
	desc = "Danger:Handle with care."
	icon_state = "seed-plasmagarlic"
	species = "plasmagarlic"
	plantname = "Plasma Garlic Sprouts"
	product = /obj/item/reagent_containers/food/snacks/grown/plasmagarlic
	yield = 2
	potency = 15
	rarity = 25
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_add = list(/datum/reagent/consumable/garlic = 0.15, /datum/reagent/toxin/plasma = 0.1)

/obj/item/reagent_containers/food/snacks/grown/plasmagarlic
	seed = /obj/item/seeds/garlic/plasma
	name = "plasma garlic"
	desc = "Tasty for the daring."
	icon_state = "plasmagarlic"
	filling_color = "#D742F4"
	bitesize_mod = 2
	tastes = list("toxins" = 1)
	wine_power = 10