/// The root of all cubes. Entirely devoid of purpose, and yet so malleable to the whims of man. Go forth, build with the blocks of life.
/obj/item/cube
	name = "dev cube"
	desc = "You shouldn't be seeing this cube!"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "cube"
	inhand_icon_state = "cuboid"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("cubes", "squares", "deducts")
	attack_verb_simple = list("cube", "square", "deduct")

	/**The rarity of this cube.
	 * Changes the rarity of /datum/component/cuboid on Initialize()
	 * To update this AFTER Initialize(), use update_cube_rarity(updated_rarity, updated_reference)
	**/
	var/rarity = COMMON_CUBE
	/// If this cube is a reference to something else. Same rule on updating applies.
	var/reference = FALSE
	/// Set this to the color we want to apply to the held icon, or leave null to just leave it the default color.
	var/overwrite_held_color = null
	/// The color that this cube gets given when in-hand. If you want to change the color of a cube manually, use `change_cubecolor()`
	var/cube_color = COLOR_WHITE

/obj/item/cube/Initialize(mapload)
	. = ..()
	force = rarity
	throwforce = rarity
	AddElement(/datum/element/beauty, 25*rarity)
	AddComponent(/datum/component/cuboid, cube_rarity = rarity, isreference = reference, ismapload = mapload)

/obj/item/cube/proc/update_cubecolor(new_cubecolor)
	cube_color = new_cubecolor
	add_filter("cube color", 1, color_matrix_filter(cube_color))

/// Randomize the color for the cube
/obj/item/cube/proc/randcolor()
	update_cubecolor(ready_random_color())

/// Randomize icons. Only random cubes get the longer list of random ones.
/obj/item/cube/proc/give_random_icon()
	icon_state = pick_weight(fill_with_ones(fetch_cube_list()))
	var/list/smallones = list("pixel", "voxel")
	if(smallones.Find(icon_state))
		inhand_icon_state = null

/// Overwritten for cube/randoms
/obj/item/cube/proc/fetch_cube_list()
	/// Since we don't edit this one at all it's just a static list
	var/static/list/possible_normal_cube_visuals
	if(!possible_normal_cube_visuals)
		possible_normal_cube_visuals = list(
			"cube",
			"isometric"
		)
	return possible_normal_cube_visuals

/// Updates the cube rarity & the cuboid rarity without deleting the cube
/obj/item/cube/proc/update_cube_rarity(updated_rarity = COMMON_CUBE, updated_reference)
	rarity = updated_rarity
	var/datum/component/cuboid/cuboid = GetComponent(/datum/component/cuboid)
	cuboid.update_rarity(new_rarity = rarity, new_reference = updated_reference)

/obj/item/cube/color_atom_overlay(mutable_appearance/cubelay)
	if(cube_color)
		return filter_appearance_recursive(cubelay, color_matrix_filter(cube_color))
	return ..()
