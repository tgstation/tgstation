var/list/announcement_systems = list()

/obj/structure/announcement_system
	density = 1
	anchored = 1
	name = "\improper Automated Announcement System"
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	var/obj/item/device/radio/headset/radio

/obj/structure/announcement_system/New()
	announcement_systems += src
	radio = new /obj/item/device/radio/headset/ai(src)

/obj/structure/announcement_system/proc/announce(message, channels)
	for(var/channel in channels)
		world << "Talking into radio. Message: [message]. Channel: [channel]."
		radio.talk_into(src, message, channel, list(SPAN_ROBOT))