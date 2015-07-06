var/global/list/obj/item/beacon/beacons = list()

/obj/item/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"
	var/frequency = 1459
	origin_tech = "bluespace=1"
	flags = FPRINT

/obj/item/beacon/New()
	..()
	beacons += src

/obj/item/beacon/Destroy()
	..()
	beacons -= src

/obj/item/beacon/attack_self(mob/user as mob)
	..()
	var/newfreq = input(user, "Input a new frequency for the beacon", "Frequency", null) as num
	if(!newfreq)
		return
	frequency = sanitize_frequency(format_frequency(newfreq))

/obj/item/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if ((usr.canmove && !( usr.restrained() )))
		src.code = t
	if (!( src.code ))
		src.code = "beacon"
	src.add_fingerprint(usr)
	return


/obj/item/beacon/bacon/proc/digest_delay()
	sleep(600)
	qdel(src)


// SINGULO BEACON SPAWNER

/obj/item/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"

/obj/item/beacon/syndicate/attack_self(mob/user as mob)
	if(user)
		user << "<span class='notice'>Locked In</span>"
		new /obj/machinery/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
