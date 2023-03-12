// Potato
/obj/item/seeds/potato
	name = "pack of potato seeds"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "seed-potato"
	species = "potato"
	plantname = "Potato Plants"
	product = /obj/item/food/grown/potato
	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "potato-grow"
	icon_dead = "potato-dead"
	genes = list(/datum/plant_gene/trait/battery, /datum/plant_gene/trait/one_bite)
	mutatelist = list(/obj/item/seeds/potato/sweet)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	graft_gene = /datum/plant_gene/trait/battery

/obj/item/food/grown/potato
	seed = /obj/item/seeds/potato
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	foodtypes = VEGETABLES
	juice_results = list(/datum/reagent/consumable/potato_juice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/vodka

/obj/item/food/grown/potato/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/baked_potato, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/grown/potato/wedges
	name = "potato wedges"
	desc = "Slices of neatly cut potato."
	icon_state = "potato_wedges"
	bite_consumption_mod = 100

/obj/item/food/grown/potato/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		to_chat(user, span_notice("You cut the potato into wedges with [W]."))
		var/obj/item/food/grown/potato/wedges/Wedges = new /obj/item/food/grown/potato/wedges
		remove_item_from_storage(user)
		qdel(src)
		user.put_in_hands(Wedges)
	else
		return ..()


// Sweet Potato
/obj/item/seeds/potato/sweet
	name = "pack of sweet potato seeds"
	desc = "These seeds grow into sweet potato plants."
	icon_state = "seed-sweetpotato"
	species = "sweetpotato"
	plantname = "Sweet Potato Plants"
	product = /obj/item/food/grown/potato/sweet
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.1, /datum/reagent/consumable/sugar = 0.1, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/potato/sweet
	seed = /obj/item/seeds/potato/sweet
	name = "sweet potato"
	desc = "It's sweet."
	icon_state = "sweetpotato"
	distill_reagent = /datum/reagent/consumable/ethanol/sbiten

/obj/item/food/grown/potato/sweet/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/yakiimo, rand(15 SECONDS, 35 SECONDS), TRUE, TRUE)
