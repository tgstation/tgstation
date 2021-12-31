/obj/item/anomaly_neutralizer
	name = "anomaly neutralizer"
	desc = "A one-use device capable of instantly neutralizing anomalies."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer2"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	atom_size = ITEM_SIZE_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON

/obj/item/anomaly_neutralizer/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	if(istype(target, /obj/effect/anomaly))
		var/obj/effect/anomaly/A = target
		to_chat(user, span_notice("The circuitry of [src] fries from the strain of neutralizing [A]!"))
		A.anomalyNeutralize()
		qdel(src)
