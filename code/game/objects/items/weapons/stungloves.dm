/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/C = W
		if(!wired)
			if(C.amount >= 2)
				C.amount -= 2
				wired = 1
				user << "You wrap some wires around [src]."
				update_icon()
			else
				user << "There is not enough wire to cover [src]."
		else
			user << "[src] are already wired."

	else if(istype(W, /obj/item/weapon/cell))
		if(!wired)
			user << "[src] need to be wired first."
		else if(!cell)
			user.drop_item()
			W.loc = src
			cell = W
			user << "You attach a cell to [src]."
			update_icon()
		else
			user << "[src] already have a cell."

	else if(istype(W, /obj/item/weapon/wirecutters))
		if(cell)
			user << "You cut the cell away from [src]."
			cell.loc = get_turf(src.loc)
			cell = 0
			update_icon()
			return
		if(wired) //wires disappear into the void because fuck that shit
			user << "You cut the wires away from [src]."
			wired = 0
			update_icon()
		..()
	return

/obj/item/clothing/gloves/update_icon() //beep beep this'll probably break everything
	..()
	overlays = null
	if(wired)
		overlays += "gloves_wire"
	if(cell)
		overlays += "gloves_cell"