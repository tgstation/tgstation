/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user)
	if(istype(src, /obj/item/clothing/gloves/boxing))	//quick fix for stunglove overlay not working nicely with boxing gloves.
		user << "<span class='notice'>That won't work.</span>"	//i'm not putting my lips on that!
		..()
		return
	if(istype(W, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/C = W
		if(!wired)
			if(C.amount >= 2)
				C.amount -= 2
				wired = 1
				siemens_coefficient = 1
				user << "<span class='notice'>You wrap some wires around [src].</span>"
				update_icon()
			else
				user << "<span class='notice'>There is not enough wire to cover [src].</span>"
		else
			user << "<span class='notice'>[src] are already wired.</span>"

	else if(istype(W, /obj/item/weapon/cell))
		if(!wired)
			user << "<span class='notice'>[src] need to be wired first.</span>"
		else if(!cell)
			user.drop_item()
			W.loc = src
			cell = W
			user << "<span class='notice'>You attach a cell to [src].</span>"
			update_icon()
		else
			user << "<span class='notice'>[src] already have a cell.</span>"

	else if(istype(W, /obj/item/weapon/wirecutters))
		if(cell)
			cell.updateicon()
			cell.loc = get_turf(src.loc)
			cell = null
			user << "<span class='notice'>You cut the cell away from [src].</span>"
			update_icon()
			return
		if(wired) //wires disappear into the void because fuck that shit
			wired = 0
			siemens_coefficient = initial(siemens_coefficient)
			user << "<span class='notice'>You cut the wires away from [src].</span>"
			update_icon()
		..()
	return

/obj/item/clothing/gloves/update_icon()
	..()
	overlays = null
	if(wired)
		overlays += "gloves_wire"
	if(cell)
		overlays += "gloves_cell"