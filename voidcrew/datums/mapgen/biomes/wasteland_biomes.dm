/datum/biome/wasteland
	open_turf_types = list(/turf/open/misc/wasteland/lit = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock/asteroid = 30,
		/obj/structure/flora/tree/dead/tall = 10,
		/obj/structure/flora/tree/dead_pine = 4,
		/obj/structure/flora/tree/dead_african = 1,
		/obj/structure/flora/rock/wasteland = 10,
		/obj/structure/flora/cactus = 10
	)
	flora_spawn_chance = 5
	feature_spawn_list = list(
		/obj/item/bodypart/arm/right/robot = 40,
		/obj/item/assembly/prox_sensor = 40,
		/obj/effect/mine/explosive = 8,
		/obj/structure/geyser/random = 4,
		/obj/item/shard = 30,
		/obj/item/stack/cable_coil/cut = 30,
		/obj/item/stack/rods = 30,
		/obj/structure/spawner/ice_moon/demonic_portal/blobspore = 3,
		/obj/structure/spawner/ice_moon/demonic_portal/hivebot = 3,
		/obj/structure/ammo_printer = 1
	)
	feature_spawn_chance = 3
	mob_spawn_chance = 7
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/hermit/ranged/hunter = 5,
		/mob/living/simple_animal/hostile/asteroid/hermit/ranged/gunslinger = 5,
		/mob/living/basic/giant_spider/wasteland = 1,
		/mob/living/basic/giant_spider/tarantula/wasteland = 1,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/wasteland = 3
	)

/datum/biome/wasteland/plains
	open_turf_types = list(/turf/open/misc/dust/lit = 1)
	flora_spawn_list = list(/obj/structure/flora/deadgrass/tall = 50, /obj/structure/flora/deadgrass/tall/dense = 5, /obj/structure/flora/rock/wasteland = 1)
	flora_spawn_chance = 45
	mob_spawn_chance = 15

/datum/biome/wasteland/forest
	open_turf_types = list(/turf/open/misc/dirt/dry/lit = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/tall = 35,
		/obj/structure/flora/branches = 10,
		/obj/structure/flora/deadgrass = 80,
		/obj/structure/flora/tree/dead_pine = 15,
		/obj/structure/flora/tree/dead_african = 4
	)
	flora_spawn_chance = 25

/datum/biome/nuclear
	open_turf_types = list(/turf/open/misc/asteroid/sand/lit = 5, /turf/open/misc/asteroid/sand/dark/lit = 1)
	feature_spawn_chance = 2.5
	feature_spawn_list = list(
		/obj/structure/radioactive = 10,
		/obj/structure/radioactive/stack = 10,
		/obj/structure/radioactive/waste = 10,
		/obj/item/stack/ore/slag = 10,
		/obj/structure/flora/cactus = 20,
		/obj/structure/spawner/ice_moon/demonic_portal/blobspore = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/hivebot = 1
	)
	flora_spawn_chance = 1
	flora_spawn_list = list(/obj/structure/flora/rock/wasteland = 30, /obj/effect/decal/cleanable/greenglow = 30, /obj/structure/elite_tumor = 1)
	mob_spawn_chance = 20
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/hermit/ranged/hunter = 10,
		/mob/living/simple_animal/hostile/asteroid/hermit/ranged/gunslinger = 7,
		/mob/living/simple_animal/hostile/hivebot/rapid/wasteland = 5,
		/mob/living/basic/giant_spider/wasteland = 1,
		/mob/living/basic/giant_spider/tarantula/wasteland = 1
	)

/datum/biome/ruins
	open_turf_types = list(/turf/open/misc/dust/lit = 45, /turf/open/floor/plating/rust = 1)
	feature_spawn_chance = 5
	feature_spawn_list = list(
		/obj/structure/barrel/flaming = 6,
		/obj/structure/barrel = 10,
		/obj/structure/reagent_dispensers/fueltank = 6,
		/obj/item/shard = 12,
		/obj/item/stack/cable_coil/cut = 12,
		/obj/effect/mine/explosive = 2,
		/obj/item/food/canned/beans = 2,
		/obj/structure/mecha_wreckage/ripley = 6,
		/obj/structure/mecha_wreckage/ripley/mk2 = 2,
		/obj/structure/spawner/ice_moon/demonic_portal/blobspore = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/hivebot = 1,
		/obj/structure/ammo_printer = 1
	)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/girder = 1
	)
	mob_spawn_chance = 10
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/wasteland = 15,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/crystal/wasteland = 1,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/forgotten/wasteland = 1
	)

