/obj/item/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/starting_tc = 0

/obj/item/implant/uplink/Initialize(mapload, _owner)
	. = ..()
	AddComponent(/datum/component/uplink, _owner, TRUE, FALSE, null, starting_tc)

/obj/item/implant/uplink/implant(mob/living/target, mob/user, silent = 0)
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	if(hidden_uplink)
		for(var/X in target.implants)
			if(istype(X, type))
				var/obj/item/implant/imp_e = X
				GET_COMPONENT_FROM(their_hidden_uplink, /datum/component/uplink, imp_e)
				if(their_hidden_uplink)
					their_hidden_uplink.telecrystals += hidden_uplink.telecrystals
					qdel(src)
					return TRUE
				else
					qdel(imp_e)	//INFERIOR AND EMPTY!

	if(..())
		if(hidden_uplink)
			hidden_uplink.owner = "[user.key]"
			return TRUE
	return FALSE

/obj/item/implant/uplink/activate()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	if(hidden_uplink)
		hidden_uplink.locked = FALSE
		hidden_uplink.interact(usr)

/obj/item/implanter/uplink
	name = "implanter (uplink)"
	imp_type = /obj/item/implant/uplink

/obj/item/implanter/uplink/precharged
	name = "implanter (precharged uplink)"
	imp_type = /obj/item/implant/uplink/precharged

/obj/item/implant/uplink/precharged
	starting_tc = 10
