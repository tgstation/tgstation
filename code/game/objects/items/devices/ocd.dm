/obj/item/devices/ocd_device
    //HOW HAVE I SURVIVED THIS LONG WITHOUT BRAINCELLS?!
	name = "Occupational Corruption Device"
	desc = "When you need to make the lives of new-hires that much more confusing, think OCD."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"

/obj/item/devices/ocd_device/attack_self(mob/user)
    var/datum/round_event/bureaucratic_error/event = new(queue_event = FALSE) //God I'm fucking stupid
    event.start() //I'm REALLY fucking stupid
    deadchat_broadcast("<span class='bold'> An OCD has been activated! </span>")
    qdel(src)