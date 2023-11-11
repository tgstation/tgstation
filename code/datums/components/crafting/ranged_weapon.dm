/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/restraints/legcuffs/bola
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/sheet/iron = 6,
	)
	time = 2 SECONDS //faster than crafting them by hand!
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/gonbola
	name = "Gonbola"
	result = /obj/item/restraints/legcuffs/bola/gonbola
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/sheet/iron = 6,
		/obj/item/stack/sheet/animalhide/gondola = 1,
	)
	time = 4 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/reciever
	name = "Modular Rifle Reciever"
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER, TOOL_SAW)
	result = /obj/item/weaponcrafting/receiver
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/sticky_tape = 1,
		/obj/item/screwdriver = 1,
		/obj/item/assembly/mousetrap = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/riflestock
	name = "Wooden Rifle Stock"
	tool_paths = list(/obj/item/hatchet)
	result = /obj/item/weaponcrafting/stock
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 8,
		/obj/item/stack/sticky_tape = 1,
	)
	time = 5 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/advancedegun
	name = "Advanced Energy Gun"
	result = /obj/item/gun/energy/e_gun/nuclear
	reqs = list(
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/weaponcrafting/gunkit/nuclear = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/advancedegun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/e_gun)

/datum/crafting_recipe/tempgun
	name = "Temperature Gun"
	result = /obj/item/gun/energy/temperature
	reqs = list(
		/obj/item/gun/energy/disabler = 1,
		/obj/item/weaponcrafting/gunkit/temperature = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/tempgun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/e_gun)

/datum/crafting_recipe/beam_rifle
	name = "Particle Acceleration Rifle"
	result = /obj/item/gun/energy/beam_rifle
	reqs = list(
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/assembly/signaler/anomaly/grav = 1,
		/obj/item/weaponcrafting/gunkit/beam_rifle = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/beam_rifle/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/e_gun)

