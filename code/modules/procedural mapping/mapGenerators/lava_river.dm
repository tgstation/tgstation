/datum/mapGeneratorModule/river/generate()
	var/river_type = /turf/simulated/floor/plating/lava/smooth
	var/river_nodes = 4
	spawn_rivers(mother.start_z, river_nodes, river_type)