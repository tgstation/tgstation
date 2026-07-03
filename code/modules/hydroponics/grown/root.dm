/obj/item/food/grown/carrotlike
	seed = /obj/item/seeds/carrot
	name = "carrot?"
	desc = "What is this? It's not a carrot, that's for sure. You should tell someone about this."
	icon_state = "carrot"
	abstract_type = /obj/item/food/grown/carrotlike
	/// What do we get from inadequately sharpening this?
	var/shiv_type = null
	/// What do we get from adequately sharpening this?
	var/blade_type = null
	/// What do we call our new weapon?
	var/blade_string = null
	/// What do we subtract from potency when rolling for the better blade?
	var/potency_minimum = 50

/obj/item/food/grown/carrotlike/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!tool.get_sharpness())
		return NONE

	/// The blade our "carrot" will turn into once sharpened
	var/obj/item/blade
	/// Chance for it to become better than a shiv
	var/sword_chance = (max(0, seed.potency - potency_minimum) / 50)
	if (prob(sword_chance))
		blade = new blade_type
		to_chat(user, span_notice("You sharpen \the [src] into a [blade_string] with [tool]."))
	else
		blade = new shiv_type
		to_chat(user, span_notice("You sharpen \the [src] into a shiv with [tool]."))
	remove_item_from_storage(user)
	qdel(src)
	user.put_in_hands(blade)
	return ITEM_INTERACT_SUCCESS

// Carrot
/obj/item/seeds/carrot
	name = "carrot seed pack"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	species = "carrot"
	plantname = "Carrots"
	product = /obj/item/food/grown/carrotlike/carrot
	maturation = 10
	production = 1
	yield = 5
	instability = 15
	growthstages = 3
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
	mutatelist = list(/obj/item/seeds/carrot/parsnip, /obj/item/seeds/carrot/cahnroot)
	reagents_add = list(/datum/reagent/medicine/oculine = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)
	genes = list(/datum/plant_gene/trait/soil_lover)

/obj/item/food/grown/carrotlike/carrot
	seed = /obj/item/seeds/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	wine_power = 30

	shiv_type = /obj/item/knife/shiv/carrot
	blade_type = /obj/item/claymore/carrot
	blade_string = "sword"

/obj/item/food/grown/carrotlike/carrot/juice_typepath()
	return /datum/reagent/consumable/carrotjuice

// Parsnip
/obj/item/seeds/carrot/parsnip
	name = "parsnip seed pack"
	desc = "These seeds grow into parsnips."
	icon_state = "seed-parsnip"
	species = "parsnip"
	plantname = "Parsnip"
	product = /obj/item/food/grown/carrotlike/parsnip
	icon_dead = "carrot-dead"
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/aluminium = 0.05)

/obj/item/food/grown/carrotlike/parsnip
	seed = /obj/item/seeds/carrot/parsnip
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	foodtypes = VEGETABLES
	wine_power = 35

	shiv_type = /obj/item/knife/shiv/parsnip
	blade_type = /obj/item/melee/parsnip_sabre
	blade_string = "sabre"

/obj/item/food/grown/carrotlike/parsnip/juice_typepath()
	return /datum/reagent/consumable/parsnipjuice

// Cahn'root
/obj/item/seeds/carrot/cahnroot
	name = "cahn'root seed pack"
	desc = "These seeds grow into cahn'roots."
	icon_state = "seed-cahn'root"
	species = "cahn'root"
	plantname = "Cahn'root"
	product = /obj/item/food/grown/carrotlike/cahnroot
	genes = list(/datum/plant_gene/trait/soil_lover, /datum/plant_gene/trait/plant_type/weed_hardy)
	endurance = 50
	instability = 10
	icon_dead = "cahn'root-dead"
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/cellulose = 0.01, /datum/reagent/consumable/sugar = 0.01)
	rarity = 10
	graft_gene = /datum/plant_gene/trait/plant_type/weed_hardy

/obj/item/food/grown/carrotlike/cahnroot
	seed = /obj/item/seeds/carrot/cahnroot
	name = "cahn'root"
	desc = "Heavily modified version of terran carrot, originally made to survive the scarciest of environments by an enterprising scientist of Moth Flotilla, Cahn'Mang."
	icon_state = "cahn'root"
	foodtypes = VEGETABLES
	tastes = list("sweet dirt" = 1)
	distill_reagent = /datum/reagent/consumable/rootbeer

	shiv_type = /obj/item/knife/shiv/root
	blade_type = /obj/item/knife/combat/root
	blade_string = "dagger"
	potency_minimum = 25

/obj/item/food/grown/carrotlike/cahnroot/juice_typepath()
	return null

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
	genes = list(/datum/plant_gene/trait/soil_lover)
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
	genes = list(/datum/plant_gene/trait/soil_lover, /datum/plant_gene/trait/maxchem)
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
