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

/*
	General
*/

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
					/obj/item/weapon/clipboard,
					/obj/item/device/toner/ink,
					/obj/item/device/toner/ink)
	cost = 5
	containertype = /obj/structure/closet/crate
	containername = "Bureaucracy crate"

/datum/supply_packs/disks
	name = "Computer Disks"
	contains = list(/obj/item/weapon/storage/box/disks,
					/obj/item/weapon/storage/box/disks,
					/obj/item/weapon/storage/box/disks,
					/obj/item/weapon/storage/box/network_disks
					)
	cost = 1
	containertype = /obj/structure/closet/crate
	containername = "computer disk crate"


/datum/supply_packs/monkey
	name = "Monkey crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "monkey crate"

/datum/supply_packs/spare_id
	name = "Spare ID's, PDA's, Headsets"
	contains = list(/obj/item/weapon/storage/box/PDAs,
					/obj/item/weapon/storage/box/PDAs,
					/obj/item/weapon/storage/box/ids,
					/obj/item/weapon/storage/box/ids,
					/obj/item/device/radio/headset,
					/obj/item/device/radio/headset,
					/obj/item/device/radio/headset,
					/obj/item/device/radio/headset)
	cost = 5
	containertype = /obj/structure/closet/crate/secure
	containername = "spare ID crate"
	access = access_heads

/datum/supply_packs/encrypt_keys
	name = "Radio Encryption keys"
	contains = list(/obj/item/device/encryptionkey/headset_sec,
					/obj/item/device/encryptionkey/headset_eng,
					/obj/item/device/encryptionkey/headset_rob,
					/obj/item/device/encryptionkey/headset_med,
					/obj/item/device/encryptionkey/headset_sci,
					/obj/item/device/encryptionkey/headset_com,
					/obj/item/device/encryptionkey/headset_cargo)
	cost = 5
	containertype = /obj/structure/closet/crate/secure
	containername = "encryption crate"
	access = access_heads


/datum/supply_packs/toner
	name = "Toner Cartridges"
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	cost = 1
	containertype = /obj/structure/closet/crate
	containername = "toner cartridges"

/datum/supply_packs/packing_supplies
	name = "Packing Supplies"
	contains = list(/obj/item/weapon/packageWrap,
					/obj/item/weapon/packageWrap,
					/obj/item/stack/sheet/cardboard,
					/obj/item/stack/sheet/cardboard,
					/obj/item/stack/sheet/cardboard,
					/obj/item/stack/sheet/cardboard,
					/obj/item/stack/sheet/cardboard)
	cost = 1
	containertype = /obj/structure/closet/crate
	containername = "packing supplies"

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
	cost = 3
	containertype = /obj/structure/closet/crate
	containername = "party equipment"

/datum/supply_packs/internals
	name = "Internals crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air)
	cost = 5
	containertype = /obj/structure/closet/crate/internals
	containername = "internals crate"

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
	cost = 15
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"

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
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket)
	cost = 5
	containertype = /obj/structure/closet/crate
	containername = "janitorial supplies"

/datum/supply_packs/lightbulbs
	name = "Replacement lights"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 5
	containertype = /obj/structure/closet/crate
	containername = "replacement lights"

/datum/supply_packs/costume
	name = "Standard costume crate"
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

