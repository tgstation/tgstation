// Watermelon
/obj/item/seeds/watermelon
	name = "pack of watermelon seeds"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Watermelon Vines"
	product = /obj/item/food/grown/watermelon
	lifespan = 50
	endurance = 40
	instability = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/watermelon/holy, /obj/item/seeds/watermelon/barrel)
	reagents_add = list(/datum/reagent/water = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/seeds/watermelon/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.gib()
	new product(drop_location())
	qdel(src)
	return MANUAL_SUICIDE

/obj/item/food/grown/watermelon
	seed = /obj/item/seeds/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	juice_results = list(/datum/reagent/consumable/watermelonjuice = 0)
	wine_power = 40

/obj/item/food/grown/watermelon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/watermelonslice, 5, 20, screentip_verb = "Slice")

/obj/item/food/grown/watermelon/make_dryable()
	return //No drying

// Holymelon
/obj/item/seeds/watermelon/holy
	name = "pack of holymelon seeds"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/food/grown/holymelon
	genes = list(/datum/plant_gene/trait/glow/yellow, /datum/plant_gene/trait/anti_magic)
	mutatelist = null
	reagents_add = list(/datum/reagent/water/holywater = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20
	graft_gene = /datum/plant_gene/trait/glow/yellow

/obj/item/food/grown/holymelon
	seed = /obj/item/seeds/watermelon/holy
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	juice_results = list(/datum/reagent/water/holywater = 0)
	wine_power = 70 //Water to wine, baby.
	wine_flavor = "divinity"

/obj/item/food/grown/holymelon/make_dryable()
	return //No drying

/obj/item/food/grown/holymelon/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, check_liked = CALLBACK(src, PROC_REF(check_holyness)))

/*
 * Callback to be used with the edible component.
 * Checks whether or not the person eating the holymelon
 * is a holy_role (chaplain), as chaplains love holymelons.
 */
/obj/item/food/grown/holymelon/proc/check_holyness(fraction, mob/mob_eating)
	if(!ishuman(mob_eating))
		return
	var/mob/living/carbon/human/holy_person = mob_eating
	if(!holy_person.mind?.holy_role || HAS_TRAIT(holy_person, TRAIT_AGEUSIA))
		return
	to_chat(holy_person, span_notice("Truly, a piece of heaven!"))
	holy_person.add_mood_event("Divine_chew", /datum/mood_event/holy_consumption)
	return FOOD_LIKED

/// Barrel melon Seeds
/obj/item/seeds/watermelon/barrel
	name = "pack of barrelmelon seeds"
	desc = "These seeds grow into barrelmelon plants."
	icon_state = "seed-barrelmelon"
	species = "barrelmelon"
	plantname = "Barrel Melon Vines"
	product = /obj/item/food/grown/barrelmelon
	genes = list(/datum/plant_gene/trait/brewing)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/ethanol/ale = 0.2, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 10
	graft_gene = /datum/plant_gene/trait/brewing

/// Barrel melon Fruit
/obj/item/food/grown/barrelmelon
	seed = /obj/item/seeds/watermelon/barrel
	name = "barrelmelon"
	desc = "The nutriments within this melon have been compressed and fermented into rich alcohol."
	icon_state = "barrelmelon"
	distill_reagent = /datum/reagent/medicine/antihol //You can call it a integer overflow.
