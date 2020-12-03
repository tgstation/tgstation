// Finally, peas. Base plant.
/obj/item/seeds/peas
	name = "pack of pea pods"
	desc = "These seeds grows into vitamin rich peas!"
	icon_state = "seed-peas"
	species = "peas"
	plantname = "Pea Vines"
	product = /obj/item/reagent_containers/food/snacks/grown/peas
	maturation = 3
	potency = 25
	instability = 15
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "peas-grow"
	icon_dead = "peas-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/peas/laugh)
	reagents_add = list (/datum/reagent/consumable/nutriment/vitamin = 0.1, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/water = 0.05)

/obj/item/reagent_containers/food/snacks/grown/peas
	seed = /obj/item/seeds/peas
	name = "peapod"
	desc = "Finally... peas."
	icon_state = "peas"
	filling_color = "#739122"
	bitesize_mod = 1
	foodtype = VEGETABLES
	tastes = list ("peas" = 1, "chalky saltiness" = 1)
	wine_power = 50
	wine_flavor = "what is, distressingly, fermented peas."

// Laughin' Peas
/obj/item/seeds/peas/laugh
	name = "pack of laughin' peas"
	desc = "These seeds give off a very soft purple glow.. they should grow into Laughin' Peas."
	icon_state = "seed-laughpeas"
	species = "laughpeas"
	plantname = "Laughin' Peas"
	product = /obj/item/reagent_containers/food/snacks/grown/laugh
	maturation = 7
	potency = 10
	yield = 7
	production = 5
	growthstages = 3
	icon_grow = "laughpeas-grow"
	icon_dead = "laughpeas-dead"
	genes = list (/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/purple)
	mutatelist = list (/obj/item/seeds/peas/laugh/peace)
	reagents_add = list (/datum/reagent/consumable/laughter = 0.05, /datum/reagent/consumable/sugar = 0.05, /datum/reagent/consumable/nutriment = 0.07)
	rarity = 25 //It actually might make Central Command Officials loosen up a smidge, eh?
	graft_gene = /datum/plant_gene/trait/glow/purple

/obj/item/reagent_containers/food/snacks/grown/laugh
	seed = /obj/item/seeds/peas/laugh
	name = "pod of laughin' peas"
	desc = "Ridens Cicer, guaranteed to improve your mood dramatically upon consumption!"
	icon_state = "laughpeas"
	filling_color = "#ee7bee"
	bitesize_mod = 2
	foodtype = VEGETABLES
	juice_results = list (/datum/reagent/consumable/laughsyrup = 0)
	tastes = list ("a prancing rabbit" = 1) //Vib Ribbon sends her regards.. wherever she is.
	wine_power = 90
	wine_flavor = "a vector-graphic rabbit dancing on your tongue"

// World Peas - Peace at last, peace at last...
/obj/item/seeds/peas/laugh/peace
	name = "pack of world peas"
	desc = "These rather large seeds give off a soothing blue glow..."
	icon_state = "seed-worldpeas"
	species = "worldpeas"
	plantname = "World Peas"
	product = /obj/item/reagent_containers/food/snacks/grown/peace
	maturation = 20
	potency = 75
	yield = 1
	production = 10
	instability = 45 //The world is a very unstable place. Constantly changing.
	growthstages = 3
	icon_grow = "worldpeas-grow"
	icon_dead = "worldpeas-dead"
	genes = list (/datum/plant_gene/trait/glow/blue)
	reagents_add = list (/datum/reagent/pax = 0.1, /datum/reagent/drug/happiness = 0.1, /datum/reagent/consumable/nutriment = 0.15)
	rarity = 50 // This absolutely will make even the most hardened Syndicate Operators relax.
	graft_gene = /datum/plant_gene/trait/glow/blue

/obj/item/reagent_containers/food/snacks/grown/peace
	seed = /obj/item/seeds/peas/laugh/peace
	name = "cluster of world peas"
	desc = "A plant discovered through extensive genetic engineering, and iterative graft work. It's rumored to bring peace to any who consume it. In the wider AgSci community, it's attained the nickname of 'Pax Mundi'." //at last... world peas. I'm not sorry.
	icon_state = "worldpeas"
	filling_color = "#0099CC"
	bitesize_mod = 4
	foodtype = VEGETABLES
	tastes = list ("numbing tranquility" = 2, "warmth" = 1)
	wine_power = 100
	wine_flavor = "mind-numbing peace and warmth"
