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
	RegisterSignal(src, COMSIG_COMPONENT_REMOVING, .proc/_component_removal)

/obj/item/implant/uplink/proc/_component_removal(datum/source, datum/component/component)
	/**
	  * Callback indicating the underlying uplink component has been removed
      * generally by admin verbs or var editing. This implant does nothing
      * without an uplink implant, so it'll delete itself.
      */
	if(istype(component, /datum/component/uplink))
		qdel(src)

/obj/item/implanter/uplink
	name = "implanter (uplink)"
	imp_type = /obj/item/implant/uplink

/obj/item/implanter/uplink/precharged
	name = "implanter (precharged uplink)"
	imp_type = /obj/item/implant/uplink/precharged

/obj/item/implant/uplink/precharged
	starting_tc = 10

/obj/item/implant/uplink/starting
	starting_tc = 16  /// default TC count 20, minus cost of implant (4)
