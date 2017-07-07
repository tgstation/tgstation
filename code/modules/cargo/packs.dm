/datum/supply_pack
	var/name = "Crate"
	var/group = ""
	var/hidden = FALSE
	var/contraband = FALSE
	var/cost = 700 // Minimum cost, or infinite points are possible.
	var/access = FALSE
	var/access_any = FALSE
	var/list/contains = null
	var/crate_name = "crate"
	var/crate_type = /obj/structure/closet/crate
	var/dangerous = FALSE // Should we message admins?
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE

/datum/supply_pack/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = new crate_type(T)
	C.name = crate_name
	if(access)
		C.req_access = list(access)
	if(access_any)
		C.req_one_access = access_any

	fill(C)

	return C

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	for(var/item in contains)
		new item(C)


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/emergency
	group = "Emergency"

/datum/supply_pack/emergency/spacesuit
	name = "Space Suit Crate"
	cost = 3000
	access = GLOB.access_eva
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	crate_name = "space suit crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/vehicle
	name = "Biker Gang Kit" //TUNNEL SNAKES OWN THIS TOWN
	cost = 2000
	contraband = TRUE
	contains = list(/obj/vehicle/atv,
					/obj/item/key,
					/obj/item/clothing/suit/jacket/leather/overcoat,
					/obj/item/clothing/gloves/color/black,
					/obj/item/clothing/head/soft,
					/obj/item/clothing/mask/bandana/skull)//so you can properly #cargoniabikergang
	crate_name = "Biker Kit"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/emergency/equipment
	name = "Emergency Equipment"
	cost = 3500
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/weapon/tank/internals/air,
					/obj/item/weapon/tank/internals/air,
					/obj/item/weapon/tank/internals/air,
					/obj/item/weapon/tank/internals/air,
					/obj/item/weapon/tank/internals/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas)
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/internals
	name = "Internals Crate"
	cost = 1000
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/weapon/tank/internals/emergency_oxygen,
					/obj/item/weapon/tank/internals/emergency_oxygen,
					/obj/item/weapon/tank/internals/emergency_oxygen,
					/obj/item/weapon/tank/internals/air,
					/obj/item/weapon/tank/internals/air,
					/obj/item/weapon/tank/internals/air)
	crate_name = "internals crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/firefighting
	name = "Firefighting Crate"
	cost = 1000
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/device/flashlight,
					/obj/item/device/flashlight,
					/obj/item/weapon/tank/internals/oxygen/red,
					/obj/item/weapon/tank/internals/oxygen/red,
					/obj/item/weapon/extinguisher,
					/obj/item/weapon/extinguisher,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	crate_name = "firefighting crate"

/datum/supply_pack/emergency/atmostank
	name = "Firefighting Watertank"
	cost = 1000
	access = GLOB.access_atmospherics
	contains = list(/obj/item/weapon/watertank/atmos)
	crate_name = "firefighting watertank crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/radiation
	name = "Radiation Protection Crate"
	cost = 1000
	contains = list(/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/device/geiger_counter,
					/obj/item/device/geiger_counter,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass)
	crate_name = "radiation protection crate"
	crate_type = /obj/structure/closet/crate/radiation

/datum/supply_pack/emergency/weedcontrol
	name = "Weed Control Crate"
	cost = 1500
	access = GLOB.access_hydroponics
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	crate_name = "weed control crate"
	crate_type = /obj/structure/closet/crate/secure/hydroponics

/datum/supply_pack/emergency/metalfoam
	name = "Metal Foam Grenade Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/box/metalfoam)
	crate_name = "metal foam grenade crate"

/datum/supply_pack/emergency/droneshells
	name = "Drone Shell Crate"
	cost = 1000
	contains = list(/obj/item/drone_shell,
					/obj/item/drone_shell,
					/obj/item/drone_shell)
	crate_name = "drone shell crate"

/datum/supply_pack/emergency/specialops
	name = "Special Ops Supplies"
	hidden = TRUE
	cost = 2000
	contains = list(/obj/item/weapon/storage/box/emps,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/pen/sleepy,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/syndicate
	name = "NULL_ENTRY"
	hidden = TRUE
	cost = 20000
	contains = list()
	crate_name = "emergency crate"
	crate_type = /obj/structure/closet/crate/internals
	dangerous = TRUE

/datum/supply_pack/emergency/syndicate/fill(obj/structure/closet/crate/C)
	var/crate_value = 30
	var/list/uplink_items = get_uplink_items(SSticker.mode)
	while(crate_value)
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]

		if(!I.surplus || prob(100 - I.surplus))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		new I.item(C)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security
	group = "Security"
	access = GLOB.access_security
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/supplies
	name = "Security Supplies Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/storage/box/handcuffs)
	crate_name = "security supply crate"

/datum/supply_pack/security/helmets
	name = "Helmets Crate"
	cost = 1000
	contains = list(/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec)
	crate_name = "helmet crate"

/datum/supply_pack/security/armor
	name = "Armor Crate"
	cost = 1000
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	crate_name = "armor crate"

/datum/supply_pack/security/baton
	name = "Stun Batons Crate"
	cost = 1000
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded)
	crate_name = "stun baton crate"

/datum/supply_pack/security/wall_flash
	name = "Wall-Mounted Flash Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/box/wall_flash,
					/obj/item/weapon/storage/box/wall_flash,
					/obj/item/weapon/storage/box/wall_flash,
					/obj/item/weapon/storage/box/wall_flash)
	crate_name = "wall-mounted flash crate"

/datum/supply_pack/security/laser
	name = "Lasers Crate"
	cost = 2000
	contains = list(/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser)
	crate_name = "laser crate"

/datum/supply_pack/security/taser
	name = "Taser Crate"
	cost = 3000
	contains = list(/obj/item/weapon/gun/energy/e_gun/advtaser,
					/obj/item/weapon/gun/energy/e_gun/advtaser,
					/obj/item/weapon/gun/energy/e_gun/advtaser)
	crate_name = "taser crate"

