/obj/item/effect_granter/washing_machine
	name = "Washing Machine Entrance"
	icon_state = "washing_machine"


/obj/item/effect_granter/washing_machine/grant_effect(mob/living/carbon/granter)
	var/obj/structure/closet/supplypod/washer_pod/washer_pod = new(null)
	washer_pod.explosionSize = list(0,0,0,0)
	washer_pod.bluespace = TRUE

	var/turf/granter_turf = get_turf(granter)
	granter.forceMove(washer_pod)
	new /obj/effect/pod_landingzone(granter_turf, washer_pod)
	. = ..()
