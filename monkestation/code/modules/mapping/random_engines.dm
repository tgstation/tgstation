
/datum/map_template/random_engines
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/station_name //Matches this template with that right station
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 1 //how many times this room can appear in a round

/** EXAMPLE OF WEIGHT CHANCES:
 * Given the following list:
 * A = 6, B = 3, C = 1, D = 0
 * A would have a 60% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 0% chance of being picked.
 * You should only pass integers in.
*/

// *!! BOXSTATION ENGINES!!*
/datum/map_template/random_engines/box_supermatter
	name = "Box Supermatter"
	room_id = "box_supermatter"
	mappath = "monkestation/_maps/RandomEngines/BoxStation/supermatter.dmm"
	centerspawner = FALSE
	template_height = 27
	template_width = 32
	weight = 8
	station_name = "Box Station"

/datum/map_template/random_engines/box_particle_accelerator
	name = "Box Particle Accelerator"
	room_id = "box_particle_accelerator"
	mappath = "monkestation/_maps/RandomEngines/BoxStation/particle_accelerator.dmm"
	centerspawner = FALSE
	template_height = 27
	template_width = 32
	weight = 2
	station_name = "Box Station"


// *!! METASTATION ENGINES !!*
/datum/map_template/random_engines/meta_supermatter
	name = "Meta Supermatter"
	room_id = "meta_supermatter"
	mappath = "monkestation/_maps/RandomEngines/MetaStation/supermatter.dmm"
	centerspawner = FALSE
	template_height = 26
	template_width = 32
	weight = 8
	station_name = "MetaStation"

/datum/map_template/random_engines/meta_particle_accelerator
	name = "Meta Particle Accelerator"
	room_id = "meta_particle_accelerator"
	mappath = "monkestation/_maps/RandomEngines/MetaStation/particle_accelerator.dmm"
	centerspawner = FALSE
	template_height = 26
	template_width = 32
	weight = 2
	station_name = "MetaStation"

/datum/map_template/random_engines/meta_rbmk_reactor
	name = "Meta RBMK Reactor"
	room_id = "meta_rbmk_reactor"
	mappath = "monkestation/_maps/RandomEngines/MetaStation/rbmk_reactor.dmm"
	centerspawner = FALSE
	template_height = 26
	template_width = 32
	weight = 4
	station_name = "MetaStation"
