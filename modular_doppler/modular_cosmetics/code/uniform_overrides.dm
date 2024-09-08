/obj/item/storage/bag/garment/captain/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/command(src)
	new /obj/item/clothing/neck/doppler_mantle/command(src)
	new /obj/item/clothing/head/beret/doppler_command/command(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/command(src)

/obj/item/storage/bag/garment/hop/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/service(src)
	new /obj/item/clothing/neck/doppler_mantle/service(src)
	new /obj/item/clothing/head/beret/doppler_command/service(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/service(src)

/obj/item/storage/bag/garment/hos/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/security(src)
	new /obj/item/clothing/neck/doppler_mantle/security(src)
	new /obj/item/clothing/head/beret/doppler_command/security(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/security(src)

/obj/item/storage/bag/garment/warden/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/security(src)
	new /obj/item/clothing/neck/doppler_mantle/performer(src)
	new /obj/item/clothing/head/beret/doppler_command/performer(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/performer(src)

/obj/item/storage/bag/garment/research_director/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/science(src)
	new /obj/item/clothing/neck/doppler_mantle/science(src)
	new /obj/item/clothing/head/beret/doppler_command/science(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/science(src)

/obj/item/storage/bag/garment/chief_medical/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/medical(src)
	new /obj/item/clothing/neck/doppler_mantle/medical(src)
	new /obj/item/clothing/head/beret/doppler_command/medical(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/medical(src)

/obj/item/storage/bag/garment/engineering_chief/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/engineering(src)
	new /obj/item/clothing/neck/doppler_mantle/engineering(src)
	new /obj/item/clothing/head/beret/doppler_command/engineering(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/engineering(src)

/obj/item/storage/bag/garment/quartermaster/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/misc/doppler_uniform/cargo(src)
	new /obj/item/clothing/neck/doppler_mantle/cargo(src)
	new /obj/item/clothing/head/beret/doppler_command/cargo(src)
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_command/cargo(src)



/// Job loadout overrides
// HEADS
/datum/outfit/job/cmo
	uniform = /obj/item/clothing/under/misc/doppler_uniform/medical
	head = /obj/item/clothing/head/beret/doppler_command/medical
	neck = /obj/item/clothing/neck/doppler_mantle/medical

/datum/outfit/job/rd
	uniform = /obj/item/clothing/under/misc/doppler_uniform/science
	head = /obj/item/clothing/head/utility/hardhat/welding/doppler_command/science
	neck = /obj/item/clothing/neck/doppler_mantle/science

/datum/outfit/job/ce
	uniform = /obj/item/clothing/under/misc/doppler_uniform/engineering
	head = /obj/item/clothing/head/utility/hardhat/welding/doppler_command/engineering
	neck = /obj/item/clothing/neck/doppler_mantle/engineering

/datum/outfit/job/quartermaster
	uniform = /obj/item/clothing/under/misc/doppler_uniform/cargo
	head = /obj/item/clothing/head/beret/doppler_command/cargo
	neck = /obj/item/clothing/neck/doppler_mantle/cargo

/datum/outfit/job/hop
	uniform = /obj/item/clothing/under/misc/doppler_uniform/service
	head = /obj/item/clothing/head/beret/doppler_command/service
	neck = /obj/item/clothing/neck/doppler_mantle/service

/datum/outfit/job/captain
	uniform = /obj/item/clothing/under/misc/doppler_uniform/command
	head = /obj/item/clothing/head/beret/doppler_command/command
	neck = /obj/item/clothing/neck/doppler_mantle/command

/datum/outfit/job/warden //not technically a head, but we make fun of them with pink drip bc lmao
	uniform = /obj/item/clothing/under/misc/doppler_uniform/security
	head = /obj/item/clothing/head/utility/hardhat/welding/doppler_command/performer
	neck = /obj/item/clothing/neck/doppler_mantle/performer

/datum/outfit/job/hos
	uniform = /obj/item/clothing/under/misc/doppler_uniform/security
	head = /obj/item/clothing/head/beret/doppler_command/security
	neck = /obj/item/clothing/neck/doppler_mantle/security

// MEDICAL
/datum/outfit/job/doctor
	uniform = /obj/item/clothing/under/misc/doppler_uniform/medical

/datum/outfit/job/chemist
	uniform = /obj/item/clothing/under/misc/doppler_uniform/medical

/datum/outfit/job/coroner
	uniform = /obj/item/clothing/under/misc/doppler_uniform/medical

/datum/outfit/job/paramedic
	uniform = /obj/item/clothing/under/misc/doppler_uniform/medical

// SCIENCE
/datum/outfit/job/scientist
	uniform = /obj/item/clothing/under/misc/doppler_uniform/science

/datum/outfit/job/roboticist
	uniform = /obj/item/clothing/under/misc/doppler_uniform/science

/datum/outfit/job/geneticist
	uniform = /obj/item/clothing/under/misc/doppler_uniform/science

// ENGINEERING
/datum/outfit/job/engineer
	uniform = /obj/item/clothing/under/misc/doppler_uniform/engineering

/datum/outfit/job/atmos
	uniform = /obj/item/clothing/under/misc/doppler_uniform/engineering

// CARGO
/datum/outfit/job/cargo_tech
	uniform = /obj/item/clothing/under/misc/doppler_uniform/cargo

/datum/outfit/job/miner
	uniform = /obj/item/clothing/under/misc/doppler_uniform/cargo

/datum/outfit/job/bitrunner
	uniform = /obj/item/clothing/under/misc/doppler_uniform/cargo

// SERVICE
/datum/outfit/job/cook
	uniform = /obj/item/clothing/under/misc/doppler_uniform/service

/datum/outfit/job/bartender
	uniform = /obj/item/clothing/under/misc/doppler_uniform/service

/datum/outfit/job/curator
	uniform = /obj/item/clothing/under/misc/doppler_uniform/service

/datum/outfit/job/psychologist
	uniform = /obj/item/clothing/under/misc/doppler_uniform/service

/datum/outfit/job/chaplain
	uniform = /obj/item/clothing/under/misc/doppler_uniform/service

// COMMAND
/datum/outfit/job/lawyer
	uniform = /obj/item/clothing/under/misc/doppler_uniform/command

/datum/outfit/job/bridge_assistant
	uniform = /obj/item/clothing/under/misc/doppler_uniform/command
	head = /obj/item/clothing/head/utility/hardhat/welding/doppler_command/performer

/datum/outfit/job/human_ai
	uniform = /obj/item/clothing/under/misc/doppler_uniform/command
	head = /obj/item/clothing/head/utility/hardhat/welding/doppler_command/science

/datum/outfit/job/veteran_advisor
	uniform = /obj/item/clothing/under/misc/doppler_uniform/command
	head = /obj/item/clothing/head/utility/hardhat/welding/doppler_command/security

// PERFORMERS
/datum/outfit/job/botanist
	uniform = /obj/item/clothing/under/misc/doppler_uniform/performer

/datum/outfit/job/clown
	uniform = /obj/item/clothing/under/misc/doppler_uniform/performer

/datum/outfit/job/mime
	uniform = /obj/item/clothing/under/misc/doppler_uniform/performer

/datum/outfit/job/janitor
	uniform = /obj/item/clothing/under/misc/doppler_uniform/performer

// SECURITY
/datum/outfit/job/detective
	uniform = /obj/item/clothing/under/misc/doppler_uniform/security

/datum/outfit/job/security
	uniform = /obj/item/clothing/under/misc/doppler_uniform/security

// ASSISTANTS & OTHER UNASSIGNED CREW
/datum/outfit/job
	uniform = /obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls

/datum/colored_assistant/grey
	jumpsuits = list(/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls)
	jumpskirts = list(/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls) // TODO: jumpskirt variants for all of these

/datum/colored_assistant/random
	jumpsuits = list(/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/random)
	jumpskirts = list(/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/random) // DITTO: see above



/// BESPOKE UNIFORMS IN APPROPRIATE WARDROBE VENDORS
// Medical
/obj/machinery/vending/wardrobe/medi_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/medical] = 3
	. = ..()

/obj/machinery/vending/wardrobe/chem_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/medical] = 3
	. = ..()

/obj/machinery/vending/wardrobe/viro_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/medical] = 3
	. = ..()

// Science
/obj/machinery/vending/wardrobe/science_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/science] = 3
	. = ..()

/obj/machinery/vending/wardrobe/gene_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/science] = 3
	. = ..()

/obj/machinery/vending/wardrobe/robo_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/science] = 3
	. = ..()

// Engineering
/obj/machinery/vending/wardrobe/engi_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/engineering] = 3
	. = ..()

