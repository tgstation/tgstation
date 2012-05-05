//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list("/obj/item/weapon/storage/emp_kit",
					"/obj/item/weapon/smokebomb",
					"/obj/item/weapon/smokebomb",
					"/obj/item/weapon/smokebomb",
					"/obj/item/weapon/pen/paralysis",
					"/obj/item/weapon/chem_grenade/incendiary")
	cost = 20
	containertype = "/obj/structure/closet/crate"
	containername = "Special Ops crate"
	hidden = 1

/datum/supply_packs/boxes
	name = "Empty Box supplies"
	contains = list("/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",
	"/obj/item/weapon/storage/box",)
	cost = 5
	containertype = "/obj/structure/closet/crate"
	containername = "Empty Box crate"

/datum/supply_packs/pcm
	name = "Power Control Module supplies"
	contains = list("/obj/item/weapon/storage/PCMBox",
	"/obj/item/weapon/storage/PCMBox")
	cost = 25
	containertype = "/obj/structure/closet/crate"
	containername = "Power Control Module crate"

/datum/supply_packs/body_bags
	name = "Body Bag supplies"
	contains = list(
	"/obj/item/weapon/bodybag",
	"/obj/item/weapon/bodybag",
	"/obj/item/weapon/bodybag",
	"/obj/item/weapon/bodybag",
	)
	cost = 10
	containertype = "/obj/structure/closet/crate"
	containername = "Body Bag crate"

/datum/supply_packs/stationary
	name = "Stationary supplies"
	contains = list("/obj/item/device/taperecorder",
	"/obj/item/weapon/packageWrap",
	"/obj/item/weapon/clipboard",
	"/obj/item/weapon/clipboard",
	"/obj/item/weapon/hand_labeler",
	"/obj/item/weapon/paper_bin",
	"/obj/item/weapon/pen",
	"/obj/item/weapon/pen",
	"/obj/item/weapon/pen",
	"/obj/item/weapon/stamp",
	"/obj/item/weapon/stamp/denied",
	"/obj/item/weapon/storage/diskbox",
	"/obj/item/weapon/storage/recordsbox",
	)
	cost = 5
	containertype = "/obj/structure/closet/crate"
	containername = "Stationary crate"

/datum/supply_packs/artscrafts
	name = "Arts and Crafts supplies"
	contains = list("/obj/item/toy/crayonbox",
	"/obj/item/weapon/camera_test",
	"/obj/item/weapon/storage/photo_album",
	"/obj/item/weapon/packageWrap",
	"/obj/item/weapon/reagent_containers/glass/paint/red",
	"/obj/item/weapon/reagent_containers/glass/paint/green",
	"/obj/item/weapon/reagent_containers/glass/paint/blue",
	"/obj/item/weapon/reagent_containers/glass/paint/yellow",
	"/obj/item/weapon/reagent_containers/glass/paint/violet",
	"/obj/item/weapon/reagent_containers/glass/paint/black",
	"/obj/item/weapon/reagent_containers/glass/paint/white",
	"/obj/item/weapon/reagent_containers/glass/paint/remover",
	"/obj/item/weapon/wrapping_paper",
	"/obj/item/weapon/wrapping_paper",
	"/obj/item/weapon/wrapping_paper")
	cost = 5
	containertype = "/obj/structure/closet/crate"
	containername = "Arts and Crafts crate"

/datum/supply_packs/empty
	name = "Empty crate"
	contains = list()
	cost = 5
	containertype = "/obj/structure/closet/crate"
	containername = "crate"

/datum/supply_packs/charge
	cost = 10
	containertype = "/obj/structure/closet/crate"
	group = "Charges"

/datum/supply_packs/charge/medical
	name = "Medical Charge"
	contains = list("/obj/item/weapon/vending_charge/medical")
	containername = "Medical charge crate"

/datum/supply_packs/charge/chemistry
	name = "Chemistry Charge"
	contains = list("/obj/item/weapon/vending_charge/chemistry")
	containername = "Chemistry charge crate"

/datum/supply_packs/charge/toxins
	name = "Toxins Research Charge"
	contains = list("/obj/item/weapon/vending_charge/toxins")
	containername = "Toxins Reasearch charge crate"

