///prototype for mining mobs
/mob/living/basic/mining
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	combat_mode = TRUE
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	faction = list(FACTION_MINING)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	/// Message to output if throwing damage is absorbed
	var/throw_blocked_message = "bounces off"
	/// What crusher trophy this mob drops, if any
	var/crusher_loot
	/// What is the chance the mob drops it if all their health was taken by crusher attacks
	var/crusher_drop_chance = 25

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
	var/static/list/vulnerable_projectiles
	if(!vulnerable_projectiles)
		vulnerable_projectiles = string_list(MINING_MOB_PROJECTILE_VULNERABILITY)
	AddElement(\
		/datum/element/ranged_armour,\
		minimum_projectile_force = 30,\
		below_projectile_multiplier = 0.3,\
		vulnerable_projectile_types = vulnerable_projectiles,\
		minimum_thrown_force = 20,\
		throw_blocked_message = throw_blocked_message,\
	)
	if(crusher_loot)
		AddElement(\
			/datum/element/crusher_loot,\
			trophy_type = crusher_loot,\
			drop_mod = crusher_drop_chance,\
			drop_immediately = basic_mob_flags & DEL_ON_DEATH,\
		)
