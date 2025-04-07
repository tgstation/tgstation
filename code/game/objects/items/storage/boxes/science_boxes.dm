// This file contains all boxes used by the Science department and its purpose on the station.

/obj/item/storage/box/swab
	name = "box of microbiological swabs"
	desc = "Contains a number of sterile swabs for collecting microbiological samples."
	illustration = "swab"

/obj/item/storage/box/swab/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/swab

/obj/item/storage/box/petridish
	name = "box of petri dishes"
	desc = "This box purports to contain a number of high rim petri dishes."
	illustration = "petridish"

/obj/item/storage/box/petridish/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/petri_dish

/obj/item/storage/box/plumbing
	name = "box of plumbing supplies"
	desc = "Contains a small supply of pipes, water recyclers, and iron to connect to the rest of the station."

//Disk boxes

/obj/item/storage/box/disks
	name = "diskette box"
	illustration = "disk_kit"

/obj/item/storage/box/disks/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/disk/data

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon_state = "monkeycubebox"
	illustration = null
	custom_price = PAYCHECK_CREW * 2
	storage_type = /datum/storage/box/monkey_cubes

	/// Which type of cube are we spawning in this box?
	var/cube_type = /obj/item/food/monkeycube

/obj/item/storage/box/monkeycubes/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += cube_type

/obj/item/storage/box/monkeycubes/syndicate
	desc = "Waffle Corp. brand monkey cubes. Just add water and a dash of subterfuge!"
	cube_type = /obj/item/food/monkeycube/syndicate

/obj/item/storage/box/gorillacubes
	name = "gorilla cube box"
	desc = "Waffle Corp. brand gorilla cubes. Do not taunt."
	icon_state = "monkeycubebox"
	illustration = null
	storage_type = /datum/storage/box/gorilla_cubes

/obj/item/storage/box/gorillacubes/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/food/monkeycube/gorilla

/obj/item/storage/box/stockparts
	storage_type = /datum/storage/box/stockparts

/obj/item/storage/box/stockparts/basic //for ruins where it's a bad idea to give access to an autolathe/protolathe, but still want to make stock parts accessible
	name = "box of stock parts"
	desc = "Contains a variety of basic stock parts."

/obj/item/storage/box/stockparts/basic/PopulateContents()
	var/static/items_inside = flatten_quantified_list(list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/servo = 3,
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/stock_parts/scanning_module = 3,
	))

	return items_inside

/obj/item/storage/box/stockparts/deluxe
	name = "box of deluxe stock parts"
	desc = "Contains a variety of deluxe stock parts."
	icon_state = "syndiebox"

/obj/item/storage/box/stockparts/deluxe/PopulateContents()
	var/static/items_inside = flatten_quantified_list(list(
		/obj/item/stock_parts/capacitor/quadratic = 3,
		/obj/item/stock_parts/scanning_module/triphasic = 3,
		/obj/item/stock_parts/servo/femto = 3,
		/obj/item/stock_parts/micro_laser/quadultra = 3,
		/obj/item/stock_parts/matter_bin/bluespace = 3,
	))

	return items_inside

/obj/item/storage/box/rndboards
	name = "\proper the liberator's legacy"
	desc = "A box containing a gift for worthy golems."
	illustration = "scicircuit"

/obj/item/storage/box/rndboards/PopulateContents()
	return list(
		/obj/item/circuitboard/machine/protolathe/offstation,
		/obj/item/circuitboard/machine/destructive_analyzer,
		/obj/item/circuitboard/machine/circuit_imprinter/offstation,
		/obj/item/circuitboard/computer/rdconsole,
	)

/obj/item/storage/box/stabilized //every single stabilized extract from xenobiology
	name = "box of stabilized extracts"
	icon_state = "syndiebox"

/obj/item/storage/box/stabilized/PopulateContents(datum/storage_config/config)
	config.compute_max_values()

	var/static/items_inside = list(
		/obj/item/slimecross/stabilized/adamantine,
		/obj/item/slimecross/stabilized/black,
		/obj/item/slimecross/stabilized/blue,
		/obj/item/slimecross/stabilized/bluespace,
		/obj/item/slimecross/stabilized/cerulean,
		/obj/item/slimecross/stabilized/darkblue,
		/obj/item/slimecross/stabilized/darkpurple,
		/obj/item/slimecross/stabilized/gold,
		/obj/item/slimecross/stabilized/green,
		/obj/item/slimecross/stabilized/grey,
		/obj/item/slimecross/stabilized/lightpink,
		/obj/item/slimecross/stabilized/metal,
		/obj/item/slimecross/stabilized/oil,
		/obj/item/slimecross/stabilized/orange,
		/obj/item/slimecross/stabilized/pink,
		/obj/item/slimecross/stabilized/purple,
		/obj/item/slimecross/stabilized/pyrite,
		/obj/item/slimecross/stabilized/rainbow,
		/obj/item/slimecross/stabilized/red,
		/obj/item/slimecross/stabilized/sepia,
		/obj/item/slimecross/stabilized/silver,
		/obj/item/slimecross/stabilized/yellow,
		)

	return items_inside
