/obj/item/crucifix
	name = "ornate crucifix"
	desc = "An ornate golden crucifix, adorned with various gemstones and tiny carvings. For some reason, it always feels warm to the touch."
	icon = 'modular_skyrat/modules/modular_items/icons/obj/items/crucifix.dmi'
	icon_state = "cross_ornate"
	lefthand_file = 'modular_skyrat/modules/modular_items/icons/mob/inhands/cross_left.dmi'
	righthand_file = 'modular_skyrat/modules/modular_items/icons/mob/inhands/cross_right.dmi'
	force = 10 //Gem-encrusted and reinforced with GOD
	throw_speed = 3
	throw_range = 4
	throwforce = 15
	w_class = WEIGHT_CLASS_TINY

/datum/crafting_recipe/cross
	name = "Ornate Cross"
	result = /obj/item/crucifix
	reqs = list(/obj/item/stack/sheet/mineral/gold = 1,
				/obj/item/stack/sheet/mineral/diamond = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 20
	category = CAT_MISC
