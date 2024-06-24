/obj/effect/spawner/random/bedsheet
	name = "random dorm bedsheet"
	icon_state = "random_bedsheet"
	loot = list(/obj/item/bedsheet = 8,
		/obj/item/bedsheet/blue = 8,
		/obj/item/bedsheet/green = 8,
		/obj/item/bedsheet/grey = 8,
		/obj/item/bedsheet/orange = 8,
		/obj/item/bedsheet/purple = 8,
		/obj/item/bedsheet/red = 8,
		/obj/item/bedsheet/yellow = 8,
		/obj/item/bedsheet/brown = 8,
		/obj/item/bedsheet/black = 8,
		/obj/item/bedsheet/patriot = 2,
		/obj/item/bedsheet/rainbow = 2,
		/obj/item/bedsheet/ian = 2,
		/obj/item/bedsheet/runtime = 2,
		/obj/item/bedsheet/cosmos = 2,
		/obj/item/bedsheet/nanotrasen = 2,
		/obj/item/bedsheet/pirate = 2,
		/obj/item/bedsheet/gondola = 1,
	)

/obj/effect/spawner/random/bedsheet/double
	name = "random dorm double bedsheet"
	icon_state = "random_doublesheet"
	loot = list(
		/obj/item/bedsheet/double = 4,
		/obj/item/bedsheet/blue/double = 4,
		/obj/item/bedsheet/green/double = 4,
		/obj/item/bedsheet/grey/double = 4,
		/obj/item/bedsheet/orange/double = 4,
		/obj/item/bedsheet/purple/double = 4,
		/obj/item/bedsheet/red/double = 4,
		/obj/item/bedsheet/yellow/double = 4,
		/obj/item/bedsheet/brown/double = 4,
		/obj/item/bedsheet/black/double = 4,
		/obj/item/bedsheet/patriot/double = 1,
		/obj/item/bedsheet/rainbow/double = 1,
		/obj/item/bedsheet/ian/double = 1,
		/obj/item/bedsheet/runtime/double = 1,
		/obj/item/bedsheet/cosmos/double = 1,
		/obj/item/bedsheet/nanotrasen/double = 1,
	)

/obj/effect/spawner/random/bedsheet/any
	name = "random single bedsheet"
	loot = null
	var/static/list/bedsheet_list = list()
	var/spawn_type = BEDSHEET_SINGLE

/obj/effect/spawner/random/bedsheet/any/Initialize(mapload)
	if(isnull(bedsheet_list[spawn_type]))
		var/list/spawn_list = list()
		for(var/obj/item/bedsheet/sheet as anything in typesof(/obj/item/bedsheet))
			if(initial(sheet.bedsheet_type) == spawn_type)
				spawn_list += sheet
		bedsheet_list[spawn_type] = spawn_list
	loot = bedsheet_list[spawn_type]
	return ..()

/obj/effect/spawner/random/bedsheet/any/double
	icon_state = "random_doublesheet"
	spawn_type = BEDSHEET_DOUBLE