/* removed these for now, as to not confuse people (the machines are in the tg map)
/datum/supply_packs/charge/genetics
	name = "Genetics Research Charge"
	contains = list("/obj/item/weapon/vending_charge/genetics")
	containername = "Genetics charge crate"

/datum/supply_packs/charge/robotics
	name = "Robotics Charge"
	contains = list("/obj/item/weapon/vending_charge/robotics")
	containername = "Robotics charge crate"
*/

/datum/supply_packs/charge/bar
	name = "Bar Charge"
	contains = list("/obj/item/weapon/vending_charge/bar")
	containername = "Bar charge crate"

/datum/supply_packs/charge/kitchen
	name = "Kitchen Charge"
	contains = list("/obj/item/weapon/vending_charge/kitchen")
	containername = "Kitchen charge crate"

/datum/supply_packs/charge/engineering
	name = "Engineering Charge"
	contains = list("/obj/item/weapon/vending_charge/engineering")
	containername = "Engineering charge crate"

/datum/supply_packs/charge/security
	name = "Security Charge"
	contains = list("/obj/item/weapon/vending_charge/security")
	containername = "Security charge crate"

/datum/supply_packs/charge/coffee
	name = "Coffee Charge"
	contains = list("/obj/item/weapon/vending_charge/coffee")
	containername = "Coffee charge crate"

/datum/supply_packs/charge/snack
	name = "Snack Charge"
	contains = list("/obj/item/weapon/vending_charge/snack")
	containername = "Snack charge crate"

/*
/datum/supply_packs/charge/cart
	name = "PDA Cart Charge"
	contains = list("/obj/item/weapon/vending_charge/cart")
	containername = "PDA Cart charge crate"
*/

/datum/supply_packs/charge/cigarette
	name = "Cigarette Charge"
	contains = list("/obj/item/weapon/vending_charge/cigarette")
	containername = "Cigarette charge crate"

/datum/supply_packs/charge/soda
	name = "Soda Charge"
	contains = list("/obj/item/weapon/vending_charge/soda")
	containername = "Soda machine charge crate"

/datum/supply_packs/charge/hydroponics
	name = "Hydroponics Charge"
	contains = list("/obj/item/weapon/vending_charge/hydroponics")
	containername = "Hydroponics charge crate"

/* Wrong toxins charge!
/datum/supply_packs/charge/tl
	name = "Toxins Lab Charge"
	contains = list("/obj/item/weapon/vending_charge/toxinslab")
	containername = "Toxins Lab charge crate"
*/

/datum/supply_packs/food
	name = "Food crate"
	contains = list("/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/drinks/milk",
					"/obj/item/weapon/reagent_containers/food/drinks/milk",
					"/obj/item/kitchen/egg_box",
					"/obj/item/weapon/reagent_containers/food/condiment/enzyme",
					"/obj/item/weapon/reagent_containers/food/snacks/grown/banana",
					"/obj/item/weapon/reagent_containers/food/snacks/grown/banana",
					"/obj/item/weapon/reagent_containers/food/snacks/grown/banana")
	cost = 5
	containertype = "/obj/structure/closet/crate/freezer"
	containername = "Food crate"
	group = "Kitchen / Bar"

/datum/supply_packs/monkey
	name = "Monkey crate"
	contains = list ("/obj/item/weapon/monkeycube_box")
	cost = 20
	containertype = "/obj/structure/closet/crate/freezer"
	containername = "Monkey crate"
	group = "Medical / Science"

/*
/datum/supply_packs/shotgun
	name = "Shotgun crate"
	contains = list("/obj/item/weapon/gun/projectile/shotgun",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag")
	cost = 25
	containertype = "/obj/structure/closet/crate"
	containername = "Shotgun crate"
//APPARENTLY OP?
*/

/datum/supply_packs/beanbagammo
	name = "Beanbag shells"
	contains = list("/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag",
					"/obj/item/ammo_casing/shotgun/beanbag")
	cost = 10
	containertype = "/obj/structure/closet/crate"
	containername = "Beanbag shells"
	group = "Security"

