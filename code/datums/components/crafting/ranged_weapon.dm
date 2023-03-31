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
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/e_gun/nuclear
	reqs = list(
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/nuclear = 1,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/advancedegun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/e_gun)

/datum/crafting_recipe/tempgun
	name = "Temperature Gun"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/temperature
	reqs = list(
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/temperature = 1,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/tempgun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/e_gun)

/datum/crafting_recipe/beam_rifle
	name = "Particle Acceleration Rifle"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/beam_rifle
	reqs = list(
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/assembly/signaler/anomaly/grav = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/beam_rifle = 1,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/beam_rifle/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/e_gun)

/datum/crafting_recipe/ebow
	name = "Energy Crossbow"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/recharge/ebow/large
	reqs = list(
		/obj/item/gun/energy/recharge/kinetic_accelerator = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/ebow = 1,
		/datum/reagent/uranium/radium = 15,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/xraylaser
	name = "X-ray Laser Gun"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/xray
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/xray = 1,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/xraylaser/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/hellgun
	name = "Hellfire Laser Gun"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/laser/hellgun
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/hellgun = 1,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/hellgun/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/ioncarbine
	name = "Ion Carbine"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/ionrifle/carbine
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/ion = 1,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/ioncarbine/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/decloner
	name = "Biological Demolecularisor"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/decloner
	reqs = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/decloner = 1,
		/datum/reagent/baldium = 30,
		/datum/reagent/toxin/mutagen = 4,
	)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/decloner/New()
	..()
	blacklist += subtypesof(/obj/item/gun/energy/laser)

/datum/crafting_recipe/teslacannon
	name = "Tesla Cannon"
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/gun/energy/tesla_cannon
	reqs = list(
		/obj/item/assembly/signaler/anomaly/flux = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/weaponcrafting/gunkit/tesla = 1,
	)
	time = 20 SECONDS
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
