/**
 * Command
 */
/obj/item/computer_hardware/hard_drive/portable/command
	icon_state = "datadisk7"


/obj/item/computer_hardware/hard_drive/portable/command/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/crew_manifest)
	store_file(new /datum/computer_file/program/science)
	store_file(new /datum/computer_file/program/status)

/obj/item/computer_hardware/hard_drive/portable/command/captain
	name = "captain data disk"
	desc = "Removable disk used to download essential Captain tablet apps."
	icon_state = "datadisk10"

/obj/item/computer_hardware/hard_drive/portable/command/captain/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security)
	store_file(new /datum/computer_file/program/records/medical)
	store_file(new /datum/computer_file/program/phys_scanner/all)

/obj/item/computer_hardware/hard_drive/portable/command/cmo
	name = "chief medical officer data disk"
	desc = "Removable disk used to download essential CMO tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/cmo/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/all)
	store_file(new /datum/computer_file/program/records/medical)

/obj/item/computer_hardware/hard_drive/portable/command/rd
	name = "research director data disk"
	desc = "Removable disk used to download essential RD tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/rd/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signal_commander)
	store_file(new /datum/computer_file/program/phys_scanner/chemistry)

/obj/item/computer_hardware/hard_drive/portable/command/hos
	name = "head of security data disk"
	desc = "Removable disk used to download essential HoS tablet apps."
	icon_state = "datadisk9"

/obj/item/computer_hardware/hard_drive/portable/command/hos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security)

/obj/item/computer_hardware/hard_drive/portable/command/hop
	name = "head of personnel data disk"
	desc = "Removable disk used to download essential HoP tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/hop/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security)
	store_file(new /datum/computer_file/program/job_management)

/obj/item/computer_hardware/hard_drive/portable/command/ce
	name = "chief engineer data disk"
	desc = "Removable disk used to download essential CE tablet apps."

/obj/item/computer_hardware/hard_drive/portable/command/ce/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/supermatter_monitor)
	store_file(new /datum/computer_file/program/atmosscan)
	store_file(new /datum/computer_file/program/alarm_monitor)

/**
 * Security
 */
/obj/item/computer_hardware/hard_drive/portable/security
	name = "security officer data disk"
	desc = "Removable disk used to download security-related tablet apps."
	icon_state = "datadisk9"

/obj/item/computer_hardware/hard_drive/portable/security/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/records/security)
	store_file(new /datum/computer_file/program/crew_manifest)

/**
 * Medical
 */
/obj/item/computer_hardware/hard_drive/portable/medical
	name = "medical doctor data disk"
	desc = "Removable disk used to download medical-related tablet apps."
	icon_state = "datadisk7"

/obj/item/computer_hardware/hard_drive/portable/medical/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/medical)
	store_file(new /datum/computer_file/program/records/medical)

/obj/item/computer_hardware/hard_drive/portable/chemistry
	name = "chemistry data disk"
	desc = "Removable disk used to download chemistry-related tablet apps."
	icon_state = "datadisk5"

/obj/item/computer_hardware/hard_drive/portable/chemistry/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/phys_scanner/chemistry)

/**
 * Supply
 */
/obj/item/computer_hardware/hard_drive/portable/quartermaster
	name = "cargo data disk"
	desc = "Removable disk used to download cargo-related tablet apps."
	icon_state = "cargodisk"

/obj/item/computer_hardware/hard_drive/portable/quartermaster/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/shipping)
	store_file(new /datum/computer_file/program/budgetorders)

/**
 * Science
 */
/obj/item/computer_hardware/hard_drive/portable/ordnance
	name = "ordnance data disk"
	desc = "Removable disk used to download ordnance-related tablet apps."
	icon_state = "datadisk5"

/obj/item/computer_hardware/hard_drive/portable/ordnance/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/signal_commander)

/obj/item/computer_hardware/hard_drive/portable/scipaper_program
	name = "NT Frontier data disk"
	desc = "Data disk containing NT Frontier. Simply insert to a computer and open File Manager!"
	icon_state = "datadisk5"

/obj/item/computer_hardware/hard_drive/portable/scipaper_program/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/scipaper_program)

/**
 * Engineering
 */
/obj/item/computer_hardware/hard_drive/portable/engineering
	name = "station engineer data disk"
	desc = "Removable disk used to download engineering-related tablet apps."
	icon_state = "datadisk6"

/obj/item/computer_hardware/hard_drive/portable/engineering/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/supermatter_monitor)

/obj/item/computer_hardware/hard_drive/portable/atmos
	name = "atmospheric technician data disk"
	desc = "Removable disk used to download atmos-related tablet apps."
	icon_state = "datadisk6"


/obj/item/computer_hardware/hard_drive/portable/atmos/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/atmosscan)
	store_file(new /datum/computer_file/program/alarm_monitor)
