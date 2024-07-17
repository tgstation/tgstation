/obj/item/pod_equipment
	// the pod we are attached to
	var/obj/vehicle/sealed/space_pod/pod
	// the slot we go in
	var/slot

/obj/item/pod_equipment/examine(mob/user)
	. = ..()
	. += span_notice("This goes into the [slot].")

/obj/item/pod_equipment/Destroy(force)
	. = ..()
	on_detach()
	pod = null

/// Optional, return an actual overlay or an icon state name to show when attached.
/obj/item/pod_equipment/proc/get_overlay()

/obj/item/pod_equipment/proc/on_attach(mob/user)

/obj/item/pod_equipment/proc/on_detach(mob/user)


// todo
// also potentially attaching code could be on the pod equipment itself

// primary and equipment slot items have no reason to have a shared parent type aside from /obj/item/pod_equipment, just set the slot