/obj/machinery/vending/wardrobe/atmos_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/engineering] = 3
	. = ..()

// Cargo
/obj/machinery/vending/wardrobe/cargo_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/cargo] = 3
	. = ..()

// Service
/obj/machinery/vending/wardrobe/bar_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/service] = 3
	. = ..()

/obj/machinery/vending/wardrobe/chef_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/service] = 3
	. = ..()

/obj/machinery/vending/wardrobe/curator_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/service] = 3
	. = ..()

//PSYCH HAS NO DEDICATED WARDROBE

/obj/machinery/vending/wardrobe/chap_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/service] = 3
	. = ..()

// Command
/obj/machinery/vending/wardrobe/law_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/command] = 3
	. = ..()

// Performers/casual crew
/obj/machinery/vending/wardrobe/hydro_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/performer] = 3
	. = ..()

// Security
/obj/machinery/vending/wardrobe/sec_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/security] = 3
	. = ..()

/obj/machinery/vending/wardrobe/det_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/misc/doppler_uniform/security] = 3
	. = ..()

// Autodrobe
/obj/machinery/vending/autodrobe/Initialize(mapload)
	premium[/obj/item/clothing/under/misc/doppler_uniform/standard] = 10
	premium[/obj/item/clothing/under/misc/doppler_uniform/standard/cozy] = 10
	premium[/obj/item/clothing/under/misc/doppler_uniform/standard/suit] = 10
	premium[/obj/item/clothing/under/misc/doppler_uniform/standard/overalls] = 10
	premium[/obj/item/clothing/under/misc/doppler_uniform/standard/cozy/overalls] = 10
	premium[/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls] = 10
	. = ..()