/datum/supply_pack/security/disabler
	name = "Disabler Crate"
	cost = 1500
	contains = list(/obj/item/weapon/gun/energy/disabler,
					/obj/item/weapon/gun/energy/disabler,
					/obj/item/weapon/gun/energy/disabler)
	crate_name = "disabler crate"

/datum/supply_pack/security/forensics
	name = "Forensics Crate"
	cost = 2000
	contains = list(/obj/item/device/detective_scanner,
	                /obj/item/weapon/storage/box/evidence,
	                /obj/item/device/camera,
	                /obj/item/device/taperecorder,
	                /obj/item/toy/crayon/white,
	                /obj/item/clothing/head/fedora/det_hat)
	crate_name = "forensics crate"

/datum/supply_pack/security/armory
	access = GLOB.access_armory
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/armory/riothelmets
	name = "Riot Helmets Crate"
	cost = 1500
	contains = list(/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot)
	crate_name = "riot helmets crate"

/datum/supply_pack/security/armory/riotarmor
	name = "Riot Armor Crate"
	cost = 1500
	contains = list(/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot)
	crate_name = "riot armor crate"

/datum/supply_pack/security/armory/riotshields
	name = "Riot Shields Crate"
	cost = 2000
	contains = list(/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot)
	crate_name = "riot shields crate"

/datum/supply_pack/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	cost = 1500
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof)
	crate_name = "bulletproof armor crate"

/datum/supply_pack/security/armory/swat
	name = "SWAT Crate"
	cost = 6000
	contains = list(/obj/item/clothing/head/helmet/swat/nanotrasen,
					/obj/item/clothing/head/helmet/swat/nanotrasen,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/weapon/storage/belt/military/assault,
					/obj/item/weapon/storage/belt/military/assault,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/gloves/combat)
	crate_name = "swat crate"

/datum/supply_pack/security/armory/combatknives
	name = "Combat Knives Crate"
	cost = 3000
	contains = list(/obj/item/weapon/kitchen/knife/combat,
					/obj/item/weapon/kitchen/knife/combat,
					/obj/item/weapon/kitchen/knife/combat)
	crate_name = "combat knife crate"

/datum/supply_pack/security/armory/laserarmor
	name = "Reflector Vest Crate"
	cost = 2000
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)
	crate_name = "reflector vest crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/ballistic
	name = "Combat Shotguns Crate"
	cost = 8000
	contains = list(/obj/item/weapon/gun/ballistic/shotgun/automatic/combat,
					/obj/item/weapon/gun/ballistic/shotgun/automatic/combat,
					/obj/item/weapon/gun/ballistic/shotgun/automatic/combat,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier)
	crate_name = "combat shotguns crate"

/datum/supply_pack/security/armory/energy
	name = "Energy Guns Crate"
	cost = 2500
	contains = list(/obj/item/weapon/gun/energy/e_gun,
					/obj/item/weapon/gun/energy/e_gun)
	crate_name = "energy gun crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/fire
	name = "Incendiary Weapons Crate"
	cost = 1500
	access = GLOB.access_heads
	contains = list(/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/tank/internals/plasma,
					/obj/item/weapon/tank/internals/plasma,
					/obj/item/weapon/tank/internals/plasma,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	crate_name = "incendiary weapons crate"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/security/armory/wt550
	name = "WT-550 Auto Rifle Crate"
	cost = 3500
	contains = list(/obj/item/weapon/gun/ballistic/automatic/wt550,
					/obj/item/weapon/gun/ballistic/automatic/wt550)
	crate_name = "auto rifle crate"

/datum/supply_pack/security/armory/wt550ammo
	name = "WT-550 Auto Rifle Ammo Crate"
	cost = 3000
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9)
	crate_name = "auto rifle ammo crate"

/datum/supply_pack/security/armory/mindshield
	name = "mindshield implants Crate"
	cost = 4000
	contains = list(/obj/item/weapon/storage/lockbox/loyalty)
	crate_name = "mindshield implant crate"

/datum/supply_pack/security/armory/trackingimp
	name = "Tracking Implants Crate"
	cost = 2000
	contains = list(/obj/item/weapon/storage/box/trackimp)
	crate_name = "tracking implant crate"

/datum/supply_pack/security/armory/chemimp
	name = "Chemical Implants Crate"
	cost = 2000
	contains = list(/obj/item/weapon/storage/box/chemimp)
	crate_name = "chemical implant crate"

/datum/supply_pack/security/armory/exileimp
	name = "Exile Implants Crate"
	cost = 3000
	contains = list(/obj/item/weapon/storage/box/exileimp)
	crate_name = "exile implant crate"

/datum/supply_pack/security/securitybarriers
	name = "Security Barriers Crate"
	contains = list(/obj/item/weapon/grenade/barrier,
					/obj/item/weapon/grenade/barrier,
					/obj/item/weapon/grenade/barrier,
					/obj/item/weapon/grenade/barrier)
	cost = 2000
	crate_name = "security barriers crate"

/datum/supply_pack/security/firingpins
	name = "Standard Firing Pins Crate"
	cost = 2000
	contains = list(/obj/item/weapon/storage/box/firingpins,
					/obj/item/weapon/storage/box/firingpins)
	crate_name = "firing pins crate"

/datum/supply_pack/security/securityclothes
	name = "Security Clothing Crate"
	cost = 3000
	contains = list(/obj/item/clothing/under/rank/security/navyblue,
					/obj/item/clothing/under/rank/security/navyblue,
					/obj/item/clothing/suit/security/officer,
					/obj/item/clothing/suit/security/officer,
					/obj/item/clothing/head/beret/sec/navyofficer,
					/obj/item/clothing/head/beret/sec/navyofficer,
					/obj/item/clothing/under/rank/warden/navyblue,
					/obj/item/clothing/suit/security/warden,
					/obj/item/clothing/head/beret/sec/navywarden,
					/obj/item/clothing/under/rank/head_of_security/navyblue,
					/obj/item/clothing/suit/security/hos,
					/obj/item/clothing/head/beret/sec/navyhos)
	crate_name = "security clothing crate"

