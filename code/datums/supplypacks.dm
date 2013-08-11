//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

// Supply Groups
var/const/supply_emergency 	= 1
var/const/supply_security 	= 2
var/const/supply_engineer	= 3
var/const/supply_medical	= 4
var/const/supply_science	= 5
var/const/supply_organic	= 6
var/const/supply_materials 	= 7
var/const/supply_misc		= 8

var/list/all_supply_groups = list(supply_emergency,supply_security,supply_engineer,supply_medical,supply_science,supply_organic,supply_materials,supply_misc)

/proc/get_supply_group_name(var/cat)
	switch(cat)
		if(1)
			return "Emergency"
		if(2)
			return "Security"
		if(3)
			return "Engineering"
		if(4)
			return "Medical"
		if(5)
			return "Science"
		if(6)
			return "Food & Livestock"
		if(7)
			return "Raw Materials"
		if(8)
			return "Miscellaneous"


/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = supply_misc


/datum/supply_packs/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = new path()
		manifest += "<li>[AM.name]</li>"
		AM.loc = null	//just to make sure they're deleted by the garbage collector
	manifest += "</ul>"


////// Use the sections to keep things tidy please /Malkevin

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/weapon/storage/box/emps,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/pen/paralysis,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	hidden = 1
	group = supply_emergency

/datum/supply_packs/internals
	name = "Internals crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air)
	cost = 10
	containertype = /obj/structure/closet/crate/internals
	containername = "internals crate"
	group = supply_emergency

/datum/supply_packs/evacuation
	name = "Emergency equipment"
	contains = list(/obj/machinery/bot/floorbot,
					/obj/machinery/bot/floorbot,
					/obj/machinery/bot/medbot,
					/obj/machinery/bot/medbot,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas)
	cost = 35
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"
	group = supply_emergency

/datum/supply_packs/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = access_hydroponics
	group = supply_emergency


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/security
	name = "Security Supplies crate"
	contains = list(/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/storage/box/handcuffs)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "security supply crate"
	access = access_security
	group = supply_security

/////// Implants

/datum/supply_packs/loyalty
	name = "Loyalty implants crate"
	contains = list (/obj/item/weapon/storage/lockbox/loyalty)
	cost = 40
	containertype = /obj/structure/closet/crate/secure
	containername = "loyalty implant crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/trackingimp
	name = "Tracking implants crate"
	contains = list (/obj/item/weapon/storage/box/trackimp)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "tracking implant crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/chemimp
	name = "Chemical implants crate"
	contains = list (/obj/item/weapon/storage/box/chemimp)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "chemical implant crate"
	access = access_armory
	group = supply_security


////// Armor: Basic

/datum/supply_packs/helmets
	name = "Helmets crate"
	contains = list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "helmet crate"
	access = access_security
	group = supply_security

/datum/supply_packs/armor
	name = "Armor crate"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "armor crate"
	access = access_security
	group = supply_security

////// Weapons: Basic

/datum/supply_packs/baton
	name = "Stun Batons crate"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "stun baton crate"
	access = access_security
	group = supply_security

