/obj/item/weapon/computer_hardware/tesla_link
	name = "tesla link"
	desc = "An advanced tesla link that wirelessly recharges connected device from nearby area power controller."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 2		// Can't be installed into tablets
	origin_tech = list("programming" = 2, "powerstorage" = 3, "engineering" = 2)
	var/obj/machinery/modular_computer/holder

/obj/item/weapon/computer_hardware/tesla_link/New(var/obj/L)
	if(istype(L, /obj/machinery/modular_computer))
		holder = L
		return
	..(L)

/obj/item/weapon/computer_hardware/tesla_link/Destroy()
	if(holder && (holder.tesla_link == src))
		holder.tesla_link = null
	..()

/obj/item/weapon/computer_hardware/tesla_link/try_install_component(mob/living/user, obj/item/modular_computer/M, found = 0)
	if(istype(M, /obj/item/modular_computer/processor))
		var/obj/item/modular_computer/processor/P = M
		if(P.machinery_computer.tesla_link)
			user << "This computer's tesla link slot is already occupied by \the [P.machinery_computer.tesla_link]."
			return
		holder = P.machinery_computer
		P.machinery_computer.tesla_link = src
		found = 1
	..(user, M, found)