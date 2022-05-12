
// This is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."

/obj/item/modular_computer/tablet/preset/cheap/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer/micro))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/preset/advanced/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/preset/science/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = new
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(hard_drive)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/network_card)
	hard_drive.store_file(new /datum/computer_file/program/signal_commander)

/obj/item/modular_computer/tablet/preset/cargo/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = new
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(hard_drive)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/printer/mini)
	hard_drive.store_file(new /datum/computer_file/program/shipping)
	var/datum/computer_file/program/chatclient/chatprogram
	chatprogram = new
	hard_drive.store_file(chatprogram)
	chatprogram.username = get_cargochat_username()

/obj/item/modular_computer/tablet/preset/cargo/proc/get_cargochat_username()
	return "cargonian_[rand(1,999)]"

/obj/item/modular_computer/tablet/preset/cargo/quartermaster/get_cargochat_username()
	return "quartermaster"

/obj/item/modular_computer/tablet/preset/advanced/atmos/Initialize(mapload) //This will be defunct and will be replaced when NtOS PDAs are done
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	install_component(new /obj/item/computer_hardware/sensorpackage)
	hard_drive.store_file(new /datum/computer_file/program/alarm_monitor)
	hard_drive.store_file(new /datum/computer_file/program/atmosscan)

/obj/item/modular_computer/tablet/preset/advanced/custodial/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	hard_drive.store_file(new /datum/computer_file/program/radar/custodial_locator)

/obj/item/modular_computer/tablet/preset/advanced/curator/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	hard_drive.store_file(new /datum/computer_file/program/newscaster)

/obj/item/modular_computer/tablet/preset/advanced/engineering/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	hard_drive.store_file(new /datum/computer_file/program/alarm_monitor)
	hard_drive.store_file(new /datum/computer_file/program/supermatter_monitor)

/obj/item/modular_computer/tablet/preset/advanced/security/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	hard_drive.store_file(new /datum/computer_file/program/crew_manifest)
	hard_drive.store_file(new /datum/computer_file/program/robocontrol)

/obj/item/modular_computer/tablet/preset/advanced/command/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	install_component(new /obj/item/computer_hardware/sensorpackage)
	install_component(new /obj/item/computer_hardware/card_slot/secondary)
	hard_drive.store_file(new /datum/computer_file/program/budgetorders)
	hard_drive.store_file(new /datum/computer_file/program/science)

/obj/item/modular_computer/tablet/preset/advanced/command/engineering/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
	hard_drive.store_file(new /datum/computer_file/program/alarm_monitor)
	hard_drive.store_file(new /datum/computer_file/program/supermatter_monitor)

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/hard_drive/small/nukeops)
	install_component(new /obj/item/computer_hardware/network_card)

//Borg Built-in tablet
/obj/item/modular_computer/tablet/integrated/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/recharger/cyborg)
	install_component(new /obj/item/computer_hardware/network_card/integrated)
