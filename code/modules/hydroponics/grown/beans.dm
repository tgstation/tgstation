// Soybeans
/obj/item/seeds/soya
	name = "soybean seed pack"
	desc = "These seeds grow into soybean plants."
	icon_state = "seed-soybean"
	species = "soybean"
	plantname = "Soybean Plants"
	product = /obj/item/food/grown/soybeans
	maturation = 4
	production = 4
	potency = 15
	growthstages = 4
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
	icon_grow = "soybean-grow"
	icon_dead = "soybean-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/soya/koi, /obj/item/seeds/soya/butter)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/consumable/nutriment/fat/oil = 0.03) //Vegetable oil!

/obj/item/food/grown/soybeans
	seed = /obj/item/seeds/soya
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/soymilk = 0)
	tastes = list("soy" = 1)
	distill_reagent = /datum/reagent/consumable/soysauce

// Koibean
/obj/item/seeds/soya/koi
	name = "koibean seed pack"
	desc = "These seeds grow into koibean plants."
	icon_state = "seed-koibean"
	species = "koibean"
	plantname = "Koibean Plants"
	product = /obj/item/food/grown/koibeans
	potency = 10
	mutatelist = null
	reagents_add = list(/datum/reagent/toxin/carpotoxin = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)
	rarity = PLANT_MODERATELY_RARE

/obj/item/food/grown/koibeans
	seed = /obj/item/seeds/soya/koi
	name = "koibean"
	desc = "Something about these seems fishy, they seem really soft, almost squeezable!"
	icon_state = "koibeans"
	foodtypes = VEGETABLES
	tastes = list("koi" = 1)
	wine_power = 40

//Now squeezable for imitation carpmeat
/obj/item/food/grown/koibeans/attack_self(mob/living/user)
	user.visible_message(span_notice("[user] crushes [src] into a slab of carplike meat."), span_notice("You crush [src] into something that resembles a slab of carplike meat."))
	playsound(user, 'sound/effects/blob/blobattack.ogg', 50, TRUE)
	var/obj/item/food/fishmeat/carp/imitation/fishie = new(null)
	fishie.reagents.set_all_reagents_purity(seed.get_reagent_purity())
	qdel(src)
	user.put_in_hands(fishie)
	return TRUE

//Butterbeans, the beans wid da butta!
// Butterbeans! - Squeeze for a single butter slice!
/obj/item/seeds/soya/butter
	name = "butterbean seed pack"
	desc = "These seeds grow into butterbean plants."
	icon_state = "seed-butterbean"
	species = "butterbean"
	plantname = "butterbean Plants"
	product = /obj/item/food/grown/butterbeans
	potency = 10
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/milk = 0.05, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/cream = 0.05)
	rarity = 20

/obj/item/food/grown/butterbeans
	seed = /obj/item/seeds/soya/butter
	name = "butterbean"
	desc = "Soft, creamy and milky... You could almost smear them over toast."
	icon_state = "butterbeans"
	foodtypes = VEGETABLES | DAIRY
	tastes = list("creamy butter" = 1)
	distill_reagent = /datum/reagent/consumable/yoghurt

/obj/item/food/grown/butterbeans/attack_self(mob/living/user)
	user.visible_message(span_notice("[user] crushes [src] into a pat of butter."), span_notice("You crush [src] into something that resembles butter."))
	playsound(user, 'sound/effects/blob/blobattack.ogg', 50, TRUE)
	var/obj/item/food/butterslice/butties = new(null)
	butties.reagents.set_all_reagents_purity(seed.get_reagent_purity())
	qdel(src)
	user.put_in_hands(butties)
	return TRUE

// Green Beans
/obj/item/seeds/greenbean
	name = "green bean seed pack"
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
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
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
	name = "jumping bean seed pack"
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
	rarity = PLANT_MODERATELY_RARE

/obj/item/food/grown/jumpingbeans
	seed = /obj/item/seeds/greenbean/jump
	name = "jumping bean"
	desc = "Umm, what's causing it to move like that?"
	icon_state = "jumpingbean"
	foodtypes = FRUIT | BUGS
	tastes = list("bugs" = 1)
