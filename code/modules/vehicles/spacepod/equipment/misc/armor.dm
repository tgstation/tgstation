/obj/item/pod_equipment/armor
	slot = POD_SLOT_MISC
	var/integrity_added = 50

/obj/item/pod_equipment/armor/on_attach(mob/user)
	. = ..()
	var/percentage = pod.get_integrity_percentage()
	pod.max_integrity += integrity_added
	pod.update_integrity(pod.max_integrity / 100 * percentage)

/obj/item/pod_equipment/armor/on_detach(mob/user)
	. = ..()
	var/percentage = pod.get_integrity_percentage()
	pod.max_integrity -= integrity_added
	pod.update_integrity(pod.max_integrity / 100 * percentage)
	if(pod.atom_integrity <= 0)
		pod.atom_destruction()
