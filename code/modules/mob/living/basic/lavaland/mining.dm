///prototype for mining mobs
/mob/living/basic/mining
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	combat_mode = TRUE
	status_flags = NONE //don't inherit standard basicmob flags
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_MINING
	faction = list(FACTION_MINING, FACTION_ASHWALKER)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	// Pale purple, should be red enough to see stuff on lavaland
	lighting_cutoff_red = 25
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	/// Message to output if throwing damage is absorbed
	var/throw_blocked_message = "bounces off"
	/// What crusher trophy this mob drops, if any
	var/crusher_loot
	/// What is the chance the mob drops it if all their health was taken by crusher attacks
	var/crusher_drop_chance = 25
	/// Does this mob count for mining mob kills counter?
	var/kill_count = TRUE

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)
	if (kill_count)
		AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
	var/static/list/vulnerable_projectiles
	if(!vulnerable_projectiles)
		vulnerable_projectiles = string_list(MINING_MOB_PROJECTILE_VULNERABILITY)
	add_ranged_armour(vulnerable_projectiles)
	if(crusher_loot)
		AddElement(\
			/datum/element/crusher_loot,\
			trophy_type = crusher_loot,\
			drop_mod = crusher_drop_chance,\
			drop_immediately = basic_mob_flags & DEL_ON_DEATH,\
		)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(check_ashwalker_peace_violation))
	// We add this to ensure that mobs will actually receive the above signal, as some will lack AI
	// handling for retaliation and attack special cases
	AddElement(/datum/element/relay_attackers)

/mob/living/basic/mining/proc/add_ranged_armour(list/vulnerable_projectiles)
	AddElement(\
		/datum/element/ranged_armour,\
		minimum_projectile_force = 30,\
		below_projectile_multiplier = 0.3,\
		vulnerable_projectile_types = vulnerable_projectiles,\
		minimum_thrown_force = 20,\
		throw_blocked_message = throw_blocked_message,\
	)

/mob/living/basic/mining/proc/check_ashwalker_peace_violation(datum/source, mob/living/carbon/human/possible_ashwalker)
	SIGNAL_HANDLER

	if(!isashwalker(possible_ashwalker) || !(FACTION_ASHWALKER in faction))
		return
	faction.Remove(FACTION_ASHWALKER)
