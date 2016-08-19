
/obj/item/modular_computer/tablet/proc/install_programs()
	return

// Available as custom loadout item, this is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/preset/cheap/New()
	. = ..()
	desc = "A low-end tablet often seen among low ranked station personnel."
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	battery_module = new/obj/item/weapon/computer_hardware/battery_module/micro(src)
	battery_module.charge_to_full()
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/micro(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card(src)

// Alternative version, an average one, for higher ranked positions mostly
/obj/item/modular_computer/tablet/preset/advanced/New()
	. = ..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	battery_module = new/obj/item/weapon/computer_hardware/battery_module(src)
	battery_module.charge_to_full()
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/small(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card(src)
	nano_printer = new/obj/item/weapon/computer_hardware/nano_printer(src)
	card_slot = new/obj/item/weapon/computer_hardware/card_slot(src)

//For the network administrator!
/obj/item/modular_computer/tablet/preset/netmin/New()
	. = ..()
	name = "Command Tablet"
	desc = "The special tablet of the network administrator."
	unacidable = 1
	icon_state = "rdtablet"
	icon_state_unpowered = "rdtablet"
	surgeprotected = 1
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	battery_module = new/obj/item/weapon/computer_hardware/battery_module/super(src)
	battery_module.charge_to_full()
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/super(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card/advanced(src)
	nano_printer = new/obj/item/weapon/computer_hardware/nano_printer(src)
	card_slot = new/obj/item/weapon/computer_hardware/card_slot(src)
	install_programs()

//Should give all network-related programs to this.
/obj/item/modular_computer/tablet/preset/netmin/install_programs()
	hard_drive.store_file(new/datum/computer_file/program/nttransfer())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/ntnetmonitor())

