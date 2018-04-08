/obj/item/melee/transforming/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
    if(istype(W, /obj/item/device/multitool))
        var/color = input(user, "Select a color!", "Esword color") as null|anything in list("red", "green", "blue", "purple", "rainbow")
		(!color) return
		icon_state = "sword[color]"		
		item_color = "[color]"
