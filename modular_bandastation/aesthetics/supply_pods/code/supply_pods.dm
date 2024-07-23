/obj/structure/closet/supplypod/teleporter
	style = /datum/pod_style/teleport
	bluespace = TRUE
	explosionSize = list(0,0,0,0)
	fallingSound = null
	landingSound = SFX_PORTAL_CREATED
	openingSound = SFX_PORTAL_ENTER
	leavingSound = SFX_PORTAL_CLOSE
	pod_flags = FIRST_SOUNDS

/obj/structure/closet/supplypod/teleporter/setStyle(chosenStyle)
	. = ..()
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal"

/obj/effect/pod_landingzone/setupSmoke(rotation)
	if(pod.style == /datum/pod_style/teleport)
		return
	. = ..()

/obj/effect/pod_landingzone/drawSmoke()
	if(pod.style == /datum/pod_style/teleport)
		return
	. = ..()

/obj/effect/pod_landingzone/endLaunch()
	if(pod.style == /datum/pod_style/teleport)
		pod.pixel_x = 0
		pod.pixel_z = 0
		pod.transform = matrix()
	. = ..()