/datum/supply_packs/party
	name = "Party equipment"
	contains = list("/obj/item/weapon/storage/drinkingglasses",
					"/obj/item/weapon/reagent_containers/food/drinks/shaker",
					"/obj/item/weapon/reagent_containers/food/drinks/bottle/patron",
					"/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager",
					"/obj/item/weapon/reagent_containers/food/drinks/ale",
					"/obj/item/weapon/reagent_containers/food/drinks/ale",
					"/obj/item/weapon/reagent_containers/food/drinks/beer",
					"/obj/item/weapon/reagent_containers/food/drinks/beer",
					"/obj/item/weapon/reagent_containers/food/drinks/beer",
					"/obj/item/weapon/reagent_containers/food/drinks/beer")
	cost = 20
	containertype = "/obj/structure/closet/crate"
	containername = "Party equipment"
	group = "Kitchen / Bar"

/datum/supply_packs/internals
	name = "Internals crate"
	contains = list("/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air")
	cost = 10
	containertype = "/obj/structure/closet/crate/internals"
	containername = "Internals crate"

/datum/supply_packs/evacuation
	name = "Emergency equipment"
	contains = list("/obj/machinery/bot/floorbot",
					"/obj/machinery/bot/floorbot",
					"/obj/machinery/bot/medbot",
					"/obj/machinery/bot/medbot",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air",
					"/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas")
	cost = 35
	containertype = "/obj/structure/closet/crate/internals"
	containername = "Emergency Crate"

/datum/supply_packs/janitor
	name = "Janitorial supplies"
	contains = list("/obj/item/weapon/reagent_containers/glass/bucket",
					"/obj/item/weapon/reagent_containers/glass/bucket",
					"/obj/item/weapon/reagent_containers/glass/bucket",
					"/obj/item/weapon/mop",
					"/obj/item/weapon/caution",
					"/obj/item/weapon/caution",
					"/obj/item/weapon/caution",
					"/obj/item/weapon/cleaner",
					"/obj/item/weapon/chem_grenade/cleaner",
					"/obj/item/weapon/chem_grenade/cleaner",
					"/obj/item/weapon/chem_grenade/cleaner",
					"/obj/structure/mopbucket")
	cost = 10
	containertype = "/obj/structure/closet/crate"
	containername = "Janitorial supplies"

/datum/supply_packs/lightbulbs
	name = "Replacement lights"
	contains = list("/obj/item/weapon/storage/lightbox/mixed",
					"/obj/item/weapon/storage/lightbox/mixed",
					"/obj/item/weapon/storage/lightbox/mixed")
	cost = 5
	containertype = "/obj/structure/closet/crate"
	containername = "Replacement lights"

/datum/supply_packs/costume
	name = "Standard Costume crate"
	contains = list("/obj/item/weapon/storage/backpack/clown",
					"/obj/item/clothing/shoes/clown_shoes",
					"/obj/item/clothing/mask/gas/clown_hat",
					"/obj/item/clothing/under/rank/clown",
					"/obj/item/weapon/bikehorn",
					"/obj/item/clothing/under/mime",
					"/obj/item/clothing/shoes/black",
					"/obj/item/clothing/gloves/white",
					"/obj/item/clothing/mask/gas/mime",
					"/obj/item/clothing/head/beret",
					"/obj/item/clothing/suit/suspenders",
					"/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing")
	cost = 10
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Standard Costumes"
	access = access_theatre
	group = "Clothing"

/datum/supply_packs/wizard
	name = "Wizard costume"
	contains = list("/obj/item/weapon/staff",
					"/obj/item/clothing/suit/wizrobe/fake",
					"/obj/item/clothing/shoes/sandal",
					"/obj/item/clothing/head/wizard/fake")
	cost = 20
	containertype = "/obj/structure/closet/crate"
	containername = "Wizard costume crate"
	group = "Clothing"

/datum/supply_packs/mule
	name = "MULEbot Crate"
	contains = list("/obj/machinery/bot/mulebot")
	cost = 20
	containertype = "/obj/structure/closet/crate"
	containername = "MULEbot Crate"

