#define HACK_STEALTH 1	// Reduces network security measures, and prevents security from being triggered by standard commands.
#define HACK_BRUTE 2	// Allows using -b in place of an encryption key to bruteforce and bypass it, though typically triggering security systems by doing so.
#define HACK_PROBE 4	// Lets you see hidden networks and commands, at the cost of triggering security systems more loudly.
#define HACK_BYPASS 8	// Allows you to connect to locked networks. This will trigger security systems quite loudly.

/obj/item/device/hacktool
	name = "net-tool"
	desc = "an advanced tool that can be used to remotely access machine networks."
	icon = 'icons/obj/device.dmi'
	icon_state = "hacktool"
	force = 5
	w_class = 2
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	origin_tech = "magnets=1;programming=3;bluespace=1"
	hitsound = 'sound/weapons/tap.ogg'
	var/datum/network/head	// The network this tool is connected to, if any.
	var/lastfeed			// Only bother storing two 'lines' of feedback.
	var/currfeed
	var/software = 0

/obj/item/device/hacktool/proc/disconnect()
	head = null

/obj/item/device/hacktool/proc/get_feedback(var/F)
	lastfeed = currfeed
	currfeed = F

/obj/item/device/hacktool/proc/connect(var/datum/network/N)
	if(istype(N, /datum/network))
		head = N

/obj/item/device/hacktool/proc/bruteforce(var/datum/network/N) // Will attempt to connect to N after a timer.
	if(!N)
		return
	get_feedback("Activating bruteforce software...")



/obj/item/device/hacktool/upgraded
	name = "hacktool"
	desc = "an upgraded net-tool loaded with improved software and anti-security features."
	icon_state = "hacktool-u"
	origin_tech = "magnets=1;programming=4;bluespace=1;syndicate=1"

/obj/item/device/hacktool/upgraded/integrated
	name = "integrated hacktool"
	desc = "an integrated networking tool that can be used to remotely access machine networks."
	icon_state = "hacktool-i"
