//Toggle implants. Implants you can toggle on and off.

/obj/item/weapon/implant/toggle
	var/on = 0

/obj/item/weapon/implant/toggle/activate()
	on = !on
	icon_state = "[initial(icon_state)]-[on]"


/obj/item/weapon/implant/toggle/weldingshield
	name = "welding lense augment"
	desc = "Allows for convenient eye protection when welding."
	icon_state = "weldingshield"
	flash_protect = 2
	tint = 2
	on = 1

/obj/item/weapon/implant/toggle/weldingshield/activate()
	..()
	if(on)
		flash_protect = initial(flash_protect)
		tint = initial(tint)
	else
		flash_protect = 0
		tint = 0

/obj/item/weapon/implant/toggle/flashlight
	name = "flashlight augment"
	desc = "Allows for convenient illumination."
	icon_state = "flashlight"
	var/brightness_on = 4

/obj/item/weapon/implant/toggle/flashlight/activate()
	..()
	if(on)
		usr.AddLuminosity(brightness_on)
	else
		usr.AddLuminosity(-brightness_on)