/datum/supply_pack/security/justiceinbound
	name = "Standard Justice Enforcer Crate"
	cost = 6000 //justice comes at a price. An expensive, noisy price.
	contraband = TRUE
	contains = list(/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/mask/gas/sechailer)
	crate_name = "security clothing crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/engineering
	group = "Engineering"
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engineering/fueltank
	name = "Fuel Tank Crate"
	cost = 800
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	crate_name = "fuel tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/oxygen
	name = "Oxygen Canister"
	cost = 1500
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	crate_name = "oxygen canister crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/nitrogen
	name = "Nitrogen Canister"
	cost = 2000
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	crate_name = "nitrogen canister crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/carbon_dio
	name = "Carbon Dioxide Canister"
	cost = 3000
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	crate_name = "carbon dioxide canister crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/science/nitrous_oxide_canister
	name = "Nitrous Oxide Canister"
	cost = 3000
	access = GLOB.access_atmospherics
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrous_oxide)
	crate_name = "nitrous oxide canister crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/engineering/tools
	name = "Toolbox Crate"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/mechanical)
	cost = 1000
	crate_name = "toolbox crate"

/datum/supply_pack/engineering/powergamermitts
	name = "Insulated Gloves Crate"
	cost = 2000	//Made of pure-grade bullshittinium
	contains = list(/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow)
	crate_name = "insulated gloves crate"

/datum/supply_pack/engineering/power
	name = "Powercell Crate"
	cost = 1000
	contains = list(/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high)
	crate_name = "electrical maintenance crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/inducers
	name = "NT-75 Electromagnetic Power Inducers Crate"
	cost = 2000
	contains = list(/obj/item/weapon/inducer/sci {cell_type = /obj/item/weapon/stock_parts/cell/{maxcharge = 5000; charge = 5000};opened = 0},/obj/item/weapon/inducer/sci {cell_type = /obj/item/weapon/stock_parts/cell/{maxcharge = 5000; charge = 5000};opened = 0}) //FALSE doesn't work in modified type paths apparently.
	crate_name = "inducer crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/engiequipment
	name = "Engineering Gear Crate"
	cost = 1300
	contains = list(/obj/item/weapon/storage/belt/utility,
					/obj/item/weapon/storage/belt/utility,
					/obj/item/weapon/storage/belt/utility,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/glasses/meson/engine,
					/obj/item/clothing/glasses/meson/engine)
	crate_name = "engineering gear crate"


/datum/supply_pack/engineering/shieldgen
	name = "Anti-breach Shield Projector Crate"
	cost = 2500
	contains = list(/obj/machinery/shieldgen,
					/obj/machinery/shieldgen)
	crate_name = "anti-breach shield projector crate"

/datum/supply_pack/engineering/grounding_rods
	name = "Grounding Rod Crate"
	cost = 1700
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	crate_name = "grounding rod crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/pacman
	name = "P.A.C.M.A.N Generator Crate"
	cost = 2500
	contains = list(/obj/machinery/power/port_gen/pacman)
	crate_name = "PACMAN generator crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/solar
	name = "Solar Panel Crate"
	cost = 2000
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/weapon/circuitboard/computer/solar_control,
					/obj/item/weapon/electronics/tracker,
					/obj/item/weapon/paper/solar)
	crate_name = "solar panel crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/engine
	name = "Emitter Crate"
	cost = 1500
	access = GLOB.access_ce
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	crate_name = "emitter crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engineering/engine/field_gen
	name = "Field Generator Crate"
	cost = 1500
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	crate_name = "field generator crate"

/datum/supply_pack/engineering/engine/sing_gen
	name = "Singularity Generator Crate"
	cost = 5000
	contains = list(/obj/machinery/the_singularitygen)
	crate_name = "singularity generator crate"

/datum/supply_pack/engineering/engine/tesla_gen
	name = "Tesla Generator Crate"
	cost = 5000
	contains = list(/obj/machinery/the_singularitygen/tesla)
	crate_name = "tesla generator crate"

/datum/supply_pack/engineering/engine/collector
	name = "Collector Crate"
	cost = 2500
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	crate_name = "collector crate"

/datum/supply_pack/engineering/engine/PA
	name = "Particle Accelerator Crate"
	cost = 3000
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	crate_name = "particle accelerator crate"

/datum/supply_pack/engineering/engine/supermatter_shard
	name = "Supermatter Shard Crate"
	cost = 10000
	access = GLOB.access_ce
	contains = list(/obj/machinery/power/supermatter_shard)
	crate_name = "supermatter shard crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engineering/engine/am_shielding
	name = "Antimatter Shielding Crate"
	cost = 2000
	contains = list(/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container)//10 shields: 3x3 containment and a core
	crate_name = "antimatter shielding crate"

/datum/supply_pack/engineering/engine/am_core
	name = "Antimatter Control Crate"
	cost = 5000
	contains = list(/obj/machinery/power/am_control_unit)
	crate_name = "antimatter control crate"

/datum/supply_pack/engineering/engine/am_jar
	name = "Antimatter Containment Jar Crate"
	cost = 2000
	contains = list(/obj/item/weapon/am_containment,
					/obj/item/weapon/am_containment)
	crate_name = "antimatter jar crate"

/datum/supply_pack/engineering/shuttle_engine
	name = "Shuttle Engine Crate"
	cost = 5000
	access = GLOB.access_ce
	contains = list(/obj/structure/shuttle/engine/propulsion/burst/cargo)
	crate_name = "shuttle engine crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	special = TRUE

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/medical
	group = "Medical"
	crate_type = /obj/structure/closet/crate/medical

