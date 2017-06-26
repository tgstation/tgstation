
/obj/item/device/modular_computer/tablet/preset/proc/install_programs()
	return

// This is literally the worst possible cheap tablet
/obj/item/device/modular_computer/tablet/preset/cheap
	desc = "A low-end tablet often seen among low ranked station personnel."

/obj/item/device/modular_computer/tablet/preset/cheap/New()
	. = ..()
	install_component(new /obj/item/weapon/computer_hardware/processor_unit/small)
	install_component(new /obj/item/weapon/computer_hardware/battery(src, /obj/item/weapon/stock_parts/cell/computer/micro))
	install_component(new /obj/item/weapon/computer_hardware/hard_drive/small)
	install_component(new /obj/item/weapon/computer_hardware/network_card)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/device/modular_computer/tablet/preset/advanced/New()
	. = ..()
	install_component(new /obj/item/weapon/computer_hardware/processor_unit/small)
	install_component(new /obj/item/weapon/computer_hardware/battery(src, /obj/item/weapon/stock_parts/cell/computer))
	install_component(new /obj/item/weapon/computer_hardware/hard_drive/small)
	install_component(new /obj/item/weapon/computer_hardware/network_card)
	install_component(new /obj/item/weapon/computer_hardware/card_slot)
	install_component(new /obj/item/weapon/computer_hardware/printer/mini)
	install_programs()

/obj/item/device/modular_computer/tablet/preset/advanced/engi/install_programs()
	var/obj/item/weapon/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/supermatter_monitor())

/obj/item/device/modular_computer/tablet/preset/cargo/New()
	. = ..()
	install_component(new /obj/item/weapon/computer_hardware/processor_unit/small)
	install_component(new /obj/item/weapon/computer_hardware/battery(src, /obj/item/weapon/stock_parts/cell/computer))
	install_component(new /obj/item/weapon/computer_hardware/hard_drive/small)
	install_component(new /obj/item/weapon/computer_hardware/network_card)
	install_component(new /obj/item/weapon/computer_hardware/printer/mini)
