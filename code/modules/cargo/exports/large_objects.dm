/datum/export/large/crate
	cost = 500
	k_elasticity = 0
	unit_name = "crate"
	export_types = list(/obj/structure/closet/crate)
	exclude_types = list(/obj/structure/closet/crate/large, /obj/structure/closet/crate/wooden)

/datum/export/large/crate/total_printout() // That's why a goddamn metal crate costs that much.
	. = ..()
	if(.)
		. += " Thanks for participating in Nanotrasen Crates Recycling Program."

/datum/export/large/crate/wooden
	cost = 100
	unit_name = "large wooden crate"
	export_types = list(/obj/structure/closet/crate/large)
	exclude_types = list()

/datum/export/large/crate/wooden/ore
	unit_name = "ore box"
	export_types = list(/obj/structure/ore_box)

/datum/export/large/crate/wood
	cost = 240
	unit_name = "wooden crate"
	export_types = list(/obj/structure/closet/crate/wooden)
	exclude_types = list()

/datum/export/large/crate/coffin
	cost = 250//50 wooden crates cost 2000 points, and you can make 10 coffins in seconds with those planks. Each coffin selling for 250 means you can make a net gain of 500 points for wasting your time making coffins.
	unit_name = "coffin"
	export_types = list(/obj/structure/closet/crate/coffin)

/datum/export/large/reagent_dispenser
	cost = 100 // +0-400 depending on amount of reagents left
	var/contents_cost = 400

/datum/export/large/reagent_dispenser/get_cost(obj/O)
	var/obj/structure/reagent_dispensers/D = O
	var/ratio = D.reagents.total_volume / D.reagents.maximum_volume

	return ..() + round(contents_cost * ratio)

/datum/export/large/reagent_dispenser/water
	unit_name = "watertank"
	export_types = list(/obj/structure/reagent_dispensers/watertank)
	contents_cost = 200

/datum/export/large/reagent_dispenser/fuel
	unit_name = "fueltank"
	export_types = list(/obj/structure/reagent_dispensers/fueltank)

/datum/export/large/reagent_dispenser/beer
	unit_name = "beer keg"
	contents_cost = 700
	export_types = list(/obj/structure/reagent_dispensers/beerkeg)



/datum/export/large/emitter
	cost = 200
	unit_name = "emitter"
	export_types = list(/obj/machinery/power/emitter)

/datum/export/large/field_generator
	cost = 200
	unit_name = "field generator"
	export_types = list(/obj/machinery/field/generator)

/datum/export/large/collector
	cost = 200
	unit_name = "collector"
	export_types = list(/obj/machinery/power/rad_collector)

/datum/export/large/collector/pa
	cost = 300
	unit_name = "particle accelerator part"
	export_types = list(/obj/structure/particle_accelerator)

/datum/export/large/collector/pa/controls
	cost = 500
	unit_name = "particle accelerator control console"
	export_types = list(/obj/machinery/particle_accelerator/control_box)

/datum/export/large/pipedispenser
	cost = 500
	unit_name = "pipe dispenser"
	export_types = list(/obj/machinery/pipedispenser)

/datum/export/large/supermatter
	cost = 9000
	unit_name = "supermatter shard"
	export_types = list(/obj/machinery/power/supermatter_crystal/shard)


/datum/export/large/iv
	cost = 50
	unit_name = "iv drip"
	export_types = list(/obj/machinery/iv_drip)

/datum/export/large/barrier
	cost = 25
	unit_name = "security barrier"
	export_types = list(/obj/item/grenade/barrier, /obj/structure/barricade/security)