/datum/supply_pack/medical/supplies
	name = "Medical Supplies Crate"
	cost = 2000
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/charcoal,
					/obj/item/weapon/reagent_containers/glass/bottle/charcoal,
					/obj/item/weapon/reagent_containers/glass/bottle/epinephrine,
					/obj/item/weapon/reagent_containers/glass/bottle/epinephrine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/weapon/reagent_containers/pill/insulin,
					/obj/item/weapon/reagent_containers/pill/insulin,
					/obj/item/weapon/reagent_containers/pill/insulin,
					/obj/item/weapon/reagent_containers/pill/insulin,
					/obj/item/stack/medical/gauze,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/storage/box/syringes,
				    /obj/item/weapon/storage/box/bodybags)
	crate_name = "medical supplies crate"

/datum/supply_pack/medical/firstaid
	name = "First Aid Kit Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular)
	crate_name = "first aid kit crate"

/datum/supply_pack/medical/firstaidbruises
	name = "Bruise Treatment Kit Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/brute)
	crate_name = "brute treatment kit crate"

/datum/supply_pack/medical/firstaidburns
	name = "Burn Treatment Kit Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire)
	crate_name = "burn treatment kit crate"

/datum/supply_pack/medical/firstaidtoxins
	name = "Toxin Treatment Kit Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin)
	crate_name = "toxin treatment kit crate"

/datum/supply_pack/medical/firstaidoxygen
	name = "Oxygen Deprivation Kit Crate"
	cost = 1000
	contains = list(/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2)
	crate_name = "oxygen deprivation kit crate"

/datum/supply_pack/medical/virus
	name = "Virus Crate"
	cost = 2500
	access = GLOB.access_cmo
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/flu_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/cold,
					/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/weapon/reagent_containers/glass/bottle/magnitis,
					/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/weapon/reagent_containers/glass/bottle/brainrot,
					/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/anxiety,
					/obj/item/weapon/reagent_containers/glass/bottle/beesease,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/reagent_containers/glass/bottle/mutagen)
	crate_name = "virus crate"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/medical/bloodpacks
	name = "Blood Pack Variety Crate"
	cost = 3500
	contains = list(/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/APlus,
					/obj/item/weapon/reagent_containers/blood/AMinus,
					/obj/item/weapon/reagent_containers/blood/BPlus,
					/obj/item/weapon/reagent_containers/blood/BMinus,
					/obj/item/weapon/reagent_containers/blood/OPlus,
					/obj/item/weapon/reagent_containers/blood/OMinus)
	crate_name = "blood freezer"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/medical/iv_drip
	name = "IV Drip Crate"
	cost = 1000
	contains = list(/obj/machinery/iv_drip)
	crate_name = "iv drip crate"

/datum/supply_pack/medical/defibs
	name = "Defibrillator Crate"
	cost = 2500
	contains = list(/obj/item/weapon/defibrillator/loaded,
					/obj/item/weapon/defibrillator/loaded)
	crate_name = "defibrillator crate"

/datum/supply_pack/medical/vending
	name = "Medical Vending Crate"
	cost = 2000
	contains = list(/obj/item/weapon/vending_refill/medical,
					/obj/item/weapon/vending_refill/medical,
					/obj/item/weapon/vending_refill/medical)
	crate_name = "medical vending crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/science
	group = "Science"
	crate_type = /obj/structure/closet/crate/science

