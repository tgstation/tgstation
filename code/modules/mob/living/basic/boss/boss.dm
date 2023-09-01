///prototype for boss mobs
/mob/living/basic/boss
	combat_mode = TRUE
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 400
	light_range = 3
	faction = list(FACTION_MINING)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

/mob/living/basic/boss/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
