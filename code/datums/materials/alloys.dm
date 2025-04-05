/** Materials made from other materials.
 */
/datum/material/alloy
	name = "alloy"
	desc = "A material composed of two or more other materials."
	init_flags = NONE
	/// The materials this alloy is made from weighted by their ratios.
	var/list/composition = null

/datum/material/alloy/return_composition(amount = 1)
	. = list()

	var/list/cached_comp = composition
	for(var/comp_mat in cached_comp)
		var/datum/material/component_material = GET_MATERIAL_REF(comp_mat)
		var/list/component_composition = component_material.return_composition(cached_comp[comp_mat])
		for(var/comp_comp_mat in component_composition)
			.[comp_comp_mat] += component_composition[comp_comp_mat] * amount


/** Plasteel
 *
 * An alloy of iron and plasma.
 * Applies a significant slowdown effect to any and all items that contain it.
 */
/datum/material/alloy/plasteel
	name = "plasteel"
	desc = "The heavy duty result of infusing iron with plasma."
	color = "#706374"
	init_flags = MATERIAL_INIT_MAPLOAD
	value_per_unit = 0.135
	strength_modifier = 1.25
	integrity_modifier = 1.5 // Heavy duty.
	armor_modifiers = list(MELEE = 1.4, BULLET = 1.4, LASER = 1.1, ENERGY = 1.1, BOMB = 1.5, BIO = 1, FIRE = 1.1, ACID = 1)
	sheet_type = /obj/item/stack/sheet/plasteel
	categories = list(
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	composition = list(/datum/material/iron=1, /datum/material/plasma=1)
	mat_rust_resistance = RUST_RESISTANCE_REINFORCED
	added_slowdown = 0.05
	fish_weight_modifier = 1.75
	fishing_difficulty_modifier = 5
	fishing_experience_multiplier = 1.1
	fishing_gravity_mult = 1.6

/datum/material/alloy/plasteel/on_applied(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		ADD_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/alloy/plasteel/on_removed(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		REMOVE_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/** Plastitanium
 *
 * An alloy of titanium and plasma.
 */
/datum/material/alloy/plastitanium
	name = "plastitanium"
	desc = "The extremely heat resistant result of infusing titanium with plasma."
	color = "#3a313a"
	init_flags = MATERIAL_INIT_MAPLOAD
	value_per_unit = 0.225
	strength_modifier = 0.9 // It's a lightweight alloy.
	integrity_modifier = 1.3
	armor_modifiers = list(MELEE = 1.1, BULLET = 1.1, LASER = 1.4, ENERGY = 1.4, BOMB = 1.1, BIO = 1.2, FIRE = 1.5, ACID = 1)
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	categories = list(
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	composition = list(/datum/material/titanium=1, /datum/material/plasma=1)
	mat_rust_resistance = RUST_RESISTANCE_TITANIUM
	fish_weight_modifier = 1.1
	fishing_difficulty_modifier = -7
	fishing_cast_range = 1
	fishing_experience_multiplier = 0.95

/datum/material/alloy/plastitanium/on_applied(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		ADD_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/alloy/plastitanium/on_removed(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		REMOVE_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/** Plasmaglass
 *
 * An alloy of silicate and plasma.
 */
/datum/material/alloy/plasmaglass
	name = "plasmaglass"
	desc = "Plasma-infused silicate. It is much more durable and heat resistant than either of its component materials."
	color = "#ff80f4"
	alpha = 150
	starlight_color = COLOR_STRONG_MAGENTA
	init_flags = MATERIAL_INIT_MAPLOAD
	integrity_modifier = 0.5
	armor_modifiers = list(MELEE = 0.8, BULLET = 0.8, LASER = 1.2, ENERGY = 1.2, BOMB = 0.3, BIO = 1.2, FIRE = 2, ACID = 2)
	sheet_type = /obj/item/stack/sheet/plasmaglass
	shard_type = /obj/item/shard/plasma
	debris_type = /obj/effect/decal/cleanable/glass/plasma
	value_per_unit = 0.075
	categories = list(
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	composition = list(/datum/material/glass=1, /datum/material/plasma=0.5)
	fish_weight_modifier = 1.2
	fishing_difficulty_modifier = 5
	fishing_experience_multiplier = 1.3
	fishing_gravity_mult = 0.9

/** Titaniumglass
 *
 * An alloy of glass and titanium.
 */
/datum/material/alloy/titaniumglass
	name = "titanium glass"
	desc = "A specialized silicate-titanium alloy that is commonly used in shuttle windows."
	color = "#cfbee0"
	alpha = 150
	starlight_color = COLOR_COMMAND_BLUE
	init_flags = MATERIAL_INIT_MAPLOAD
	armor_modifiers = list(MELEE = 1.2, BULLET = 1.2, LASER = 0.8, ENERGY = 0.8, BOMB = 0.5, BIO = 1.2, FIRE = 0.8, ACID = 2)
	sheet_type = /obj/item/stack/sheet/titaniumglass
	shard_type = /obj/item/shard/titanium
	debris_type = /obj/effect/decal/cleanable/glass/titanium
	value_per_unit = 0.04
	categories = list(
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	composition = list(/datum/material/glass=1, /datum/material/titanium=0.5)
	fish_weight_modifier = 1.25
	fishing_difficulty_modifier = -5
	fishing_experience_multiplier = 1.25
	fishing_gravity_mult = 0.95

/** Plastitanium Glass
 *
 * An alloy of plastitanium and glass.
 */
/datum/material/alloy/plastitaniumglass
	name = "plastitanium glass"
	desc = "A specialized silicate-plastitanium alloy."
	color = "#5d3369"
	starlight_color = COLOR_CENTCOM_BLUE
	alpha = 150
	init_flags = MATERIAL_INIT_MAPLOAD
	integrity_modifier = 1.1
	armor_modifiers = list(MELEE = 1.2, BULLET = 1.2, LASER = 1.2, ENERGY = 1.2, BOMB = 0.5, BIO = 1.2, FIRE = 2, ACID = 2)
	sheet_type = /obj/item/stack/sheet/plastitaniumglass
	shard_type = /obj/item/shard/plastitanium
	debris_type = /obj/effect/decal/cleanable/glass/plastitanium
	value_per_unit = 0.125
	categories = list(
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	composition = list(/datum/material/glass=1, /datum/material/alloy/plastitanium=0.5)
	fish_weight_modifier = 1.2
	fishing_experience_multiplier = 1.5
	fishing_gravity_mult = 0.9

/** Alien Alloy
 *
 * Densified plasteel.
 * Applies a significant slowdown effect to anything that contains it.
 * Anything constructed from it can slowly regenerate.
 */
/datum/material/alloy/alien
	name = "alien alloy"
	desc = "An extremely dense alloy similar to plasteel in composition. It requires exotic metallurgical processes to create."
	color = "#6041aa"
	init_flags = MATERIAL_INIT_MAPLOAD
	strength_modifier = 1.5 // It's twice the density of plasteel and just as durable. Getting hit with it is going to HURT.
	integrity_modifier = 1.5
	armor_modifiers = list(MELEE = 1.4, BULLET = 1.4, LASER = 1.2, ENERGY = 1.2, BOMB = 1.5, BIO = 1.2, FIRE = 1.2, ACID = 1.2)
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	value_per_unit = 0.4
	categories = list(
		MAT_CATEGORY_RIGID=TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
	)
	composition = list(/datum/material/iron=2, /datum/material/plasma=2)
	added_slowdown = 0.1
	fish_weight_modifier = 2.4
	fishing_difficulty_modifier = -20
	fishing_cast_range = 2
	fishing_experience_multiplier = 0.5
	fishing_completion_speed = 2
	fishing_bait_speed_mult = 1.25
	fishing_deceleration_mult = 1.5
	fishing_bounciness_mult = 0.5
	fishing_gravity_mult = 2

/datum/material/alloy/alien/on_applied(atom/target, mat_amount, multiplier)
	. = ..()
	if(isobj(target))
		target.AddElement(/datum/element/obj_regen, _rate=0.02) // 2% regen per tick.
	if(istype(target, /obj/item/fishing_rod))
		ADD_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/alloy/alien/on_removed(atom/target, mat_amount, multiplier)
	. = ..()
	if(isobj(target))
		target.RemoveElement(/datum/element/obj_regen, _rate=0.02)
	if(istype(target, /obj/item/fishing_rod))
		REMOVE_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))
