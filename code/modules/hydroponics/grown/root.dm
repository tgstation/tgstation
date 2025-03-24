// Carrot
/obj/item/seeds/carrot
	name = "carrot seed pack"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	species = "carrot"
	plantname = "Carrots"
	product = /obj/item/food/grown/carrot
	maturation = 10
	production = 1
	yield = 5
	instability = 15
	growthstages = 3
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
	mutatelist = list(/obj/item/seeds/carrot/parsnip, /obj/item/seeds/carrot/cahnroot)
	reagents_add = list(/datum/reagent/medicine/oculine = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/carrot
	seed = /obj/item/seeds/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/carrotjuice
	wine_power = 30

/obj/item/food/grown/carrot/attackby(obj/item/I, mob/user, list/modifiers)
	if(!I.get_sharpness())
		return ..()

	/// The blade carrot will turn into once sharpened
	var/obj/item/carrot_blade
	/// Chance for it to become a sword rather than a shiv
	var/carrot_sword_chance = (max(0, seed.potency - 50) / 50)
	if (prob(carrot_sword_chance))
		carrot_blade = new /obj/item/claymore/carrot
		to_chat(user, span_notice("You sharpen the carrot into a sword with [I]."))
	else
		carrot_blade = new /obj/item/knife/shiv/carrot
		to_chat(user, span_notice("You sharpen the carrot into a shiv with [I]."))
	remove_item_from_storage(user)
	qdel(src)
	user.put_in_hands(carrot_blade)

// Parsnip
/obj/item/seeds/carrot/parsnip
	name = "parsnip seed pack"
	desc = "These seeds grow into parsnips."
	icon_state = "seed-parsnip"
	species = "parsnip"
	plantname = "Parsnip"
	product = /obj/item/food/grown/parsnip
	icon_dead = "carrot-dead"
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/aluminium = 0.05)

/obj/item/food/grown/parsnip
	seed = /obj/item/seeds/carrot/parsnip
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/parsnipjuice
	wine_power = 35

/obj/item/food/grown/parsnip/attackby(obj/item/I, mob/user, list/modifiers)
	if(!I.get_sharpness())
		return ..()

	/// The blade parsnip will turn into once sharpened
	var/obj/item/parsnip_blade
	/// Chance for it to become a sabre rather than a shiv
	var/parsnip_sabre_chance = (max(0, seed.potency - 50) / 50)
	if (prob(parsnip_sabre_chance))
		parsnip_blade = new /obj/item/melee/parsnip_sabre
		to_chat(user, span_notice("You sharpen the parsnip into a sabre with [I]."))
	else
		parsnip_blade = new /obj/item/knife/shiv/parsnip
		to_chat(user, span_notice("You sharpen the parsnip into a shiv with [I]."))
	remove_item_from_storage(user)
	qdel(src)
	user.put_in_hands(parsnip_blade)


// Cahn'root
/obj/item/seeds/carrot/cahnroot
	name = "cahn'root seed pack"
	desc = "These seeds grow into cahn'roots."
	icon_state = "seed-cahn'root"
	species = "cahn'root"
	plantname = "Cahn'root"
	product = /obj/item/food/grown/cahnroot
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)
	endurance = 50
	instability = 10
	icon_dead = "cahn'root-dead"
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/cellulose = 0.01, /datum/reagent/consumable/sugar = 0.01)
	rarity = 10
	graft_gene = /datum/plant_gene/trait/plant_type/weed_hardy

/obj/item/food/grown/cahnroot
	seed = /obj/item/seeds/carrot/cahnroot
	name = "cahn'root"
	desc = "Heavily modified version of terran carrot, originally made to survive the scarciest of environments by an enterprising scientist of Moth Flotilla, Cahn'Mang."
	icon_state = "cahn'root"
	foodtypes = VEGETABLES
	juice_typepath = null
	tastes = list("sweet dirt" = 1)
	distill_reagent = /datum/reagent/consumable/rootbeer

/obj/item/food/grown/cahnroot/attackby(obj/item/I, mob/user, list/modifiers)
	if(!I.get_sharpness())
		return ..()

	/// The blade cahn'root will turn into once sharpened
	var/obj/item/knife/root_blade
	/// Chance for it to become a dagger rather than a shiv
	var/root_dagger_chance = (max(0, seed.potency - 25) / 50)
	if (prob(root_dagger_chance))
		root_blade = new /obj/item/knife/combat/root
		to_chat(user, span_notice("You sharpen the cahn'root into a dagger with [I]."))
	else
		root_blade = new /obj/item/knife/shiv/root
		to_chat(user, span_notice("You sharpen the cahn'root into a shiv with [I]."))
	remove_item_from_storage(user)
	qdel(src)
	user.put_in_hands(root_blade)

// White-Beet
/obj/item/seeds/whitebeet
	name = "white-beet seed pack"
	desc = "These seeds grow into sugary beet producing plants."
	icon_state = "seed-whitebeet"
	species = "whitebeet"
	plantname = "White-Beet Plants"
	product = /obj/item/food/grown/whitebeet
	lifespan = 60
	endurance = 50
	yield = 6
	instability = 10
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	mutatelist = list(/obj/item/seeds/redbeet)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/sugar = 0.2, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/whitebeet
	seed = /obj/item/seeds/whitebeet
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	wine_power = 40

// Red Beet
/obj/item/seeds/redbeet
	name = "redbeet seed pack"
	desc = "These seeds grow into red beet producing plants."
	icon_state = "seed-redbeet"
	species = "redbeet"
	plantname = "Red-Beet Plants"
	product = /obj/item/food/grown/redbeet
	lifespan = 60
	endurance = 50
	yield = 5
	instability = 15
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	genes = list(/datum/plant_gene/trait/maxchem)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05)
	graft_gene = /datum/plant_gene/trait/maxchem

/obj/item/food/grown/redbeet
	seed = /obj/item/seeds/redbeet
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	wine_power = 60
