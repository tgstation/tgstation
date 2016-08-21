// This device is wrapper for actual power cell. I have decided to not use power cells directly as even low-end cells available on station
// have tremendeous capacity in comparsion. Higher tier cells would provide your device with nearly infinite battery life, which is something i want to avoid.
/obj/item/weapon/computer_hardware/battery_module
	name = "standard battery"
	desc = "A standard power cell, commonly seen in high-end portable microcomputers or low-end laptops. It's rating is 750."
	icon_state = "battery_normal"
	critical = 1
	malfunction_probability = 1
	origin_tech = list("powerstorage" = 1, "engineering" = 1)
	var/battery_rating = 750
	var/obj/item/weapon/stock_parts/cell/battery = null

/obj/item/weapon/computer_hardware/battery_module/advanced
	name = "advanced battery"
	desc = "An advanced power cell, often used in most laptops. It is too large to be fitted into smaller devices. It's rating is 1100."
	icon_state = "battery_advanced"
	origin_tech = list("powerstorage" = 2, "engineering" = 2)
	hardware_size = 2
	battery_rating = 1100

/obj/item/weapon/computer_hardware/battery_module/super
	name = "super battery"
	desc = "A very advanced power cell, often used in high-end devices, or as uninterruptable power supply for important consoles or servers. It's rating is 1500."
	icon_state = "battery_super"
	origin_tech = list("powerstorage" = 3, "engineering" = 3)
	hardware_size = 2
	battery_rating = 1500

/obj/item/weapon/computer_hardware/battery_module/ultra
	name = "ultra battery"
	desc = "A very advanced large power cell. It's often used as uninterruptable power supply for critical consoles or servers. It's rating is 2000."
	icon_state = "battery_ultra"
	origin_tech = list("powerstorage" = 5, "engineering" = 4)
	hardware_size = 3
	battery_rating = 2000

/obj/item/weapon/computer_hardware/battery_module/micro
	name = "micro battery"
	desc = "A small power cell, commonly seen in most portable microcomputers. It's rating is 500."
	icon_state = "battery_micro"
	origin_tech = list("powerstorage" = 2, "engineering" = 2)
	battery_rating = 500

/obj/item/weapon/computer_hardware/battery_module/nano
	name = "nano battery"
	desc = "A tiny power cell, commonly seen in low-end portable microcomputers. It's rating is 300."
	icon_state = "battery_nano"
	origin_tech = list("powerstorage" = 1, "engineering" = 1)
	battery_rating = 300

// This is not intended to be obtainable in-game. Intended for adminbus and debugging purposes.
/obj/item/weapon/computer_hardware/battery_module/lambda
	name = "lambda coil"
	desc = "A very complex device that creates it's own bluespace dimension. This dimension may be used to store massive amounts of energy."
	icon_state = "battery_lambda"
	hardware_size = 1
	battery_rating = 1000000

/obj/item/weapon/computer_hardware/battery_module/diagnostics(var/mob/user)
	..()
	user << "Internal battery charge: [battery.charge]/[battery.maxcharge] CU"

/obj/item/weapon/computer_hardware/battery_module/New()
	battery = new/obj/item/weapon/stock_parts/cell(src)
	battery.maxcharge = battery_rating
	battery.charge = battery.maxcharge/2
	..()

/obj/item/weapon/computer_hardware/battery_module/proc/charge_to_full()
	if(battery)
		battery.charge = battery.maxcharge

/obj/item/weapon/computer_hardware/battery_module/try_install_component(mob/living/user, obj/item/modular_computer/M, found = 0)
	if(!user.drop_item(src))
		return
	if(M.battery_module)
		user << "This computer's battery slot is already occupied by \the [M.battery_module]."
		return
	found = 1
	M.battery_module = src
	..(user, M, found)