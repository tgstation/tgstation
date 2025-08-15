/**
 * # Virtual Domains
 * Create your own: Read the readme file in the '_maps/virtual_domains' folder.
 */
/datum/lazy_template/virtual_domain
	map_dir = "_maps/virtual_domains"
	map_name = "None"
	key = "Virtual Domain"
	place_on_top = TRUE
	/// Whether to tell observers this map is being used
	var/announce_to_ghosts = FALSE
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// The start time of the map. Used to calculate time taken
	var/start_time
	/// This map is specifically for unit tests. Shouldn't display in game
	var/test_only = FALSE

	/**
	 * Generic settings / UI
	 */

	/// Cost of this map to load
	var/cost = BITRUNNER_COST_NONE
	/// The description of the map for the console UI
	var/desc = "A map."
	/// Affects the ui and ability to scan info.
	var/difficulty = BITRUNNER_DIFFICULTY_NONE
	/// Write these to help complete puzzles and other objectives. Viewed in the domain info ability.
	var/help_text
	// Name to show in the UI
	var/name = "Virtual Domain"
	/// Points to reward for completion. Used to purchase new domains and calculate ore rewards.
	var/reward_points = BITRUNNER_REWARD_MIN

	/**
	 * Player customization
	 */

	/// Any restrictions this domain has on what external sources can load in
	var/external_load_flags = NONE
	/// Any outfit that you wish to force on avatars. Overrides preferences
	var/datum/outfit/forced_outfit

	/**
	 * Loot
	 */

	/// An assoc list of typepath/amount to spawn on completion. Not weighted - the value is the amount
	var/list/completion_loot
	/// An assoc list of typepath/amount to spawn from secondary objectives. Not weighted - the value is the total number of items that can be obtained.
	var/list/secondary_loot = list()
	/// Number of secondary loot boxes generated. Resets when the domain is reloaded.
	var/secondary_loot_generated
	/// Has this domain been beaten with high enough score to spawn a tech disk?
	var/disk_reward_spawned = FALSE

	/**
	 * Modularity
	 */

	/// Whether to display this as a modular map
	var/is_modular = FALSE
	/// Byond will look for modular mob segment landmarks then choose from here at random. You can make them unique also.
	var/list/datum/modular_mob_segment/mob_modules = list()
	/// Forces all mob modules to only load once
	var/modular_unique_mobs = FALSE

	/**
	 * Spawning
	 */

	/// Looks for random landmarks to spawn on.
	var/list/custom_spawns = list()
	/// Set TRUE if you want reusable custom spawners
	var/keep_custom_spawns = FALSE
	/// The domain must have this many ghost candidates willing to join as entities, or else it will not load.
	var/mission_min_candidates = 0
	/// Maximum amount possible of above.
	var/mission_max_candidates = 0
	/// Ghosts that will be spawned as, presumably, an antagonist in the map.
	var/list/chosen_ghosts
	/// List of spawners used for candidates.
	var/list/obj/effect/mob_spawn/ghost_role/ghost_spawners
	/// Current domain mobs being held by ghosts
	var/list/mob/living/ghost_mobs
	/// The role that ghosts will get. Only used for poll text.
	var/spawner_role = "Antagonist"

/datum/lazy_template/virtual_domain/Destroy(force)
	QDEL_NULL(ghost_spawners)
	QDEL_NULL(ghost_mobs)
	. = ..()

/// Sends a point to any loot signals on the map
/datum/lazy_template/virtual_domain/proc/add_points(points_to_add = 1)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_GOAL_POINT, points_to_add)

/// Loads the ghost candidates.
/datum/lazy_template/virtual_domain/proc/load_advanced_npcs(list/mob/lucky_ghosts)
	for(var/mob/lucky_ghost as anything in lucky_ghosts)
		var/obj/effect/mob_spawn/ghost_role/ghost_spawner = pick(ghost_spawners)
		LAZYREMOVE(ghost_spawners, ghost_spawner)

		var/mob/new_mob = ghost_spawner.create(lucky_ghost, lucky_ghost.real_name)
		LAZYADD(ghost_mobs, new_mob)

		var/ghostname = lucky_ghost.name
		notify_ghosts("[ghostname] has been selected to be a [ghost_spawner.prompt_name]!", source = new_mob, header = "001010110")

/// Overridable proc to be called after the map is loaded.
/datum/lazy_template/virtual_domain/proc/setup_domain(list/created_atoms)
	return