/datum/supply_packs/laser
	name = "Lasers crate"
	contains = list(/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "laser crate"
	access = access_security
	group = supply_security

/datum/supply_packs/taser
	name = "Stun Guns crate"
	contains = list(/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/gun/energy/taser)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "stun gun crate"
	access = access_security
	group = supply_security

///// Armor: Specialist

/datum/supply_packs/riotshields
	name = "Riot shields crate"
	contains = list(/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "riot shields crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/riot
	name = "Riot helmets crate"
	contains = list(/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "riot helmets crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/riot
	name = "Riot suits crate"
	contains = list(/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "riot suits crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/bulletarmor
	name = "Bulletproof armor crate"
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "bulletproof armor crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/laserarmor
	name = "Ablative armor crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)		// Only two vests to keep costs down for balance
	cost = 20
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ablative armor crate"
	access = access_armory
	group = supply_security

/////// Weapons: Specialist



/datum/supply_packs/ballistic
	name = "Combat Shotguns crate"
	contains = list(/obj/item/weapon/gun/projectile/shotgun/pump/combat,
					/obj/item/weapon/gun/projectile/shotgun/pump/combat,
					/obj/item/weapon/gun/projectile/shotgun/pump/combat)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "combat shotgun crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/expenergy
	name = "Energy Guns crate"
	contains = list(/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)			// Only two guns to keep costs down
	cost = 25
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "energy gun crate"
	access = access_armory
	group = supply_security

/datum/supply_packs/eweapons
	name = "Incendiary weapons crate"
	contains = list(/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 15	// its a fecking flamethrower and some plasma, why the shit did this cost so much before!?
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "incendiary weapons crate"
	access = access_heads
	group = supply_security

/datum/supply_packs/securitybarriers
	name = "Security Barriers"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "security barriers crate"
	group = supply_security


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"
	group = supply_engineer

/datum/supply_packs/toolbox		//the most robust crate
	name = "Toolbox crate"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/mechanical)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "electrical maintenance crate"
	group = supply_engineer

/datum/supply_packs/powergamermitts
	name = "Insulated Gloves crate"
	contains = list(/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow)
	cost = 20	//Made of pure-grade bullshittinium
	containertype = /obj/structure/closet/crate
	containername = "insulated gloves crate"
	group = supply_engineer

/datum/supply_packs/power
	name = "Powercell crate"
	contains = list(/obj/item/weapon/cell/high,		//Changed to an extra high powercell because normal cells are useless
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "electrical maintenance crate"
	group = supply_engineer

/datum/supply_packs/engiequipment
	name = "Engineering Gear crate"
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
					/obj/item/clothing/head/hardhat)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "engineering gear crate"
	group = supply_engineer

/datum/supply_packs/solar
	name = "Solar Pack crate"
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
					/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/tracker_electronics,
					/obj/item/weapon/paper/solar)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "solar pack crate"
	group = supply_engineer

/datum/supply_packs/engine
	name = "Emitter crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "emitter crate"
	access = access_ce
	group = supply_engineer

/datum/supply_packs/engine/field_gen
	name = "Field Generator crate"
	contains = list(/obj/machinery/field_generator,
					/obj/machinery/field_generator)
	containertype = /obj/structure/closet/crate/secure
	containername = "field generator crate"
	access = access_ce
	group = supply_engineer

/datum/supply_packs/engine/sing_gen
	name = "Singularity Generator crate"
	contains = list(/obj/machinery/the_singularitygen)
	containertype = /obj/structure/closet/crate/secure
	containername = "singularity generator crate"
	access = access_ce
	group = supply_engineer

/datum/supply_packs/engine/collector
	name = "Collector crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	containername = "collector crate"
	group = supply_engineer

/datum/supply_packs/engine/PA
	name = "Particle Accelerator crate"
	cost = 25
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	containertype = /obj/structure/closet/crate/secure
	containername = "particle accelerator crate"
	access = access_ce
	group = supply_engineer


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/medical
	name = "Medical Supplies crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/storage/box/syringes)
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "medical supplies crate"
	group = supply_medical

/datum/supply_packs/firstaid
	name = "First Aid Kits crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "first aid kits crate"
	group = supply_medical

/datum/supply_packs/firstaidburns
	name = "Burns Treatment Kits crate"
	contains = list(/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "fire first aid kits crate"
	group = supply_medical

/datum/supply_packs/firstaidtoxins
	name = "Toxin Treatment Kits crate"
	contains = list(/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "toxin first aid kits crate"
	group = supply_medical

/datum/supply_packs/firstaidoxygen
	name = "Oxygen Deprivation Kits crate"
	contains = list(/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "oxygen deprivation kits crate"
	group = supply_medical


/datum/supply_packs/virus
	name = "Virus crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/flu_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/cold,
					/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/weapon/reagent_containers/glass/bottle/magnitis,
					/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/weapon/reagent_containers/glass/bottle/brainrot,
					/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/reagent_containers/glass/bottle/mutagen)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "virus crate"
	access = access_cmo
	group = supply_medical


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/mecha_ripley
	name = "Circuit Crate (\"Ripley\" APLU)"
	contains = list(/obj/item/weapon/book/manual/ripley_build_and_repair,
					/obj/item/weapon/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper APLU \"Ripley\" circuit crate"
	access = access_robotics
	group = supply_science

/datum/supply_packs/mecha_odysseus
	name = "Circuit Crate (\"Odysseus\")"
	contains = list(/obj/item/weapon/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper \"Odysseus\" circuit crate"
	access = access_robotics
	group = supply_science


/datum/supply_packs/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "robotics assembly crate"
	access = access_robotics
	group = supply_science

/datum/supply_packs/plasma
	name = "Plasma assembly crate"
	contains = list(/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasma assembly crate"
	access = access_tox_storage
	group = supply_science

/datum/supply_packs/shieldwalls
	name = "Shield Generators"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "shield generators crate"
	access = access_teleporter
	group = supply_science


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/food
	name = "Food crate"
	contains = list(/obj/item/weapon/reagent_containers/food/drinks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/reagent_containers/food/drinks/soymilk,
					/obj/item/weapon/storage/fancy/egg_box,
					/obj/item/weapon/reagent_containers/food/condiment/enzyme,
					/obj/item/weapon/reagent_containers/food/condiment/sugar,
					/obj/item/weapon/reagent_containers/food/snacks/meat/monkey,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "food crate"
	group = supply_organic

/datum/supply_packs/monkey
	name = "Monkey crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "monkey crate"
	group = supply_organic

/datum/supply_packs/party
	name = "Party equipment"
	contains = list(/obj/item/weapon/storage/box/drinkingglasses,
					/obj/item/weapon/reagent_containers/food/drinks/shaker,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/patron,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/ale,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer,
					/obj/item/weapon/reagent_containers/food/drinks/beer)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "party equipment"
	group = supply_organic

//////// livestock
/datum/supply_packs/cow
	name = "Cow Crate"
	cost = 30
	containertype = /obj/structure/largecrate/cow
	containername = "cow crate"
	access = access_hydroponics
	group = supply_organic

/datum/supply_packs/goat
	name = "Goat Crate"
	cost = 25
	containertype = /obj/structure/largecrate/goat
	containername = "goat crate"
	access = access_hydroponics
	group = supply_organic

/datum/supply_packs/chicken
	name = "Chicken Crate"
	cost = 20
	containertype = /obj/structure/largecrate/chick
	containername = "chicken crate"
	access = access_hydroponics
	group = supply_organic

/datum/supply_packs/lisa
	name = "Corgi Crate"
	contains = list()
	cost = 50
	containertype = /obj/structure/largecrate/lisa
	containername = "corgi crate"
	group = supply_organic

////// hippy gear

/datum/supply_packs/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/hatchet,
					/obj/item/weapon/minihoe,
					/obj/item/device/analyzer/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with new things
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics crate"
	access = access_hydroponics
	group = supply_organic

/datum/supply_packs/seeds
	name = "Seeds Crate"
	contains = list(/obj/item/seeds/chiliseed,
					/obj/item/seeds/berryseed,
					/obj/item/seeds/cornseed,
					/obj/item/seeds/eggplantseed,
					/obj/item/seeds/tomatoseed,
					/obj/item/seeds/soyaseed,
					/obj/item/seeds/wheatseed,
					/obj/item/seeds/carrotseed,
					/obj/item/seeds/sunflowerseed,
					/obj/item/seeds/chantermycelium,
					/obj/item/seeds/potatoseed,
					/obj/item/seeds/sugarcaneseed)
	cost = 10
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "seeds crate"
	access = access_hydroponics
	group = supply_organic

/datum/supply_packs/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list(/obj/item/seeds/nettleseed,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/plumpmycelium,
					/obj/item/seeds/libertymycelium,
					/obj/item/seeds/amanitamycelium,
					/obj/item/seeds/reishimycelium,
					/obj/item/seeds/bananaseed,
					/obj/item/seeds/eggyseed)
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "exotic seeds crate"
	access = access_hydroponics
	group = supply_organic


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Materials ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "metal sheets crate"
	group = supply_materials

/datum/supply_packs/plasteel20
	name = "20 Plasteel Sheets"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 20
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "plasteel sheets crate"
	group = supply_materials

/datum/supply_packs/plasteel50
	name = "50 Plasteel Sheets"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 50
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "plasteel sheets crate"
	group = supply_materials

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "glass sheets crate"
	group = supply_materials

/datum/supply_packs/cardboard50
	name = "50 Cardboard Sheets"
	contains = list(/obj/item/stack/sheet/cardboard)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "cardboard sheets crate"
	group = supply_materials

/datum/supply_packs/sandstone30
	name = "30 Sandstone Blocks"
	contains = list(/obj/item/stack/sheet/mineral/sandstone)
	amount = 30
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "sandstone blocks crate"
	group = supply_materials
/*		// Disabled by request of coderbus
/datum/supply_packs/wood30
	name = "25 Wood Planks"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 25
	cost = 25
	containertype = /obj/structure/closet/crate
	containername = "wood planks crate"
	group = supply_materials

/datum/supply_packs/wood50
	name = "50 Wood Planks"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 50
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "wood planks crate"
	group = supply_materials

/// Precious materials: these are intentionally priced high to not make mining redundent

/datum/supply_packs/silver10
	name = "10 Silver Ingots"
	contains = list(/obj/item/stack/sheet/mineral/silver)
	amount = 10
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "silver ingots crate"
	group = supply_materials

/datum/supply_packs/silver20
	name = "20 Silver Ingots"
	contains = list(/obj/item/stack/sheet/mineral/silver)
	amount = 20
	cost = 45
	containertype = /obj/structure/closet/crate
	containername = "silver ingots crate"
	group = supply_materials

/datum/supply_packs/gold10
	name = "10 Gold Ingots"
	contains = list(/obj/item/stack/sheet/mineral/gold)
	amount = 10
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "gold ingots crate"
	group = supply_materials

/datum/supply_packs/gold20
	name = "20 Gold Ingots"
	contains = list(/obj/item/stack/sheet/mineral/gold)
	amount = 20
	cost = 45
	containertype = /obj/structure/closet/crate
	containername = "gold ingots crate"
	group = supply_materials

/datum/supply_packs/uranium10
	name = "10 Uranium Blocks"
	contains = list(/obj/item/stack/sheet/mineral/uranium)
	amount = 10
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "uranium blocks crate"
	group = supply_materials

/datum/supply_packs/uranium20
	name = "20 Uranium Blocks"
	contains = list(/obj/item/stack/sheet/mineral/uranium)
	amount = 20
	cost = 45
	containertype = /obj/structure/closet/crate
	containername = "uranium blocks crate"
	group = supply_materials

/datum/supply_packs/diamonds10
	name = "10 Diamonds"
	contains = list(/obj/item/stack/sheet/mineral/diamond)
	amount = 10
	cost = 60		// Damn Space Jews artificially inflating prices
	containertype = /obj/structure/closet/crate
	containername = "diamond crate"
	group = supply_materials

/datum/supply_packs/plasma10
	name = "10 Plasma Blocks"
	contains = list(/obj/item/stack/sheet/mineral/plasma)
	amount = 10
	cost = 50		// One of the reasons the station exists is to mine this shit, hence the high cost
	containertype = /obj/structure/closet/crate
	containername = "plasma blocks crate"
	group = supply_materials
*/

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/mule
	name = "MULEbot Crate"
	contains = list(/obj/machinery/bot/mulebot)
	cost = 20
	containertype = /obj/structure/largecrate/mule
	containername = "\improper MULEbot Crate"
	group = supply_misc

/datum/supply_packs/watertank
	name = "Water tank crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "water tank crate"
	group = supply_misc


///////////// Paper Work

/datum/supply_packs/paper
	name = "Bureaucracy crate"
	contains = list(/obj/structure/filingcabinet/chestdrawer/wheeled,
					/obj/item/device/camera_film,
					/obj/item/weapon/hand_labeler,
					/obj/item/hand_labeler_refill,
					/obj/item/hand_labeler_refill,
					/obj/item/weapon/paper_bin,
					/obj/item/weapon/pen,
					/obj/item/weapon/pen/blue,
					/obj/item/weapon/pen/red,
					/obj/item/weapon/folder/blue,
					/obj/item/weapon/folder/red,
					/obj/item/weapon/folder/yellow,
					/obj/item/weapon/clipboard,
					/obj/item/weapon/clipboard)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Bureaucracy crate"
	group = supply_misc

/datum/supply_packs/toner
	name = "Toner Cartridges"
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "toner cartridges"
	group = supply_misc


///////////// Janitor Supplies

/datum/supply_packs/janitor
	name = "Janitorial supplies"
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
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "janitorial supplies"
	group = supply_misc

/datum/supply_packs/janicart
	name = "Janitorial Cart crate"
	contains = list(/obj/structure/janitorialcart)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "janitorial cart crate"
	group = supply_misc

/datum/supply_packs/lightbulbs
	name = "Replacement lights"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "replacement lights"
	group = supply_misc


///////////// Costumes

/datum/supply_packs/costume
	name = "Standard Costume crate"
	contains = list(/obj/item/weapon/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/weapon/bikehorn,
					/obj/item/clothing/under/mime,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/gloves/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "standard costumes"
	access = access_theatre
	group = supply_misc

/datum/supply_packs/wizard
	name = "Wizard costume"
	contains = list(/obj/item/weapon/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "wizard costume crate"
	group = supply_misc

/datum/supply_packs/randomised
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
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	name = "Collectable hat crate!"
	cost = 200
	containertype = /obj/structure/closet/crate
	containername = "Collectable hats crate! Brought to you by Bass.inc!"
	group = supply_misc

/datum/supply_packs/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()


/datum/supply_packs/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/weapon/contraband/poster,
					/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
					/obj/item/weapon/lipstick/random)
	name = "Contraband crate"
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "crate"	//let's keep it subtle, eh?
	contraband = 1
	group = supply_misc