/datum/supply_pack/science/robotics
	name = "Robotics Assembly Crate"
	cost = 1000
	access = GLOB.access_robotics
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high)
	crate_name = "robotics assembly crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/robotics/mecha_ripley
	name = "Circuit Crate (Ripley APLU)"
	cost = 3000
	access = GLOB.access_robotics
	contains = list(/obj/item/weapon/book/manual/ripley_build_and_repair,
					/obj/item/weapon/circuitboard/mecha/ripley/main,
					/obj/item/weapon/circuitboard/mecha/ripley/peripherals)
	crate_name = "\improper APLU Ripley circuit crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/robotics/mecha_odysseus
	name = "Circuit Crate (Odysseus)"
	cost = 2500
	access = GLOB.access_robotics
	contains = list(/obj/item/weapon/circuitboard/mecha/odysseus/peripherals,
					/obj/item/weapon/circuitboard/mecha/odysseus/main)
	crate_name = "\improper Odysseus circuit crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/plasma
	name = "Plasma Assembly Crate"
	cost = 1000
	access = GLOB.access_tox_storage
	contains = list(/obj/item/weapon/tank/internals/plasma,
					/obj/item/weapon/tank/internals/plasma,
					/obj/item/weapon/tank/internals/plasma,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	crate_name = "plasma assembly crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/science/shieldwalls
	name = "Shield Generators"
	cost = 2000
	access = GLOB.access_teleporter
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	crate_name = "shield generators crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	cost = 6000
	access = GLOB.access_rd
	contains = list(/obj/item/device/transfer_valve,
					/obj/item/device/transfer_valve)
	crate_name = "tank transfer valves crate"
	crate_type = /obj/structure/closet/crate/secure/science
	dangerous = TRUE

/datum/supply_pack/science/bz_canister
	name = "BZ Canister"
	cost = 2000
	access_any = list(GLOB.access_rd, GLOB.access_atmospherics)
	contains = list(/obj/machinery/portable_atmospherics/canister/bz)
	crate_name = "bz canister crate"
	crate_type = /obj/structure/closet/crate/secure/science
	dangerous = TRUE

/datum/supply_pack/science/freon_canister
	name = "Freon Canister"
	cost = 6000
	access_any = list(GLOB.access_rd, GLOB.access_atmospherics)
	contains = list(/obj/machinery/portable_atmospherics/canister/freon)
	crate_name = "freon canister crate"
	crate_type = /obj/structure/closet/crate/secure/science
	dangerous = TRUE

/datum/supply_pack/science/research
	name = "Machine Prototype Crate"
	cost = 8000
	access = GLOB.access_research
	contains = list(/obj/item/device/machineprototype)
	crate_name = "machine prototype crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/tablets
	name = "Tablet Crate"
	cost = 5000
	contains = list(/obj/item/device/modular_computer/tablet/preset/cargo,
					/obj/item/device/modular_computer/tablet/preset/cargo,
					/obj/item/device/modular_computer/tablet/preset/cargo,
					/obj/item/device/modular_computer/tablet/preset/cargo,
					/obj/item/device/modular_computer/tablet/preset/cargo)
	crate_name = "tablet crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/organic
	group = "Food & Livestock"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/organic/food
	name = "Food Crate"
	cost = 1000
	contains = list(/obj/item/weapon/reagent_containers/food/condiment/flour,
					/obj/item/weapon/reagent_containers/food/condiment/rice,
					/obj/item/weapon/reagent_containers/food/condiment/milk,
					/obj/item/weapon/reagent_containers/food/condiment/soymilk,
					/obj/item/weapon/reagent_containers/food/condiment/saltshaker,
					/obj/item/weapon/reagent_containers/food/condiment/peppermill,
					/obj/item/weapon/storage/fancy/egg_box,
					/obj/item/weapon/reagent_containers/food/condiment/enzyme,
					/obj/item/weapon/reagent_containers/food/condiment/sugar,
					/obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	crate_name = "food crate"

/datum/supply_pack/organic/pizza
	name = "Pizza Crate"
	cost = 6000 // Best prices this side of the galaxy.
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable)
	crate_name = "pizza crate"

/datum/supply_pack/organic/cream_piee
	name = "High-yield Clown-grade Cream Pie Crate"
	cost = 6000
	contains = list(/obj/item/weapon/storage/backpack/duffelbag/clown/cream_pie)
	crate_name = "party equipment crate"
	contraband = TRUE
	access = GLOB.access_theatre
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/organic/monkey
	name = "Monkey Crate"
	cost = 2000
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	crate_name = "monkey crate"

/datum/supply_pack/organic/party
	name = "Party Equipment"
	cost = 2000
	contains = list(/obj/item/weapon/storage/box/drinkingglasses,
					/obj/item/weapon/reagent_containers/food/drinks/shaker,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/patron,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/device/flashlight/glowstick,
					/obj/item/device/flashlight/glowstick/red,
					/obj/item/device/flashlight/glowstick/blue,
					/obj/item/device/flashlight/glowstick/cyan,
					/obj/item/device/flashlight/glowstick/orange,
					/obj/item/device/flashlight/glowstick/yellow,
					/obj/item/device/flashlight/glowstick/pink)
	crate_name = "party equipment crate"

/datum/supply_pack/organic/critter
	crate_type = /obj/structure/closet/crate/critter

/datum/supply_pack/organic/critter/cow
	name = "Cow Crate"
	cost = 3000
	contains = list(/mob/living/simple_animal/cow)
	crate_name = "cow crate"

/datum/supply_pack/organic/critter/goat
	name = "Goat Crate"
	cost = 2500
	contains = list(/mob/living/simple_animal/hostile/retaliate/goat)
	crate_name = "goat crate"

/datum/supply_pack/organic/critter/chick
	name = "Chicken Crate"
	cost = 2000
	contains = list( /mob/living/simple_animal/chick)
	crate_name = "chicken crate"

/datum/supply_pack/organic/critter/corgi
	name = "Corgi Crate"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/corgi,
					/obj/item/clothing/neck/petcollar)
	crate_name = "corgi crate"

/datum/supply_pack/organic/critter/corgi/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/dog/corgi/D = locate() in .
		qdel(D)
		new /mob/living/simple_animal/pet/dog/corgi/Lisa(.)

/datum/supply_pack/organic/critter/cat
	name = "Cat Crate"
	cost = 5000 //Cats are worth as much as corgis.
	contains = list(/mob/living/simple_animal/pet/cat,
					/obj/item/clothing/neck/petcollar,
                    /obj/item/toy/cattoy)
	crate_name = "cat crate"

/datum/supply_pack/organic/critter/cat/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/cat/C = locate() in .
		qdel(C)
		new /mob/living/simple_animal/pet/cat/Proc(.)

/datum/supply_pack/organic/critter/pug
	name = "Pug Crate"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/pug,
					/obj/item/clothing/neck/petcollar)
	crate_name = "pug crate"

/datum/supply_pack/organic/critter/fox
	name = "Fox Crate"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/fox,
					/obj/item/clothing/neck/petcollar)
	crate_name = "fox crate"

/datum/supply_pack/organic/critter/butterfly
	name = "Butterflies Crate"
	contraband = TRUE
	cost = 5000
	contains = list(/mob/living/simple_animal/butterfly)
	crate_name = "entomology samples crate"

/datum/supply_pack/organic/critter/butterfly/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/simple_animal/butterfly(.)

/datum/supply_pack/organic/hydroponics
	name = "Hydroponics Crate"
	cost = 1500
	contains = list(/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/hatchet,
					/obj/item/weapon/cultivator,
					/obj/item/device/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron)
	crate_name = "hydroponics crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/hydrotank
	name = "Hydroponics Backpack Crate"
	cost = 1000
	access = GLOB.access_hydroponics
	contains = list(/obj/item/weapon/watertank)
	crate_name = "hydroponics backpack crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/organic/potted_plants
	name = "Potted Plants Crate"
	cost = 700
	contains = list(/obj/item/weapon/twohanded/required/kirbyplants/random,
					/obj/item/weapon/twohanded/required/kirbyplants/random,
					/obj/item/weapon/twohanded/required/kirbyplants/random,
					/obj/item/weapon/twohanded/required/kirbyplants/random,
					/obj/item/weapon/twohanded/required/kirbyplants/random)
	crate_name = "potted plants crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/seeds
	name = "Seeds Crate"
	cost = 1000
	contains = list(/obj/item/seeds/chili,
					/obj/item/seeds/berry,
					/obj/item/seeds/corn,
					/obj/item/seeds/eggplant,
					/obj/item/seeds/tomato,
					/obj/item/seeds/soya,
					/obj/item/seeds/wheat,
					/obj/item/seeds/wheat/rice,
					/obj/item/seeds/carrot,
					/obj/item/seeds/sunflower,
					/obj/item/seeds/chanter,
					/obj/item/seeds/potato,
					/obj/item/seeds/sugarcane)
	crate_name = "seeds crate"

