/obj/item/food/grown/melonlike
	seed = /obj/item/seeds/watermelon
	name = "melon?"
	desc = "You felt like this was a melon, but it definitely isn't. You should tell somebody about this."
	icon_state = "watermelon"
	inhand_icon_state = "watermelon"
	abstract_type = /obj/item/food/grown/melonlike
	/// chestplate made by hollowing out the melon
	var/chestplate_type = null
	/// fire-resistant version of above
	var/fire_resistant_chestplate_type = null
	/// headgear received by hollowing out the melon
	var/helmet_type = null
	/// fire-resistant version of above
	var/fire_resistant_helmet_type = null
	/// pulp received by hollowing out the melon
	var/pulp_type = null
	/// slices received by cutting the melon
	var/slice_type = null

/obj/item/food/grown/melonlike/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, 5, 20, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/grown/melonlike/make_dryable()
	return //No drying

/obj/item/food/grown/melonlike/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/kitchen/spoon))
		return NONE

	var/pulp_count = 1
	if(seed)
		pulp_count += round(seed.potency / 25)

	user.balloon_alert(user, "scooped out [pulp_count] pulp(s)")
	for(var/i in 1 to pulp_count)
		new pulp_type(user.loc)

	/// The piece of armour melon turns into; either chetsplate or helmet
	var/obj/item/clothing/received_armor
	if (prob(max(0, seed.potency - 50) / 50))
		if(seed.resistance_flags & FIRE_PROOF)
			received_armor = new fire_resistant_chestplate_type
		else
			received_armor = new chestplate_type
		to_chat(user, span_notice("You hollow \the [src] into a helmet with [tool]."))
	else
		if(seed.resistance_flags & FIRE_PROOF)
			received_armor = new fire_resistant_helmet_type
		else
			received_armor = new helmet_type
		to_chat(user, span_notice("You hollow \the [src] into a chestplate with [tool]."))

	remove_item_from_storage(user)
	qdel(src)
	user.put_in_hands(received_armor)
	return ITEM_INTERACT_SUCCESS


// Watermelon
/obj/item/seeds/watermelon
	name = "watermelon seed pack"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Watermelon Vines"
	product = /obj/item/food/grown/melonlike/watermelon
	lifespan = 50
	endurance = 40
	instability = 20
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/watermelon/holy, /obj/item/seeds/watermelon/barrel)
	reagents_add = list(/datum/reagent/water = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/seeds/watermelon/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.gib(DROP_ALL_REMAINS)
	new product(drop_location())
	qdel(src)
	return MANUAL_SUICIDE

/obj/item/food/grown/melonlike/watermelon
	seed = /obj/item/seeds/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	inhand_icon_state = "watermelon"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	wine_power = 40

	fire_resistant_chestplate_type = /obj/item/clothing/suit/armor/durability/watermelon/fire_resist
	chestplate_type = /obj/item/clothing/suit/armor/durability/watermelon
	fire_resistant_helmet_type = /obj/item/clothing/head/helmet/durability/watermelon/fire_resist
	helmet_type = /obj/item/clothing/head/helmet/durability/watermelon
	pulp_type = /obj/item/food/watermelonmush
	slice_type = /obj/item/food/watermelonslice

/obj/item/food/grown/melonlike/watermelon/juice_typepath()
	return /datum/reagent/consumable/watermelonjuice

// Holymelon
/obj/item/seeds/watermelon/holy
	name = "holymelon seed pack"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/food/grown/melonlike/holymelon
	genes = list(/datum/plant_gene/trait/glow/yellow, /datum/plant_gene/trait/anti_magic)
	mutatelist = null
	reagents_add = list(/datum/reagent/water/holywater = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = PLANT_MODERATELY_RARE
	graft_gene = /datum/plant_gene/trait/glow/yellow

/obj/item/food/grown/melonlike/holymelon
	seed = /obj/item/seeds/watermelon/holy
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon"
	inhand_icon_state = "holymelon"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	wine_power = 70 //Water to wine, baby.
	wine_flavor = "divinity"

	fire_resistant_chestplate_type = /obj/item/clothing/suit/armor/durability/holymelon/fire_resist
	chestplate_type = /obj/item/clothing/suit/armor/durability/holymelon
	fire_resistant_helmet_type = /obj/item/clothing/head/helmet/durability/holymelon/fire_resist
	helmet_type = /obj/item/clothing/head/helmet/durability/holymelon
	pulp_type = /obj/item/food/holymelonmush
	slice_type = /obj/item/food/holymelonslice

/obj/item/food/grown/melonlike/holymelon/juice_typepath()
	return /datum/reagent/water/holywater

/obj/item/food/grown/melonlike/holymelon/make_edible()
	. = ..()
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, check_liked = CALLBACK(src, PROC_REF(check_holyness)))

/*
 * Callback to be used with the edible component.
 * Checks whether or not the person eating the holymelon
 * is a holy_role (chaplain), as chaplains love holymelons.
 */
/obj/item/food/grown/melonlike/holymelon/proc/check_holyness(mob/mob_eating)
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
	name = "barrelmelon seed pack"
	desc = "These seeds grow into barrelmelon plants."
	icon_state = "seed-barrelmelon"
	species = "barrelmelon"
	plantname = "Barrel Melon Vines"
	product = /obj/item/food/grown/melonlike/barrelmelon
	genes = list(/datum/plant_gene/trait/brewing)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/ethanol/ale = 0.2, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 10
	graft_gene = /datum/plant_gene/trait/brewing

/// Barrel melon Fruit
/obj/item/food/grown/melonlike/barrelmelon
	seed = /obj/item/seeds/watermelon/barrel
	name = "barrelmelon"
	desc = "The nutriments within this melon have been compressed and fermented into rich alcohol."
	icon_state = "barrelmelon"
	inhand_icon_state = "barrelmelon"
	distill_reagent = /datum/reagent/medicine/antihol //You can call it a integer overflow.

	fire_resistant_chestplate_type = /obj/item/clothing/suit/armor/durability/barrelmelon/fire_resist
	chestplate_type = /obj/item/clothing/suit/armor/durability/barrelmelon
	fire_resistant_helmet_type = /obj/item/clothing/head/helmet/durability/barrelmelon/fire_resist
	helmet_type = /obj/item/clothing/head/helmet/durability/barrelmelon
	pulp_type = /obj/item/food/barrelmelonmush
	slice_type = /obj/item/food/barrelmelonslice

