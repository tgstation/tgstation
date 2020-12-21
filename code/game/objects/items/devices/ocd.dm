/obj/item/devices/ocd_device
	name = "Occupational Corruption Device"
	desc = "When you need to make the lives of new-hires that much more confusing, think OCD."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"

/obj/item/devices/ocd_device/attack_self(mob/user)
	var/datum/round_event/bureaucratic_error/event = new()
	event.start()
	deadchat_broadcast("<span class='bold'> An OCD has been activated! </span>")
	qdel(src)
