/mob/living/basic/bee/friendly
	name = "friendly maintenance bee"
	desc = "He wants to bee friends!"
	faction = list(FACTION_NEUTRAL)
	response_help_continuous = "hugs"
	response_help_simple = "hug"
	attack_verb_continuous = "nuzzles"
	attack_verb_simple = "nuzzle"
	melee_damage_lower = 0
	melee_damage_upper = 0
	obj_damage = 0
	icon_base = "bee"


/mob/living/basic/bee/friendly/Initialize()
	. = ..()
	var/datum/reagent/R = pick(typesof(/datum/reagent/drug)) //if it's from maint, it's probably drugs
	assign_reagent(GLOB.chemical_reagents_list[R])

/obj/item/stack/sheet/animalhide/bee
	name = "bee fuzz"
	desc = "How could you do this."
	singular_name = "a piece of bee fuzz"
	icon = 'monkestation/icons/mob/simple/bees.dmi'
	icon_state = "sheet-bee_fuzz"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/bee

/obj/item/food/pollensac
	name = "pollen sac"
	desc = "A pollen sac dropped from a bee."
	icon = 'monkestation/icons/mob/simple/bees.dmi'
	icon_state = "pollen_sac"
	bite_consumption = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("honey" = 1)
	foodtypes = SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	var/datum/reagent/beegent

GLOBAL_LIST_INIT(bee_recipes, list ( \
	new/datum/stack_recipe("bee jumpsuit", /obj/item/clothing/under/costume/bee, 3, check_density = FALSE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("bee hat", /obj/item/clothing/head/bee, 2, check_density = FALSE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("bee cloak", /obj/item/clothing/neck/beecloak, 5, check_density = FALSE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("bee costume", /obj/item/clothing/suit/hooded/bee_costume, 6, check_density = FALSE, category = CAT_CLOTHING), \
	))

/obj/item/stack/sheet/animalhide/bee/get_main_recipes()
	. = ..()
	. += GLOB.bee_recipes
