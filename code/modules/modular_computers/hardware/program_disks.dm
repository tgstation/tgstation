/**
 * Command
 */

/obj/item/computer_hardware/hard_drive/small/command/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/crew_manifest(src))
	store_file(new /datum/computer_file/program/status(src))

/obj/item/computer_hardware/hard_drive/small/command/cmo/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/all(src))
	store_file(new /datum/computer_file/program/records/medical(src))

/obj/item/computer_hardware/hard_drive/small/command/rd/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signaler(src))
	store_file(new /datum/computer_file/program/phys_scanner/chemistry(src))

/obj/item/computer_hardware/hard_drive/small/command/hos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))

/obj/item/computer_hardware/hard_drive/small/command/ce/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/power_monitor(src))
	store_file(new /datum/computer_file/program/supermatter_monitor(src))
	store_file(new /datum/computer_file/program/atmosscan(src))
	store_file(new /datum/computer_file/program/alarm_monitor(src))

/**
 * Security
 */
/obj/item/computer_hardware/hard_drive/small/security/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))

/**
 * Medical
 */
/obj/item/computer_hardware/hard_drive/small/medical/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/medical(src))
	store_file(new /datum/computer_file/program/records/medical(src))

/obj/item/computer_hardware/hard_drive/small/chemistry/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/chemistry(src))

/**
 * Supply
 */
/obj/item/computer_hardware/hard_drive/small/quartermaster/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/shipping(src))
	store_file(new /datum/computer_file/program/budgetorders(src))

/**
 * Science
 */
/obj/item/computer_hardware/hard_drive/small/ordnance/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signaler(src))

/**
 * Engineering
 */
/obj/item/computer_hardware/hard_drive/small/engineering/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/power_monitor(src))
	store_file(new /datum/computer_file/program/supermatter_monitor(src))

/obj/item/computer_hardware/hard_drive/small/atmos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/atmosscan(src))
	store_file(new /datum/computer_file/program/alarm_monitor(src))