/datum/supply_packs/wizard
	name = "Wizard costume"
	contains = list(/obj/item/weapon/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "wizard costume crate"

/datum/supply_packs/mule
	name = "MULEbot Crate"
	contains = list(/obj/machinery/bot/mulebot)
	cost = 10
	containertype = /obj/structure/largecrate/mule
	containername = "\improper MULEbot Crate"


/*
	Hydroponics
*/

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

//farm animals - useless and annoying, but potentially a good source of food
/datum/supply_packs/cow
	name = "Cow Crate"
	cost = 10
	containertype = /obj/structure/largecrate/cow
	containername = "cow crate"
	access = access_hydroponics

/datum/supply_packs/goat
	name = "Goat Crate"
	cost = 10
	containertype = /obj/structure/largecrate/goat
	containername = "goat crate"
	access = access_hydroponics

/datum/supply_packs/chicken
	name = "Chicken Crate"
	cost = 5
	containertype = /obj/structure/largecrate/chick
	containername = "chicken crate"
	access = access_hydroponics

/datum/supply_packs/lisa
	name = "Corgi Crate"
	contains = list()
	cost = 25
	containertype = /obj/structure/largecrate/lisa
	containername = "corgi crate"

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

/datum/supply_packs/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	cost = 5
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = access_hydroponics

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
	cost = 5
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "exotic seeds crate"
	access = access_hydroponics

/datum/supply_packs/hydroponics_trays
	name = "Hydroponics Trays"
	contains = list(/obj/machinery/hydroponics,
					/obj/machinery/hydroponics,
					/obj/machinery/hydroponics)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "hydroponics trays"
	access = access_hydroponics

/*
	Medical
*/

/datum/supply_packs/medical
	name = "Medical crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/box/bodybags,
					/obj/item/weapon/storage/box/gloves,
					/obj/item/weapon/storage/box/masks,
					/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/storage/box/syringes)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"

/datum/supply_packs/surgical
	name = "Surgical Tools crate"
	contains = list(/obj/item/weapon/surgicaldrill,
					/obj/item/weapon/hemostat,
					/obj/item/weapon/circular_saw,
					/obj/item/weapon/scalpel,
					/obj/item/weapon/retractor,
					/obj/item/weapon/cautery,
					/obj/item/weapon/surgical_drapes
	)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "surgical equipment crate"
	access = access_cmo

/datum/supply_packs/trolley
	name = "Medical Trolley"
	cost = 10
	containertype = /obj/structure/stool/bed
	containername = "bed"

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

/*
	Logistics
*/
/datum/supply_packs/plasteel50
	name = "50 Plasteel Sheets"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "plasteel sheets crate"

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 5
	containertype = /obj/structure/closet/crate
	containername = "metal sheets crate"

