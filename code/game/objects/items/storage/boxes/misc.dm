/obj/item/storage/box/syndie_kit/syndicate_teleporter
	name = "syndicate teleporter kit"

/obj/item/storage/box/syndie_kit/syndicate_teleporter/PopulateContents()
	new /obj/item/syndicate_teleporter(src)
	new /obj/item/paper/syndicate_teleporter(src)

/obj/item/storage/box/alchemist_basic_chems
	name = "box of alchemical bases"
	desc = "Contains a set of basic reagents, for all your potion-making needs! If only you labeled them."
	illustration = "beaker"

/obj/item/storage/box/alchemist_basic_chems/PopulateContents()
	for(var/i in 1 to 7)
		if(prob(1))
			new /obj/item/reagent_containers/cup/glass/coffee(src)
			continue
		new /obj/item/reagent_containers/cup/bottle/alchemist_basic(src)

/obj/item/storage/box/alchemist_random_chems
	name = "box of potions"
	desc = "An especially fancy box to keep your finished potions safe."
	icon_state = "syndiebox"
	illustration = "beaker"

/obj/item/storage/box/alchemist_random_chems/PopulateContents()
	for(var/i in 1 to 7)
		if(prob(1))
			new /obj/item/reagent_containers/cup/glass/coffee(src)
			continue
		new /obj/item/reagent_containers/cup/bottle/alchemist_random(src)

/obj/item/storage/box/alchemist_chemistry_kit
	name = "box of alchemy tools"
	desc = "Contains everything needed for the up and coming chemistry student to enact hazardous chemical mishaps in the comfort of their own home."

/obj/item/storage/box/alchemist_chemistry_kit/PopulateContents()
	new /obj/item/reagent_containers/cup/mortar(src)
	new /obj/item/pestle(src)
	new /obj/item/lighter/skull(src)
	new /obj/item/ph_booklet(src)
	new /obj/item/thermometer(src)
	new /obj/item/storage/test_tube_rack/full(src)
	new /obj/item/reagent_containers/cup/glass/coffee(src)


/obj/item/storage/box/mechabeacons
	name = "exosuit tracking beacons"

/obj/item/storage/box/mechabeacons/PopulateContents()
	..()
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)

/obj/item/storage/box/methdealer
	name = "box"
	desc = "A brown box."
	icon_state = "blank_package"

/obj/item/storage/box/methdealer/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/food/drug/meth_crystal = 4,
		/obj/item/cigarette/pipe/crackpipe = 2,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/opiumdealer
	name = "box"
	desc = "A brown box."
	icon_state = "blank_package"

/obj/item/storage/box/opiumdealer/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/food/drug/opium = 4,
		/obj/item/cigarette/pipe/cobpipe = 2,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/kronkdealer
	name = "box"
	desc = "A brown box."
	icon_state = "blank_package"

/obj/item/storage/box/kronkdealer/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/food/drug/moon_rock = 4,
		/obj/item/cigarette/pipe/crackpipe = 2,
	)
	generate_items_inside(items_inside, src)
