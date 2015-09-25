/obj/machinery/vending/mining
	name = "Dwarven Mining Equipment"
	desc = "Get your mining equipment here, and above all keep digging!"
	product_slogans = "This asteroid isn't going to dig itself!;Stay safe in the tunnels, bring two Kinetic Accelerators!;Jetpacks, anyone?"
	product_ads = "Hungry, thirsty or unequipped? We have your fix!"
	vend_reply = "What a glorious time to mine!"
	icon_state = "mining"
	products = list(
		/obj/item/toy/canary = 10,
		/obj/item/weapon/reagent_containers/food/snacks/hotchili = 10,
		/obj/item/clothing/mask/cigarette/cigar/havana = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 10,
		/obj/item/weapon/soap/nanotrasen = 10,
		/obj/item/clothing/mask/facehugger/toy = 10,
		/obj/item/weapon/storage/belt/lazarus = 3,
		/obj/item/device/mobcapsule = 10,
		/obj/item/weapon/lazarus_injector = 10,
		/obj/item/weapon/pickaxe/jackhammer = 5,
		/obj/item/weapon/mining_drone_cube = 5,
		/obj/item/device/wormhole_jaunter = 10,
		/obj/item/weapon/resonator = 5,
		/obj/item/weapon/gun/energy/kinetic_accelerator = 10,
		/obj/item/weapon/tank/jetpack/carbondioxide = 3,
		/obj/item/weapon/gun/hookshot = 3,
		)
	prices = list(
		/obj/item/toy/canary = 100,
		/obj/item/weapon/reagent_containers/food/snacks/hotchili = 100,
		/obj/item/clothing/mask/cigarette/cigar/havana = 100,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 150,
		/obj/item/weapon/soap/nanotrasen = 150,
		/obj/item/clothing/mask/facehugger/toy = 250,
		/obj/item/weapon/storage/belt/lazarus = 500,
		/obj/item/device/mobcapsule = 250,
		/obj/item/weapon/lazarus_injector = 1000,
		/obj/item/weapon/pickaxe/jackhammer = 500,
		/obj/item/weapon/mining_drone_cube = 500,
		/obj/item/device/wormhole_jaunter = 250,
		/obj/item/weapon/resonator = 750,
		/obj/item/weapon/gun/energy/kinetic_accelerator = 1000,
		/obj/item/weapon/tank/jetpack/carbondioxide = 2000,
		/obj/item/weapon/gun/hookshot = 3000,
		)

	pack = /obj/structure/vendomatpack/mining

//Note : Snowflake, but I don't care. Rework the fucking economy
/obj/machinery/vending/mining/New()

	..()

	if(ticker)
		initialize()

/obj/machinery/vending/mining/initialize()

	..()

	linked_account = department_accounts["Cargo"]

/obj/structure/vendomatpack/mining
	name = "Dwarven Mining Equipment recharge pack"
	targetvendomat = /obj/machinery/vending/mining
	icon_state = "mining"

/datum/supply_packs/miningmachines
	name = "Dwarven Mining Equipment stack of packs"
	contains = list(/obj/structure/vendomatpack/mining,
					/obj/structure/vendomatpack/mining)
	cost = 10
	containertype = /obj/structure/stackopacks
	containername = "Mining stack of packs"
	group = "Vending Machine packs"