/datum/supply_packs/rglass50
	name = "50 Reinforced Glass Sheets"
	contains = list(/obj/item/stack/sheet/rglass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "reinforced glass sheets crate"

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 5
	containertype = /obj/structure/closet/crate
	containername = "glass sheets crate"

/datum/supply_packs/airlock_painter
	name = "Airlock Painter"
	contains = list(/obj/item/device/toner/ink,
					/obj/item/device/toner/ink,
					/obj/item/weapon/airlock_painter)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "airlock painter crate"
	access = access_cargo

/datum/supply_packs/area_electronics
	name = "Station Construction Electronics"
	contains = list(/obj/item/weapon/airlock_electronics,
					/obj/item/weapon/airlock_electronics,
					/obj/item/weapon/firealarm_electronics,
					/obj/item/weapon/airalarm_electronics,
					/obj/item/weapon/module/power_control,
					/obj/item/weapon/module/switch_control,
					/obj/item/weapon/module/switch_control,
					/obj/item/weapon/module/switch_control,
					/obj/item/weapon/module/console_motherboard,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cable_coil)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "station electronics crate"
	access = access_cargo

/datum/supply_packs/telecoms_electronics
	name = "Telecomms Circuitboards"
	contains = list(/obj/item/weapon/circuitboard/telecomms/receiver,
					/obj/item/weapon/circuitboard/telecomms/hub,
					/obj/item/weapon/circuitboard/telecomms/relay,
					/obj/item/weapon/circuitboard/telecomms/bus,
					/obj/item/weapon/circuitboard/telecomms/processor,
					/obj/item/weapon/circuitboard/telecomms/server,
					/obj/item/weapon/circuitboard/telecomms/broadcaster)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "telecoms electronics crate"
	access = access_cargo


/datum/supply_packs/computer_electronics
	name = "Computer Circuitboards"
	contains = list(/obj/item/weapon/circuitboard/message_monitor,
					/obj/item/weapon/circuitboard/aicore,
					/obj/item/weapon/circuitboard/aifixer,
					/obj/item/weapon/circuitboard/air_management,
					/obj/item/weapon/circuitboard/aiupload,
					/obj/item/weapon/circuitboard/arcade,
					/obj/item/weapon/circuitboard/area_atmos,
					/obj/item/weapon/circuitboard/atmos_alert,
					/obj/item/weapon/circuitboard/atmospheresiphonswitch,
					/obj/item/weapon/circuitboard/borgupload,
					/obj/item/weapon/circuitboard/card,
					/obj/item/weapon/circuitboard/card/centcom,
					/obj/item/weapon/circuitboard/cloning,
					/obj/item/weapon/circuitboard/comm_monitor,
					/obj/item/weapon/circuitboard/comm_server,
					/obj/item/weapon/circuitboard/comm_traffic,
					/obj/item/weapon/circuitboard/communications,
					/obj/item/weapon/circuitboard/crew,
					/obj/item/weapon/circuitboard/curefab,
					/obj/item/weapon/circuitboard/HolodeckControl,
					/obj/item/weapon/circuitboard/injector_control,
					/obj/item/weapon/circuitboard/mech_bay_power_console,
					/obj/item/weapon/circuitboard/mecha_control,
					/obj/item/weapon/circuitboard/med_data,
					/obj/item/weapon/circuitboard/mining,
					/obj/item/weapon/circuitboard/mining_shuttle,
					/obj/item/weapon/circuitboard/olddoor,
					/obj/item/weapon/circuitboard/operating,
					/obj/item/weapon/circuitboard/ordercomp,
					/obj/item/weapon/circuitboard/pandemic,
					/obj/item/weapon/circuitboard/pod,
					/obj/item/weapon/circuitboard/powermonitor,
					/obj/item/weapon/circuitboard/prison_shuttle,
					/obj/item/weapon/circuitboard/prisoner,
					/obj/item/weapon/circuitboard/rdconsole,
					/obj/item/weapon/circuitboard/rdservercontrol,
					/obj/item/weapon/circuitboard/robotics,
					/obj/item/weapon/circuitboard/scan_consolenew,
					/obj/item/weapon/circuitboard/secure_data,
					/obj/item/weapon/circuitboard/security,
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/circuitboard/splicer,
					/obj/item/weapon/circuitboard/stationalert,
					/obj/item/weapon/circuitboard/supplycomp,
					/obj/item/weapon/circuitboard/swfdoor,
					/obj/item/weapon/circuitboard/syndicatedoor,
					/obj/item/weapon/circuitboard/teleporter,
					/obj/item/weapon/circuitboard/turbine_control)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "computer electronics crate"
	access = access_cargo


/datum/supply_packs/electrical
	name = "Electrical maintenance crate"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/device/multitool,
					/obj/item/device/multitool,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "electrical maintenance crate"

/datum/supply_packs/mechanical
	name = "Mechanical maintenance crate"
	contains = list(/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/clothing/head/hardhat)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "mechanical maintenance crate"

/datum/supply_packs/explosive_electronics
	name = "Explosives Electronics crate"
	contains = list(/obj/item/device/assembly/signaler,
					/obj/item/device/assembly/signaler,
					/obj/item/device/assembly/signaler,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/weapon/cartridge/signal/toxins,
					/obj/item/weapon/cartridge/signal/toxins
					)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "explosives electronics crate"
	access = access_cargo

/datum/supply_packs/radios
	name = "Handheld Radios"
	contains = list(/obj/item/device/radio/off,
					/obj/item/device/radio/off,
					/obj/item/device/radio/off,
					/obj/item/device/radio/off)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "handheld radio crate"

/datum/supply_packs/mmis
	name = "Man Machine Interfaces"
	contains = list(/obj/item/device/mmi,
					/obj/item/device/mmi,
					/obj/item/device/mmi)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "mmi crate"

/*
	Closets
*/

/datum/supply_packs/fire_closet
	name = "Fire Fighting closet"
	cost = 2
	containertype = /obj/structure/closet/firecloset
	containername = "fire fighting closet"

/datum/supply_packs/emergency_closet
	name = "Emergency closet"
	cost = 2
	containertype = /obj/structure/closet/emcloset
	containername = "emergency closet"

/datum/supply_packs/radiation_closet
	name = "Radiation closet"
	cost = 2
	containertype = /obj/structure/closet/radiation
	containername = "radiation suit closet"

/datum/supply_packs/mining_closet
	name = "Miners locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/miner
	containername = "miners equipment"

/datum/supply_packs/cargotech_locker
	name = "Cargotech locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/cargotech
	containername = "cargotech locker"

/datum/supply_packs/engineering_electrical_locker
	name = "Engineering Electrical locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/engineering_electrical
	containername = "engineering electrical locker"

/datum/supply_packs/engineering_welding_locker
	name = "Engineering Welding locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/engineering_welding
	containername = "engineering welding locker"

/datum/supply_packs/engineering_personal_locker
	name = "Engineering Personal locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/engineering_personal
	containername = "engineering personal locker"

/datum/supply_packs/hydroponics_locker
	name = "Hydroponics locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/hydroponics
	containername = "hydroponics locker"

/datum/supply_packs/medical1_locker
	name = "Medicine locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/medical1
	containername = "medicine locker"

/datum/supply_packs/medical2_locker
	name = "Anaesthetic locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/medical2
	containername = "anaesthetic locker"

/datum/supply_packs/scientist_locker
	name = "Scientist locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/scientist
	containername = "scientist locker"

/datum/supply_packs/medical3_locker
	name = "Doctors locker"
	cost = 2
	containertype = /obj/structure/closet/secure_closet/medical3
	containername = "doctors locker"

/datum/supply_packs/jcloset_locker
	name = "Janitor locker"
	cost = 2
	containertype = /obj/structure/closet/jcloset
	containername = "janitor locker"

/datum/supply_packs/chefcloset_locker
	name = "Chef locker"
	cost = 2
	containertype = /obj/structure/closet/chefcloset
	containername = "chef locker"

/datum/supply_packs/gmcloset_locker
	name = "Bartender locker"
	cost = 2
	containertype = /obj/structure/closet/gmcloset
	containername = "bartender locker"

/datum/supply_packs/bombcloset_locker
	name = "EOD closet"
	cost = 2
	containertype = /obj/structure/closet/bombcloset
	containername = "EOD locker"


/*
	Tanks
*/

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
	cost = 25
	containertype = /obj/structure/largecrate
	containername = "solar pack crate"
	access = access_ce

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
	cost = 20
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	containertype = /obj/structure/largecrate
	containername = "particle accelerator crate"
	access = access_ce

/datum/supply_packs/mecha_ripley
	name = "Circuit Crate (\"Ripley\" APLU)"
	contains = list(/obj/item/weapon/book/manual/ripley_build_and_repair,
					/obj/item/weapon/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 45
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper APLU \"Ripley\" circuit crate"
	access = access_robotics

/datum/supply_packs/mecha_odysseus
	name = "Circuit Crate (\"Odysseus\")"
	contains = list(/obj/item/weapon/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 35
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper \"Odysseus\" circuit crate"
	access = access_robotics


/datum/supply_packs/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "robotics assembly crate"
	access = access_robotics

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

/*
	Weapons
*/

/datum/supply_packs/security_resupply
	name = "Security Resupply crate"
	contains = list(/obj/item/clothing/glasses/sunglasses/blindfold,
					/obj/item/clothing/glasses/sunglasses/blindfold,
					/obj/item/clothing/ears/earmuffs,
					/obj/item/clothing/ears/earmuffs,
					/obj/item/weapon/storage/box/trackimp,
					/obj/item/weapon/storage/box/chemimp,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/handcuffs,
					/obj/item/weapon/storage/box/seccarts)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "security resupply crate"
	access = access_security

/datum/supply_packs/prison_uniform
	name = "Prison Uniform crate"
	contains = list(/obj/item/clothing/under/color/orange,
					/obj/item/clothing/under/color/orange,
					/obj/item/clothing/under/color/orange,
					/obj/item/clothing/shoes/orange,
					/obj/item/clothing/shoes/orange,
					/obj/item/clothing/shoes/orange)
	cost = 2
	containertype = /obj/structure/closet/crate
	containername = "prison uniform crate"

/datum/supply_packs/glasses_hud
	name = "Glasses and HUD crate"
	contains = list(/obj/item/clothing/glasses/meson,
					/obj/item/clothing/glasses/science,
					/obj/item/clothing/glasses/night,
					/obj/item/clothing/glasses/hud/security,
					/obj/item/clothing/glasses/hud/health)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "vision equipment crate"
	access = access_cargo

/datum/supply_packs/weapons
	name = "Station Blueprints"
	contains = list(/obj/item/blueprints)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "blueprints crate"
	access = access_ce

/datum/supply_packs/weapons
	name = "Weapons crate"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/gun/energy/taser,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "weapons crate"
	access = access_security

/datum/supply_packs/eweapons
	name = "Incendiary weapons crate"
	contains = list(/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
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
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/handcuffs,
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
	contains = list (/obj/item/weapon/storage/lockbox/loyalty)
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
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "ballistic gear crate"
	access = access_armory

/datum/supply_packs/expenergy
	name = "Experimental energy gear crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof,
					/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)
	cost = 35
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
	contains = list(/obj/item/weapon/contraband/poster,
					/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
					/obj/item/weapon/lipstick/random)
	name = "Contraband crate"
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "crate"	//let's keep it subtle, eh?
	contraband = 1

	name = "Scrubber Huge Machine"
	contains = list(/obj/machinery/portable_atmospherics/scrubber/huge)
	cost = 45
	containertype = /obj/structure/largecrate
	containername = "Scrubber Huge machine crate"
	access = access_ce

/datum/supply_packs/scrubber
	name = "Scrubber Machine"
	contains = list(/obj/machinery/portable_atmospherics/scrubber)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "Scrubber machine crate"
	access = access_ce

/datum/supply_packs/space_heater
	name = "Space Heater Machine"
	contains = list(/obj/machinery/space_heater)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "space_heater machine crate"
	access = access_ce

/datum/supply_packs/air_pump
	name = "Air Pump Machine"
	contains = list(/obj/machinery/portable_atmospherics/pump)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "air pump machine crate"
	access = access_ce

/datum/supply_packs/engineering_hardsuit
	name = "Engineering Hardsuit"
	contains = list(/obj/item/clothing/suit/space/rig,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/head/helmet/space/rig)
	cost = 5
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "engineering hardsuit crate"
	access = access_heads

/datum/supply_packs/medical_hardsuit
	name = "Medical Hardsuit"
	contains = list(/obj/item/clothing/suit/space/rig/medical,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/clothing/head/helmet/space/rig/medical)
	cost = 5
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "medical hardsuit crate"
	access = access_heads

/datum/supply_packs/security_hardsuit
	name = "Security Hardsuit"
	contains = list(/obj/item/clothing/suit/space/rig/security,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/head/helmet/space/rig/security)
	cost = 5
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "security hardsuit crate"
	access = access_heads

/datum/supply_packs/magboots
	name = "Magboots"
	contains = list(/obj/item/clothing/shoes/magboots)
	cost = 5
	containertype = /obj/structure/closet/crate/secure/gear
	containername = "magboots crate"
	access = access_heads

/datum/supply_packs/suit_storage_unit
	name = "Suit Storage Unit"
	contains = list(/obj/machinery/suit_storage_unit)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "suit_storage_unit crate"
	access = access_engine

/datum/supply_packs/recharge_station
	name = "Recharge Station Machine"
	contains = list(/obj/machinery/recharge_station)
	cost = 25
	containertype = /obj/structure/largecrate
	containername = "recharge_station machine crate"
	access = access_engine

/datum/supply_packs/bookbinder
	name = "Bookbinder Machine"
	contains = list(/obj/machinery/bookbinder)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "bookbinder machine crate"
	access = access_library

/datum/supply_packs/photocopier
	name = "Photocopier Machine"
	contains = list(/obj/machinery/photocopier)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "photocopier machine crate"

/datum/supply_packs/librarycomp
	name = "Librarycomp Machine"
	contains = list(/obj/machinery/librarycomp)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "librarycomp machine crate"
	access = access_library

/datum/supply_packs/fridge
	name = "Fridge Machine"
	contains = list(/obj/structure/closet/secure_closet/freezer/fridge)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Fridge machine crate"
	access = access_kitchen

/datum/supply_packs/microwave
	name = "Microwave Machine"
	contains = list(/obj/machinery/microwave)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "microwave machine crate"
	access = access_kitchen

/datum/supply_packs/smartfridge
	name = "Smartfridge Machine"
	contains = list(/obj/machinery/smartfridge)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "smartfridge machine crate"
	access = access_kitchen

/datum/supply_packs/processor
	name = "All-In-One Processor Machine"
	contains = list(/obj/machinery/processor)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "processor machine crate"
	access = access_kitchen

/datum/supply_packs/reagentgrinder
	name = "Reagentgrinder Machine"
	contains = list(/obj/machinery/reagentgrinder)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "reagentgrinder machine crate"
	access = access_kitchen

/datum/supply_packs/gibber
	name = "Gibber Machine"
	contains = list(/obj/machinery/gibber)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "gibber machine crate"
	access = access_kitchen

/datum/supply_packs/dinnerware_vending
	name = "Dinnerware Machine"
	contains = list(/obj/machinery/vending/dinnerware)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "dinnerware machine crate"
	access = access_kitchen

/datum/supply_packs/boozeomat_vending
	name = "Booze-O-Matt Machine"
	contains = list(/obj/machinery/vending/boozeomat)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Booze-o-Matt machine crate"
	access = access_kitchen

/datum/supply_packs/cigarette_vending
	name = "Cigarette Vending Machine"
	contains = list(/obj/machinery/vending/cigarette)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Cigarette Vending machine crate"
	access = access_kitchen

/datum/supply_packs/snack_vending
	name = "Snack Vending Machine"
	contains = list(/obj/machinery/vending/snack)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Snack Vending machine crate"
	access = access_kitchen

/datum/supply_packs/cola_vending
	name = "Cola Vending Machine"
	contains = list(/obj/machinery/vending/cola)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Cola Vending machine crate"
	access = access_kitchen
/datum/supply_packs/seed_extractor
	name = "Seed Extractor Machine"
	contains = list(/obj/machinery/seed_extractor)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Seed Extractor crate"
	access = access_hydroponics

/datum/supply_packs/biogenerator
	name = "Biogenerator Machine"
	contains = list(/obj/machinery/biogenerator)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Biogenerator crate"
	access = access_hydroponics

/datum/supply_packs/hydronutrients
	name = "Hydronutrients Vending Machine"
	contains = list(/obj/machinery/vending/hydronutrients)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "hydronutrients vending machine crate"
	access = access_hydroponics

/datum/supply_packs/hydroseeds
	name = "Hydroseeds Vending Machine"
	contains = list(/obj/machinery/vending/hydroseeds)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "hydroseeds vending machine crate"
	access = access_hydroponics

/datum/supply_packs/dna_scanner
	name = "Dna Scanner Machine"
	contains = list(/obj/machinery/dna_scannernew)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "DNA Scanner machine crate"
	access = access_cmo

/datum/supply_packs/clonepod
	name = "Clonepod Machine"
	contains = list(/obj/machinery/clonepod)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "clonepod machine crate"
	access = access_cmo

/datum/supply_packs/cryo_cell
	name = "Cryo Cell Machine"
	contains = list(/obj/machinery/atmospherics/unary/cryo_cell)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "Cryo Cell machine crate"
	access = access_cmo

/datum/supply_packs/sleeper
	name = "Sleeper Machine"
	contains = list(/obj/machinery/sleeper)
	cost = 25
	containertype = /obj/structure/largecrate
	containername = "sleeper machine crate"
	access = access_cmo

/datum/supply_packs/sleep_console
	name = "Sleeper Console Machine"
	contains = list(/obj/machinery/sleep_console)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "sleeper console machine crate"
	access = access_cmo

/datum/supply_packs/optable
	name = "Surgical Table"
	contains = list(/obj/structure/optable)
	cost = 5
	containertype = /obj/structure/largecrate
	containername = "Surgical Table crate"
	access = access_cmo

/datum/supply_packs/chem_dispenser
	name = "Chemical Dispensor Machine"
	contains = list(/obj/machinery/chem_dispenser)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "chem dispenser crate"
	access = access_cmo

/datum/supply_packs/chem_master
	name = "ChemMaster 3000 Machine"
	contains = list(/obj/machinery/chem_master)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "ChemMaster 3000 crate"
	access = access_chemistry

/datum/supply_packs/atmos_freezer
	name = "Atmos Freezer Machine"
	contains = list(/obj/machinery/atmospherics/unary/cold_sink/freezer)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Atmos Freezer machine crate"
	access = access_engine

/datum/supply_packs/atmos_heater
	name = "Atmos Heater Machine"
	contains = list(/obj/machinery/atmospherics/unary/heat_reservoir/heater)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "Atmos Heater machine crate"
	access = access_engine

/datum/supply_packs/pipe_dispenser
	name = "Pipe Dispenser Machine"
	contains = list(/obj/machinery/pipedispenser)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "pipe dispenser machine crate"
	access = access_engine

/datum/supply_packs/disposal_pipe_dispenser
	name = "Disposal Pipe Dispenser Machine"
	contains = list(/obj/machinery/pipedispenser/disposal)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "disposal pipe dispenser machine crate"
	access = access_engine

/datum/supply_packs/tank_dispenser
	name = "Tank Dispenser Machine"
	contains = list(/obj/structure/dispenser)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "tank dispenser machine crate"
	access = access_engine

/datum/supply_packs/autolathe
	name = "Autolathe Machine"
	contains = list(/obj/machinery/autolathe)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "autolathe machine crate"
	access = access_research

/datum/supply_packs/protolathe
	name = "Protolathe Machine"
	contains = list(/obj/machinery/r_n_d/protolathe)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "protolathe machine crate"
	access = access_research

/datum/supply_packs/rnd_server_core
	name = "Rnd Server Core Machine"
	contains = list(/obj/machinery/r_n_d/server/core)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "RnD Server Core machine crate"
	access = access_research

/datum/supply_packs/rnd_server_robotics
	name = "Rnd Server Robotics Machine"
	contains = list(/obj/machinery/r_n_d/server/robotics)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "RnD Server Robotics machine crate"
	access = access_research

/datum/supply_packs/rnd_destructive_analyzer
	name = "Rnd Destructive Analyzer Machine"
	contains = list(/obj/machinery/r_n_d/destructive_analyzer)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "RnD Destructive Analyzer machine crate"
	access = access_research

/datum/supply_packs/rnd_circuit_imprinter
	name = "Rnd Circuit Imprinter Machine"
	contains = list(/obj/machinery/r_n_d/circuit_imprinter)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "RnD circuit imprinter machine crate"
	access = access_research

/datum/supply_packs/robotic_fabricator
	name = "Robotic Fabricator Machine"
	contains = list(/obj/machinery/robotic_fabricator)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "robotic_fabricator machine crate"
	access = access_research

/datum/supply_packs/exosuit_fabricator
	name = "Exosuit Fabricator Machine"
	contains = list(/obj/machinery/mecha_part_fabricator)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "exosuit fabricator machine crate"
	access = access_research

/datum/supply_packs/crematorium
	name = "Crematorium Machine"
	contains = list(/obj/structure/crematorium)
	cost = 25
	containertype = /obj/structure/largecrate
	containername = "crematorium machine crate"
	access = access_ce

/datum/supply_packs/morgue
	name = "Morgue Machine"
	contains = list(/obj/structure/morgue)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "morgue machine crate"
	access = access_ce

/datum/supply_packs/pacman_generator
	name = "PACMAN Generator"
	contains = list(/obj/machinery/power/port_gen/pacman)
	cost = 5
	containertype = /obj/structure/closet/crate
	containername = "PACMAN Generator crate"

/datum/supply_packs/janitor_cart
	name = "Janitor Cart Machine"
	contains = list(/obj/structure/janitorialcart)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "janitor cart machine crate"
	access = access_research

/datum/supply_packs/external_airlock
	name = "External Airlock"
	contains = list(/obj/machinery/door/airlock/external)
	cost = 20
	containertype = /obj/structure/largecrate
	containername = "External Airlock crate"
	access = access_ce

/datum/supply_packs/power_storage_unit
	name = "Power Storage Unit"
	contains = list(/obj/machinery/power/smes)
	cost = 300
	containertype = /obj/structure/largecrate
	containername = "power storage unit crate"
	access = access_ce
