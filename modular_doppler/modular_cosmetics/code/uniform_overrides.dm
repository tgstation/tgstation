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
