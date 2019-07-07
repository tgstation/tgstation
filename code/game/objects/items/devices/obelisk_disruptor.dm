/obj/item/obelisk_disruptor
	name = "obelisk disruptor"
	desc = "A device that can dismantle abductor obelisks."
	icon = 'icons/obj/device.dmi'
	icon_state = "obelisk_neutralizer"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON

/obj/item/obelisk_disruptor/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	if(istype(target, /obj/machinery/abductor/obelisk))
		var/obj/machinery/abductor/obelisk/A = target
		to_chat(user, "<span class='notice'>You place [src] on the surface of [A] and activate it!</span>")
		A.disintegrate()
		qdel(src)
