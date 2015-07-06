/obj/item/device/beacon
	name = "tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	var/code = ""
	origin_tech = "bluespace=1"

/obj/item/device/beacon/New()
	..()
	beacons += src
	if (!code)
		code = name


/obj/item/device/beacon/Destroy()
	beacons -= src
	..()


/obj/item/device/beacon/attack_self(mob/user)
	alter_name(user)


/obj/item/device/beacon/proc/alter_name(mob/user)
	if(user.stat || !user.canmove || user.restrained() || !ishuman(user))
		return
	var/new_name = stripped_input(user, "What would you like to label the beacon?", "Beacon renaming", null, MAX_NAME_LEN)
	if(user.stat || !user.canmove || user.restrained() || !ishuman(user)) //Check twice to avoid TOCTOU
		return
	code = new_name
	if (!(code))
		code = "beacon"
	src.add_fingerprint(user)
	return

/*
/obj/item/device/radio/beacon/bacon //Probably a better way of doing this, I'm lazy.
	proc/digest_delay()
		spawn(600)
			qdel(src)*/ //Bacon beacons are no more rip in peace