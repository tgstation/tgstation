/obj/item/seeds/onion
	name = "onion seed pack"
	desc = "These seeds grow into onions."
	icon_state = "seed-onion"
	species = "onion"
	plantname = "Onion Sprouts"
	product = /obj/item/food/grown/onion
	lifespan = 20
	maturation = 3
	production = 4
	yield = 6
	endurance = 25
	instability = 10
	growthstages = 3
	weed_chance = 3
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/tearjuice = 0.25)
	mutatelist = list(/obj/item/seeds/onion/red)

/obj/item/food/grown/onion
	seed = /obj/item/seeds/onion
	name = "onion"
	desc = "Nothing to cry over."
	icon_state = "onion"
	tastes = list("onions" = 1)
	wine_power = 30

/obj/item/food/grown/onion/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/onion_slice, 2, 15, screentip_verb = "Cut")

/obj/item/seeds/onion/red
	name = "red onion seed pack"
	desc = "For growing exceptionally potent onions."
	icon_state = "seed-onionred"
	species = "onion_red"
	plantname = "Red Onion Sprouts"
	weed_chance = 1
	product = /obj/item/food/grown/onion/red
	mutatelist = null

/obj/item/food/grown/onion/red
	seed = /obj/item/seeds/onion/red
	name = "red onion"
	desc = "Purple despite the name."
	icon_state = "onion_red"
	wine_power = 60

/obj/item/food/grown/onion/red/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/onion_slice/red, 2, 15, screentip_verb = "Cut")

/obj/item/food/grown/onion/UsedforProcessing(mob/living/user, obj/item/I, list/chosen_option)
	var/datum/effect_system/fluid_spread/smoke/chem/cry_about_it = new //Since the onion is destroyed when it's sliced,
	var/splat_location = get_turf(src) //we need to set up the smoke beforehand
	cry_about_it.attach(splat_location)
	cry_about_it.set_up(0, holder = src, location = splat_location, carry = reagents, silent = FALSE)
	cry_about_it.start()
	qdel(cry_about_it)
	return ..()

/obj/item/food/onion_slice
	name = "onion slice"
	desc = "Ring, not for wearing."
	icon_state = "onionslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/onion_slice/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/onionrings, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/onion_slice/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/onionrings)

/obj/item/food/onion_slice/red
	name = "red onion slice"
	desc = "It shines like an exceptionally low quality amethyst."
	icon_state = "onionslice_red"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/tearjuice = 2.5)
