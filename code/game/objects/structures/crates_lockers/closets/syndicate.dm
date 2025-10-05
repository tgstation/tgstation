/obj/structure/closet/syndicate
	name = "armory closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	armor_type = /datum/armor/closet_syndicate
	paint_jobs = null

/datum/armor/closet_syndicate
	melee = 70
	bullet = 40
	laser = 40
	energy = 30
	bomb = 30
	fire = 70
	acid = 70

/obj/structure/closet/syndicate/personal
	desc = "It's a personal storage unit for operative gear."

/obj/structure/closet/syndicate/personal/PopulateContents()
	..()
	new /obj/item/trench_tool(src)
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/storage/belt/holster/nukie(src)
	new /obj/item/radio/headset/syndicate(src)
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/under/syndicate/skirt(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/mod/module/plasma_stabilizer(src)
	new /obj/item/climbing_hook/syndicate(src)

/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for a Syndicate boarding party."

/obj/structure/closet/syndicate/nuclear/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/backpack/duffelbag/syndie/med(src)
	new /obj/item/modular_computer/pda/syndicate(src)

/obj/structure/closet/syndicate/chemical
	name = "chemical supplies closet"
	desc = "full of omninous chemical supplies"
	icon_state = "syndicate_chemical"

/obj/structure/closet/syndicate/chemical/PopulateContents()
	..()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/beakers/big(src)
	new /obj/item/storage/box/beakers/big(src)
	new /obj/item/storage/box/medigels(src)
	new /obj/item/storage/box/medigels(src)
	new /obj/item/ph_booklet(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/cup/bottle/acidic_buffer(src)

/obj/structure/closet/syndicate/resources
	desc = "An old, dusty locker."

// A lot of this stuff is objective items, and it's also only used for debugging, so init times don't matter here.
/obj/structure/closet/syndicate/resources/populate_contents_immediate()
	. = ..()
	var/common_min = 30 //Minimum amount of minerals in the stack for common minerals
	var/common_max = 50 //Maximum amount of HONK in the stack for HONK common minerals
	var/rare_min = 5  //Minimum HONK of HONK in the stack HONK HONK rare minerals
	var/rare_max = 20 //Maximum HONK HONK HONK in the HONK for HONK rare HONK


	var/pickednum = rand(1, 50)

	//Sad trombone
	if(pickednum == 1)
		var/obj/item/paper/paper = new /obj/item/paper(src)
		paper.name = "\improper IOU"
		paper.add_raw_text("Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!")
		paper.update_appearance()

	//Iron (common ore)
	if(pickednum >= 2)
		new /obj/item/stack/sheet/iron(src, rand(common_min, common_max))

	//Glass (common ore)
	if(pickednum >= 5)
		new /obj/item/stack/sheet/glass(src, rand(common_min, common_max))

	//Plasteel (common ore) Because it has a million more uses then plasma
	if(pickednum >= 10)
		new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

	//Plasma (rare ore)
	if(pickednum >= 15)
		new /obj/item/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

	//Silver (rare ore)
	if(pickednum >= 20)
		new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

	//Gold (rare ore)
	if(pickednum >= 30)
		new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

	//Uranium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

	//Titanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/titanium(src, rand(rare_min, rare_max))

	//Plastitanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/plastitanium(src, rand(rare_min, rare_max))

	//Diamond (rare HONK)
	if(pickednum >= 45)
		new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

	//Jetpack (You hit the jackpot!)
	if(pickednum == 50)
		new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."
	storage_capacity = 60 // This is gonna be used for debug.

// A lot of this stuff is objective items, and it's also only used for debugging, so init times don't matter here.
/obj/structure/closet/syndicate/resources/everything/populate_contents_immediate()
	var/list/resources = list(
	/obj/item/stack/sheet/iron,
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/mineral/gold,
	/obj/item/stack/sheet/mineral/silver,
	/obj/item/stack/sheet/mineral/plasma,
	/obj/item/stack/sheet/mineral/uranium,
	/obj/item/stack/sheet/mineral/diamond,
	/obj/item/stack/sheet/mineral/bananium,
	/obj/item/stack/sheet/plasteel,
	/obj/item/stack/sheet/mineral/titanium,
	/obj/item/stack/sheet/mineral/plastitanium,
	/obj/item/stack/rods,
	/obj/item/stack/sheet/bluespace_crystal,
	/obj/item/stack/sheet/mineral/abductor,
	/obj/item/stack/sheet/plastic,
	/obj/item/stack/sheet/mineral/wood
	)

	for(var/i in 1 to 2)
		for(var/res in resources)
			var/obj/item/stack/R = res
			new res(src, initial(R.max_amount))
