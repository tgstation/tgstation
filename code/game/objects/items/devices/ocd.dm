/obj/item/devices/bureaucratic_error_remote
	name = "Occupational Corruption Device"
	desc = "When you need to make the lives of new-hires that much more confusing, think OCD."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"

/obj/item/devices/bureaucratic_error_remote/attack_self(mob/user)
	var/datum/round_event/bureaucratic_error/event = new()
	event.start()
	deadchat_broadcast(span_bold("An Occupational Corruption Device has been activated!"))
	qdel(src)
