//gangtool device
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does if you don't know how to operate it."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	origin_tech = "programming=5;bluespace=2;syndicate=5"
	var/datum/gang/gang //Which gang uses this?
	var/free_pen = 0