/datum/supply_packs/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list("/obj/item/weapon/plantbgone",
					"/obj/item/weapon/plantbgone",
					"/obj/item/weapon/plantbgone",
					"/obj/item/weapon/plantbgone",
					"/obj/item/weapon/hatchet",
					"/obj/item/weapon/minihoe",
					"/obj/item/device/analyzer/plant_analyzer",
					"/obj/item/clothing/gloves/botanic_leather",
					"/obj/item/clothing/suit/storage/apron") // Updated with new things
	cost = 10
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "Hydroponics crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/seeds
	name = "Seeds Crate"
	contains = list("/obj/item/seeds/chiliseed",
					"/obj/item/seeds/berryseed",
					"/obj/item/seeds/cornseed",
					"/obj/item/seeds/eggplantseed",
					"/obj/item/seeds/tomatoseed",
					"/obj/item/seeds/soyaseed",
					"/obj/item/seeds/wheatseed",
					"/obj/item/seeds/carrotseed",
					"/obj/item/seeds/sunflowerseed",
					"/obj/item/seeds/chantermycelium",
					"/obj/item/seeds/potatoseed")
	cost = 10
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "Seeds crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list("/obj/item/seeds/nettleseed",
					"/obj/item/seeds/replicapod",
					"/obj/item/seeds/replicapod",
					"/obj/item/seeds/replicapod",
					"/obj/item/seeds/plumpmycelium",
					"/obj/item/seeds/libertymycelium",
					"/obj/item/seeds/amanitamycelium",
					"/obj/item/seeds/bananaseed",
					"/obj/item/seeds/eggyseed")
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "Exotic Seeds crate"
	access = access_hydroponics
	group = "Hydroponics"

/datum/supply_packs/medical
	name = "Medical crate"
	contains = list("/obj/item/weapon/storage/firstaid/regular",
					"/obj/item/weapon/storage/firstaid/fire",
					"/obj/item/weapon/storage/firstaid/toxin",
					"/obj/item/weapon/storage/firstaid/o2",
					"/obj/item/weapon/reagent_containers/glass/bottle/antitoxin",
					"/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline",
					"/obj/item/weapon/reagent_containers/glass/bottle/stoxin",
					"/obj/item/weapon/storage/syringes",
					"/obj/item/weapon/reagent_containers/glass/large")
	cost = 10
	containertype = "/obj/structure/closet/crate/medical"
	containername = "Medical crate"
	group = "Medical / Science"

/*	yay for new virus system
/datum/supply_packs/virus
	name = "Virus crate"
	contains = list("/obj/item/weapon/reagent_containers/glass/bottle/flu_virion",
					"/obj/item/weapon/reagent_containers/glass/bottle/cold",
					"/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs",
					"/obj/item/weapon/reagent_containers/glass/bottle/magnitis",
//					"/obj/item/weapon/reagent_containers/glass/bottle/wizarditis", worse than GBS if anything
//					"/obj/item/weapon/reagent_containers/glass/bottle/gbs", No. Just no.
					"/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat",
					"/obj/item/weapon/reagent_containers/glass/bottle/brainrot",
					"/obj/item/weapon/storage/syringes",
					"/obj/item/weapon/storage/beakerbox")
	cost = 20
	containertype = "/obj/structure/closet/crate/secure/weapon"
	containername = "Virus crate"
	access = access_cmo
	group = "Medical / Science"
*/

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	contains = list("/obj/item/stack/sheet/metal")
	amount = 50
	cost = 10
	containertype = "/obj/structure/closet/crate"
	containername = "Metal sheets crate"
	group = "Engineering"

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	contains = list("/obj/item/stack/sheet/glass")
	amount = 50
	cost = 10
	containertype = "/obj/structure/closet/crate"
	containername = "Glass sheets crate"
	group = "Engineering"

/datum/supply_packs/electrical
	name = "Electrical maintenance crate"
	contains = list("/obj/item/weapon/storage/toolbox/electrical",
					"/obj/item/weapon/storage/toolbox/electrical",
					"/obj/item/clothing/gloves/yellow",
					"/obj/item/clothing/gloves/yellow",
					"/obj/item/weapon/cell",
					"/obj/item/weapon/cell",
					"/obj/item/weapon/cell/high",
					"/obj/item/weapon/cell/high")
	cost = 15
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Electrical maintenance crate"
	access = access_engine
	group = "Engineering"

