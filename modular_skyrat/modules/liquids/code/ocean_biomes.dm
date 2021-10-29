/datum/biome/ocean_sand
	turf_type = /turf/open/floor/plating/ocean
	flora_types = list(/obj/effect/spawner/ocean_curio, /obj/structure/flora/rock, /obj/structure/flora/rock/pile, /obj/structure/flora/ocean/glowweed, /obj/structure/flora/ocean/seaweed, /obj/structure/flora/ocean/longseaweed)
	flora_density = 10

/datum/biome/ocean_sand_flora
	turf_type = /turf/open/floor/plating/ocean
	flora_types = list(/obj/effect/spawner/ocean_curio, /obj/structure/flora/rock/pile, /obj/structure/flora/ocean/glowweed, /obj/structure/flora/ocean/seaweed, /obj/structure/flora/ocean/longseaweed, /obj/structure/flora/ocean/coral)
	flora_density = 25
	fauna_density = 0.03
	fauna_types = list(/mob/living/simple_animal/hostile/carp)

/datum/biome/ocean_redsand
	turf_type = /turf/open/floor/plating/ocean/ironsand
	flora_types = list(/obj/effect/spawner/ocean_curio, /obj/structure/flora/rock/pile, /obj/structure/flora/ocean/glowweed, /obj/structure/flora/ocean/seaweed, /obj/structure/flora/ocean/longseaweed, /obj/structure/flora/ocean/coral)
	flora_density = 40
	fauna_density = 0.06
	fauna_types = list(/mob/living/simple_animal/hostile/carp)

/datum/biome/ocean_rocklight
	turf_type = /turf/open/floor/plating/ocean/rock
	flora_types = list(/obj/effect/spawner/ocean_curio/rock, /obj/structure/flora/rock, /obj/structure/flora/rock/pile)
	flora_density = 3

/datum/biome/ocean_rockmed
	turf_type = /turf/open/floor/plating/ocean/rock/medium
	flora_types = list(/obj/effect/spawner/ocean_curio/rock, /obj/structure/flora/rock, /obj/structure/flora/rock/pile)
	flora_density = 5

/datum/biome/ocean_rockheavy
	turf_type = /turf/open/floor/plating/ocean/rock/heavy
	flora_types = list(/obj/effect/spawner/ocean_curio/rock, /obj/structure/flora/rock, /obj/structure/flora/rock/pile)
	flora_density = 7

/datum/biome/ocean_wall
	turf_type = /turf/closed/mineral/random/stationside/ocean
	flora_density = 0
