/obj/item/pod_equipment/armor
	name = "light pod armor plating"
	desc = "Some armor for a pod. Makes your pod slightly sturdier and heavier. Not to be confused with hull kits."
	icon_state = "lgtplating"
	slot = POD_SLOT_MISC
	allow_dupes = TRUE
	/// integrity added to pod
	var/integrity_added = 50
	/// inertia force weight added to pod
	var/weight_added = 0.2

/obj/item/pod_equipment/armor/on_attach(mob/user)
	. = ..()
	var/percentage = pod.get_integrity_percentage()
	pod.max_integrity += integrity_added
	pod.update_integrity(pod.max_integrity * percentage)
	pod.inertia_force_weight += weight_added

/obj/item/pod_equipment/armor/on_detach(mob/user)
	. = ..()
	var/percentage = pod.get_integrity_percentage()
	pod.max_integrity -= integrity_added
	pod.update_integrity(pod.max_integrity * percentage)
	pod.inertia_force_weight -= weight_added
	if(pod.get_integrity() <= 0)
		pod.atom_destruction()
