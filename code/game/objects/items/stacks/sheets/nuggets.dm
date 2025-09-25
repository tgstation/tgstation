// A small denominational amount, in the same vein as glass shards.

/obj/item/stack/nugget
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/ore.dmi'
	force = 2
	throwforce = 3
	max_amount = 30
	armor_type = /datum/armor/item_shard
	material_type = null
	item_flags = ABSTRACT
	singular_name = "bit"
	var/icon_prefix = ""

/obj/item/stack/nugget/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()
	update_appearance()

/obj/item/stack/nugget/update_icon_state()
	. = ..()
	var/amount = get_amount()
	if(amount <= 5)
		icon_state = "[icon_prefix]_nugget[amount > 1 ? "[amount]" : ""]"
	else
		icon_state = "[icon_prefix]_nuggets"

/obj/item/stack/nugget/gold
	name = "gold nugget"
	desc = "A tiny chunk of precious, shiny metal."
	icon_state = "gold_nugget"
	singular_name = "gold nugget"
	w_class = WEIGHT_CLASS_TINY
	force = 2
	throwforce = 3
	max_amount = 30
	mats_per_unit = list(/datum/material/gold = COIN_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/gold = 2)
	item_flags = SKIP_FANTASY_ON_SPAWN
	icon_prefix = "gold"

/obj/item/stack/nugget/uranium
	name = "uranium sliver"
	desc = "A tiny sliver of dull, radioactive metal."
	icon_state = "uranium_nugget"
	singular_name = "uranium sliver"
	mats_per_unit = list(/datum/material/uranium = COIN_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/uranium = 2)
	item_flags = SKIP_FANTASY_ON_SPAWN
	icon_prefix = "uranium"

/obj/item/stack/nugget/plasma
	name = "plasma chunk"
	desc = "A tiny chunk of glassy, reactive material."
	icon_state = "plasma_nugget"
	singular_name = "plasma chunk"
	resistance_flags = FLAMMABLE
	mats_per_unit = list(/datum/material/plasma = COIN_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/toxin/plasma = 2)
	item_flags = SKIP_FANTASY_ON_SPAWN
	icon_prefix = "plasma"
