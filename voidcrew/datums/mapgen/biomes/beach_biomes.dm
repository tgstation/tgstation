/datum/biome/grass
	open_turf_types = list(/turf/open/misc/grass/lit = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/jungle = 1,
		/obj/structure/flora/ausbushes/brflowers = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
		/obj/structure/flora/ausbushes/ywflowers = 1,
		/obj/structure/flora/tree/palm = 1
	)
	flora_spawn_chance = 25
	mob_spawn_list = list(
		/mob/living/simple_animal/butterfly/beach = 1,
		/mob/living/simple_animal/slime/pet/beach = 1,
		///mob/living/simple_animal/chicken/rabbit/normal/beach = 1,
		/mob/living/simple_animal/chicken/beach = 1,
		/mob/living/simple_animal/chick/beach = 1,
		/mob/living/basic/mouse/beach = 1,
		/mob/living/basic/cow/beach = 1,
		/mob/living/basic/deer/beach = 1
	)
	mob_spawn_chance = 1

/datum/biome/grass/dense
	flora_spawn_chance = 65
	mob_spawn_list = list(
		/mob/living/simple_animal/pet/cat/cak/beach = 1,
		/mob/living/simple_animal/butterfly/beach = 4,
		/mob/living/simple_animal/hostile/retaliate/snake/beach = 5,
		/mob/living/simple_animal/slime/random/beach = 3,
		/mob/living/simple_animal/hostile/poison/bees/toxin/beach = 3
	)
	mob_spawn_chance = 2
	feature_spawn_chance = 0.1
	feature_spawn_list = list(/obj/structure/spawner/cave/beach = 1)

/datum/biome/beach
	open_turf_types = list(/turf/open/misc/asteroid/sand/beach/lit = 1)
	//mob_spawn_list = list(/mob/living/simple_animal/crab/beach = 7, /mob/living/simple_animal/turtle/beach = 4, /mob/living/simple_animal/hostile/retaliate/gator/steppy = 1)
	mob_spawn_chance = 0.3
	feature_spawn_chance = 3
	feature_spawn_list = list(
		/obj/structure/chair/plastic = 7,
		/obj/item/toy/beach_ball = 12,
		/obj/structure/fluff/beach_umbrella = 20,
		/obj/structure/fluff/beach_umbrella/engine = 18,
		/obj/item/storage/cans/sixbeer = 2,
		/obj/item/clothing/mask/cigarette/rollie/cannabis = 2,
		/obj/item/clothing/under/shorts/purple = 4,
		/obj/item/clothing/under/shorts/red = 4
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/palm = 1
	)
	flora_spawn_chance = 1

/datum/biome/beach/dense
	open_turf_types = list(/turf/open/misc/asteroid/sand/beach/dense/lit = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock/asteroid = 6,
		/obj/structure/flora/rock/beach = 1
	)
	flora_spawn_chance = 0.6

/datum/biome/ocean
	open_turf_types = list(/turf/open/water/beach = 1)
	mob_spawn_list = list(
		/mob/living/simple_animal/beachcarp = 1,
		/mob/living/basic/carp/beach = 1,
		/mob/living/basic/carp/beach/small = 1,
		/mob/living/simple_animal/beachcarp/bass = 1,
		/mob/living/simple_animal/beachcarp/trout = 1,
		/mob/living/simple_animal/beachcarp/salmon = 1,
		/mob/living/simple_animal/beachcarp/perch = 1
	)
	mob_spawn_chance = 1.4
	flora_spawn_list = list(
		/obj/structure/flora/rock/beach = 1,
		/obj/structure/flora/rock/pile = 1
	)
	flora_spawn_chance = 1
	feature_spawn_chance = 0.04
	feature_spawn_list = list(/obj/vehicle/ridden/lavaboat/dragon = 1)

/datum/biome/ocean/deep
	open_turf_types = list(/turf/open/water/beach/deep = 1)
	mob_spawn_chance = 1.4
	mob_spawn_list = list(
		/mob/living/basic/carp/beach = 6,
		/mob/living/basic/carp/beach/small = 5,
		/mob/living/simple_animal/beachcarp/bass = 5,
		/mob/living/simple_animal/beachcarp/trout = 5,
		/mob/living/simple_animal/beachcarp/salmon = 5,
		/mob/living/simple_animal/beachcarp/perch = 5,
		/mob/living/simple_animal/hostile/pirate/melee/beach/boat = 3,
		/mob/living/simple_animal/hostile/pirate/ranged/beach/boat = 1
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
//		/obj/structure/spawner/sea_crystal = 1
	)

/datum/biome/cave/beach
	open_turf_types = list(/turf/open/misc/asteroid/sand/beach/dense = 1)
	closed_turf_types = list(/turf/closed/mineral/random/beach = 1)
	flora_spawn_chance = 4
	flora_spawn_list = list(/obj/structure/flora/rock/beach = 1, /obj/structure/flora/rock/asteroid = 6)
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/bear/cave = 5,
		/mob/living/simple_animal/hostile/killertomato/beach = 1,
		/mob/living/simple_animal/hostile/mushroom/beach = 1
	)

/datum/biome/cave/beach/cove
	open_turf_types = list(/turf/open/misc/asteroid/sand/beach/dense = 1, /turf/open/floor/wood/yew = 3)
	flora_spawn_list = list(/obj/structure/flora/tree/dead_pine = 1, /obj/structure/flora/rock/beach = 1)
	flora_spawn_chance = 5
	feature_spawn_list = list(
		///obj/structure/destructible/tribal_torch/lit = 7,
		/obj/structure/spawner/cave/beach = 20,
		/obj/structure/fermenting_barrel = 10,
		/obj/vehicle/ridden/lavaboat/dragon = 1,
		/obj/vehicle/ridden/atv/beach = 1,
		/obj/machinery/jukebox/disco/beach = 1,
		///obj/effect/spawner/bundle/costume/mafia/white = 1,
		///obj/machinery/vending/boozeomat/all_access/beach = 1
	)
	feature_spawn_chance = 30

/datum/biome/cave/beach/magical
	open_turf_types = list(/turf/open/misc/grass/lit = 1)
	flora_spawn_chance = 20
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/fernybush = 1,
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/genericbush = 1,
		/obj/structure/flora/ausbushes/grassybush = 1,
		/obj/structure/flora/ausbushes/leafybush = 1,
		/obj/structure/flora/ausbushes/palebush = 1,
		/obj/structure/flora/ausbushes/pointybush = 1,
		/obj/structure/flora/ausbushes/reedbush = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/stalkybush = 1,
		/obj/structure/flora/ausbushes/sunnybush = 1,
	)
	mob_spawn_chance = 5
	mob_spawn_list = list(
		/mob/living/simple_animal/butterfly = 1,
		/mob/living/simple_animal/slime/pet = 1,
		/mob/living/simple_animal/hostile/lightgeist = 1
	)