/datum/biome/cave/wasteland
	open_turf_types = list(/turf/open/misc/dirt/dry = 1, /turf/open/misc/dust = 1)
	closed_turf_types = list(/turf/closed/mineral/random/high_chance/wasteland = 1)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/basic/wumborian_fugu/wasteland = 15,
		/mob/living/simple_animal/hostile/asteroid/wolf/wasteland/random = 15,
		/obj/structure/spawner/ice_moon/demonic_portal/blobspore = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/hivebot = 1
	)
	flora_spawn_chance = 10
	flora_spawn_list = list(
		/obj/structure/flora/rock/wasteland = 5,
		/obj/structure/flora/ash/leaf_shroom = 4,
		/obj/structure/flora/ash/cap_shroom = 4,
		/obj/structure/flora/ash/stem_shroom = 4,
		/obj/structure/flora/ash/cacti = 2,
		/obj/structure/flora/ash/tall_shroom = 4,
		/obj/structure/flora/ash/whitesands/puce = 1
	)
	feature_spawn_chance = 3
	feature_spawn_list = list(
		/obj/structure/spawner/cave = 20,
		/obj/structure/closet/crate/grave/filled = 40,
		/obj/structure/closet/crate/grave/filled/lead_researcher = 20,
		/obj/item/pickaxe/rusted = 40,
		/obj/item/pickaxe/diamond = 1,
		/obj/item/shovel/serrated = 30,
		/obj/structure/radioactive = 30,
		/obj/structure/radioactive/stack = 50,
		/obj/structure/radioactive/waste = 50,
		/obj/item/stack/ore/slag = 60,
		/obj/structure/ammo_printer = 10
	)

/datum/biome/cave/rubble
	open_turf_types = list(/turf/open/floor/plating/rubble = 1, /turf/open/floor/plating/tunnel = 6)
	closed_turf_types = list(/turf/closed/wall/r_wall/rust = 1, /turf/closed/wall/rust = 4,/turf/closed/mineral/random/high_chance/wasteland = 10)
	feature_spawn_list = list(
		/obj/effect/spawner/random/maintenance = 10,
		/obj/item/stack/rods = 5,
		/obj/structure/closet/crate/secure/loot = 1,
		/obj/structure/spawner/cave = 2,
		/obj/structure/barrel/flaming = 2,
		/obj/structure/reagent_dispensers/fueltank = 2,
		/obj/structure/girder = 2,
		/obj/item/shard = 2,
		/obj/item/stack/cable_coil/cut = 2,
		/obj/effect/mine/explosive = 2,
		///obj/item/ammo_casing/caseless/arrow/bone = 2,
		/obj/item/healthanalyzer = 2,
		/obj/item/storage/medkit = 2,
		/obj/structure/ammo_printer = 1
	)
	feature_spawn_chance = 5
	flora_spawn_list = list(/obj/structure/flora/rock/wasteland = 1)
	flora_spawn_chance = 1
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/basic/giant_spider/tarantula/wasteland = 1,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/wasteland = 20,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/wasteland = 15,
		/obj/structure/spawner/ice_moon/demonic_portal/blobspore = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/hivebot = 1
	)

/datum/biome/cave/mossy_stone
	open_turf_types = list(/turf/open/floor/plating/mossy_stone = 5, /turf/open/misc/dirt/dry = 1)
	feature_spawn_list = list(
		/obj/effect/decal/cleanable/greenglow = 30,
		/obj/machinery/portable_atmospherics/canister/plasma = 15,
		/obj/machinery/portable_atmospherics/canister/miasma = 15,
		/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 15,
		/obj/structure/barrel/flaming = 20,
		/obj/structure/geyser/random = 1,
		/obj/structure/spawner/cave = 5
	)
	feature_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/glowshroom = 20,
	)
	flora_spawn_chance = 30
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/blob/blobbernaut/independent/wasteland = 1,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing/wasteland = 4,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 3,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/wasteland = 3,
		/obj/structure/spawner/ice_moon/demonic_portal/blobspore = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/hivebot = 1
	)
