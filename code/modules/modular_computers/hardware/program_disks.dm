/**
 * Command
 */
/obj/item/computer_hardware/hard_drive/portable/command
	icon_state = "datadisk7"


/obj/item/computer_hardware/hard_drive/portable/command/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/crew_manifest(src))
	store_file(new /datum/computer_file/program/science(src))
	store_file(new /datum/computer_file/program/status(src))

/obj/item/computer_hardware/hard_drive/portable/command/captain
	name = "captain data disk"
	desc = "Removable disk used to download essential Captain tablet apps."
	icon_state = "datadisk10"

/obj/item/computer_hardware/hard_drive/portable/command/captain/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))
	store_file(new /datum/computer_file/program/records/medical(src))
	store_file(new /datum/computer_file/program/phys_scanner/all(src))

/obj/item/computer_hardware/hard_drive/portable/command/cmo
	name = "chief medical officer data disk"
	desc = "Removable disk used to download essential CMO tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/cmo/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/all(src))
	store_file(new /datum/computer_file/program/records/medical(src))

/obj/item/computer_hardware/hard_drive/portable/command/rd
	name = "research director data disk"
	desc = "Removable disk used to download essential RD tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/rd/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signal_commander(src))
	store_file(new /datum/computer_file/program/phys_scanner/chemistry(src))

/obj/item/computer_hardware/hard_drive/portable/command/hos
	name = "head of security data disk"
	desc = "Removable disk used to download essential HoS tablet apps."
	icon_state = "datadisk9"

/obj/item/computer_hardware/hard_drive/portable/command/hos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))

/obj/item/computer_hardware/hard_drive/portable/command/hop
	name = "head of personnel data disk"
	desc = "Removable disk used to download essential HoP tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/hop/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))
	store_file(new /datum/computer_file/program/job_management(src))

/obj/item/computer_hardware/hard_drive/portable/command/ce
	name = "chief engineer data disk"
	desc = "Removable disk used to download essential CE tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/ce/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/power_monitor(src))
	store_file(new /datum/computer_file/program/supermatter_monitor(src))
	store_file(new /datum/computer_file/program/atmosscan(src))
	store_file(new /datum/computer_file/program/alarm_monitor(src))

/**
 * Security
 */
/obj/item/computer_hardware/hard_drive/portable/security
	name = "security officer data disk"
	desc = "Removable disk used to download security-related tablet apps."
	icon_state = "datadisk9"

/obj/item/computer_hardware/hard_drive/portable/security/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security(src))
	store_file(new /datum/computer_file/program/crew_manifest(src))

/**
 * Medical
 */
/obj/item/computer_hardware/hard_drive/portable/medical
	name = "medical doctor data disk"
	desc = "Removable disk used to download medical-related tablet apps."
	icon_state = "datadisk7"

/obj/item/computer_hardware/hard_drive/portable/medical/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/medical(src))
	store_file(new /datum/computer_file/program/records/medical(src))

/obj/item/computer_hardware/hard_drive/portable/chemistry
	name = "chemistry data disk"
	desc = "Removable disk used to download chemistry-related tablet apps."
	icon_state = "datadisk5"

/obj/item/computer_hardware/hard_drive/portable/chemistry/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/chemistry(src))

/**
 * Supply
 */
/obj/item/computer_hardware/hard_drive/portable/quartermaster
	name = "cargo data disk"
	desc = "Removable disk used to download cargo-related tablet apps."
	icon_state = "cargodisk"

/obj/item/computer_hardware/hard_drive/portable/quartermaster/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/shipping(src))
	store_file(new /datum/computer_file/program/budgetorders(src))

/**
 * Science
 */
/obj/item/computer_hardware/hard_drive/portable/ordnance
	name = "ordnance data disk"
	desc = "Removable disk used to download ordnance-related tablet apps."
	icon_state = "datadisk5"

/obj/item/computer_hardware/hard_drive/portable/ordnance/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signal_commander(src))

/**
 * Engineering
 */
/obj/item/computer_hardware/hard_drive/portable/engineering
	name = "station engineer data disk"
	desc = "Removable disk used to download engineering-related tablet apps."
	icon_state = "datadisk6"

/obj/item/computer_hardware/hard_drive/portable/engineering/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/power_monitor(src))
	store_file(new /datum/computer_file/program/supermatter_monitor(src))

/obj/item/computer_hardware/hard_drive/portable/atmos
	name = "atmospheric technician data disk"
	desc = "Removable disk used to download atmos-related tablet apps."
	icon_state = "datadisk6"


/obj/item/computer_hardware/hard_drive/portable/atmos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/atmosscan(src))
	store_file(new /datum/computer_file/program/alarm_monitor(src))
