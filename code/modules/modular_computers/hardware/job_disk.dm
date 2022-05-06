/obj/item/computer_hardware/hard_drive/role
	name = "job data disk"
	desc = "A disk meant to give a worker the needed programs to work."
	power_usage = 0
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	critical = FALSE
	max_capacity = 500
	device_type = MC_HDD_JOB
	default_installs = FALSE

	var/disk_flags = 0 // bit flag for the programs
	var/can_spam = FALSE
	var/list/bot_access = list()

/obj/item/computer_hardware/hard_drive/role/on_remove(obj/item/modular_computer/remove_from, mob/user)
	return

/obj/item/computer_hardware/hard_drive/role/Initialize(mapload)
	. = ..()
	var/list/progs_to_store = list()

	if(disk_flags & DISK_POWER)
		progs_to_store += new /datum/computer_file/program/power_monitor(src)
		progs_to_store += new /datum/computer_file/program/supermatter_monitor(src)

	if(disk_flags & DISK_ATMOS)
		progs_to_store += new /datum/computer_file/program/atmosscan(src)

	if(disk_flags & DISK_MANIFEST)
		progs_to_store += new /datum/computer_file/program/crew_manifest(src)

	if(disk_flags & DISK_SEC)
		progs_to_store += new /datum/computer_file/program/records/security(src)

	if(disk_flags & DISK_JANI)
		progs_to_store += new /datum/computer_file/program/radar/custodial_locator(src)

	if((disk_flags & DISK_CHEM) || (disk_flags & DISK_MED))
		var/datum/computer_file/program/phys_scanner/scanner = new(src)

		if(disk_flags & DISK_CHEM)
			scanner.available_modes += DISK_CHEM

		if(disk_flags & DISK_MED)
			progs_to_store += new /datum/computer_file/program/records/medical(src)
			scanner.available_modes += DISK_MED

		progs_to_store += scanner

	if(disk_flags & DISK_ROBOS)
		var/datum/computer_file/program/robocontrol/robo = new(src)
		robo.cart_mode = TRUE
		progs_to_store += robo

	if(disk_flags & DISK_CARGO)
		progs_to_store += new /datum/computer_file/program/shipping(src)

	if(disk_flags & DISK_SIGNAL)
		progs_to_store += new /datum/computer_file/program/signaler(src)

	if(disk_flags & DISK_NEWS)
		progs_to_store += new /datum/computer_file/program/newscaster(src)

	if(disk_flags & DISK_BUDGET)
		progs_to_store += new /datum/computer_file/program/budgetorders(src)

	if(disk_flags & DISK_STATUS)
		progs_to_store += new /datum/computer_file/program/status(src)

	if(disk_flags & DISK_SCI)
		progs_to_store += new /datum/computer_file/program/science(src)

	for (var/datum/computer_file/program/prog in progs_to_store)
		prog.usage_flags = PROGRAM_ALL
		prog.required_access = list()
		prog.transfer_access = list()
		store_file(prog)



/obj/item/computer_hardware/hard_drive/role/proc/CanSpam()
	return can_spam

// Disk Definitions

/obj/item/computer_hardware/hard_drive/role/engineering
	name = "Power-ON disk"
	desc = "Engineers ignoring station power-draw since 2400."
	icon_state = "datadisk2"
	disk_flags = DISK_POWER

