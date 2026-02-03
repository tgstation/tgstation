/// Materials made from other materials.
/datum/material/alloy
	name = "alloy"
	desc = "A material composed of two or more other materials."
	abstract_type = /datum/material/alloy
	/// The materials this alloy is made from weighted by their ratios.
	var/list/composition = null

/datum/material/alloy/return_composition(amount = 1, flags)
	if(flags & MATCONTAINER_ACCEPT_ALLOYS)
		return ..()

	. = list()

	var/list/cached_comp = composition
	for(var/comp_mat in cached_comp)
		var/datum/material/component_material = SSmaterials.get_material(comp_mat)
		var/list/component_composition = component_material.return_composition(cached_comp[comp_mat], flags)
		for(var/comp_comp_mat in component_composition)
			.[comp_comp_mat] += component_composition[comp_comp_mat] * amount

/**
 * Plasteel
 * An alloy of iron and plasma.
 * Applies a significant slowdown effect to any and all items that contain it.
 */
/datum/material/alloy/plasteel
	name = "plasteel"
	desc = "The heavy duty result of infusing iron with plasma."
	color = "#706374"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 6,
		MATERIAL_HARDNESS = 8,
		MATERIAL_FLEXIBILITY = 1,
		MATERIAL_REFLECTIVITY = 5,
		MATERIAL_ELECTRICAL = 8,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 6,
	)
	value_per_unit = 0.135
	sheet_type = /obj/item/stack/sheet/plasteel
	material_reagent = list(/datum/reagent/iron = 1, /datum/reagent/toxin/plasma = 1)
	composition = list(/datum/material/iron = 1, /datum/material/plasma = 1)
	mat_rust_resistance = RUST_RESISTANCE_REINFORCED

/datum/material/alloy/plasteel/on_applied(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		ADD_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/alloy/plasteel/on_removed(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		REMOVE_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/**
 * Plastitanium
 * An alloy of titanium and plasma.
 */
/datum/material/alloy/plastitanium
	name = "plastitanium"
	desc = "The extremely heat resistant result of infusing titanium with plasma."
	color = "#3a313a"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 8,
		MATERIAL_FLEXIBILITY = 1,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 8,
	)
	value_per_unit = 0.225
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	material_reagent = /datum/reagent/toxin/plasma
	composition = list(/datum/material/titanium = 1, /datum/material/plasma = 1)
	mat_rust_resistance = RUST_RESISTANCE_TITANIUM

/datum/material/alloy/plastitanium/on_applied(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		ADD_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/datum/material/alloy/plastitanium/on_removed(atom/target, mat_amount, multiplier)
	. = ..()
	if(istype(target, /obj/item/fishing_rod))
		REMOVE_TRAIT(target, TRAIT_ROD_LAVA_USABLE, REF(src))

/**
 * Plasmaglass
 * An alloy of silicate and plasma.
 */
/datum/material/alloy/plasmaglass
	name = "plasmaglass"
	desc = "Plasma-infused silicate. It is much more durable and heat resistant than either of its component materials."
	color = "#ff80f4"
	alpha = 150
	starlight_color = COLOR_STRONG_MAGENTA
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 5,
		MATERIAL_HARDNESS = 6,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 0,
		MATERIAL_THERMAL = 2,
		MATERIAL_CHEMICAL = 8,
	)
	sheet_type = /obj/item/stack/sheet/plasmaglass
	shard_type = /obj/item/shard/plasma
	debris_type = /obj/effect/decal/cleanable/glass/plasma
	material_reagent = list(/datum/reagent/silicon = 1, /datum/reagent/toxin/plasma = 0.5)
	value_per_unit = 0.075
	composition = list(/datum/material/glass = 1, /datum/material/plasma = 0.5)

/**
 * Titanium Glass
 * An alloy of glass and titanium.
 */
/datum/material/alloy/titaniumglass
	name = "titanium glass"
	desc = "A specialized silicate-titanium alloy that is commonly used in shuttle windows."
	color = "#cfbee0"
	alpha = 150
	starlight_color = COLOR_COMMAND_BLUE
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 5,
		MATERIAL_HARDNESS = 5,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 0,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 8,
	)
	sheet_type = /obj/item/stack/sheet/titaniumglass
	shard_type = /obj/item/shard/titanium
	debris_type = /obj/effect/decal/cleanable/glass/titanium
	material_reagent = /datum/reagent/silicon
	value_per_unit = 0.04
	composition = list(/datum/material/glass = 1, /datum/material/titanium = 0.5)

/**
 * Plastitanium Glass
 * An alloy of plastitanium and glass.
 */
/datum/material/alloy/plastitaniumglass
	name = "plastitanium glass"
	desc = "A specialized silicate-plastitanium alloy."
	color = "#5d3369"
	starlight_color = COLOR_CENTCOM_BLUE
	alpha = 150
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 8,
		MATERIAL_FLEXIBILITY = 0,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 0,
		MATERIAL_THERMAL = 2,
		MATERIAL_CHEMICAL = 8,
	)
	sheet_type = /obj/item/stack/sheet/plastitaniumglass
	shard_type = /obj/item/shard/plastitanium
	debris_type = /obj/effect/decal/cleanable/glass/plastitanium
	material_reagent = list(/datum/reagent/silicon = 1, /datum/reagent/toxin/plasma = 0.5)
	value_per_unit = 0.125
	composition = list(/datum/material/glass = 1, /datum/material/alloy/plastitanium = 0.5)

/**
 * Alien Alloy
 * Densified plasteel.
 * Applies a significant slowdown effect to anything that contains it.
 * Anything constructed from it can slowly regenerate.
 */
/datum/material/alloy/alien
	name = "alien alloy"
	desc = "An extremely dense alloy similar to plasteel in composition. It requires exotic metallurgical processes to create."
	color = "#6041aa"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 8,
		MATERIAL_HARDNESS = 8,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 7,
		MATERIAL_ELECTRICAL = 8,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 10,
	)
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	material_reagent = list(/datum/reagent/iron = 1, /datum/reagent/toxin/plasma = 1)
	value_per_unit = 0.4
	composition = list(/datum/material/iron = 2, /datum/material/plasma = 2)

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
