/obj/item/dropbeacon/sm_beacon
	var/used = FALSE
	name = "supermatter beacon"
	desc = "A beacon for a supermatter shard, when used, it will call in a shard to it's location, make sure to move!"
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	var/droptype = /obj/machinery/power/supermatter_crystal/shard/anchored

/obj/item/dropbeacon/sm_beacon/proc/calldown_pod()
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	new droptype(pod)
	pod.explosionSize = list(0,0,0,0)
	new /obj/effect/pod_landingzone(get_turf(src), pod)
	qdel(src)

/obj/item/dropbeacon/sm_beacon/attack_self(mob/user)
	if(used == FALSE)
		to_chat(user, "<span class='notice'>Pod enroute to the beacon's location, drop it and stand back!</span>")
		addtimer(CALLBACK(src, .proc/calldown_pod), 5 SECONDS)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, TRUE)
		used = TRUE
	else
		return
