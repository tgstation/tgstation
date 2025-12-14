#define PLATFORM_BASE_MATERIAL_AMOUNT (2 * SHEET_MATERIAL_AMOUNT)

/// A raised platform you can stand on top of
/obj/structure/platform
	name = "platform"
	desc = "A raised platform which can make you slightly taller."
	icon = 'icons/obj/smooth_structures/platform/window_frame_normal.dmi'
	icon_state = "window_frame_normal-0"
	base_icon_state = "window_frame_normal"
	smoothing_flags = SMOOTH_BITMASK|SMOOTH_OBJ
	smoothing_groups = SMOOTH_GROUP_PLATFORMS
	canSmoothWith = SMOOTH_GROUP_PLATFORMS
	pass_flags_self = PASSTABLE | LETPASSTHROW | PASSGRILLE | PASSWINDOW
	opacity = FALSE
	density = TRUE
	rad_insulation = null
	max_integrity = 50
	anchored = TRUE
	armor_type = /datum/armor/half_wall
	material_flags = MATERIAL_EFFECTS | MATERIAL_AFFECT_STATISTICS
	/// Icon used for the frame
	var/frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_normal.dmi'
	/// Material used in our construction
	var/sheet_type = null
	/// Count of sheets used in our construction
	var/sheet_amount = 2
	/// What footstep do we use?
	var/footstep = FOOTSTEP_FLOOR
	/// Traits to give people who have clambered onto our tile
	var/static/list/turf_traits = list(TRAIT_TURF_IGNORE_SLOWDOWN, TRAIT_TURF_IGNORE_SLIPPERY, TRAIT_IMMERSE_STOPPED)

/datum/armor/half_wall
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10
	bio = 100
	fire = 0
	acid = 0

/obj/structure/platform/Initialize(mapload)
	. = ..()

	register_context()
	update_appearance(UPDATE_OVERLAYS)
	AddComponent(/datum/component/climb_walkable)
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)
	AddElement(/datum/element/give_turf_traits, string_list(turf_traits))
	AddElement(/datum/element/footstep_override, footstep = footstep, priority = STEP_SOUND_TABLE_PRIORITY)
	AddComponent(/datum/component/table_smash)

/obj/structure/platform/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_RMB] = "Disassemble"
		. = CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		. = CONTEXTUAL_SCREENTIP_SET

	return . || NONE

