/obj/item/food/honeydewslice
	name = "honeydew melon slice"
	desc = "a sweet slice of honeydew"
	icon = 'monkestation/icons/obj/food/misc.dmi'
	icon_state = "honeydewslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 0.25,
		/datum/reagent/consumable/nutriment = 0.75
	)
	tastes = list("watery honey" = 1)
	foodtypes = FRUIT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/badrecipe/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)