/datum/supply_pack/organic/hydroponics/exoticseeds
	name = "Exotic Seeds Crate"
	cost = 1500
	contains = list(/obj/item/seeds/nettle,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/plump,
					/obj/item/seeds/liberty,
					/obj/item/seeds/amanita,
					/obj/item/seeds/reishi,
					/obj/item/seeds/banana,
					/obj/item/seeds/eggplant/eggy,
					/obj/item/seeds/random,
					/obj/item/seeds/random)
	crate_name = "exotic seeds crate"

/datum/supply_pack/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Crate"
	cost = 1500
	contains = list(/obj/structure/beebox,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/weapon/melee/flyswatter)
	crate_name = "beekeeping starter crate"

/datum/supply_pack/organic/hydroponics/beekeeping_suits
	name = "Beekeeper Suit Crate"
	cost = 1000
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	crate_name = "beekeeper suits"

/datum/supply_pack/organic/vending
	name = "Bartending Supply Crate"
	cost = 2000
	contains = list(/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee)
	crate_name = "bartending supply crate"

/datum/supply_pack/organic/vending/snack
	name = "Snack Supply Crate"
	cost = 1500
	contains = list(/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack)
	crate_name = "snacks supply crate"

/datum/supply_pack/organic/vending/cola
	name = "Softdrinks Supply Crate"
	cost = 1500
	contains = list(/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola)
	crate_name = "soft drinks supply crate"

/datum/supply_pack/organic/vending/cigarette
	name = "Cigarette Supply Crate"
	cost = 1500
	contains = list(/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette)
	crate_name = "cigarette supply crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Materials ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/materials
	group = "Raw Materials"

/datum/supply_pack/materials/metal50
	name = "50 Metal Sheets"
	cost = 1000
	contains = list(/obj/item/stack/sheet/metal/fifty)
	crate_name = "metal sheets crate"

/datum/supply_pack/materials/plasteel20
	name = "20 Plasteel Sheets"
	cost = 7500
	contains = list(/obj/item/stack/sheet/plasteel/twenty)
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/plasteel50
	name = "50 Plasteel Sheets"
	cost = 16500
	contains = list(/obj/item/stack/sheet/plasteel/fifty)
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/glass50
	name = "50 Glass Sheets"
	cost = 1000
	contains = list(/obj/item/stack/sheet/glass/fifty)
	crate_name = "glass sheets crate"

/datum/supply_pack/materials/wood50
	name = "50 Wood Planks"
	cost = 2000
	contains = list(/obj/item/stack/sheet/mineral/wood/fifty)
	crate_name = "wood planks crate"

/datum/supply_pack/materials/cardboard50
	name = "50 Cardboard Sheets"
	cost = 1000
	contains = list(/obj/item/stack/sheet/cardboard/fifty)
	crate_name = "cardboard sheets crate"

/datum/supply_pack/materials/plastic50
	name = "50 Plastic Sheets"
	cost = 1000
	contains = list(/obj/item/stack/sheet/plastic/fifty)
	crate_name = "plastic sheets crate"

/datum/supply_pack/materials/sandstone30
	name = "30 Sandstone Blocks"
	cost = 1000
	contains = list(/obj/item/stack/sheet/mineral/sandstone/thirty)
	crate_name = "sandstone blocks crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc
	group = "Miscellaneous Supplies"

/datum/supply_pack/misc/minerkit
	name = "Shaft Miner Starter Kit"
	cost = 2500
	access = GLOB.access_qm
	contains = list(/obj/item/weapon/pickaxe/mini,
			/obj/item/clothing/glasses/meson,
			/obj/item/device/t_scanner/adv_mining_scanner/lesser,
			/obj/item/device/radio/headset/headset_cargo/mining,
			/obj/item/weapon/storage/bag/ore,
			/obj/item/clothing/suit/hooded/explorer,
			/obj/item/clothing/mask/gas/explorer)
	crate_name = "shaft miner starter kit"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/misc/mule
	name = "MULEbot Crate"
	cost = 2000
	contains = list(/mob/living/simple_animal/bot/mulebot)
	crate_name = "\improper MULEbot Crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/conveyor
	name = "Conveyor Assembly Crate"
	cost = 1500
	contains = list(/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_switch_construct,
					/obj/item/weapon/paper/conveyor)
	crate_name = "conveyor assembly crate"

