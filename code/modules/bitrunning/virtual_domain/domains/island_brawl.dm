/datum/lazy_template/virtual_domain/island_brawl
	name = "Island Brawl"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_HIGH
	desc = "A deceptively peaceful island with only a few combatants yearning for a fight."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/beachbum/combat
	help_text = "There may be bounties laid out across the island, but the primary objective is to survive."
	key = "island_brawl"
	map_name = "island_brawl"
	reward_points = BITRUNNER_REWARD_HIGH


/datum/lazy_template/virtual_domain/island_brawl/setup_domain(list/created_atoms)
	for(var/obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander/spawner in created_atoms)
		custom_spawns += spawner

		RegisterSignals(spawner, list(COMSIG_GHOSTROLE_SPAWNED, COMSIG_BITRUNNER_SPAWNED), PROC_REF(on_spawn))


/// Someone has spawned in, so we check for their death
/datum/lazy_template/virtual_domain/island_brawl/proc/on_spawn(datum/source, mob/living/spawned_mob)
	SIGNAL_HANDLER

	RegisterSignals(spawned_mob, list(COMSIG_LIVING_DEATH), PROC_REF(on_death))


/// Mob has died, so we add a point to the domain
/datum/lazy_template/virtual_domain/island_brawl/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	add_points(0.5)


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander
	name = "Islander"
	outfit = /datum/outfit/beachbum/combat
	prompt_name = "a combat beach bum"
	you_are_text = "You are a virtual islander."
	flavour_text = "Don't let those pasty bitrunners ruin your idyllic vacation spot. Eliminate them!"
