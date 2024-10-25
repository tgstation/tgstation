/obj/item/pod_equipment/extra_seats
	name = "pod extra seats kit"
	desc = "Installs two extra seats in a pod, seats folded using highly advanced folding technology, usually reserved for folding clothing for NT Representatives."
	icon_state = "extraseats"
	slot = POD_SLOT_SECONDARY
	/// how many more seats do we grant
	var/occupant_count = 2

/obj/item/pod_equipment/extra_seats/on_attach(mob/user)
	. = ..()
	pod.max_occupants += occupant_count

/obj/item/pod_equipment/extra_seats/on_detach(mob/user)
	. = ..()
	pod.max_occupants = max(initial(pod.max_occupants), pod.max_occupants - occupant_count)
	if(QDELING(src))
		return
	var/list/pod_occupants = pod.occupants.Copy()
	pod_occupants.Cut(1, pod.max_occupants)
	for(var/mob/living/occupant as anything in pod_occupants)
		pod.mob_exit(occupant, randomstep = TRUE)

/obj/item/pod_equipment/extra_seats/get_overlay()
	return "top_cover" //no unique overlay yet

/obj/item/pod_equipment/extra_seats/badmin
	name = "pod bluespace passenger wormhole kit"
	desc = "This pod grants infinite seats in a pod. Bad idea."
	occupant_count = INFINITY
