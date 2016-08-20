// These are basically USB data sticks and may be used to transfer files between devices
/obj/item/weapon/computer_hardware/hard_drive/portable/
	name = "basic data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. It's capacity is 16 GQ."
	power_usage = 10
	icon_state = "flashdrive_basic"
	hardware_size = 1
	max_capacity = 16
	origin_tech = list("programming" = 1)

/obj/item/weapon/computer_hardware/hard_drive/portable/advanced
	name = "advanced data crystal"
	desc = "Small crystal with imprinted high-density photonic circuits that can be used to store data. It's capacity is 64 GQ."
	power_usage = 20
	icon_state = "flashdrive_advanced"
	hardware_size = 1
	max_capacity = 64
	origin_tech = list("programming" = 2)

/obj/item/weapon/computer_hardware/hard_drive/portable/super
	name = "super data crystal"
	desc = "Small crystal with imprinted ultra-density photonic circuits that can be used to store data. It's capacity is 256 GQ."
	power_usage = 40
	icon_state = "flashdrive_super"
	hardware_size = 1
	max_capacity = 256
	origin_tech = list("programming" = 4)

/obj/item/weapon/computer_hardware/hard_drive/portable/New()
	..()
	stored_files = list()
	recalculate_size()


/obj/item/weapon/computer_hardware/hard_drive/portable/try_install_component(mob/living/user, obj/item/modular_computer/M, found = 0)
	if(!user.drop_item(src))
		return
	if(M.portable_drive)
		user << "This computer's portable drive slot is already occupied by \the [M.portable_drive]."
		return
	found = 1
	M.portable_drive = src
	..(user, M, found)