/datum/supply_packs/mechanical
	name = "Mechanical maintenance crate"
	contains = list("/obj/item/weapon/storage/belt/utility/full",
					"/obj/item/weapon/storage/belt/utility/full",
					"/obj/item/weapon/storage/belt/utility/full",
					"/obj/item/clothing/suit/hazardvest",
					"/obj/item/clothing/suit/hazardvest",
					"/obj/item/clothing/suit/hazardvest",
					"/obj/item/clothing/head/helmet/welding",
					"/obj/item/clothing/head/helmet/welding",
					"/obj/item/clothing/head/helmet/hardhat")
	cost = 10
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Mechanical maintenance crate"
	access = access_engine
	group = "Engineering"

/datum/supply_packs/waterfueltank
	name = "Water/Fuel tank crate"
	contains = list("/obj/structure/reagent_dispensers/watertank",
					"/obj/structure/reagent_dispensers/fueltank")
	cost = 15
	containertype = "/obj/structure/closet/crate"
	containername = "Water/Fuel tank crate"

/datum/supply_packs/engine
	name = "Emitter crate"
	contains = list("/obj/machinery/emitter",
					"/obj/machinery/emitter",)
	cost = 10
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Emitter crate"
	access = access_heads
	group = "Engineering"

/datum/supply_packs/engine/field_gen
	name = "Field Generator crate"
	contains = list("/obj/machinery/field_generator",
					"/obj/machinery/field_generator",)
	containername = "Field Generator crate"
	group = "Engineering"

/datum/supply_packs/engine/sing_gen
	name = "Singularity Generator crate"
	contains = list("/obj/machinery/the_singularitygen")
	containername = "Singularity Generator crate"
	group = "Engineering"

/datum/supply_packs/engine/collector
	name = "Collector crate"
	contains = list("/obj/machinery/power/rad_collector",
					"/obj/machinery/power/rad_collector",
					"/obj/machinery/power/rad_collector")
	containername = "Collector crate"
	group = "Engineering"

/datum/supply_packs/engine/PA
	name = "Particle Accelerator crate"
	cost = 40
	contains = list("/obj/structure/particle_accelerator/fuel_chamber",
					"/obj/machinery/particle_accelerator/control_box",
					"/obj/structure/particle_accelerator/particle_emitter/center",
					"/obj/structure/particle_accelerator/particle_emitter/left",
					"/obj/structure/particle_accelerator/particle_emitter/right",
					"/obj/structure/particle_accelerator/power_box",
					"/obj/structure/particle_accelerator/end_cap")
	containername = "Particle Accelerator crate"
	group = "Engineering"

/datum/supply_packs/mecha_ripley
	name = "Circuit Crate (\"Ripley\" APLU)"
	contains = list("/obj/item/weapon/book/manual/ripley_build_and_repair",
					"/obj/item/weapon/circuitboard/mecha/ripley/main", //TEMPORARY due to lack of circuitboard printer
					"/obj/item/weapon/circuitboard/mecha/ripley/peripherals") //TEMPORARY due to lack of circuitboard printer
	cost = 30
	containertype = "/obj/structure/closet/crate/secure"
	containername = "APLU \"Ripley\" Circuit Crate"
	access = access_robotics
	group = "Robotics"

/datum/supply_packs/surgery
	name = "Surgery crate"
	contains = list("/obj/item/weapon/cautery",
					"/obj/item/weapon/surgicaldrill",
					"/obj/item/weapon/hemostat",
					"/obj/item/weapon/scalpel",
					"/obj/item/weapon/surgical_tool/bonegel",
					"/obj/item/weapon/retractor",
					"/obj/item/weapon/surgical_tool/bonesetter",
					"/obj/item/weapon/circular_saw")
	cost = 20
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Surgery crate"
	access = access_medical
	group = "Medical / Science"

/datum/supply_packs/mecha_odysseus
	name = "Circuit Crate (\"Odysseus\")"
	contains = list(
						"/obj/item/weapon/circuitboard/mecha/odysseus/peripherals", //TEMPORARY due to lack of circuitboard printer
						"/obj/item/weapon/circuitboard/mecha/odysseus/main" //TEMPORARY due to lack of circuitboard printer
						)
	cost = 25
	containertype = "/obj/structure/closet/crate/secure"
	containername = "\"Odysseus\" Circuit Crate"
	access = access_robotics
	group = "Robotics"

