/obj/item/melee/transforming/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/color = input("Select a color!", "Esword color") in list("red", "green", "blue", "purple", "rainbow")
		icon_state = "sword[color]"
		item_color = "[color]"
