/obj/item/melee/transforming/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/color = input(user, "Select a color!", "Esword color") as null|anything in list("red", "green", "blue", "purple", "rainbow")
		if(!color)
			return
		item_color = color
		
		if(active)
			icon_state = "sword[color]"
			user.update_inv_hands()
	else
		..()