/datum/supply_packs/robotics
	name = "Robotics Assembly Crate"
	contains = list("/obj/item/device/assembly/prox_sensor",
					"/obj/item/device/assembly/prox_sensor",
					"/obj/item/device/assembly/prox_sensor",
					"/obj/item/weapon/storage/toolbox/electrical",
					"/obj/item/device/flash",
					"/obj/item/device/flash",
					"/obj/item/device/flash",
					"/obj/item/device/flash",
					"/obj/item/weapon/cell/high",
					"/obj/item/weapon/cell/high")
	cost = 10
	containertype = "/obj/structure/closet/crate/secure/gear"
	containername = "Robotics Assembly"
	access = access_robotics
	group = "Robotics"

/datum/supply_packs/plasma
	name = "Plasma assembly crate"
	contains = list("/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/device/assembly/igniter",
					"/obj/item/device/assembly/igniter",
					"/obj/item/device/assembly/igniter",
					"/obj/item/device/assembly/prox_sensor",
					"/obj/item/device/assembly/prox_sensor",
					"/obj/item/device/assembly/prox_sensor",
					"/obj/item/device/assembly/timer",
					"/obj/item/device/assembly/timer",
					"/obj/item/device/assembly/timer")
	cost = 10
	containertype = "/obj/structure/closet/crate/secure/plasma"
	containername = "Plasma assembly crate"
	access = access_tox
	group = "Medical / Science"

/datum/supply_packs/weapons
	name = "Weapons crate"
	contains = list("/obj/item/weapon/melee/baton",
					"/obj/item/weapon/melee/baton",
					"/obj/item/weapon/gun/energy/laser",
					"/obj/item/weapon/gun/energy/laser",
					"/obj/item/weapon/gun/energy/taser",
					"/obj/item/weapon/gun/energy/taser",
					"/obj/item/weapon/storage/flashbang_kit",
					"/obj/item/weapon/storage/flashbang_kit")
	cost = 30
	containertype = "/obj/structure/closet/crate/secure/weapon"
	containername = "Weapons crate"
	access = access_security
	group = "Security"

/datum/supply_packs/eweapons
	name = "Experimental weapons crate"
	contains = list("/obj/item/weapon/flamethrower/full",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/chem_grenade/incendiary",
					"/obj/item/weapon/chem_grenade/incendiary",
					"/obj/item/weapon/chem_grenade/incendiary")
	cost = 25
	containertype = "/obj/structure/closet/crate/secure/weapon"
	containername = "Experimental weapons crate"
	access = access_heads
	group = "Security"

/datum/supply_packs/armor
	name = "Armor crate"
	contains = list("/obj/item/clothing/head/helmet",
					"/obj/item/clothing/head/helmet",
					"/obj/item/clothing/suit/armor/vest",
					"/obj/item/clothing/suit/armor/vest")
	cost = 15
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Armor crate"
	access = access_security
	group = "Security"