/datum/crafting_recipe/ebow
	name = "Energy Crossbow"
	result = /obj/item/gun/energy/recharge/ebow/large
	reqs = list(
		/obj/item/gun/energy/recharge/kinetic_accelerator = 1,
		/obj/item/weaponcrafting/gunkit/ebow = 1,
		/datum/reagent/uranium/radium = 15,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/xraylaser
	name = "X-ray Laser Gun"
	result = /obj/item/gun/energy/xray
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/weaponcrafting/gunkit/xray = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/xraylaser/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/hellgun
	name = "Hellfire Laser Gun"
	result = /obj/item/gun/energy/laser/hellgun
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/weaponcrafting/gunkit/hellgun = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/hellgun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/ioncarbine
	name = "Ion Carbine"
	result = /obj/item/gun/energy/ionrifle/carbine
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/weaponcrafting/gunkit/ion = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/ioncarbine/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/decloner
	name = "Biological Demolecularisor"
	result = /obj/item/gun/energy/decloner
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/weaponcrafting/gunkit/decloner = 1,
		/datum/reagent/baldium = 30,
		/datum/reagent/toxin/mutagen = 4,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/decloner/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/teslacannon
	name = "Tesla Cannon"
	result = /obj/item/gun/energy/tesla_cannon
	reqs = list(
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/weaponcrafting/gunkit/tesla = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/improvised_pneumatic_cannon //Pretty easy to obtain but
	name = "Pneumatic Cannon"
	result = /obj/item/pneumatic_cannon/ghetto
	tool_behaviors = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/package_wrap = 8,
		/obj/item/pipe/quaternary = 2,
	)
	time = 5 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/flamethrower
	name = "Flamethrower"
	result = /obj/item/flamethrower
	reqs = list(
		/obj/item/weldingtool = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/rods = 1,
	)
	parts = list(
		/obj/item/assembly/igniter = 1,
		/obj/item/weldingtool = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 1 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/pipegun
	name = "Pipegun"
	result = /obj/item/gun/ballistic/rifle/boltaction/pipegun
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
		/obj/item/pipe = 1,
		/obj/item/weaponcrafting/stock = 1,
		/obj/item/stack/sticky_tape = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/pipegun_prime
	name = "Regal Pipegun"
	always_available = FALSE
	result = /obj/item/gun/ballistic/rifle/boltaction/pipegun/prime
	reqs = list(
		/obj/item/gun/ballistic/rifle/boltaction/pipegun = 1,
		/obj/item/food/deadmouse = 1,
		/datum/reagent/consumable/grey_bull = 20,
		/obj/item/spear = 1,
		/obj/item/storage/toolbox = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	tool_paths = list(/obj/item/clothing/gloves/color/yellow, /obj/item/clothing/mask/gas, /obj/item/melee/baton/security/cattleprod)
	time = 30 SECONDS //contemplate for a bit
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/deagle_prime //When you factor in the makarov (7 tc), the toolbox (1 tc), and the emag (3 tc), this comes to a total of 18 TC or thereabouts. Igorning the 20k pricetag, obviously.
	name = "Regal Condor"
	always_available = FALSE
	result = /obj/item/gun/ballistic/automatic/pistol/deagle/regal
	reqs = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/stack/sheet/mineral/gold = 25,
		/obj/item/stack/sheet/mineral/silver = 25,
		/obj/item/food/donkpocket = 1,
		/obj/item/stack/telecrystal = 4,
		/obj/item/clothing/head/costume/crown/fancy = 1, //the captain's crown
		/obj/item/storage/toolbox/syndicate = 1,
		/obj/item/stack/sheet/iron = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	tool_paths = list(
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/card/emag
	)
	time = 30 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/deagle_prime/New()
	..()
	blacklist += subtypesof(/obj/item/gun/ballistic/automatic/pistol)

/datum/crafting_recipe/deagle_prime_mag
	name = "Regal Condor Magazine (10mm Reaper)"
	always_available = FALSE
	result = /obj/item/ammo_box/magazine/r10mm
	reqs = list(
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/sheet/mineral/gold = 10,
		/obj/item/stack/sheet/mineral/silver = 10,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/food/donkpocket = 1, //Station mass murder, as sponsored by Donk Co.
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	tool_paths = list(
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/card/emag,
		/obj/item/gun/ballistic/automatic/pistol/deagle/regal
	)
	time = 5 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/trash_cannon
	name = "Trash Cannon"
	always_available = FALSE
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	result = /obj/structure/cannon/trash
	reqs = list(
		/obj/item/melee/skateboard/improvised = 1,
		/obj/item/tank/internals/oxygen = 1,
		/datum/reagent/drug/maint/tar = 15,
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/storage/toolbox = 1,
	)
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/laser_musket
	name = "Laser Musket"
	result = /obj/item/gun/energy/laser/musket
	reqs = list(
		/obj/item/weaponcrafting/stock = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/stack/rods = 4,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/clothing/glasses/regular = 1,
		/obj/item/reagent_containers/cup/glass/drinkingglass = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/laser_musket_prime
	name = "Heroic Laser Musket"
	always_available = FALSE
	result = /obj/item/gun/energy/laser/musket/prime
	reqs = list(
		/obj/item/gun/energy/laser/musket = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/stack/sheet/mineral/silver = 5,
		/obj/item/stock_parts/water_recycler = 1,
		/datum/reagent/consumable/nuka_cola = 15,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	tool_paths = list(/obj/item/clothing/head/cowboy, /obj/item/clothing/shoes/cowboy)
	time = 30 SECONDS //contemplate for a bit
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/smoothbore_disabler
	name = "Smoothbore Disabler"
	result = /obj/item/gun/energy/disabler/smoothbore
	reqs = list(
		/obj/item/weaponcrafting/stock = 1, //it becomes the grip
		/obj/item/stack/cable_coil = 5,
		/obj/item/pipe = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/assembly/mousetrap = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/smoothbore_disabler_prime
	name = "Elite Smoothbore Disabler"
	always_available = FALSE
	result = /obj/item/gun/energy/disabler/smoothbore/prime
	reqs = list(
		/obj/item/gun/energy/disabler/smoothbore = 1,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stock_parts/cell/hyper = 1,
		/datum/reagent/reaction_agent/speed_agent = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED
