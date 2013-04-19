//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

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

/datum/supply_packs/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = new path()
		manifest += "<li>[AM.name]</li>"
		AM.loc = null	//just to make sure they're deleted by the garbage collector
	manifest += "</ul>"

/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/office/pen/paralysis,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	hidden = 1

/datum/supply_packs/food
	name = "Food crate"
	contains = list(/obj/item/chem/food/drinks/flour,
					/obj/item/chem/food/drinks/milk,
					/obj/item/chem/food/drinks/milk,
					/obj/item/storage/fancy/egg_box,
					/obj/item/chem/food/condiment/enzyme,
					/obj/item/chem/food/snacks/grown/banana,
					/obj/item/chem/food/snacks/grown/banana,
					/obj/item/chem/food/snacks/grown/banana)
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "food crate"

/datum/supply_packs/paper
	name = "Bureaucracy crate"
	contains = list(/obj/structure/filingcabinet/chestdrawer/wheeled,
					/obj/item/part/refill/camera_film,
					/obj/item/office/labeler,
					/obj/item/part/refill/labeler,
					/obj/item/part/refill/labeler,
					/obj/item/office/bin,
					/obj/item/office/pen,
					/obj/item/office/pen/blue,
					/obj/item/office/pen/red,
					/obj/item/office/folder/blue,
					/obj/item/office/folder/red,
					/obj/item/office/folder/yellow,
					/obj/item/office/clipboard,
					/obj/item/office/clipboard)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Bureaucracy crate"

/datum/supply_packs/monkey
	name = "Monkey crate"
	contains = list (/obj/item/storage/box/monkeycubes)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "monkey crate"

/datum/supply_packs/toner
	name = "Toner Cartridges"
	contains = list(/obj/item/part/refill/toner,
					/obj/item/part/refill/toner,
					/obj/item/part/refill/toner,
					/obj/item/part/refill/toner,
					/obj/item/part/refill/toner,
					/obj/item/part/refill/toner)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "toner cartridges"

/datum/supply_packs/party
	name = "Party equipment"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/chem/food/drinks/shaker,
					/obj/item/chem/food/drinks/bottle/patron,
					/obj/item/chem/food/drinks/bottle/goldschlager,
					/obj/item/chem/food/drinks/ale,
					/obj/item/chem/food/drinks/ale,
					/obj/item/chem/food/drinks/beer,
					/obj/item/chem/food/drinks/beer,
					/obj/item/chem/food/drinks/beer,
					/obj/item/chem/food/drinks/beer)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "party equipment"

/datum/supply_packs/internals
	name = "Internals crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/tank/air,
					/obj/item/clothing/tank/air,
					/obj/item/clothing/tank/air)
	cost = 10
	containertype = /obj/structure/closet/crate/internals
	containername = "internals crate"

/datum/supply_packs/evacuation
	name = "Emergency equipment"
	contains = list(/obj/machinery/bot/floorbot,
					/obj/machinery/bot/floorbot,
					/obj/machinery/bot/medbot,
					/obj/machinery/bot/medbot,
					/obj/item/clothing/tank/air,
					/obj/item/clothing/tank/air,
					/obj/item/clothing/tank/air,
					/obj/item/clothing/tank/air,
					/obj/item/clothing/tank/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas)
	cost = 35
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"

