#define ishacktool(H) (istype(H, /obj/item/device/hacktool/upgraded))

/obj/item/device/hacktool
	name = "net-tool"
	icon = 'icons/obj/device.dmi'
	icon_state = "hacktool"
	force = 5
	w_class = 2
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	origin_tech = "magnets=1;programming=3;bluespace=1"
	hitsound = 'sound/weapons/tap.ogg'
	var/datum/network/head	// The network this tool is connected to, if any.

/obj/item/device/hacktool/proc/disconnect()
	head = null

/obj/item/device/hacktool/proc/feed(var/F)
	return

/obj/item/device/hacktool/proc/connect(var/datum/network/N)
	if(istype(N, /datum/network))
		head = N

/obj/item/device/hacktool/upgraded
	name = "hacktool"
	icon_state = "hacktool-u"
	origin_tech = "magnets=1;programming=4;bluespace=1;syndicate=1"