/datum/supply_pack/misc/watertank
	name = "Water Tank Crate"
	cost = 600
	contains = list(/obj/structure/reagent_dispensers/watertank)
	crate_name = "water tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/hightank
	name = "High-Capacity Water Tank Crate"
	cost = 1200
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	crate_name = "high-capacity water tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/water_vapor
	name = "Water Vapor Canister"
	cost = 2500
	contains = list(/obj/machinery/portable_atmospherics/canister/water_vapor)
	crate_name = "water vapor canister crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/lasertag
	name = "Laser Tag Crate"
	cost = 1500
	contains = list(/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	crate_name = "laser tag crate"

/datum/supply_pack/misc/lasertag/pins
	name = "Laser Tag Firing Pins Crate"
	cost = 3000
	contraband = TRUE
	contains = list(/obj/item/weapon/storage/box/lasertagpins)
	crate_name = "laser tag crate"

/datum/supply_pack/misc/clownpin
	name = "Hilarious Firing Pin Crate"
	cost = 5000
	contraband = TRUE
	contains = list(/obj/item/device/firing_pin/clown)
	// It's /technically/ a toy. For the clown, at least.
	crate_name = "toy crate"

/datum/supply_pack/misc/religious_supplies
	name = "Religious Supplies Crate"
	cost = 4000	// it costs so much because the Space Church is ran by Space Jews
	contains = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/weapon/storage/book/bible/booze,
					/obj/item/weapon/storage/book/bible/booze,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/under/burial,
					/obj/item/clothing/under/burial)
	crate_name = "religious supplies crate"

/datum/supply_pack/misc/book_crate
	name = "Book Crate"
	cost = 1500
	contains = list(/obj/item/weapon/book/codex_gigas,
					/obj/item/weapon/book/manual/random/,
					/obj/item/weapon/book/manual/random/,
					/obj/item/weapon/book/manual/random/,
					/obj/item/weapon/book/random/triple)

/datum/supply_pack/misc/paper
	name = "Bureaucracy Crate"
	cost = 1500
	contains = list(/obj/structure/filingcabinet/chestdrawer/wheeled,
					/obj/item/device/camera_film,
					/obj/item/weapon/hand_labeler,
					/obj/item/hand_labeler_refill,
					/obj/item/hand_labeler_refill,
					/obj/item/weapon/paper_bin,
					/obj/item/weapon/pen/fourcolor,
					/obj/item/weapon/pen/fourcolor,
					/obj/item/weapon/pen,
					/obj/item/weapon/pen/fountain,
					/obj/item/weapon/pen/blue,
					/obj/item/weapon/pen/red,
					/obj/item/weapon/folder/blue,
					/obj/item/weapon/folder/red,
					/obj/item/weapon/folder/yellow,
					/obj/item/weapon/clipboard,
					/obj/item/weapon/clipboard,
					/obj/item/weapon/stamp,
					/obj/item/weapon/stamp/denied)
	crate_name = "bureaucracy crate"

/datum/supply_pack/misc/fountainpens
	name = "Calligraphy Crate"
	cost = 700
	contains = list(/obj/item/weapon/storage/box/fountainpens)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/toner
	name = "Toner Crate"
	cost = 1000
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	crate_name = "toner crate"

/datum/supply_pack/misc/janitor
	name = "Janitorial Supplies Crate"
	cost = 1000
	contains = list(/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/mop,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/storage/bag/trash,
					/obj/item/weapon/reagent_containers/spray/cleaner,
					/obj/item/weapon/reagent_containers/glass/rag,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner)
	crate_name = "janitorial supplies crate"

/datum/supply_pack/misc/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	cost = 2000
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	crate_name = "janitorial cart crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/janitor/janitank
	name = "Janitor Backpack Crate"
	cost = 1000
	access = GLOB.access_janitor
	contains = list(/obj/item/weapon/watertank/janitor)
	crate_name = "janitor backpack crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/misc/janitor/lightbulbs
	name = "Replacement Lights"
	cost = 1000
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	crate_name = "replacement lights"

/datum/supply_pack/misc/noslipfloor
	name = "High-traction Floor Tiles"
	cost = 2000
	contains = list(/obj/item/stack/tile/noslip/thirty)
	crate_name = "high-traction floor tiles crate"

/datum/supply_pack/misc/plasmaman
	name = "Plasmaman Supply Kit"
	cost = 2000
	contains = list(/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/weapon/tank/internals/plasmaman/belt/full,
					/obj/item/weapon/tank/internals/plasmaman/belt/full,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman)
	crate_name = "plasmaman supply kit"

/datum/supply_pack/misc/costume
	name = "Standard Costume Crate"
	cost = 1000
	access = GLOB.access_theatre
	contains = list(/obj/item/weapon/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/weapon/bikehorn,
					/obj/item/clothing/under/rank/mime,
					/obj/item/clothing/shoes/sneakers/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing,
					/obj/item/weapon/storage/backpack/mime)
	crate_name = "standard costume crate"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/misc/costume_original
	name = "Original Costume Crate"
	cost = 1000
	contains = list(/obj/item/clothing/head/snowman,
					/obj/item/clothing/suit/snowman,
					/obj/item/clothing/head/chicken,
					/obj/item/clothing/suit/chickensuit,
					/obj/item/clothing/mask/gas/monkeymask,
					/obj/item/clothing/suit/monkeysuit,
					/obj/item/clothing/head/cardborg,
					/obj/item/clothing/suit/cardborg,
					/obj/item/clothing/head/xenos,
					/obj/item/clothing/suit/xenos,
					/obj/item/clothing/suit/hooded/ian_costume,
					/obj/item/clothing/suit/hooded/carp_costume,
					/obj/item/clothing/suit/hooded/bee_costume)
	crate_name = "original costume crate"

