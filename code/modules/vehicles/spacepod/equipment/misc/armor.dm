/obj/item/pod_equipment/armor
	slot = POD_SLOT_MISC
	var/integrity_added = 50

/obj/item/pod_equipment/armor/on_attach(mob/user)
	. = ..()
	pod.max_integrity += integrity_added
	pod.atom_integrity += integrity_added

/obj/item/pod_equipment/armor/on_detach(mob/user)
	. = ..()
	pod.max_integrity -= integrity_added
	pod.atom_integrity -= integrity_added
	if(pod.atom_integrity <= 0)
		pod.atom_destruction()
