/datum/table_recipe
	var/name = ""
	var/reqs[] = list()
	var/results[] = list()
	var/tools[] = list()
	var/time = 0
	var/parts[] = list()
	var/chem_catalists[] = list()

/datum/table_recipe/IED
	name = "IED"
	results = list(/obj/item/weapon/grenade/iedcasing)
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/cable_coil = 1,
				/obj/item/device/assembly/igniter = 1,
				/obj/item/weapon/reagent_containers/food/drinks/soda_cans = 1,
				/datum/reagent/fuel = 10)
	time = 80

/datum/table_recipe/stunprod
	name = "Stunprod"
	results = list(/obj/item/weapon/melee/baton/cattleprod)
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/weapon/wirecutters = 1,
				/obj/item/weapon/stock_parts/cell = 1)
	time = 80
	parts = list(/obj/item/weapon/stock_parts/cell = 1)

/datum/table_recipe/ed209
	name = "ED209"
	results = list(/obj/machinery/bot/ed209)
	reqs = list(/obj/item/robot_parts/robot_suit = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/clothing/suit/armor/vest = 1,
				/obj/item/robot_parts/l_leg = 1,
				/obj/item/robot_parts/r_leg = 1,
				/obj/item/stack/sheet/metal = 5,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weapon/gun/energy/taser = 1,
				/obj/item/weapon/stock_parts/cell = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	tools = list(/obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver)
	time = 120

/datum/table_recipe/secbot
	name = "Secbot"
	results = list(/obj/machinery/bot/secbot)
	reqs = list(/obj/item/device/assembly/signaler = 1,
				/obj/item/clothing/head/helmet = 1,
				/obj/item/weapon/melee/baton = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	tools = list(/obj/item/weapon/weldingtool)
	time = 120

/datum/table_recipe/cleanbot
	name = "Cleanbot"
	results = list(/obj/machinery/bot/cleanbot)
	reqs = list(/obj/item/weapon/reagent_containers/glass/bucket = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/table_recipe/floorbot
	name = "Floorbot"
	results = list(/obj/machinery/bot/floorbot)
	reqs = list(/obj/item/weapon/storage/toolbox/mechanical = 1,
				/obj/item/stack/tile/plasteel = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/table_recipe/medbot
	name = "Medbot"
	results = list(/obj/machinery/bot/medbot)
	reqs = list(/obj/item/device/healthanalyzer = 1,
				/obj/item/weapon/storage/firstaid = 1,
				/obj/item/device/assembly/prox_sensor = 1,
				/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/table_recipe/flamethrower
	name = "Flamethrower"
	results = list(/obj/item/weapon/flamethrower)
	reqs = list(/obj/item/weapon/weldingtool = 1,
				/obj/item/device/assembly/igniter = 1,
				/obj/item/stack/rods = 2)
	tools = list(/obj/item/weapon/screwdriver)
	time = 20

/datum/table_recipe/meteorshot
	name = "Meteorshot Shell"
	results = list(/obj/item/ammo_casing/shotgun/meteorshot)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/weapon/rcd_ammo = 1,
				/obj/item/weapon/stock_parts/manipulator = 2)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5

/datum/table_recipe/pulseslug
	name = "Pulse Slug Shell"
	results = list(/obj/item/ammo_casing/shotgun/pulseslug)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/weapon/stock_parts/capacitor/adv = 2,
				/obj/item/weapon/stock_parts/micro_laser/ultra = 1)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5

/datum/table_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	results = list(/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath)
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/phosphorus = 5,)
	tools = list(/obj/item/weapon/screwdriver)
	time = 5