/datum/supply_pack/misc/wizard
	name = "Wizard Costume Crate"
	cost = 2000
	contains = list(/obj/item/weapon/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	crate_name = "wizard costume crate"

/datum/supply_pack/misc/randomised
	name = "Collectable Hats Crate!"
	cost = 20000
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/HoP,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	crate_name = "collectable hats crate"

/datum/supply_pack/misc/randomised/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	for(var/i in 1 to num_contained)
		var/item = pick_n_take(L)
		new item(C)


/datum/supply_pack/misc/randomised/contraband
	name = "Contraband Crate"
	contraband = TRUE
	cost = 3000
	num_contained = 5
	contains = list(/obj/item/weapon/poster/random_contraband,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_shadyjims,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_midori,
					/obj/item/seeds/ambrosia/deus,
					/obj/item/clothing/neck/necklace/dope)
	crate_name = "crate"

/datum/supply_pack/misc/randomised/toys
	name = "Toy Crate"
	cost = 5000 // or play the arcade machines ya lazy bum
	// TODO make this actually just use the arcade machine loot list
	num_contained = 5
	contains = list(/obj/item/toy/spinningtoy,
	                /obj/item/toy/sword,
	                /obj/item/toy/foamblade,
	                /obj/item/toy/talking/AI,
	                /obj/item/toy/talking/owl,
	                /obj/item/toy/talking/griffin,
	                /obj/item/toy/nuke,
	                /obj/item/toy/minimeteor,
	                /obj/item/toy/carpplushie,
	                /obj/item/weapon/coin/antagtoken,
	                /obj/item/stack/tile/fakespace/loaded,
	                /obj/item/weapon/gun/ballistic/shotgun/toy/crossbow,
	                /obj/item/toy/redbutton,
					/obj/item/toy/eightball)
	crate_name = "toy crate"

/datum/supply_pack/misc/autodrobe
	name = "Autodrobe Supply Crate"
	cost = 1500
	contains = list(/obj/item/weapon/vending_refill/autodrobe,
					/obj/item/weapon/vending_refill/autodrobe)
	crate_name = "autodrobe supply crate"

/datum/supply_pack/misc/formalwear
	name = "Formalwear Crate"
	cost = 3000 //Lots of very expensive items. You gotta pay up to look good!
	contains = list(/obj/item/clothing/under/blacktango,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/lawyer/bluesuit,
					/obj/item/clothing/suit/toggle/lawyer,
					/obj/item/clothing/under/lawyer/purpsuit,
					/obj/item/clothing/suit/toggle/lawyer/purple,
					/obj/item/clothing/under/lawyer/blacksuit,
					/obj/item/clothing/suit/toggle/lawyer/black,
					/obj/item/clothing/accessory/waistcoat,
					/obj/item/clothing/neck/tie/blue,
					/obj/item/clothing/neck/tie/red,
					/obj/item/clothing/neck/tie/black,
					/obj/item/clothing/head/bowler,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/head/flatcap,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/head/that,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/under/suit_jacket/charcoal,
					/obj/item/clothing/under/suit_jacket/navy,
					/obj/item/clothing/under/suit_jacket/burgundy,
					/obj/item/clothing/under/suit_jacket/checkered,
					/obj/item/clothing/under/suit_jacket/tan,
					/obj/item/weapon/lipstick/random)
	crate_name = "formalwear crate"

/datum/supply_pack/misc/foamforce
	name = "Foam Force Crate"
	cost = 1000
	contains = list(/obj/item/weapon/gun/ballistic/shotgun/toy,
					/obj/item/weapon/gun/ballistic/shotgun/toy,
					/obj/item/weapon/gun/ballistic/shotgun/toy,
					/obj/item/weapon/gun/ballistic/shotgun/toy,
					/obj/item/weapon/gun/ballistic/shotgun/toy,
					/obj/item/weapon/gun/ballistic/shotgun/toy,
					/obj/item/weapon/gun/ballistic/shotgun/toy,
					/obj/item/weapon/gun/ballistic/shotgun/toy)
	crate_name = "foam force crate"

/datum/supply_pack/misc/foamforce/bonus
	name = "Foam Force Pistols Crate"
	contraband = TRUE
	cost = 4000
	contains = list(/obj/item/weapon/gun/ballistic/automatic/toy/pistol,
					/obj/item/weapon/gun/ballistic/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	crate_name = "foam force crate"

/datum/supply_pack/misc/artsupply
	name = "Art Supplies"
	cost = 800
	contains = list(/obj/structure/easel,
					/obj/structure/easel,
					/obj/item/weapon/canvas/nineteenXnineteen,
					/obj/item/weapon/canvas/nineteenXnineteen,
					/obj/item/weapon/canvas/twentythreeXnineteen,
					/obj/item/weapon/canvas/twentythreeXnineteen,
					/obj/item/weapon/canvas/twentythreeXtwentythree,
					/obj/item/weapon/canvas/twentythreeXtwentythree,
					/obj/item/toy/crayon/rainbow,
					/obj/item/toy/crayon/rainbow)
	crate_name = "art supply crate"

/datum/supply_pack/misc/bsa
	name = "Bluespace Artillery Parts"
	cost = 15000
	special = TRUE
	contains = list(/obj/item/weapon/circuitboard/machine/bsa/front,
					/obj/item/weapon/circuitboard/machine/bsa/middle,
					/obj/item/weapon/circuitboard/machine/bsa/back,
					/obj/item/weapon/circuitboard/computer/bsa_control
					)
	crate_name= "bluespace artillery parts crate"

/datum/supply_pack/misc/dna_vault
	name = "DNA Vault Parts"
	cost = 12000
	special = TRUE
	contains = list(
					/obj/item/weapon/circuitboard/machine/dna_vault,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe
					)
	crate_name= "dna vault parts crate"

/datum/supply_pack/misc/dna_probes
	name = "DNA Vault Samplers"
	cost = 3000
	special = TRUE
	contains = list(/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe
					)
	crate_name= "dna samplers crate"


/datum/supply_pack/misc/shield_sat
	name = "Shield Generator Satellite"
	cost = 3000
	special = TRUE
	contains = list(
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield
					)
	crate_name= "shield sat crate"


/datum/supply_pack/misc/shield_sat_control
	name = "Shield System Control Board"
	cost = 5000
	special = TRUE
	contains = list(
					/obj/item/weapon/circuitboard/machine/computer/sat_control
					)
	crate_name= "shield control board crate"

/datum/supply_pack/misc/bicycle
	name = "Bicycle"
	cost = 1000000
	contains = list(/obj/vehicle/bicycle)
	crate_name = "Bicycle Crate"
	crate_type = /obj/structure/closet/crate/large