/datum/supply_packs/riot
	name = "Riot gear crate"
	contains = list("/obj/item/weapon/melee/baton",
					"/obj/item/weapon/melee/baton",
					"/obj/item/weapon/melee/baton",
					"/obj/item/weapon/shield/riot",
					"/obj/item/weapon/shield/riot",
					"/obj/item/weapon/shield/riot",
					"/obj/item/weapon/storage/flashbang_kit",
					"/obj/item/weapon/storage/flashbang_kit",
					"/obj/item/weapon/storage/flashbang_kit",
					"/obj/item/weapon/handcuffs",
					"/obj/item/weapon/handcuffs",
					"/obj/item/weapon/handcuffs",
					"/obj/item/clothing/head/helmet/riot",
					"/obj/item/clothing/suit/armor/riot",
					"/obj/item/clothing/head/helmet/riot",
					"/obj/item/clothing/suit/armor/riot",
					"/obj/item/clothing/head/helmet/riot",
					"/obj/item/clothing/suit/armor/riot")
	cost = 60
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Riot gear crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/loyalty
	name = "Loyalty implant crate"
	contains = list ("/obj/item/weapon/storage/lockbox/loyalty")
	cost = 60
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Loyalty implant crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/ballistic
	name = "Ballistic gear crate"
	contains = list("/obj/item/clothing/suit/armor/bulletproof",
					"/obj/item/clothing/suit/armor/bulletproof",
					"/obj/item/weapon/gun/projectile/shotgun/combat2",
					"/obj/item/weapon/gun/projectile/shotgun/combat2")
	cost = 50
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Ballistic gear crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/expenergy
	name = "Experimental energy gear crate"
	contains = list("/obj/item/clothing/suit/armor/laserproof",
					"/obj/item/clothing/suit/armor/laserproof",
					"/obj/item/weapon/gun/energy/gun",
					"/obj/item/weapon/gun/energy/gun")
	cost = 50
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Experimental energy gear crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/exparmor
	name = "Experimental armor crate"
	contains = list("/obj/item/clothing/suit/armor/laserproof",
					"/obj/item/clothing/suit/armor/bulletproof",
					"/obj/item/clothing/head/helmet/riot",
					"/obj/item/clothing/suit/armor/riot")
	cost = 35
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Experimental armor crate"
	access = access_armory
	group = "Security"

/datum/supply_packs/securitybarriers
	name = "Security Barriers"
	contains = list("/obj/machinery/deployable/barrier",
					"/obj/machinery/deployable/barrier",
					"/obj/machinery/deployable/barrier",
					"/obj/machinery/deployable/barrier")
	cost = 20
	containertype = "/obj/structure/closet/crate/secure/gear"
	containername = "Secruity Barriers crate"
	group = "Security"

/datum/supply_packs/hats/
	contains = list("/obj/item/clothing/head/collectable/chef",
					"/obj/item/clothing/head/collectable/paper",
					"/obj/item/clothing/head/collectable/tophat",
					"/obj/item/clothing/head/collectable/captain",
					"/obj/item/clothing/head/collectable/beret",
					"/obj/item/clothing/head/collectable/welding",
					"/obj/item/clothing/head/collectable/flatcap",
					"/obj/item/clothing/head/collectable/pirate",
					"/obj/item/clothing/head/collectable/kitty",
					"/obj/item/clothing/head/collectable/rabbitears",
					"/obj/item/clothing/head/collectable/wizard",
					"/obj/item/clothing/head/collectable/hardhat",
					"/obj/item/clothing/head/collectable/HoS",
					"/obj/item/clothing/head/collectable/thunderdome",
					"/obj/item/clothing/head/collectable/swat",
					"/obj/item/clothing/head/collectable/metroid",
					"/obj/item/clothing/head/collectable/metroid",
					"/obj/item/clothing/head/collectable/police",
					"/obj/item/clothing/head/collectable/police",
					"/obj/item/clothing/head/collectable/slime",
					"/obj/item/clothing/head/collectable/slime",
					"/obj/item/clothing/head/collectable/xenom",
					"/obj/item/clothing/head/collectable/xenom",
					"/obj/item/clothing/head/collectable/petehat")
	name = "Collectable Hat Crate!"
	cost = 200
	containertype = "/obj/structure/closet/crate/hat"
	containername = "Collectable Hats Crate! Brought to you by Bass.inc!"
	group = "Clothing"

/datum/supply_packs/hats/New()
	var/list/tempContains = list()
	for(var/i = 0,i<min(3,contains.len),i++)
		tempContains += pick(contains)
	contains = tempContains
	..()


/datum/supply_packs/contraband
	contains = list("/obj/item/weapon/contraband/poster",) //We randomly pick 5 items from this list through the constructor, look below
	name = "Contraband Crate"
	cost = 30
	containertype = "/obj/structure/closet/crate/contraband"
	containername = "Contraband crate"
	group = "ERROR"
	contraband = 1

/datum/supply_packs/contraband/New()
	var/list/tempContains = list()
	for(var/i = 0,i<5,i++)
		tempContains += pick(contains)
	src.contains = tempContains
	..()

//SUPPLY PACKS