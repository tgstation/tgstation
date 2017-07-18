/obj/item/device/radio/beacon
	name = "tracking beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "beacon"
	var/code = "electronic"
	origin_tech = "bluespace=1"
	dog_fashion = null

/obj/item/device/radio/beacon/Initialize()
	. = ..()
	GLOB.teleportbeacons += src

/obj/item/device/radio/beacon/Destroy()
	GLOB.teleportbeacons.Remove(src)
	return ..()

/obj/item/device/radio/beacon/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	return

/obj/item/device/radio/beacon/send_hear()
	return null


/obj/item/device/radio/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if ((usr.canmove && !( usr.restrained() )))
		src.code = t
	if (!( src.code ))
		src.code = "beacon"
	src.add_fingerprint(usr)
	return

/*
//Probably a better way of doing this, I'm lazy.
/obj/item/device/radio/beacon/bacon/proc/digest_delay()
	spawn(600)
		qdel(src)*/ //Bacon beacons are no more rip in peace
