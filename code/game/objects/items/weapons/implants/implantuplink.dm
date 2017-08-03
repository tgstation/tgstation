/obj/item/weapon/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"
	var/starting_tc = 0

/obj/item/weapon/implant/uplink/Initialize()
	. = ..()
	AddComponent(/datum/component/uplink, null, starting_tc)

/obj/item/weapon/implant/uplink/implant(mob/living/target, mob/user, silent = 0)
	for(var/X in target.implants)
		GET_COMPONENT_FROM(uplink, /datum/component/uplink, X)
		if(uplink)
			var/datum/D = X
			D.TakeComponent(GetComponent(/datum/component/uplink))
			qdel(src)
			return TRUE

	if(..())
		GET_COMPONENT(uplink, /datum/component/uplink)
		uplink.owner = user.key
		return 1
	return 0

/obj/item/weapon/implant/uplink/activate()
	GET_COMPONENT(uplink, /datum/component/uplink)
	uplink.interact(usr)

/obj/item/weapon/implanter/uplink
	name = "implanter (uplink)"
	imp_type = /obj/item/weapon/implant/uplink

/obj/item/weapon/implanter/uplink/precharged
	name = "implanter (precharged uplink)"
	imp_type = /obj/item/weapon/implant/uplink/precharged

/obj/item/weapon/implant/uplink/precharged
	starting_tc = 10
