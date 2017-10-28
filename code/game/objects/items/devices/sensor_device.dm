/obj/item/device/sensor_device
	name = "handheld crew monitor" //Thanks to Gun Hog for the name!
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "programming=3;materials=3;magnets=3"

/obj/item/device/sensor_device/attack_self(mob/user)
	GLOB.crewmonitor.show(user) //Proc already exists, just had to call it
