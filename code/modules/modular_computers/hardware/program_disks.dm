/**
 * Command
 */

/obj/item/computer_hardware/hard_drive/portable/command/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/crew_manifest(src))
	store_file(new /datum/computer_file/program/status(src))

/obj/item/computer_hardware/hard_drive/portable/command/captain/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))
	store_file(new /datum/computer_file/program/records/medical(src))
	store_file(new /datum/computer_file/program/phys_scanner/all(src))

/obj/item/computer_hardware/hard_drive/portable/command/cmo/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/all(src))
	store_file(new /datum/computer_file/program/records/medical(src))

/obj/item/computer_hardware/hard_drive/portable/command/rd/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signaler(src))
	store_file(new /datum/computer_file/program/phys_scanner/chemistry(src))

/obj/item/computer_hardware/hard_drive/portable/command/hos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))

/obj/item/computer_hardware/hard_drive/portable/command/hop/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))
	store_file(new /datum/computer_file/program/job_management(src))

/obj/item/computer_hardware/hard_drive/portable/command/ce/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/power_monitor(src))
	store_file(new /datum/computer_file/program/supermatter_monitor(src))
	store_file(new /datum/computer_file/program/atmosscan(src))
	store_file(new /datum/computer_file/program/alarm_monitor(src))

/**
 * Security
 */
/obj/item/computer_hardware/hard_drive/portable/security/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))

/**
 * Medical
 */
/obj/item/computer_hardware/hard_drive/portable/medical/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/medical(src))
	store_file(new /datum/computer_file/program/records/medical(src))

/obj/item/computer_hardware/hard_drive/portable/chemistry/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/chemistry(src))

/**
 * Supply
 */
/obj/item/computer_hardware/hard_drive/portable/quartermaster/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/shipping(src))
	store_file(new /datum/computer_file/program/budgetorders(src))

/**
 * Science
 */
/obj/item/computer_hardware/hard_drive/portable/ordnance/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signaler(src))

/**
 * Engineering
 */
/obj/item/computer_hardware/hard_drive/portable/engineering/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/power_monitor(src))
	store_file(new /datum/computer_file/program/supermatter_monitor(src))

/obj/item/computer_hardware/hard_drive/portable/atmos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/atmosscan(src))
	store_file(new /datum/computer_file/program/alarm_monitor(src))
