//like a stack, but for paper, and less useful except for my code - Comic
//functions pretty much the same as a regular stack, but it can't be added to (to avoid having to store paper details)
//mainly used for the blueprinter, but planning to nanopaper and paper bin functionality
//TODO - Sprite this and add to paper bins
//TODO - Add a ribbon to hair

/obj/item/weapon/paper_pack
	name = "paper pack"
	desc = "A pack of papers, secured by some red ribbon."
	icon = 'icons/obj/paper.dmi'
	icon_state = "pp_ribbon"
	gender = NEUTER
	throwforce = 2
	w_class = 3.0
	throw_range = 5
	throw_speed = 1
	layer = 3.9
	pressure_resistance = 1
	attack_verb = list("slaps", "baps", "whaps")
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	var/amount = 0
	var/maxamount = 20
	var/papertype = /obj/item/weapon/paper
	var/pptype = ""

/obj/item/weapon/paper_pack/New()
	..()
	amount = 20
	pixel_x = rand(-5, 3)
	pixel_y = rand(-3, 5)
	update_icon()

/obj/item/weapon/paper_pack/attack_self()
	if(usr.loc)
		new papertype(usr.loc)
		usepaper(1)

/obj/item/weapon/paper_pack/proc/usepaper(var/sheetcount = 0)
	var/usedpaper = 0 //tracks the actual paper removed
	if(sheetcount && sheetcount <= amount)
		usedpaper = sheetcount
		amount -= sheetcount
	if(sheetcount && sheetcount > amount)
		usedpaper = sheetcount - amount
		amount = 0
	update_icon()
	return usedpaper

/obj/item/weapon/paper_pack/update_icon()
	if(amount)
		if(amount>14)
			icon_state = "[pptype]pp_large"
		else if(amount>8)
			icon_state = "[pptype]pp_medium"
		else if(amount>0)
			icon_state = "[pptype]pp_small"
		name = "[pptype]paper pack"
		desc = "A pack of [pptype]papers, secured by some red ribbon."
	else
		new/obj/item/weapon/ribbon(src.loc)
		qdel(src)

/obj/item/weapon/paper_pack/examine()
	if(amount)
		..()
		usr << "<span class='notice'>There are [amount] sheets in the pack.</span>"
	else
		..()

/obj/item/weapon/paper_pack/verb/ribbontie()
	set name = "Untie Paper Pack"
	set category = "Object"
	set src in usr

	if(amount <= 5) //lag protection and general nonsense avoidance. Could be reduced, but for now just lets you empty it (why you would do this, I don't know)
		for(var/i = 1; i <= amount; i++)
			new papertype(usr.loc)
		usepaper(amount)
		usr << "<span class='notice'>You pick the ribbon knot and drop all the papers.</span>"
	else
		usr << "<span class='warning'>You don't think it would be wise to drop this much paper.</span>"

/obj/item/weapon/paper_pack/nano //now in flavours!
	papertype = /obj/item/weapon/paper/nano
	pptype = "nano"

/obj/item/weapon/ribbon //yay, pointless things
	name = "red ribbon"
	desc = "A red ribbon, normally used to tie things up."
	icon = 'icons/obj/paper.dmi'
	icon_state = "ribbon"
	gender = NEUTER
	slot_flags = SLOT_HEAD
	throwforce = 0
	w_class = 1.0
	throw_range = 4
	throw_speed = 1