/obj/item/computer_hardware/hard_drive/role/atmos
	name = "\improper BreatheDeep disk"
	icon_state = "datadisk2"
	disk_flags = DISK_ATMOS | DISK_ROBOS
	bot_access = list(
		FLOOR_BOT,
		FIRE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/medical
	name = "\improper Med-U disk"
	icon_state = "datadisk7"
	disk_flags = DISK_MED | DISK_ROBOS
	bot_access = list(
		MED_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/chemistry
	name = "\improper ChemWhiz disk"
	icon_state = "datadisk7"
	disk_flags = DISK_CHEM

/obj/item/computer_hardware/hard_drive/role/security
	name = "\improper R.O.B.U.S.T. disk"
	icon_state = "datadisk9"
	disk_flags = DISK_SEC | DISK_MANIFEST | DISK_ROBOS
	bot_access = list(
		SEC_BOT,
		ADVANCED_SEC_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/detective
	name = "\improper D.E.T.E.C.T. disk"
	icon_state = "datadisk9"
	disk_flags = DISK_MED | DISK_SEC | DISK_MANIFEST | DISK_ROBOS
	bot_access = list(
		SEC_BOT,
		ADVANCED_SEC_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/janitor
	name = "\improper CustodiPRO disk"
	icon_state = "datadisk5"
	desc = "The ultimate in clean-room design."
	disk_flags = DISK_JANI | DISK_ROBOS
	bot_access = list(
		CLEAN_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/lawyer
	name = "\improper P.R.O.V.E. disk"
	icon_state = "datadisk9"
	disk_flags = DISK_SEC
	can_spam = TRUE

/obj/item/computer_hardware/hard_drive/role/curator
	name = "\improper Lib-Tweet disk"
	icon_state = "datadisk2"
	disk_flags = DISK_NEWS

/obj/item/computer_hardware/hard_drive/role/roboticist
	name = "\improper B.O.O.P. Remote Control disk"
	icon_state = "datadisk5"
	desc = "Packed with heavy duty quad-bot interlink!"
	disk_flags = DISK_ROBOS
	bot_access = list(
		FLOOR_BOT,
		CLEAN_BOT,
		MED_BOT,
		FIRE_BOT,
		VIBE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/signal
	name = "generic signaler disk"
	icon_state = "datadisk5"
	desc = "A data disk with an integrated radio signaler module."
	disk_flags = DISK_SIGNAL

/obj/item/computer_hardware/hard_drive/role/signal/ordnance
	name = "\improper Signal Ace 2 disk"
	icon_state = "datadisk5"
	desc = "Complete with integrated radio signaler!"
	disk_flags = DISK_ATMOS | DISK_SIGNAL | DISK_CHEM

/obj/item/computer_hardware/hard_drive/role/quartermaster
	name = "space parts & space vendors disk"
	icon_state = "datadisk0"
	desc = "Perfect for the Quartermaster on the go!"
	disk_flags = DISK_CARGO | DISK_ROBOS | DISK_BUDGET
	bot_access = list(
		MULE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/head
	name = "\improper Easy-Record DELUXE disk"
	icon_state = "datadisk7"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_BUDGET | DISK_SCI

/obj/item/computer_hardware/hard_drive/role/hop
	name = "\improper HumanResources9001 disk"
	icon_state = "datadisk7"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_JANI | DISK_SEC | DISK_NEWS | DISK_CARGO | DISK_ROBOS | DISK_BUDGET | DISK_SCI
	bot_access = list(
		MULE_BOT,
		CLEAN_BOT,
		VIBE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/hos
	name = "\improper R.O.B.U.S.T. DELUXE disk"
	icon_state = "datadisk7"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_SEC | DISK_ROBOS | DISK_BUDGET | DISK_SCI
	bot_access = list(
		SEC_BOT,
		ADVANCED_SEC_BOT,
	)


/obj/item/computer_hardware/hard_drive/role/ce
	name = "\improper Power-On DELUXE disk"
	icon_state = "datadisk7"
	disk_flags = DISK_POWER | DISK_ATMOS | DISK_MANIFEST | DISK_STATUS | DISK_ROBOS | DISK_BUDGET | DISK_SCI
	bot_access = list(
		FLOOR_BOT,
		FIRE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/cmo
	name = "\improper Med-U DELUXE disk"
	icon_state = "datadisk7"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_CHEM | DISK_ROBOS | DISK_BUDGET | DISK_SCI
	bot_access = list(
		MED_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/rd
	name = "\improper Signal Ace DELUXE disk"
	icon_state = "rndmajordisk"
	disk_flags = DISK_ATMOS | DISK_MANIFEST | DISK_STATUS | DISK_CHEM | DISK_ROBOS | DISK_BUDGET | DISK_SIGNAL | DISK_SCI
	bot_access = list(
		FLOOR_BOT,
		CLEAN_BOT,
		MED_BOT,
		FIRE_BOT,
		VIBE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/captain
	name = "\improper Value-PAK disk"
	icon_state = "datadisk8"
	desc = "Now with 350% more value!" //Give the Captain...EVERYTHING! (Except Mime, Clown, and Syndie)
	disk_flags = ~0
	can_spam = TRUE
	bot_access = list(
		SEC_BOT,
		ADVANCED_SEC_BOT,
		MULE_BOT,
		FLOOR_BOT,
		CLEAN_BOT,
		MED_BOT,
		FIRE_BOT,
		VIBE_BOT,
	)
