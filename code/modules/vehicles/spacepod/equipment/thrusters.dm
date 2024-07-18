/obj/item/pod_equipment/thrusters
	slot = POD_SLOT_THRUSTERS
	/// max drift speed we can get via moving intentionally
	var/max_speed = 10 NEWTONS //fucking balls value change this
	/// Force per process run to bring us to a halt
	var/stabilizer_force = 1 NEWTONS

/obj/item/pod_equipment/thrusters/get_overlay()
	return icon_state

/obj/item/pod_equipment/thrusters/on_attach(mob/user)
	. = ..()
	pod.max_speed += max_speed
	pod.stabilizer_force += stabilizer_force

/obj/item/pod_equipment/thrusters/on_detach(mob/user)
	. = ..()
	pod.max_speed -= max_speed
	pod.stabilizer_force -= stabilizer_force
