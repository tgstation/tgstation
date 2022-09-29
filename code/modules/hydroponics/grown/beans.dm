// Soybeans
/obj/item/seeds/soya
	name = "pack of soybean seeds"
	desc = "These seeds grow into soybean plants."
	icon_state = "seed-soybean"
	species = "soybean"
	plantname = "Soybean Plants"
	product = /obj/item/food/grown/soybeans
	maturation = 4
	production = 4
	potency = 15
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "soybean-grow"
	icon_dead = "soybean-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/soya/koi)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/consumable/cooking_oil = 0.03) //Vegetable oil!

/obj/item/food/grown/soybeans
	seed = /obj/item/seeds/soya
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/soymilk = 0)
	tastes = list("soy" = 1)
	wine_power = 20

// Koibean
/obj/item/seeds/soya/koi
	name = "pack of koibean seeds"
	desc = "These seeds grow into koibean plants."
	icon_state = "seed-koibean"
	species = "koibean"
	plantname = "Koibean Plants"
	product = /obj/item/food/grown/koibeans
	potency = 10
	mutatelist = null
	reagents_add = list(/datum/reagent/toxin/carpotoxin = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)
	rarity = 20

/obj/item/food/grown/koibeans
	seed = /obj/item/seeds/soya/koi
	name = "koibean"
	desc = "Something about these seems fishy."
	icon_state = "koibeans"
	foodtypes = VEGETABLES
	tastes = list("koi" = 1)
	wine_power = 40

// Green Beans
/obj/item/seeds/greenbean
	name = "pack of green bean seeds"
	desc = "These seeds grow into green bean plants."
	icon_state = "seed-greenbean"
	species = "greenbean"
	plantname = "Green Bean Plants"
	product = /obj/item/food/grown/greenbeans
	instability = 0
	maturation = 4
	production = 3
	potency = 10
	growthstages = 4
	icon_dead = "bean-dead"
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/never_mutate, /datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/greenbean/jump)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/medicine/c2/multiver = 0.04) //They're good for you!
	graft_gene = /datum/plant_gene/trait/never_mutate

/obj/item/food/grown/greenbeans
	seed = /obj/item/seeds/greenbean
	name = "green beans"
	desc = "Simple and healthy, what more do you need?"
	gender = PLURAL
	icon_state = "greenbean"
	foodtypes = FRUIT
	tastes = list("beans" = 1)

// Jumping Bean
/obj/item/seeds/greenbean/jump
	name = "pack of jumping bean seeds"
	desc = "These seeds grow into jumping bean plants."
	icon_state = "seed-jumpingbean"
	species = "jumpingbean"
	plantname = "Jumping Bean Plants"
	product = /obj/item/food/grown/jumpingbeans
	yield = 2
	instability = 18
	maturation = 8
	production = 4
	potency = 20
	genes = list(/datum/plant_gene/trait/stable_stats, /datum/plant_gene/trait/repeated_harvest)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05, /datum/reagent/ants = 0.1) //IRL jumping beans contain insect larve, hence the ants
	graft_gene = /datum/plant_gene/trait/stable_stats
	rarity = 20

/obj/item/food/grown/jumpingbeans
	seed = /obj/item/seeds/greenbean/jump
	name = "jumping bean"
	desc = "Umm, what's causing it to move like that?"
	icon_state = "jumpingbean"
	foodtypes = FRUIT | BUGS
	tastes = list("bugs" = 1)

