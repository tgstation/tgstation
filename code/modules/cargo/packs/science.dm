/datum/supply_pack/science
	group = "Science"
	access_view = ACCESS_RESEARCH
	crate_type = /obj/structure/closet/crate/science

/datum/supply_pack/science/plasma
	name = "Plasma Assembly Crate"
	desc = "Everything you need to burn something to the ground, this contains three \
		plasma assembly sets. Each set contains a plasma tank, igniter, proximity sensor, \
		and timer! Warranty void if exposed to high temperatures."
	cost = CARGO_CRATE_VALUE * 2
	access = ACCESS_ORDNANCE
	access_view = ACCESS_ORDNANCE
	contains = list(/obj/item/tank/internals/plasma = 3,
					/obj/item/assembly/igniter = 3,
					/obj/item/assembly/prox_sensor = 3,
					/obj/item/assembly/timer = 3,
				)
	crate_name = "plasma assembly crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/science/robotics
	name = "Robotics Assembly Crate"
	desc = "The tools you need to replace those finicky humans with a loyal robot army! \
		Contains four proximity sensors, two empty first aid kits, two health analyzers, \
		two red hardhats, two toolboxes, and two cleanbot assemblies!"
	cost = CARGO_CRATE_VALUE * 3
	access = ACCESS_ROBOTICS
	access_view = ACCESS_ROBOTICS
	contains = list(/obj/item/assembly/prox_sensor = 4,
					/obj/item/healthanalyzer = 2,
					/obj/item/clothing/head/utility/hardhat/red = 2,
					/obj/item/storage/medkit = 2,
					/obj/item/storage/toolbox = 2,
					/obj/item/bot_assembly/cleanbot = 2)
	crate_name = "robotics assembly crate"
	crate_type = /obj/structure/closet/crate/secure/science/robo

/datum/supply_pack/science/rped
	name = "RPED crate"
	desc = "Need to rebuild the ORM but science got annihilated after a bomb test? \
		Buy this for the most advanced parts NT can give you."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/storage/part_replacer/cargo)
	crate_name = "\improper RPED crate"

/datum/supply_pack/science/shieldwalls
	name = "Shield Generator Crate"
	desc = "These high powered Shield Wall Generators are guaranteed to keep any unwanted \
		lifeforms on the outside, where they belong! Contains four shield wall generators."
	cost = CARGO_CRATE_VALUE * 4
	access = ACCESS_TELEPORTER
	access_view = ACCESS_TELEPORTER
	contains = list(/obj/machinery/power/shieldwallgen = 4)
	crate_name = "shield generators crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	desc = "The key ingredient for making a lot of people very angry very fast. \
		Contains two tank transfer valves."
	cost = CARGO_CRATE_VALUE * 12
	access = ACCESS_RD
	contains = list(/obj/item/transfer_valve = 2)
	crate_name = "tank transfer valves crate"
	crate_type = /obj/structure/closet/crate/secure/science
	dangerous = TRUE

/datum/supply_pack/science/monkey_helmets
	name = "Monkey Mind Magnification Helmet crate"
	desc = "Some research is best done with monkeys, yet sometimes they're \
		just too dumb to complete more complicated tasks. These two helmets should help."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/clothing/head/helmet/monkey_sentience = 2)
	crate_name = "monkey mind magnification crate"

/datum/supply_pack/science/cytology
	name = "Cytology supplies crate"
	desc = "Did out-of-control specimens pulverize xenobiology? Here's some more \
		supplies for further testing. Contains a microscope, biopsy tool, two petri dishes, \
		a box of swabs, and a plumbing tool."
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_XENOBIOLOGY
	contains = list(/obj/structure/microscope,
					/obj/item/biopsy_tool,
					/obj/item/storage/box/petridish = 2,
					/obj/item/storage/box/swab,
					/obj/item/construction/plumbing/research,
				)
	crate_name = "cytology supplies crate"

/datum/supply_pack/science/mod_core
	name = "MOD core Crate"
	desc = "Three cores, perfect for any MODsuit construction! Naturally Harvested™, of course."
	cost = CARGO_CRATE_VALUE * 3
	access = ACCESS_ROBOTICS
	access_view = ACCESS_ROBOTICS
	contains = list(/obj/item/mod/core/standard = 3)
	crate_name = "\improper MOD core crate"
	crate_type = /obj/structure/closet/crate/secure/science/robo
