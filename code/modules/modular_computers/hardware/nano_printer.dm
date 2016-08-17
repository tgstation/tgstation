/obj/item/weapon/computer_hardware/nano_printer
	name = "nano printer"
	desc = "Small integrated printer with paper recycling module."
	power_usage = 50
	origin_tech = list("programming" = 2, "engineering" = 2)
	critical = 0
	icon_state = "printer"
	hardware_size = 1
	var/stored_paper = 5
	var/max_paper = 10

/obj/item/weapon/computer_hardware/nano_printer/diagnostics(var/mob/user)
	..()
	user << "Paper buffer level: [stored_paper]/[max_paper]"

/obj/item/weapon/computer_hardware/nano_printer/proc/print_text(var/text_to_print, var/paper_title = null)
	if(!stored_paper)
		return 0
	if(!enabled)
		return 0
	if(!check_functionality())
		return 0

	var/obj/item/weapon/paper/P = new/obj/item/weapon/paper(get_turf(holder2))

	// Damaged printer causes the resulting paper to be somewhat harder to read.
	if(damage > damage_malfunction)
		P.info = stars(text_to_print, 100-malfunction_probability)
	else
		P.info = text_to_print
	if(paper_title)
		P.name = paper_title
	P.update_icon()
	stored_paper--
	P = null
	return 1

/obj/item/weapon/computer_hardware/nano_printer/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/paper))
		if(stored_paper >= max_paper)
			user << "You try to add \the [W] into [src], but it's paper bin is full"
			return

		user << "You insert \the [W] into [src]."
		qdel(W)
		stored_paper++

/obj/item/weapon/computer_hardware/nano_printer/Destroy()
	if(holder2 && (holder2.nano_printer == src))
		holder2.nano_printer = null
	holder2 = null
	..()

/obj/item/weapon/computer_hardware/nano_printer/try_install_component(mob/living/user, obj/item/modular_computer/M, found = 0)
	if(M.nano_printer)
		user << "This computer's nano printer slot is already occupied by \the [M.nano_printer]."
		return
	found = 1
	M.nano_printer = src
	..(user, M, found)