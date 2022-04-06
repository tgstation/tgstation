/obj/item/computer_hardware/hard_drive/role
	name = "job data disk"
	desc = "A disk meant to give a worker the needed programs to work."
	power_usage = 0
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	critical = FALSE
	max_capacity = 50
	device_type = MC_HDD_JOB
	default_installs = FALSE

	var/disk_flags = 0 // bit flag for the programs
	var/can_spam = FALSE
	var/list/bot_access = list()

/obj/item/computer_hardware/hard_drive/role/on_remove(obj/item/modular_computer/remove_from, mob/user)
	return

/obj/item/computer_hardware/hard_drive/role/Initialize(mapload)
	. = ..()
	if(disk_flags & DISK_POWER)
		store_file(new /datum/computer_file/program/power_monitor(src))
	if(disk_flags & DISK_ATMOS)
		store_file(new /datum/computer_file/program/atmosscan(src))
	if(disk_flags & DISK_MANIFEST)
		store_file(new /datum/computer_file/program/crew_manifest(src))

/obj/item/computer_hardware/hard_drive/role/proc/CanSpam()
	return can_spam

// Disk Definitions

/obj/item/computer_hardware/hard_drive/role/engineering
	name = "Power-ON disk"
	desc = "Engineers ignoring station power-draw since 2400."
	disk_flags = DISK_POWER

/obj/item/computer_hardware/hard_drive/role/atmos
	name = "\improper BreatheDeep disk"
	disk_flags = DISK_ATMOS | DISK_ROBOS
	bot_access = list(
		FLOOR_BOT,
		FIRE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/medical
	name = "\improper Med-U disk"
	disk_flags = DISK_MED
	bot_access = list(
		MED_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/chemistry
	name = "\improper ChemWhiz disk"
	disk_flags = DISK_CHEM
	bot_access = list(
		MED_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/security
	name = "\improper R.O.B.U.S.T. disk"
	disk_flags = DISK_SEC | DISK_MANIFEST
	bot_access = list(
		SEC_BOT,
		ADVANCED_SEC_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/detective
	name = "\improper D.E.T.E.C.T. disk"
	disk_flags = DISK_SEC | DISK_MED | DISK_MANIFEST
	bot_access = list(
		SEC_BOT,
		ADVANCED_SEC_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/janitor
	name = "\improper CustodiPRO disk"
	desc = "The ultimate in clean-room design."
	disk_flags = DISK_JANI | DISK_ROBOS
	bot_access = list(
		CLEAN_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/lawyer
	name = "\improper P.R.O.V.E. disk"
	disk_flags = DISK_SEC
	can_spam = TRUE

/obj/item/computer_hardware/hard_drive/role/curator
	name = "\improper Lib-Tweet disk"
	disk_flags = DISK_NEWS

/obj/item/computer_hardware/hard_drive/role/roboticist
	name = "\improper B.O.O.P. Remote Control disk"
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
	desc = "A data disk with an integrated radio signaler module."

/obj/item/computer_hardware/hard_drive/role/signal/ordnance
	name = "\improper Signal Ace 2 disk"
	desc = "Complete with integrated radio signaler!"
	disk_flags = DISK_CHEM | DISK_ATMOS

/obj/item/computer_hardware/hard_drive/role/quartermaster
	name = "space parts & space vendors disk"
	desc = "Perfect for the Quartermaster on the go!"
	disk_flags = DISK_CARGO
	bot_access = list(
		MULE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/head
	name = "\improper Easy-Record DELUXE disk"
	disk_flags = DISK_MANIFEST | DISK_STATUS

/obj/item/computer_hardware/hard_drive/role/hop
	name = "\improper HumanResources9001 disk"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_JANI | DISK_SEC | DISK_NEWS | DISK_CARGO | DISK_ROBOS
	bot_access = list(
		MULE_BOT,
		CLEAN_BOT,
		VIBE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/hos
	name = "\improper R.O.B.U.S.T. DELUXE disk"
	disk_flags = DISK_MANIFEST | DISK_STATUS | CART_SECURITY
	bot_access = list(
		SEC_BOT,
		ADVANCED_SEC_BOT,
	)


/obj/item/computer_hardware/hard_drive/role/ce
	name = "\improper Power-On DELUXE disk"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_POWER | DISK_ATMOS | DISK_ROBOS
	bot_access = list(
		FLOOR_BOT,
		FIRE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/cmo
	name = "\improper Med-U DELUXE disk"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_CHEM | DISK_MED
	bot_access = list(
		MED_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/rd
	name = "\improper Signal Ace DELUXE disk"
	disk_flags = DISK_MANIFEST | DISK_STATUS | DISK_CHEM | DISK_ATMOS | DISK_ROBOS
	bot_access = list(
		FLOOR_BOT,
		CLEAN_BOT,
		MED_BOT,
		FIRE_BOT,
		VIBE_BOT,
	)

/obj/item/computer_hardware/hard_drive/role/captain
	name = "\improper Value-PAK disk"
	desc = "Now with 350% more value!" //Give the Captain...EVERYTHING! (Except Mime, Clown, and Syndie)
	disk_flags = ~(DISK_CLOWN | DISK_MIME)
	can_spam = 1
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
