
/mob/dead/observer/vip
	name = "vip ghost"
	var/mob/living/oldMob

/mob/dead/observer/vip/Initialize(mapload, var/mob/living/M)
	oldMob = M
	verbs += /mob/dead/observer/vip/proc/launch_pod
	..()

/mob/dead/observer/vip/proc/launch_pod()
	set category = "Ghost"
	set name = "Launch Pod"
	set desc= "Do it to em"
	var/obj/structure/closet/supplypod/centcompod/pod = new()
	pod.damage = 0
	pod.explosionSize = list(0,0,0,0)
	pod.effectStun = TRUE
	pod.landingDelay = 20
	pod.fallDuration = 100
	pod.setStyle(STYLE_SEXY)
	var/area/A = locate(/area/centcom/vip) in GLOB.sortedAreas
	for(var/mob/living/M in A)
		M.forceMove(pod)
	var/obj/effect/DPtarget/DP
	if (observetarget)
		DP = new /obj/effect/DPtarget(get_turf(observetarget), pod)
	else
		DP = new /obj/effect/DPtarget(get_turf(src), pod)
	DP.visible_message("<span class='notice'>YOU SEE A BEAUTIFUL COUPLE FLYING IN FROM THE HEAVENS. WHAT MAJESTY! IT PUTS MIKE MURDOCK TO SHAME!</span>")
	src.mind.transfer_to(oldMob)
	qdel(src)
	