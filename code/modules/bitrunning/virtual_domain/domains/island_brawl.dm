/datum/lazy_template/virtual_domain/island_brawl
	name = "Island Brawl"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_HIGH
	desc = "A 'peaceful' island tucked away in the middle of nowhere. This map will auto-complete after a number of deaths have occurred."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/beachbum_combat
	help_text = "There may be bounties laid out across the island, but the primary objective is to survive. Deaths on the island will count towards the final score."
	key = "island_brawl"
	map_name = "island_brawl"
	reward_points = BITRUNNER_REWARD_HIGH
	secondary_loot = list(
		/obj/item/toy/beach_ball = 2,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/gun/ballistic/automatic/mini_uzi = 1,
	)


/datum/lazy_template/virtual_domain/island_brawl/setup_domain(list/created_atoms)
	for(var/obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander/spawner in created_atoms)
		custom_spawns += spawner

		RegisterSignal(spawner, COMSIG_QDELETING, PROC_REF(on_spawner_qdeleted))
		RegisterSignals(spawner, list(COMSIG_GHOSTROLE_SPAWNED, COMSIG_BITRUNNER_SPAWNED), PROC_REF(on_spawn))


/datum/lazy_template/virtual_domain/island_brawl/proc/on_spawner_qdeleted(obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander/source)
	SIGNAL_HANDLER

	custom_spawns -= source
	UnregisterSignal(source, COMSIG_QDELETING)


/// Someone has spawned in, so we check for their death
/datum/lazy_template/virtual_domain/island_brawl/proc/on_spawn(datum/source, mob/living/spawned_mob)
	SIGNAL_HANDLER

	RegisterSignals(spawned_mob, list(COMSIG_LIVING_DEATH), PROC_REF(on_death))


/// Mob has died, so we add a point to the domain
/datum/lazy_template/virtual_domain/island_brawl/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	add_points(1)


/obj/effect/mob_spawn/ghost_role/human/virtual_domain/islander
	name = "Islander"
	outfit = /datum/outfit/beachbum_combat
	prompt_name = "a combat beach bum"
	you_are_text = "You are a virtual islander."
	flavour_text = "Don't let anyone ruin your idyllic vacation spot. Coordinate with others- or don't!"
