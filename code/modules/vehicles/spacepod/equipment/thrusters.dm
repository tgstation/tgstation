/obj/item/pod_equipment/thrusters
	slot = POD_SLOT_THRUSTERS
	/// max drift speed we can get via moving intentionally
	var/max_speed = 0
	/// Force per process run to bring us to a halt
	var/stabilizer_force = 0

/obj/item/pod_equipment/thrusters/examine(mob/user)
	. = ..()
	. += span_notice("A label says that the engine allows a maximum speed of up to <b>[max_speed]</b> newtons, and may exert <b>[stabilizer_force]</b> for stabilization.")

/obj/item/pod_equipment/thrusters/get_overlay()
	return "thrusters"

/obj/item/pod_equipment/thrusters/on_attach(mob/user)
	. = ..()
	pod.max_speed += max_speed
	pod.stabilizer_force += stabilizer_force

/obj/item/pod_equipment/thrusters/on_detach(mob/user)
	. = ..()
	pod.max_speed -= max_speed
	pod.stabilizer_force -= stabilizer_force

/obj/item/pod_equipment/thrusters/default
	name = "pod ion thruster array"
	desc = "An array of thruster for pods, manufactured by NT. This one is the standard model."
	max_speed = 10 NEWTONS
	stabilizer_force = 0.75 NEWTONS

/obj/item/pod_equipment/thrusters/fast
	name = "pod cesium-ion thruster array"
	desc = "A variant of the standard NT thruster array, for greater speeds."
	max_speed = 15 NEWTONS
	stabilizer_force = 1 NEWTONS

/obj/item/pod_equipment/thrusters/blazer
	name = "overtuned pod thruster array"
	desc = "An array of... wait. This thing seems to be a haphazardly modified thruster array for pods. Notably, stabilizers have been removed to make way. Not safe, but its for science."
	max_speed = 25 NEWTONS
	stabilizer_force = 0 // no stabilizers

/obj/item/pod_equipment/thrusters/badmin // may or may not have severe perf consequences
	name = "POD !!!FUN!!! ARRAY"
	desc = "if youre seeing this its probably not for you"
	max_speed = INFINITY
	stabilizer_force = INFINITY
