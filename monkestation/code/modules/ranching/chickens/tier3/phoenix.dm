/mob/living/basic/chicken/phoenix
	icon_suffix = "spicy"

	breed_name = "Phoenix"
	egg_type = /obj/item/food/egg/phoenix
	mutation_list = list()

	book_desc = "These chickens have evolved to break the cycle of life and death and will always come back from the dead assuming their egg survives."

/mob/living/basic/chicken/phoenix/death()
	new /obj/effect/decal/cleanable/ash(loc)
	var/obj/item/food/egg/phoenix/rebirth = new /obj/item/food/egg/phoenix(loc)
	rebirth.layer_hen_type = src.type
	START_PROCESSING(SSobj, rebirth)
	..()
	qdel(src)

/obj/item/food/egg/phoenix
	name = "Burning Egg"
	icon_state = "phoenix"

	layer_hen_type = /mob/living/basic/chicken/phoenix

/obj/item/food/egg/phoenix/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	eater.apply_status_effect(/datum/status_effect/ranching/phoenix)

/datum/status_effect/ranching/phoenix
	id = "ranching_phoenix"
	duration = 60 SECONDS
	tick_interval = 12 SECONDS

/datum/status_effect/ranching/phoenix/tick()
	if(ishuman(owner))
		var/mob/living/carbon/human/user = owner
		user.adjustBruteLoss(-10)
		user.adjustFireLoss(-10)
		user.adjustToxLoss(-10)
