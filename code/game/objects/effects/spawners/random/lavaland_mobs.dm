
/// For map generation, has a chance to instantiate as a special subtype
/obj/effect/spawner/random/lavaland_mob
	name = "random lavaland mob"
	desc = "Spawns a random lavaland mob."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	loot = list(
		/mob/living/basic/mining/bileworm = 1,
		/mob/living/basic/mining/goldgrub = 1,
		/mob/living/basic/mining/goliath = 1,
		/mob/living/basic/mining/lobstrosity/lava = 1,
		/mob/living/basic/mining/watcher = 1,
		/mob/living/simple_animal/hostile/asteroid/brimdemon = 1,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion = 1,
	)

/// Spawns random watcher variants during map generation
/obj/effect/spawner/random/lavaland_mob/watcher
	name = "random watcher"
	desc = "Chance to spawn a rare shiny version."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "watcher"
	pixel_x = -12
	loot = list(
		/mob/living/basic/mining/watcher = 80,
		/mob/living/basic/mining/watcher/magmawing = 15,
		/mob/living/basic/mining/watcher/icewing = 5,
	)

/// Spawns random goliath variants during map generation
/obj/effect/spawner/random/lavaland_mob/goliath
	name = "random goliath"
	desc = "Chance to spawn a rare shiny version."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	icon_state = "goliath"
	pixel_x = -12
	loot = list(
		/mob/living/basic/mining/goliath = 99,
		/mob/living/basic/mining/goliath/ancient/immortal = 1,
	)

/// Spawns random legion variants during map generation
/obj/effect/spawner/random/lavaland_mob/legion
	name = "random legion"
	desc = "Chance to spawn a rare shiny version."
	icon_state = "legion"
	loot = list(
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion = 19,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/dwarf = 1,
	)
