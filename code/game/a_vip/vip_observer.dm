
/mob/dead/observer/vip
	name = "vip ghost"


/mob/dead/observer/vip/verb/launchPod()
	var/obj/structure/closet/supplypod/centcompod/pod = new()
	pod.damage = 0
	pod.explosionSize = list(0,0,0,0)
	pod.effectStun = TRUE
	pod.landingDelay = 20
	pod.fallDuration = 100
	var/area/A = locate(/area/centcom/vip) in GLOB.sortedAreas
	for(var/mob/living/M in A)
		M.forceMove(pod)
	if (observetarget)
		new /obj/effect/DPtarget(get_turf(observetarget), pod)
	else
		new /obj/effect/DPtarget(get_turf(src), pod)
	