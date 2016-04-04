/datum/mapGenerator/lavaland
	var/start_z = 5
	modules = list(/datum/mapGeneratorModule/river)

/datum/mapGenerator/lavaland/defineRegion(turf/Start, turf/End, replace = 0)
	start_z = Start.z
	..()

/datum/mapGeneratorModule/river
	var/river_type = /turf/open/floor/plating/lava/smooth
	var/river_nodes = 4
	var/start_z = 5

/datum/mapGeneratorModule/river/generate()
	if(istype(mother, /datum/mapGenerator/lavaland))
		var/datum/mapGenerator/lavaland/L = mother
		start_z = L.start_z
	spawn_rivers(start_z, river_nodes, river_type)
