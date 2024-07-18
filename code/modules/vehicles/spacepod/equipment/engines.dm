/obj/item/pod_equipment/engine
	slot = POD_SLOT_ENGINE
	/// force we add everytime the vehicle attempts to move in a direction to said direction
	var/force_per_move = 3 NEWTONS //balls value

/obj/item/pod_equipment/engine/on_attach(mob/user)
	. = ..()
	pod.force_per_move += force_per_move

/obj/item/pod_equipment/engine/on_detach(mob/user)
	. = ..()
	pod.force_per_move -= force_per_move
