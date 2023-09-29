//the base mining mob
/mob/living/simple_animal/hostile/asteroid
	vision_range = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list(FACTION_MINING)
	weather_immunities = list(TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE)
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	minbodytemp = 0
	maxbodytemp = INFINITY
	unsuitable_heat_damage = 20
	response_harm_continuous = "strikes"
	response_harm_simple = "strike"
	status_flags = 0
	combat_mode = TRUE
	var/throw_message = "bounces off of"
	/// Is this mob subtype from a spawner (e.g. necropolis tendril, demonic portal)? Can be used to affect what it drops (e.g. legions force-dropping ashen skeletons).
	var/from_spawner = FALSE
	// Pale purple, should be red enough to see stuff on lavaland
	lighting_cutoff_red = 25
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35
	mob_size = MOB_SIZE_LARGE
	var/icon_aggro = null

	///what trophy this mob drops
	var/crusher_loot
	///what is the chance the mob drops it if all their health was taken by crusher attacks
	var/crusher_drop_mod = 25

/mob/living/simple_animal/hostile/asteroid/Initialize(mapload)
	. = ..()
	if(crusher_loot)
		AddElement(/datum/element/crusher_loot, crusher_loot, crusher_drop_mod, del_on_death)
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
		throw_blocked_message = throw_message,\
	)

	RegisterSignals(src, list(COMSIG_PROJECTILE_PREHIT, COMSIG_ATOM_PREHITBY), PROC_REF(Aggro))

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	if(vision_range == aggro_vision_range && icon_aggro)
		icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	if(stat == DEAD)
		return
	icon_state = icon_living
