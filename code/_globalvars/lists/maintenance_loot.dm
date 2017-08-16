//How to balance this table
//-------------------------
//The total added weight of all the entries should be (roughly) equal to the total number of lootdrops
//(take in account those that spawn more than one object!)
//
//While this is random, probabilities tells us that item distribution will have a tendency to look like
//the content of the weighted table that created them.
//The less lootdrops, the less even the distribution.
//
//If you want to give items a weight <1 you can multiply all the weights by 10
//
//the "" entry will spawn nothing, if you increase this value,
//ensure that you balance it with more spawn points

//table data:
//-----------
//aft maintenance: 		24 items, 18 spots 2 extra (28/08/2014)
//asmaint: 				16 items, 11 spots 0 extra (08/08/2014)
//asmaint2:			 	36 items, 26 spots 2 extra (28/08/2014)
//fpmaint:				5  items,  4 spots 0 extra (08/08/2014)
//fpmaint2:				12 items, 11 spots 2 extra (28/08/2014)
//fsmaint:				0  items,  0 spots 0 extra (08/08/2014)
//fsmaint2:				40 items, 27 spots 5 extra (28/08/2014)
//maintcentral:			2  items,  2 spots 0 extra (08/08/2014)
//port:					5  items,  5 spots 0 extra (08/08/2014)

GLOBAL_LIST_INIT(maintenance_loot, list(
	/obj/item/bodybag = 1,
	/obj/item/clothing/glasses/meson = 2,
	/obj/item/clothing/glasses/sunglasses = 1,
	/obj/item/clothing/gloves/color/fyellow = 1,
	/obj/item/clothing/head/hardhat = 1,
	/obj/item/clothing/head/hardhat/red = 1,
	/obj/item/clothing/head/that = 1,
	/obj/item/clothing/head/ushanka = 1,
	/obj/item/clothing/head/welding = 1,
	/obj/item/clothing/mask/gas = 15,
	/obj/item/clothing/suit/hazardvest = 1,
	/obj/item/clothing/under/rank/vice = 1,
	/obj/item/device/assembly/prox_sensor = 4,
	/obj/item/device/assembly/timer = 3,
	/obj/item/device/flashlight = 4,
	/obj/item/device/flashlight/pen = 1,
	/obj/item/device/flashlight/glowstick/random = 4,
	/obj/item/device/multitool = 2,
	/obj/item/device/radio/off = 2,
	/obj/item/device/t_scanner = 5,
	/obj/item/airlock_painter = 1,
	/obj/item/stack/cable_coil/random = 4,
	/obj/item/stack/cable_coil/random/five = 6,
	/obj/item/stack/medical/bruise_pack = 1,
	/obj/item/stack/rods/ten = 9,
	/obj/item/stack/rods/twentyfive = 1,
	/obj/item/stack/rods/fifty = 1,
	/obj/item/stack/sheet/cardboard = 2,
	/obj/item/stack/sheet/metal/twenty = 1,
	/obj/item/stack/sheet/mineral/plasma = 1,
	/obj/item/stack/sheet/rglass = 1,
	/obj/item/book/manual/wiki/engineering_construction = 1,
	/obj/item/book/manual/wiki/engineering_hacking = 1,
	/obj/item/clothing/head/cone = 1,
	/obj/item/coin/silver = 1,
	/obj/item/coin/twoheaded = 1,
	/obj/item/poster/random_contraband = 1,
	/obj/item/poster/random_official = 1,
	/obj/item/crowbar = 1,
	/obj/item/crowbar/red = 1,
	/obj/item/extinguisher = 11,
	//obj/item/gun/ballistic/revolver/russian = 1, //disabled until lootdrop is a proper world proc.
	/obj/item/hand_labeler = 1,
	/obj/item/paper/crumpled = 1,
	/obj/item/pen = 1,
	/obj/item/reagent_containers/spray/pestspray = 1,
	/obj/item/reagent_containers/glass/rag = 3,
	/obj/item/stock_parts/cell = 3,
	/obj/item/storage/belt/utility = 2,
	/obj/item/storage/box = 2,
	/obj/item/storage/box/cups = 1,
	/obj/item/storage/box/donkpockets = 1,
	/obj/item/storage/box/lights/mixed = 3,
	/obj/item/storage/box/hug/medical = 1,
	/obj/item/storage/fancy/cigarettes/dromedaryco = 1,
	/obj/item/storage/toolbox/mechanical = 1,
	/obj/item/screwdriver = 3,
	/obj/item/tank/internals/emergency_oxygen = 2,
	/obj/item/vending_refill/cola = 1,
	/obj/item/weldingtool = 3,
	/obj/item/wirecutters = 1,
	/obj/item/wrench = 4,
	/obj/item/relic = 3,
	/obj/itemcrafting/receiver = 2,
	/obj/item/clothing/head/cone = 2,
	/obj/item/grenade/smokebomb = 2,
	/obj/item/device/geiger_counter = 3,
	/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1,
	/obj/item/device/radio/headset = 1,
	/obj/item/device/assembly/infra = 1,
	/obj/item/device/assembly/igniter = 2,
	/obj/item/device/assembly/signaler = 2,
	/obj/item/device/assembly/mousetrap = 2,
	/obj/item/reagent_containers/syringe = 2,
	/obj/item/clothing/gloves/color/random = 8,
	/obj/item/clothing/shoes/laceup = 1,
	/obj/item/storage/secure/briefcase = 3,
	/obj/item/storage/toolbox/artistic = 2,
	/obj/item/toy/eightball = 1,
	"" = 3
	))
