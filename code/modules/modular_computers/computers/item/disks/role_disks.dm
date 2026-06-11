/**
 * Command
 */
/obj/item/disk/computer/command
	icon_state = "datadisk7"
	max_capacity = 32
	///Static list of programss ALL command tablets have.
	var/static/list/datum/computer_file/command_programs = list(
		/datum/computer_file/program/science,
		/datum/computer_file/program/status,
	)

/obj/item/disk/computer/command/Initialize(mapload)
	. = ..()
	for(var/programs in command_programs)
		var/datum/computer_file/program/program_type = new programs
		add_file(program_type)

/obj/item/disk/computer/command/captain
	name = "captain data disk"
	desc = "Removable disk used to download essential Captain tablet apps."
	icon_state = "datadisk10"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/records/medical,
	)

/obj/item/disk/computer/command/cmo
	name = "chief medical officer data disk"
	desc = "Removable disk used to download essential CMO tablet apps."
	starting_programs = list(
		/datum/computer_file/program/records/medical,
	)

/obj/item/disk/computer/command/rd
	name = "research director data disk"
	desc = "Removable disk used to download essential RD tablet apps."
	starting_programs = list(
		/datum/computer_file/program/signal_commander,
	)

/obj/item/disk/computer/command/hos
	name = "head of security data disk"
	desc = "Removable disk used to download essential HoS tablet apps."
	icon_state = "datadisk9"
	starting_programs = list(
		/datum/computer_file/program/records/security,
	)

/obj/item/disk/computer/command/hop
	name = "head of personnel data disk"
	desc = "Removable disk used to download essential HoP tablet apps."
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/job_management,
	)

/obj/item/disk/computer/command/ce
	name = "chief engineer data disk"
	desc = "Removable disk used to download essential CE tablet apps."
	starting_programs = list(
		/datum/computer_file/program/supermatter_monitor,
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/alarm_monitor,
	)

/**
 * Security
 */
/obj/item/disk/computer/security
	name = "security officer data disk"
	desc = "Removable disk used to download security-related tablet apps."
	icon_state = "datadisk9"
	starting_programs = list(
		/datum/computer_file/program/records/security,
	)

/**
 * Medical
 */
/obj/item/disk/computer/medical
	name = "medical doctor data disk"
	desc = "Removable disk used to download medical-related tablet apps."
	icon_state = "datadisk7"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
	)

/**
 * Supply
 */
/obj/item/disk/computer/quartermaster
	name = "cargo data disk"
	desc = "Removable disk used to download cargo-related tablet apps."
	icon_state = "datadisk12"
	starting_programs = list(
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/restock_tracker,
	)

/**
 * Science
 */
/obj/item/disk/computer/ordnance
	name = "ordnance data disk"
	desc = "Removable disk used to download ordnance-related tablet apps."
	icon_state = "datadisk5"
	starting_programs = list(
		/datum/computer_file/program/signal_commander,
		/datum/computer_file/program/scipaper_program,
	)

/**
 * Engineering
 */
/obj/item/disk/computer/engineering
	name = "engineering data disk"
	desc = "Removable disk used to download engineering-related tablet apps."
	icon_state = "datadisk6"
	starting_programs = list(
		/datum/computer_file/program/alarm_monitor,
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/supermatter_monitor,

	)

