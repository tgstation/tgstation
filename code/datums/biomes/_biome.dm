/datum/biome
	var/turf_type
	var/flora_density = 0
	var/fauna_density = 0
	var/list/flora_types = list(/obj/structure/flora/grass/jungle)
	var/list/fauna_types = list(
	/mob/living/simple_animal/hostile/jungle/mook{faction = list("wildlife")} = 50,
	)

/datum/biome/mudlands
	turf_type = /turf/open/floor/plating/dirt/jungle/dark
	flora_types = list(/obj/structure/flora/grass/jungle,/obj/structure/flora/grass/jungle/b, /obj/structure/flora/rock/jungle, /obj/structure/flora/rock/pile/largejungle)
	flora_density = 3

/datum/biome/plains
	turf_type = /turf/open/floor/plating/grass/jungle
	flora_types = list(/obj/structure/flora/grass/jungle,/obj/structure/flora/grass/jungle/b, /obj/structure/flora/tree/jungle, /obj/structure/flora/rock/jungle, /obj/structure/flora/junglebush, /obj/structure/flora/junglebush/b, /obj/structure/flora/junglebush/c, /obj/structure/flora/junglebush/large, /obj/structure/flora/rock/pile/largejungle)
	flora_density = 15

/datum/biome/jungle
	turf_type = /turf/open/floor/plating/dirt/jungle/wasteland
	flora_types = list(/obj/structure/flora/grass/jungle,/obj/structure/flora/grass/jungle/b, /obj/structure/flora/tree/jungle, /obj/structure/flora/rock/jungle, /obj/structure/flora/junglebush, /obj/structure/flora/junglebush/b, /obj/structure/flora/junglebush/c, /obj/structure/flora/junglebush/large, /obj/structure/flora/rock/pile/largejungle)
	flora_density = 40
	fauna_density = 0.2
	fauna_types = list(
	/mob/living/simple_animal/hostile/jungle/mook{faction = list("wildlife")} = 10,
	/mob/living/simple_animal/hostile/jungle/leaper{faction = list("wildlife")} = 20,
	/mob/living/simple_animal/hostile/jungle/mega_arachnid{faction = list("wildlife")} = 20,
	/mob/living/simple_animal/hostile/jungle/seedling{faction = list("wildlife")} = 10,
	)

/datum/biome/jungle/deep
	flora_density = 65
	fauna_density = 0.25

/datum/biome/wasteland
	turf_type = /turf/open/floor/plating/dirt/jungle/wasteland

/datum/biome/water
	turf_type = /turf/open/water/jungle

/datum/biome/mountain
	turf_type = /turf/closed/mineral/random/jungle
