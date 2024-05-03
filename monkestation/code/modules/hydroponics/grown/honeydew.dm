/obj/item/seeds/watermelon/honeydew
	name = "pack of honeydew melon seeds"
	desc = "These seeds grow into sweet honeydew melon plants."
	icon = 'monkestation/icons/obj/hydroponics/fruit.dmi'
	icon_state = "honeydew-seed"
	icon_dead = "honeydew-dead"
	icon_grow = null
	icon_harvest = null
	species = "honeydew"
	plantname = "Honeydew Melon Vines"
	product = /obj/item/food/grown/honeydew
	lifespan = 60
	endurance = 40
	growing_icon = 'monkestation/icons/obj/hydroponics/growing.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.1, /datum/reagent/consumable/nutriment = 0.15)
	rarity = 20
	graft_gene = /datum/plant_gene/trait/repeated_harvest

/obj/item/food/grown/honeydew
	seed = /obj/item/seeds/watermelon/honeydew
	name = "honeydew melon"
	desc = "A sweet melon variant that, bizarrely, distills into honey."
	icon = 'monkestation/icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeydew"
	foodtypes = FRUIT
	distill_reagent = /datum/reagent/consumable/honey

/obj/item/food/grown/honeydew/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/honeydewslice, 6, 20, screentip_verb = "Slice")

/obj/item/food/grown/honeydew/Initialize()
	. = ..()
	// Used to check if they are wearing a horsemask
	RegisterSignal(src, COMSIG_FOOD_EATEN, PROC_REF(check_horse_mask))

/// Checks if the consumer of this honeydew is wearing a horse mask, if they are give them an achievement
/obj/item/food/grown/honeydew/proc/check_horse_mask(obj/item/our_plant, mob/living/carbon/human/eater, mob/feeder)
	SIGNAL_HANDLER

	// If they arent wearing a horsemask they dont get the achievement
	if(!istype(eater.wear_mask, /obj/item/clothing/mask/animal/horsehead))
		return

	to_chat(eater, span_notice("Not bad actually."))
	// Gives them the honeydew achievement
	eater.client.give_award(/datum/award/achievement/misc/jared_leto, eater)

