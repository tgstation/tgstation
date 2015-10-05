/datum/game_mode/meteor/proc/meteor_initial_supply()

	var/list/meteor_initial_drop = list(/obj/structure/closet/crate/engi/meteor_materials, \
	/obj/structure/closet/crate/meteor_assorted_protection, \
	/obj/structure/closet/crate/engi/meteor_buildgear, \
	/obj/structure/closet/crate/freezer/meteor_pizza, \
	/obj/structure/closet/crate/meteor_panic, \
	/obj/structure/closet/crate/secure/large/meteor_shieldwallgen, \
	/obj/structure/closet/crate/secure/large/meteor_shieldgens, \
	/obj/structure/closet/crate/secure/large/meteor_power, \
	/obj/structure/closet/crate/engi/meteor_breach, \
	/obj/machinery/computer/bhangmeter)

	var/area/initial_supply_area = locate(/area/crew_quarters/bar)

	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread

	//One loop for each crate
	for(var/meteor_supplypaths in meteor_initial_drop)
		var/list/turf/simulated/floor/valid = list()
		//Loop through each floor in the supply drop area
		for(var/turf/simulated/floor/F in initial_supply_area)
			if(!F.has_dense_content())
				valid.Add(F)

		var/picked = pick(valid)
		spark_system.attach(picked)
		spark_system.set_up(5, 0, picked)
		spark_system.start()
		new meteor_supplypaths(picked)

/*
 * Below are all the supply crates that spawn on the initial drop
 */

//Barricades and physical fortifications
/obj/structure/closet/crate/engi/meteor_materials
	name = "\improper Space Weather Inc. materials crate"
	desc = "For all your building and rebuilding needs."

/obj/structure/closet/crate/engi/meteor_materials/New()

	..()
	getFromPool(/obj/item/stack/sheet/metal, src, 50)
	getFromPool(/obj/item/stack/sheet/metal, src, 50)
	getFromPool(/obj/item/stack/sheet/wood, src, 50)
	getFromPool(/obj/item/stack/sheet/wood, src, 50)
	getFromPool(/obj/item/stack/sheet/glass/rglass, src, 50)
	getFromPool(/obj/item/stack/sheet/glass/plasmarglass, src, 50)

//Assorted protection items. Gloves, sunglasses
/obj/structure/closet/crate/meteor_assorted_protection
	name = "\improper Space Weather Inc. protective gear crate"
	desc = "Cool crewmen don't look at meteor explosions, with the naked eye."

/obj/structure/closet/crate/meteor_assorted_protection/New()

	..()
	//Three boxes containing seven black gloves each
	new /obj/item/weapon/storage/box/bgloves(src)
	new /obj/item/weapon/storage/box/bgloves(src)
	new /obj/item/weapon/storage/box/bgloves(src)
	//Three boxes containing seven sunglasses each
	new /obj/item/weapon/storage/box/sunglasses(src)
	new /obj/item/weapon/storage/box/sunglasses(src)
	new /obj/item/weapon/storage/box/sunglasses(src)

//Building gear
/obj/structure/closet/crate/engi/meteor_buildgear
	name = "\improper Space Weather Inc. build gear"
	desc = "Building gear, for all your building needs."

/obj/structure/closet/crate/engi/meteor_buildgear/New()

	..()
	new /obj/item/weapon/storage/belt/utility/complete(src)
	new /obj/item/weapon/storage/belt/utility/complete(src)
	new /obj/item/weapon/storage/belt/utility/complete(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)

//Pizza, just in case
/obj/structure/closet/crate/freezer/meteor_pizza
	name = "\improper Space Weather Inc. pizza stash"
	desc = "Who can endure a 24/7 weather monitoring job without pizza ? Not us."

/obj/structure/closet/crate/freezer/meteor_pizza/New()

	..()
	new /obj/item/pizzabox/margherita(src)
	new /obj/item/pizzabox/margherita(src)
	new /obj/item/pizzabox/mushroom(src)
	new /obj/item/pizzabox/meat(src)
	new /obj/item/pizzabox/meat(src)
	new /obj/item/pizzabox/vegetable(src)
	new /obj/item/weapon/kitchen/utensil/knife/large(src)

//Flavor and flares
/obj/structure/closet/crate/meteor_panic
	name = "\improper Space Weather Inc. panic kit"
	desc = "Open only in case of absolute emergency, or severe boredom."

/obj/structure/closet/crate/meteor_panic/New()

	new /obj/item/device/violin(src) //My tune will go on
	new /obj/item/weapon/phone(src)
	new /obj/item/weapon/storage/fancy/flares(src)
	new /obj/item/weapon/storage/fancy/flares(src)
	new /obj/item/weapon/paper_bin(src) //Any last wishes ?
	new /obj/item/weapon/pen/red(src)

//Will create a large forcefield if given enough power
/obj/structure/closet/crate/secure/large/meteor_shieldwallgen
	name = "\improper Space Weather Inc. wall shield generator"
	desc = "Ensure a proper power source is available for sustained operation."

/obj/structure/closet/crate/secure/large/meteor_shieldwallgen/New()

	..()
	new /obj/machinery/shieldwallgen(src)
	new /obj/machinery/shieldwallgen(src)
	new /obj/machinery/shieldwallgen(src)
	new /obj/machinery/shieldwallgen(src)

//Can protect window bays locally by putting forcefields in front of them, limited usefulness
/obj/structure/closet/crate/secure/large/meteor_shieldgens
	name = "\improper Space Weather Inc. point shield generators"
	desc = "Four portable point shield generators that can hold up a window bay against small meteor pelting."

/obj/structure/closet/crate/secure/large/meteor_shieldgens/New()

	..()
	new /obj/machinery/shieldgen(src)
	new /obj/machinery/shieldgen(src)
	new /obj/machinery/shieldgen(src)
	new /obj/machinery/shieldgen(src)

//Power to run all that fancy shit. Partially at least, evacuating the AME isn't a bad idea
/obj/structure/closet/crate/secure/large/meteor_power
	name = "\improper Space Weather Inc. emergency generator"
	desc = "Uranium-powered SUPERPACMAN emergency generator. Keep away from meteors."

/obj/structure/closet/crate/secure/large/meteor_power/New()

	..()
	new /obj/machinery/power/port_gen/pacman/super(src)
	getFromPool(/obj/item/stack/sheet/mineral/uranium, src, 50)

/obj/structure/closet/crate/engi/meteor_breach
	name = "\improper Space Weather Inc. anti-breach kit"
	desc = "Apply grenade to breached area, apply atmospherics taperoll to entrances to said area."

/obj/structure/closet/crate/engi/meteor_breach/New()

	..()
	new /obj/item/taperoll/atmos(src)
	new /obj/item/taperoll/atmos(src)
	new /obj/item/taperoll/atmos(src)
	new /obj/item/weapon/storage/box/foam(src)
	new /obj/item/weapon/storage/box/foam(src)
