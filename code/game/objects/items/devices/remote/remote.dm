//Example of implementation of the remote datum
//Nothing is special about these remotes - they just show how you can use the controller

/obj/item/device/remote
	name = "remote control"
	desc = "A remote that uses high-frequency radiation to communicate with connected devices. The label reads \"Do not hold up to face!\"."
	w_class = W_CLASS_SMALL

	icon = 'icons/obj/remote.dmi'
	icon_state = ""

	var/datum/context_click/remote_control/controller

/obj/item/device/remote/examine(mob/user)
	..()
	if(controller)
		for(var/button_id in controller.buttons)
			var/obj/item/button = controller.get_button_by_id(button_id)
			if(button)
				to_chat(user, "[bicon(button)] It has \a [button] attached.")

/obj/item/device/remote/attack_self(mob/user, params)
	if(controller)
		if(controller.action(null, user, params))
			return 1
	return ..()

/obj/item/device/remote/attackby(obj/item/I, mob/user, params)
	if(controller)
		if(controller.action(I, user, params))
			return 1
	return ..()