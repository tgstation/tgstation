#define HACK_STEALTH 1	// Reduces network security measures, and prevents security from being triggered by standard commands.
#define HACK_BRUTE 2	// Allows using -b in place of an encryption key to bruteforce and bypass it, though typically triggering security systems by doing so. This lets you connect without a password.
#define HACK_PROBE 4	// Lets you see hidden networks and commands, at the cost of potentially triggering security systems more loudly.
#define HACK_BYPASS 8	// Allows you to bypass network locks (not passwords) for a short period of time. This will trigger security systems quite loudly when activated.
#define HACK_SPEED 16	// Reduces the amount of time it takes to complete certain tasks. 1.5x faster.
#define HACK_HYPER 32	// Reduces the amount of time it takes to complete certain tasks even further. 2x faster. This stacks with HACK_SPEED to be 3x faster.
#define HACK_BOOST 64	// Signal boost software, allowing you to connect to devices from further than you normally would be able to. from(prox, area, station) to(area, station, space)
#define HACK_SECURE 128	// Better hacktool security, making it harder for networks to launch a counterattack on the hacktool. Either blocking the counter attack completely, reducing the damage, or slowing it down.

#define HACK_FEEDBACK_CAP 10 // Maximum lines of feedback to be stored.
#define HACK_LOCK_DURATION 300 // How long the hacktool is locked for after a counterattack. Time is in deciseconds.
#define HACK_BYPASS_TIME 10 // length of the 'grace period' in seconds, after performing a security bypass.

/obj/item/device/hacktool
	name = "hacktool"
	desc = "an advanced tool that can be used to remotely access machine networks."
	icon = 'icons/obj/device.dmi'
	icon_state = "hacktool"
	force = 5
	w_class = 2
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	origin_tech = "magnets=1;programming=3;bluespace=1"
	hitsound = 'sound/weapons/tap.ogg'
	var/datum/network/head	// The network this tool is connected to, if any.
	var/datum/stack/feed = null	// Only bother storing ten feedback messages.
	var/software = 0	// Bitflag for installed software upgrades.
	var/bypass = 0	// Whether or not this hacktool is in bypass mode, enabling it to ignore security measures.
	var/locked = 0	// Whether or not this hacktool has been locked by a counterattack by security.

/obj/item/device/hacktool/New()
	feed = new(list(), HACK_FEEDBACK_CAP) // Maximum of 10 lines of feedback.
	..()

/obj/item/device/hacktool/Destroy()
	qdel(feed)
	feed = null
	head = null
	..()

/obj/item/device/hacktool/proc/connect(var/datum/network/N, var/bruteforce = FALSE)
	if(!istype(N, /datum/network))
		return
	if(N == head)
		return
	head = N

/obj/item/device/hacktool/proc/disconnect()
	head = null

/obj/item/device/hacktool/proc/add_feedback(var/F) // Push a line of feedback to the hacktool. Getting rid of the oldest feedback.
	while(feed.stack.len >= feed.max_elements)
		feed.Pop()
	feed.Push(F)

/obj/item/device/hacktool/proc/bruteforce(var/datum/network/N, var/operation = "connect", var/hacktime = 30) // Will attempt to connect to N after a timer.
	if(!software & HACK_BRUTE)
		return
	add_feedback("Activating bruteforce software...")
	if(software & HACK_BOOST)
		hacktime *= 0.667
	if(software & HACK_HYPER)
		hacktime *= 0.5
	addtimer(src, operation, round(hacktime, 1), 1, N)

/obj/item/device/hacktool/proc/bypass(var/datum/network/N, var/hacktime = 30) // Will enable bypass mode, triggering network security if specified.
	if(!software & HACK_BYPASS)
		return
	add_feedback("Activating bypass software...")
	if(software & HACK_BOOST)
		hacktime *= 0.667
	if(software & HACK_HYPER)
		hacktime *= 0.5
	if(N && N != head)
		N.execute("security -bypass", src)
	if(head)
		head.execute("security -bypass", src)
	addtimer(src, "start_bypass", hacktime, 1)

/obj/item/device/hacktool/proc/start_bypass(var/duration = HACK_BYPASS_TIME)
	add_feedback("Bypass software activated. [duration] seconds before network lockout.")
	addtimer(src, "end_bypass", duration*10, 1)

/obj/item/device/hacktool/proc/end_bypass()
	if(bypass)
		bypass = 0
	add_feedback("Bypass software disabled.")

/obj/item/device/hacktool/proc/lock(var/duration = HACK_LOCK_DURATION)
	if(!duration)
		return
	if(software & HACK_SECURE)
		duration = round(duration*0.5, 1)
	locked++
	addtimer(src, "unlock", duration, 1)

/obj/item/device/hacktool/proc/unlock()
	if(locked)
		locked-- // If multiple counterattacks and locks are made, this will only remove one of them.

/obj/item/device/hacktool/cyborg
	name = "integrated hacktool"
	desc = "an integrated version of the hacktool loaded with improved software and anti-security features."
	icon = 'icons/obj/items_cyborg.dmi'
	origin_tech = "magnets=1;programming=4;bluespace=1;syndicate=1"


