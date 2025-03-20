/obj/item/cube
	name = "dev cube"
	desc = "You shouldn't be seeing this cube!"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "cube"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("cubes", "squares", "deducts")
	attack_verb_simple = list("cube", "square", "deduct")

	/**The rarity of this cube.
	 * Changes the rarity of /datum/component/cuboid on Initialize()
	 * To update this AFTER Initialize(), use update_cube_rarity(updated_rarity)
	**/
	var/rarity = COMMON_CUBE

/obj/item/cube/Initialize(mapload)
	. = ..()
	force = rarity
	throwforce = rarity
	AddElement(/datum/element/beauty, 25*rarity)
	AddComponent(/datum/component/cuboid, cube_rarity = rarity)

/// Randomize the color for the cube
/obj/item/cube/proc/randcolor()
	add_filter("cubecolor", 1, color_matrix_filter(ready_random_color()))

/// Randomize icons. HEAVILY skewed in favor of normally sized cubes
/// set true_random to TRUE to get states other than "cube" and "isometric"
/obj/item/cube/proc/give_random_icon(true_random = FALSE)
	var/list/possible_visuals
	if(true_random)
		possible_visuals = list(
			"cube" = 500,
			"isometric" = 250,
			"small" = 15*rarity,
			"massive" = 10*rarity,
			"plane" = 5*rarity,
			"voxel" = 5+rarity,
			"pixel" = 1
		)
	else
		possible_visuals = list(
			"cube",
			"isometric"
		)
	icon_state = pick_weight(fill_with_ones(possible_visuals))

/// Updates the cube rarity & the cuboid rarity without deleting the cube
/obj/item/cube/proc/update_cube_rarity(updated_rarity = COMMON_CUBE)
	rarity = updated_rarity
	var/datum/component/cuboid/cuboid = GetComponent(/datum/component/cuboid)
	cuboid.update_rarity(new_rarity = rarity)