/obj/structure/platform/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You start disassembling [src]..."))
	if(tool.use_tool(src, user, 2 SECONDS, volume=50))
		deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/platform/wrench_act_secondary(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You start deconstructing [src]..."))
	if(tool.use_tool(src, user, 4 SECONDS, volume=50))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/platform/update_overlays()
	. = ..()
	if (frame_icon)
		. += mutable_appearance(frame_icon, "[base_icon_state]-[smoothing_junction]", appearance_flags = KEEP_APART)

/obj/structure/platform/set_smoothed_icon_state(new_junction)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/platform/atom_deconstruct(disassembled = TRUE)
	var/turf/target_turf = drop_location()
	if(sheet_type)
		new sheet_type(target_turf, sheet_amount)
	else
		for(var/datum/material/mat in custom_materials)
			new mat.sheet_type(target_turf, FLOOR(custom_materials[mat] / SHEET_MATERIAL_AMOUNT, 1))

/obj/structure/platform/rusty
	icon = 'icons/obj/smooth_structures/platform/window_frame_rusty.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_rusty.dmi'
	icon_state = "window_frame_rusty-0"
	base_icon_state = "window_frame_rusty"

// Shuttle themed

/obj/structure/platform/titanium
	icon = 'icons/obj/smooth_structures/platform/window_frame_shuttle.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_shuttle.dmi'
	icon_state = "window_frame_shuttle-0"
	base_icon_state = "window_frame_shuttle"
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	custom_materials = list(/datum/material/titanium = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_SHUTTLE
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_SHUTTLE

/obj/structure/platform/plastitanium
	icon = 'icons/obj/smooth_structures/platform/window_frame_plastitanium.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_plastitanium.dmi'
	icon_state = "window_frame_plastitanium-0"
	base_icon_state = "window_frame_plastitanium"
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	custom_materials = list(/datum/material/alloy/plastitanium = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_SHUTTLE
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_SHUTTLE

// Metallic material themed

/obj/structure/platform/material
	icon = 'icons/obj/smooth_structures/platform/window_frame_material.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_material.dmi'
	icon_state = "window_frame_material-0"
	base_icon_state = "window_frame_material"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_MATERIAL
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_MATERIAL

/obj/structure/platform/iron
	name = "rough iron platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_iron.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_iron.dmi'
	icon_state = "window_frame_iron-0"
	base_icon_state = "window_frame_iron"
	sheet_type = /obj/item/stack/sheet/iron
	custom_materials = list(/datum/material/iron = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_MATERIAL
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_MATERIAL

/obj/structure/platform/silver
	name = "silver platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_silver.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_silver.dmi'
	icon_state = "window_frame_silver-0"
	base_icon_state = "window_frame_silver"
	sheet_type = /obj/item/stack/sheet/mineral/silver
	custom_materials = list(/datum/material/silver = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_MATERIAL
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_MATERIAL

/obj/structure/platform/gold
	name = "golden platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_gold.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_gold.dmi'
	icon_state = "window_frame_gold-0"
	base_icon_state = "window_frame_gold"
	sheet_type = /obj/item/stack/sheet/mineral/gold
	custom_materials = list(/datum/material/gold = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_MATERIAL
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_MATERIAL

/obj/structure/platform/bronze
	name = "clockwork platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_bronze.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_bronze.dmi'
	icon_state = "window_frame_bronze-0"
	base_icon_state = "window_frame_bronze"
	sheet_type = /obj/item/stack/sheet/bronze
	custom_materials = list(/datum/material/bronze = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_MATERIAL
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_MATERIAL

/obj/structure/platform/uranium
	name = "depleted uranium platform"
	desc = "A heavy duty platform, thankfully not radioactive."
	icon = 'icons/obj/smooth_structures/platform/window_frame_uranium.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_uranium.dmi'
	icon_state = "window_frame_uranium-0"
	base_icon_state = "window_frame_uranium"
	material_flags = NONE
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	custom_materials = list(/datum/material/uranium = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_MATERIAL
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_MATERIAL

// Wooden themed

/obj/structure/platform/wood
	name = "wooden platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_wood.dmi'
	frame_icon = null
	icon_state = "window_frame_wood-0"
	base_icon_state = "window_frame_wood"
	sheet_type = /obj/item/stack/sheet/mineral/wood
	custom_materials = list(/datum/material/wood = PLATFORM_BASE_MATERIAL_AMOUNT)
	footstep = FOOTSTEP_WOOD
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_WOOD
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_WOOD

/obj/structure/platform/wood/stage
	name = "wooden stage"
	desc = "A raised platform you can perform upon."
	icon = 'icons/obj/smooth_structures/platform/window_frame_hotel.dmi'
	icon_state = "window_frame_hotel-0"
	base_icon_state = "window_frame_hotel"

/obj/structure/platform/bamboo
	name = "bamboo platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_bamboo.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_bamboo.dmi'
	icon_state = "window_frame_bamboo-0"
	base_icon_state = "window_frame_bamboo"
	sheet_type = /obj/item/stack/sheet/mineral/bamboo
	custom_materials = list(/datum/material/bamboo = PLATFORM_BASE_MATERIAL_AMOUNT)
	footstep = FOOTSTEP_WOOD
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_WOOD
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_WOOD

// Misc

/obj/structure/platform/sandstone
	name = "stone platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_sandstone.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_sandstone.dmi'
	icon_state = "window_frame_sandstone-0"
	base_icon_state = "window_frame_sandstone"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	custom_materials = list(/datum/material/sandstone = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_STONE
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_STONE

/obj/structure/platform/cult
	name = "runed stone platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_cult.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_cult.dmi'
	icon_state = "window_frame_cult-0"
	base_icon_state = "window_frame_cult"
	sheet_type = /datum/material/runedmetal
	custom_materials = list(/datum/material/runedmetal = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_STONE
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_STONE

/obj/structure/platform/pizza
	name = "huge pizza"
	desc = "Big enough to stand on, although possibly you shouldn't eat it after that."
	icon = 'icons/obj/smooth_structures/platform/window_frame_pizza.dmi'
	frame_icon = null
	icon_state = "window_frame_pizza-0"
	base_icon_state = "window_frame_pizza"
	custom_materials = list(/datum/material/pizza = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_PIZZA
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_PIZZA
	footstep = FOOTSTEP_MEAT

/obj/structure/platform/paper
	name = "japanese platform"
	icon = 'icons/obj/smooth_structures/platform/window_frame_paperframe.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_paperframe.dmi'
	icon_state = "window_frame_paperframe-0"
	base_icon_state = "window_frame_paperframe"
	sheet_type = /obj/item/stack/sheet/paperframes
	custom_materials = list(/datum/material/paper = PLATFORM_BASE_MATERIAL_AMOUNT)
	smoothing_groups = SMOOTH_GROUP_PLATFORMS_PAPER
	canSmoothWith = SMOOTH_GROUP_PLATFORMS_PAPER
	footstep = FOOTSTEP_WOOD

#undef PLATFORM_BASE_MATERIAL_AMOUNT
