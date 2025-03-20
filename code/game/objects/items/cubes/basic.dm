// Basic random colors
/obj/item/cube/colorful
	name = "pretty cube"
	desc = "It's a wonderful shade of... whatever that is!"
	rarity = UNCOMMON_CUBE

/obj/item/cube/colorful/Initialize(mapload)
	. = ..()
	randcolor()

/obj/item/cube/colorful/isometric
	name = "isometric cube"
	desc = "Some madman turned this cube 45 degrees, now it looks all weird!"
	icon_state = "isometric"
	rarity = UNCOMMON_CUBE

/obj/item/cube/colorful/huge
	name = "huge cube"
	desc = "THAT is one BIG cube. It would probably hurt a lot if it fell on someone's head..."
	icon_state = "massive"
	rarity = RARE_CUBE
	w_class = WEIGHT_CLASS_HUGE

/obj/item/cube/colorful/huge/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = 15, wound_bonus = 5, hardhat_safety = FALSE, crushes = TRUE)

/obj/item/cube/colorful/voxel
	name = "voxel"
	desc = "Cubes just don't get any smaller."
	icon_state = "voxel"
	w_class = WEIGHT_CLASS_SMALL
	rarity = RARE_CUBE

/obj/item/cube/colorful/pixel
	name = "pixel"
	desc = "Technically a square, but close enough if you squint. Try not to lose it!"
	icon_state = "pixel"
	w_class = WEIGHT_CLASS_TINY
	rarity = EPIC_CUBE

/obj/item/cube/colorful/pixel/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER)

/obj/item/cube/colorful/plane
	name = "plane"
	desc = "A flattened cube."
	icon_state = "plane"
	rarity = UNCOMMON_CUBE

/obj/item/cube/colorful/plane/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER)

/obj/item/cube/colorful/meta
	name = "billboard Cube"
	desc = "It's always facing directly towards the camera."
	icon_state = "billboard"
	rarity = EPIC_CUBE
	//! Todo: Maybe this lets PLAYERS go undertile? see if that breaks shit.

// Material cubes
/obj/item/cube/material
	name = "material cube"
	desc = "Before the invention of material silos, stations all over the galaxy used to store their materials in the form of ultra-dense cubes."
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	rarity = RARE_CUBE

/obj/item/cube/material/Initialize(mapload)
	name = "cube"
	var/datum/material/cube_mat = pick(GLOB.typecache_material)
	custom_materials = list(cube_mat = max(SHEET_MATERIAL_AMOUNT * (1+(cube_mat.mineral_rarity/10)),1))
	give_random_icon()
	. = ..()


// Pill cubes
/obj/item/reagent_containers/pill/cube
	icon = 'icons/obj/cubes.dmi'
	icon_state = "pill_cube"
	var/cube_rarity = COMMON_CUBE

/obj/item/reagent_containers/pill/cube/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = cube_rarity)
	color = mix_color_from_reagents(reagents.reagent_list) | COLOR_WHITE

/obj/item/reagent_containers/pill/cube/ice
	name = "ice cube"
	desc = "The most common form of recreational ice, rivaled only by skating rinks."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/ice = 15)
	// Hoping this means it won't melt
	reagent_flags = NO_REACT
	alpha = 200
	cube_rarity = UNCOMMON_CUBE

/obj/item/reagent_containers/pill/cube/sugar
	name = "sugar cube"
	desc = "Perfect for those who love a good cup of tea."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/sugar = 15)
	cube_rarity = UNCOMMON_CUBE

/obj/item/reagent_containers/pill/cube/salt
	name = "salt cube"
	desc = "Perfect for those who despise a good cup of tea."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/salt = 15)
	cube_rarity = UNCOMMON_CUBE


// Sphere (disgusting)
/obj/item/cube/sphere
	name = "sphere"
	desc = "I think I'm gonna be sick."
	icon_state = "sphere"
	rarity = LEGENDARY_CUBE

/obj/item/cube/sphere/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return .
	throw_at(get_edge_target_turf(src, get_dir(user, src)), 7, 1, user)
	user.do_attack_animation(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
