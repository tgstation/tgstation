/obj/item/stack/sheet/mineral/stone
	name = "stone"
	desc = "Stone brick."
	singular_name = "stone block"
	icon = 'modular_doppler/stone/icons/ore.dmi'
	icon_state = "sheet-stone"
	inhand_icon_state = "sheet-metal"
	mats_per_unit = list(/datum/material/stone=SHEET_MATERIAL_AMOUNT)
	force = 10
	throwforce = 15
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/mineral/stone
	grind_results = null
	material_type = /datum/material/stone
	matter_amount = 0
	source = null
	walltype = /turf/closed/wall/mineral/stone
	stairs_type = /obj/structure/stairs/stone
	drop_sound = SFX_BRICK_DROP
	pickup_sound = SFX_BRICK_PICKUP

GLOBAL_LIST_INIT(stone_recipes, list ( \
	new/datum/stack_recipe("stone brick wall", /turf/closed/wall/mineral/stone, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_APPLIES_MATS, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("stone brick tile", /obj/item/stack/tile/mineral/stone, 1, 4, 20, category = CAT_TILES),
	new/datum/stack_recipe("millstone", /obj/structure/millstone, 6, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone cauldron", /obj/machinery/cauldron, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone stove", /obj/machinery/primitive_stove, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone oven", /obj/machinery/oven/stone, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	new/datum/stack_recipe("stone griddle", /obj/machinery/griddle/stone, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE),
	))

/obj/item/stack/sheet/mineral/stone/get_main_recipes()
	. = ..()
	. += GLOB.stone_recipes

/datum/material/stone
	name = "stone"
	desc = "It's stone."
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/stone
	value_per_unit = 0.005
	beauty_modifier = 0.01
	color = "#59595a"
	greyscale_colors = "#59595a"
	value_per_unit = 0.0025
	armor_modifiers = list(MELEE = 0.75, BULLET = 0.5, LASER = 1.25, ENERGY = 0.5, BOMB = 0.5, BIO = 0.25, FIRE = 1.5, ACID = 1.5)
	beauty_modifier = 0.3
	turf_sound_override = FOOTSTEP_PLATING

/obj/item/stack/stone
	name = "rough stone"
	desc = "Large chunks of uncut stone, tough enough to safely build out of... if you could manage to cut them into something usable."
	icon = 'modular_doppler/stone/icons/ore.dmi'
	icon_state = "stone_ore"
	singular_name = "rough stone boulder"
	mats_per_unit = list(/datum/material/stone = SHEET_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/stone
	force = 10
	throwforce = 15

/obj/item/stack/stone/examine()
	. = ..()
	. += span_notice("With a <b>chisel</b> or even a <b>pickaxe</b> of some kind, you could cut this into <b>blocks</b>.")

/obj/item/stack/stone/attackby(obj/item/attacking_item, mob/user, params)
	if((attacking_item.tool_behaviour != TOOL_MINING) && !(istype(attacking_item, /obj/item/chisel)))
		return ..()
	playsound(src, 'sound/effects/picaxe1.ogg', 50, TRUE)
	balloon_alert_to_viewers("cutting...")
	if(!do_after(user, 5 SECONDS, target = src))
		balloon_alert_to_viewers("stopped cutting")
		return FALSE
	new /obj/item/stack/sheet/mineral/stone(get_turf(src), amount)
	qdel(src)

/obj/item/stack/tile/mineral/stone
	name = "stone tile"
	singular_name = "stone floor tile"
	desc = "A tile made of stone bricks, for that fortress look."
	icon_state = "tile_herringbone"
	inhand_icon_state = "tile"
	turf_type = /turf/open/floor/stone
	mineralType = "stone"
	mats_per_unit = list(/datum/material/stone= HALF_SHEET_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/tile/mineral/stone

/turf/open/floor/stone
	desc = "Blocks of stone arranged in a tile-like pattern, odd, really, how it looks like real stone too, because it is!" //A play on the original description for stone tiles

/turf/closed/wall/mineral/stone
	name = "stone wall"
	desc = "A wall made of solid stone bricks."
	icon = 'modular_doppler/stone/icons/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	sheet_type = /obj/item/stack/sheet/mineral/stone
	explosive_resistance = 2 // Rock and stone to the bone, or at least a bit longer than walls made of metal sheets!
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS
	custom_materials = list(
		/datum/material/stone = SHEET_MATERIAL_AMOUNT  * 2,
	)

/turf/closed/wall/mineral/stone/try_decon(obj/item/item_used, mob/user) // Lets you break down stone walls with stone breaking tools
	if(item_used.tool_behaviour != TOOL_MINING)
		return ..()

	if(!item_used.tool_start_check(user, amount = 0))
		return FALSE

	balloon_alert_to_viewers("breaking down...")

	if(!item_used.use_tool(src, user, 5 SECONDS))
		return FALSE
	dismantle_wall()
	return TRUE

/turf/closed/indestructible/stone
	name = "stone wall"
	desc = "A wall made of unusually solid stone bricks."
	icon = 'modular_doppler/stone/icons/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS
	custom_materials = list(
		/datum/material/stone = SHEET_MATERIAL_AMOUNT  * 2,
	)

/obj/structure/falsewall/stone
	name = "stone wall"
	desc = "A wall made of solid stone bricks."
	icon = 'modular_doppler/stone/icons/wall.dmi'
	icon_state = "wall-open"
	base_icon_state = "wall"
	fake_icon = 'modular_doppler/stone/icons/wall.dmi'
	mineral = /obj/item/stack/sheet/mineral/stone
	walltype = /turf/closed/wall/mineral/stone
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_STONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_STONE_WALLS

/turf/closed/mineral/gets_drilled(mob/user, give_exp = FALSE)
	if(prob(5))
		new /obj/item/stack/stone(src)

	return ..()

/obj/item/stack/sheet/mineral/stone/fifty
	amount = 50
