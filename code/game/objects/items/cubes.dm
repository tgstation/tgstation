/obj/item/cube
	name = "dev cube"
	desc = "You shouldn't be seeing this cube!"
	icon = 'icons/obj/art/crayons.dmi'
	w_class = WEIGHT_CLASS_NORMAL

	/// The rarity of this cube
	var/rarity = COMMON_CUBE

/obj/item/cube/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = rarity)

/obj/effect/spawner/random/cube_roll
	name = "cube spawner (All Rarities)"
	desc = "Roll the small cubes to see if you get the good cubes or the bad cubes."
	icon_state = "loot"
	remove_if_cant_spawn = FALSE //don't remove stuff from the global list, which other can use.
	// see code/_globalvars/lists/objects.dm for loot table

/obj/effect/spawner/random/cube_roll/Initialize(mapload)
	loot = GLOB.all_cubes
	return ..()

/obj/effect/spawner/random/cube_roll/skew_loot_weights(list/loot_list, exponent)
	///We only need to skew the weights once, since it's a global list used by all maint spawners.
	var/static/already_cubed = FALSE
	if(loot_list == GLOB.all_cubes && already_cubed)
		return
	already_cubed = TRUE
	return ..()

/obj/effect/spawner/random/cube
	name = "cube spawner (Common)"
	desc = "Used to roll for those delicious cubes."
	icon_state = "loot"
	remove_if_cant_spawn = FALSE

	/// The rarity of the cube we're going to get. Just use this as an index instead of manually inputting an Initialize() proc in all the others.
	var/cube_rarity = COMMON_CUBE
	/// The list of the lists of all cubes
	var/static/list/all_cubelists = list(
		GLOB.common_cubes,
		GLOB.uncommon_cubes,
		GLOB.rare_cubes,
		GLOB.epic_cubes,
		GLOB.legendary_cubes,
		GLOB.mythical_cubes,
		)

/obj/effect/spawner/random/cube/Initialize(mapload)
	loot = all_cubelists[cube_rarity]
	return ..()

/obj/effect/spawner/random/cube/uncommon
	name = "cube spawner (Uncommon)"
	cube_rarity = UNCOMMON_CUBE

/obj/effect/spawner/random/cube/rare
	name = "cube spawner (Rare)"
	cube_rarity = RARE_CUBE

/obj/effect/spawner/random/cube/epic
	name = "cube spawner (Epic)"
	cube_rarity = EPIC_CUBE

/obj/effect/spawner/random/cube/legendary
	name = "cube spawner (Legendary)"
	cube_rarity = LEGENDARY_CUBE

/obj/effect/spawner/random/cube/mythical
	name = "cube spawner (Mythical)"
	cube_rarity = MYTHICAL_CUBE
