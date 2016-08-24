
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