/obj/item/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "wire1"
	item_flags = NOBLUDGEON
	///The current machine being hacked by the pAI cable.
	var/obj/machinery/hacking_machine

/obj/item/pai_cable/Destroy()
	hacking_machine = null
	return ..()

/obj/item/pai_cable/proc/plugin(obj/machinery/M, mob/living/user)
	if(!user.transferItemToLoc(src, M))
		return
	user.visible_message(span_notice("[user] inserts [src] into a data port on [M]."), span_notice("You insert [src] into a data port on [M]."), span_hear("You hear the satisfying click of a wire jack fastening into place."))
	hacking_machine = M
