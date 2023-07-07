///prototype for mining mobs
/mob/living/basic/mining
	combat_mode = TRUE
	faction = list(FACTION_MINING)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	/// Message to output if throwing damage is absorbed
	var/throw_blocked_message = "bounces off"

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
	AddElement(\
		/datum/element/ranged_armour,\
		minimum_projectile_force = 30,\
		below_projectile_multiplier = 0.3,\
		vulnerable_projectile_types = MINING_MOB_PROJECTILE_VULNERABILITY,\
		minimum_thrown_force = 20,\
		throw_blocked_message = throw_blocked_message,\
	)