/datum/supply_packs/janitor
	name = "Janitorial supplies"
	contains = list(/obj/item/chem/glass/bucket,
					/obj/item/chem/glass/bucket,
					/obj/item/chem/glass/bucket,
					/obj/item/service/mop,
					/obj/item/service/caution,
					/obj/item/service/caution,
					/obj/item/service/caution,
					/obj/item/storage/bag/trash,
					/obj/item/chem/spray/cleaner,
					/obj/item/chem/glass/rag,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "janitorial supplies"

/datum/supply_packs/lightbulbs
	name = "Replacement lights"
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "replacement lights"

/datum/supply_packs/costume
	name = "Standard Costume crate"
	contains = list(/obj/item/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/toy/bikehorn,
					/obj/item/clothing/under/mime,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/gloves/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/chem/food/drinks/bottle/bottleofnothing)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "standard costumes"
	access = access_theatre

/datum/supply_packs/wizard
	name = "Wizard costume"
	contains = list(/obj/item/magic/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "wizard costume crate"

/datum/supply_packs/mule
	name = "MULEbot Crate"
	contains = list(/obj/machinery/bot/mulebot)
	cost = 20
	containertype = /obj/structure/largecrate/mule
	containername = "\improper MULEbot Crate"

/datum/supply_packs/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/chem/spray/plantbgone,
					/obj/item/chem/spray/plantbgone,
					/obj/item/chem/glass/bottle/ammonia,
					/obj/item/chem/glass/bottle/ammonia,
					/obj/item/botany/hatchet,
					/obj/item/botany/minihoe,
					/obj/item/device/scanner/plant,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with new things
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics crate"
	access = access_hydroponics

//farm animals - useless and annoying, but potentially a good source of food
/datum/supply_packs/cow
	name = "Cow Crate"
	cost = 30
	containertype = /obj/structure/largecrate/cow
	containername = "cow crate"
	access = access_hydroponics

/datum/supply_packs/goat
	name = "Goat Crate"
	cost = 25
	containertype = /obj/structure/largecrate/goat
	containername = "goat crate"
	access = access_hydroponics

/datum/supply_packs/chicken
	name = "Chicken Crate"
	cost = 20
	containertype = /obj/structure/largecrate/chick
	containername = "chicken crate"
	access = access_hydroponics

/datum/supply_packs/lisa
	name = "Corgi Crate"
	contains = list()
	cost = 50
	containertype = /obj/structure/largecrate/lisa
	containername = "corgi crate"

/datum/supply_packs/seeds
	name = "Seeds Crate"
	contains = list(/obj/item/botany/seeds/chiliseed,
					/obj/item/botany/seeds/berryseed,
					/obj/item/botany/seeds/cornseed,
					/obj/item/botany/seeds/eggplantseed,
					/obj/item/botany/seeds/tomatoseed,
					/obj/item/botany/seeds/soyaseed,
					/obj/item/botany/seeds/wheatseed,
					/obj/item/botany/seeds/carrotseed,
					/obj/item/botany/seeds/sunflowerseed,
					/obj/item/botany/seeds/chantermycelium,
					/obj/item/botany/seeds/potatoseed,
					/obj/item/botany/seeds/sugarcaneseed)
	cost = 10
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "seeds crate"
	access = access_hydroponics

/datum/supply_packs/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/botany/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = access_hydroponics

/datum/supply_packs/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list(/obj/item/botany/seeds/nettleseed,
					/obj/item/botany/seeds/replicapod,
					/obj/item/botany/seeds/replicapod,
					/obj/item/botany/seeds/replicapod,
					/obj/item/botany/seeds/plumpmycelium,
					/obj/item/botany/seeds/libertymycelium,
					/obj/item/botany/seeds/amanitamycelium,
					/obj/item/botany/seeds/reishimycelium,
					/obj/item/botany/seeds/bananaseed,
					/obj/item/botany/seeds/eggyseed)
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "exotic seeds crate"
	access = access_hydroponics

/datum/supply_packs/medical
	name = "Medical crate"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/o2,
					/obj/item/chem/glass/bottle/antitoxin,
					/obj/item/chem/glass/bottle/inaprovaline,
					/obj/item/chem/glass/bottle/stoxin,
					/obj/item/storage/box/syringes)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"


/datum/supply_packs/virus
	name = "Virus crate"
	contains = list(/obj/item/chem/glass/bottle/flu_virion,
					/obj/item/chem/glass/bottle/cold,
					/obj/item/chem/glass/bottle/epiglottis_virion,
					/obj/item/chem/glass/bottle/liver_enhance_virion,
					/obj/item/chem/glass/bottle/fake_gbs,
					/obj/item/chem/glass/bottle/magnitis,
					/obj/item/chem/glass/bottle/pierrot_throat,
					/obj/item/chem/glass/bottle/brainrot,
					/obj/item/chem/glass/bottle/hullucigen_virion,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/beakers,
					/obj/item/chem/glass/bottle/mutagen)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "virus crate"
	access = access_cmo

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	contains = list(/obj/item/part/stack/sheet/metal)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "metal sheets crate"

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	contains = list(/obj/item/part/stack/sheet/glass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "glass sheets crate"

/datum/supply_packs/electrical
	name = "Electrical maintenance crate"
	contains = list(/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/part/cell,
					/obj/item/part/cell,
					/obj/item/part/cell/high,
					/obj/item/part/cell/high)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "electrical maintenance crate"

/datum/supply_packs/mechanical
	name = "Mechanical maintenance crate"
	contains = list(/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "mechanical maintenance crate"

/datum/supply_packs/watertank
	name = "Water tank crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "water tank crate"

/datum/supply_packs/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"

/datum/supply_packs/solar
	name = "Solar Pack crate"
	contains  = list(/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar,
					/obj/item/part/frame/solar, // 21 Solar Assemblies. 1 Extra for the controller
					/obj/item/part/circuitboard/solar_control,
					/obj/item/part/board/solar_tracker,
					/obj/item/office/paper/solar)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "solar pack crate"

/datum/supply_packs/engine
	name = "Emitter crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "emitter crate"
	access = access_ce

/datum/supply_packs/engine/field_gen
	name = "Field Generator crate"
	contains = list(/obj/machinery/field_generator,
					/obj/machinery/field_generator)
	containertype = /obj/structure/closet/crate/secure
	containername = "field generator crate"
	access = access_ce

/datum/supply_packs/engine/sing_gen
	name = "Singularity Generator crate"
	contains = list(/obj/machinery/the_singularitygen)
	containertype = /obj/structure/closet/crate/secure
	containername = "singularity generator crate"
	access = access_ce

/datum/supply_packs/engine/collector
	name = "Collector crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	containername = "collector crate"

/datum/supply_packs/engine/PA
	name = "Particle Accelerator crate"
	cost = 40
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

/datum/supply_packs/mecha_ripley
	name = "Circuit Crate (\"Ripley\" APLU)"
	contains = list(/obj/item/office/book/manual/ripley_build_and_repair,
					/obj/item/part/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer
					/obj/item/part/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 30
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper APLU \"Ripley\" circuit crate"
	access = access_robotics

/datum/supply_packs/mecha_odysseus
	name = "Circuit Crate (\"Odysseus\")"
	contains = list(/obj/item/part/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer
					/obj/item/part/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper \"Odysseus\" circuit crate"
	access = access_robotics


/datum/supply_packs/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/part/assembly/prox_sensor,
					/obj/item/part/assembly/prox_sensor,
					/obj/item/part/assembly/prox_sensor,
					/obj/item/storage/toolbox/electrical,
					/obj/item/security/flash,
					/obj/item/security/flash,
					/obj/item/security/flash,
					/obj/item/security/flash,
					/obj/item/part/cell/high,
					/obj/item/part/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "robotics assembly crate"
	access = access_robotics

/datum/supply_packs/plasma
	name = "Plasma assembly crate"
	contains = list(/obj/item/clothing/tank/plasma,
					/obj/item/clothing/tank/plasma,
					/obj/item/clothing/tank/plasma,
					/obj/item/part/assembly/igniter,
					/obj/item/part/assembly/igniter,
					/obj/item/part/assembly/igniter,
					/obj/item/part/assembly/prox_sensor,
					/obj/item/part/assembly/prox_sensor,
					/obj/item/part/assembly/prox_sensor,
					/obj/item/part/assembly/timer,
					/obj/item/part/assembly/timer,
					/obj/item/part/assembly/timer)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasma assembly crate"
	access = access_tox_storage

/datum/supply_packs/weapons
	name = "Weapons crate"
	contains = list(/obj/item/weapon/melee/baton,
					/obj/item/weapon/melee/baton,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "weapons crate"
	access = access_security

/datum/supply_packs/eweapons
	name = "Incendiary weapons crate"
	contains = list(/obj/item/weapon/flamethrower/full,
					/obj/item/clothing/tank/plasma,
					/obj/item/clothing/tank/plasma,
					/obj/item/clothing/tank/plasma,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "incendiary weapons crate"
	access = access_heads

/datum/supply_packs/armor
	name = "Armor crate"
	contains = list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "armor crate"
	access = access_security

/datum/supply_packs/riot
	name = "Riot gear crate"
	contains = list(/obj/item/weapon/melee/baton,
					/obj/item/weapon/melee/baton,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/handcuffs,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/suit/armor/riot,)
	cost = 45
	containertype = /obj/structure/closet/crate/secure
	containername = "riot gear crate"
	access = access_armory

/datum/supply_packs/loyalty
	name = "Loyalty implant crate"
	contains = list (/obj/item/storage/lockbox/loyalty)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "loyalty implant crate"
	access = access_armory

/datum/supply_packs/ballistic
	name = "Ballistic gear crate"
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/weapon/gun/projectile/shotgun/pump/combat,
					/obj/item/weapon/gun/projectile/shotgun/pump/combat)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "ballistic gear crate"
	access = access_armory

/datum/supply_packs/expenergy
	name = "Experimental energy gear crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "experimental energy gear crate"
	access = access_armory

/datum/supply_packs/exparmor
	name = "Experimental armor crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 35
	containertype = /obj/structure/closet/crate/secure
	containername = "experimental armor crate"
	access = access_armory

/datum/supply_packs/securitybarriers
	name = "Security Barriers"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "security barriers crate"

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

/datum/supply_packs/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()


/datum/supply_packs/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/office/contraband/poster,
					/obj/item/storage/fancy/cigarettes/dromedaryco,
					/obj/item/service/lipstick/random)
	name = "Contraband crate"
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "crate"	//let's keep it subtle, eh?
	contraband = 1
