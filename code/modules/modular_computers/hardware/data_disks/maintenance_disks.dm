/obj/item/computer_hardware/hard_drive/portable/maintenance
	name = "maintenance data disk"
	desc = "A data disk forgotten in the depths of maintenance, might have some useful program on it."

/// Medical health analyzer app
/obj/item/computer_hardware/hard_drive/portable/maintenance/scanner/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/maintenance/phys_scanner(src))

/obj/item/computer_hardware/hard_drive/portable/maintenance/camera/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/maintenance/camera(src))
