/obj/item/device/sensor_device
	name = "handheld crew monitor" //Thanks to Gun Hog for the name!
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = 2.0
	slot_flags = SLOT_BELT
	origin_tech = "programming=3;materials=3;magnets=3"

/obj/item/device/sensor_device/attack_self(mob/user as mob)
	crewmonitor(user,src) //Proc already exists, just had to call it
