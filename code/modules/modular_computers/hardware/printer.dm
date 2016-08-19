/obj/item/weapon/computer_hardware/printer
	name = "printer"
	desc = "Computer-integrated printer with paper recycling module."
	power_usage = 100
	origin_tech = "programming=2;engineering=2"
	icon_state = "printer"
	w_class = 3
	var/stored_paper = 20
	var/max_paper = 30

/obj/item/weapon/computer_hardware/printer/diagnostics(mob/living/user)
	..()
	user << "Paper level: [stored_paper]/[max_paper]"

/obj/item/weapon/computer_hardware/printer/examine(mob/user)
	..()
	user << "<span class='notice'>Paper level: [stored_paper]/[max_paper]</span>"


/obj/item/weapon/computer_hardware/printer/proc/print_text(var/text_to_print, var/paper_title = "")
	if(!stored_paper)
		return 0
	if(!check_functionality())
		return 0

	var/obj/item/weapon/paper/P = new/obj/item/weapon/paper(get_turf(holder))

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

/obj/item/weapon/computer_hardware/printer/try_insert(obj/item/I, mob/living/user = null)
	if(istype(I, /obj/item/weapon/paper))
		if(user && !user.unEquip(I))
			return 0

		if(stored_paper >= max_paper)
			user << "<span class='warning'>You try to add \the [I] into [src], but it's paper bin is full!</span>"
			return 0

		user << "<span class='notice'>You insert \the [I] into [src]'s paper recycler.</span>"
		qdel(I)
		stored_paper++
		return 1
	return 0

/obj/item/weapon/computer_hardware/printer/mini
	name = "miniprinter"
	desc = "A small printer with paper recycling module."
	power_usage = 50
	icon_state = "printer_mini"
	w_class = 1
	stored_paper = 5
	max_paper = 15