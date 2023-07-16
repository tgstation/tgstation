/datum/market_item/weapon
	category = "Weapons"

/datum/market_item/weapon/bear_trap
	name = "Bear Trap"
	desc = "Get the janitor back at his own game with this affordable prank kit."
	item = /obj/item/restraints/legcuffs/beartrap

	price_min = CARGO_CRATE_VALUE * 1.5
	price_max = CARGO_CRATE_VALUE * 2.75
	stock_max = 3
	availability_prob = 40

/datum/market_item/weapon/shotgun_dart
	name = "Shotgun Dart"
	desc = "These handy darts can be filled up with any chemical and be shot with a shotgun! \
	Prank your friends by shooting them with laughter! \
	Not recommended for comercial use."
	item = /obj/item/ammo_casing/shotgun/dart

	price_min = CARGO_CRATE_VALUE * 0.05
	price_max = CARGO_CRATE_VALUE * 0.25
	stock_min = 10
	stock_max = 60
	availability_prob = 40

/datum/market_item/weapon/bone_spear
	name = "Bone Spear"
	desc = "Authentic tribal spear, made from real bones! A steal at any price, especially if you're a caveman."
	item = /obj/item/spear/bonespear

	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 1.5
	stock_max = 3
	availability_prob = 60

/datum/market_item/weapon/chainsaw
	name = "Chainsaw"
	desc = "A lumberjack's best friend, perfect for cutting trees or limbs efficiently."
	item = /obj/item/chainsaw

	price_min = CARGO_CRATE_VALUE * 1.75
	price_max = CARGO_CRATE_VALUE * 3
	stock_max = 1
	availability_prob = 35

/datum/market_item/weapon/switchblade
	name = "Switchblade"
	desc = "Tunnel Snakes rule!"
	item = /obj/item/switchblade

	price_min = CARGO_CRATE_VALUE * 1.25
	price_max = CARGO_CRATE_VALUE * 1.75
	stock_max = 3
	availability_prob = 45

/datum/market_item/weapon/emp_grenade
	name = "EMP Grenade"
	desc = "Use this grenade for SHOCKING results!"
	item = /obj/item/grenade/empgrenade

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 2
	stock_max = 2
	availability_prob = 50

//monke edits
/datum/market_item/weapon/smoothbore_disabler_prime
	name = "Elite Smoothbore Disabler"
	desc = "A rare and sought after disabler often used by Nanotrasen's high command, and historical LARPers."
	item = /obj/item/gun/energy/disabler/smoothbore/prime

	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 40

/datum/market_item/weapon/pipegun_recipe
	name = "Diary of a Dead Assistant"
	desc = "Found this book in my Archives, had some barely legible scrabblings about making 'The perfect pipegun'. Figured someone here would buy this."
	item = /obj/item/book/granter/crafting_recipe/maint_gun/pipegun_prime

	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 1
	availability_prob = 40

/datum/market_item/weapon/musket_recipe
	name = "Journal of a Space Ranger"
	desc = "An old banned book written by an eccentric space ranger, notable for its detailed description of how to make powerful improvised lasers."
	item = /obj/item/book/granter/crafting_recipe/maint_gun/laser_musket_prime

	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 40

/datum/market_item/weapon/smoothbore_recipe
	name = "Old Tome"
	desc = "Ahoy Maties, I, Captain Whitebeard, have plundered the ol' Nanotrasen station, among the booty retreived was this here tome about smoothbores. Alas, I have no use for its knowlege, so I am droppin it off here."
	item = /obj/item/book/granter/crafting_recipe/maint_gun/smoothbore_disabler_prime

	price_min = CARGO_CRATE_VALUE * 6
	price_max = CARGO_CRATE_VALUE * 8
	stock_max = 1
	availability_prob = 20
