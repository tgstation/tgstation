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

///////////// Internal tool used by gang regulars ///////////

/obj/item/device/gangtool/soldier

/datum/action/innate/gang
	background_icon_state = "bg_spell"

/datum/action/innate/gang/IsAvailable()
	if(!owner.mind || !owner.mind in SSticker.mode.get_all_gangsters())
		return 0
	return ..()

/datum/action/innate/gang/tool
	name = "Personal Gang Tool"
	desc = "An implanted gang tool that lets you purchase gear"
	background_icon_state = "bg_mime"
	button_icon_state = "bolt_action"
	var/obj/item/device/gangtool/soldier/GT

/datum/action/innate/gang/tool/Grant(mob/user, obj/reg, datum/gang/G)
	. = ..()
	GT = reg
	button.color = G.color

/datum/action/innate/gang/tool/Activate()
	GT.attack_self(owner)
