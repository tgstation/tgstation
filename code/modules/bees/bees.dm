obj/item/bees
	name = "bee"
	desc = "make a bug report if you're reading this" //should not happen in regular gameplay
	var/specie
	var/strength
	var/aggresivity
	var/list/sting_toxin = list()
	var/list/produce = list()
	var/size
	var/endurance
	var/sting_potency
	var/production_speed
/obj/item/bees/Initialize()
	. = ..()
obj/item/bees/princess
	name = "A [specie] princess"
	desc = "Mate this princess with a drone to obtain a queen."
obj/item/bees/drone
	name = "A [specie] drone"
	desc = "These drones mate with princesses to make queens."
obj/item/bees/queen
	name = "A [specie] queen"
	desc = "This is the queen of it's hive"
	var/life


obj/simple_animals/bee_swarm
	var/item/bees/queen/queen