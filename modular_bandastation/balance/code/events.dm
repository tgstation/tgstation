/datum/round_event_control/operative
	min_players = 30

// Stray pods are DANGEROUS AND SPEEDY
/datum/round_event/stray_cargo/make_pod()
	. = ..()
	var/obj/structure/closet/supplypod/pod = .
	pod.explosionSize = list(1,2,3,3)
	return pod

/datum/round_event/stray_cargo/syndicate/make_pod()
	. = ..()
	var/obj/structure/closet/supplypod/pod = .
	pod.explosionSize = list(1,2,3,3)
	return pod
