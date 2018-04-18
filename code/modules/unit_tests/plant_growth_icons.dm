/datum/unit_test/plant_growth_icons

/datum/unit_test/plant_growth_icons/Run()
	var/list/files = list(
		'icons/obj/hydroponics/growing.dmi',
		'icons/obj/hydroponics/growing_fruits.dmi',
		'icons/obj/hydroponics/growing_flowers.dmi',
		'icons/obj/hydroponics/growing_mushrooms.dmi',
		'icons/obj/hydroponics/growing_vegetables.dmi',
		'goon/icons/obj/hydroponics.dmi'
		)
	var/list/states = list()
	for(var/file in files)
		states["[file]"] = icon_states(file)
	var/list/paths = typesof(/obj/item/seeds) - /obj/item/seeds - typesof(/obj/item/seeds/sample)

	for(var/seedpath in paths)
		var/obj/item/seeds/seed = new seedpath

		for(var/i in 1 to seed.growthstages)
			if("[seed.icon_grow][i]" in states[seed.growing_icon])
				continue
			Fail("[seed.name] ([seed.type]) lacks the [seed.icon_grow][i] icon!")

		if(!(seed.icon_dead in states[seed.growing_icon]))
			Fail("[seed.name] ([seed.type]) lacks the [seed.icon_dead] icon!")

		if(seed.icon_harvest) // mushrooms have no grown sprites, same for items with no product
			if(!(seed.icon_harvest in states[seed.growing_icon]))
				Fail("[seed.name] ([seed.type]) lacks the [seed.icon_harvest] icon!")
