/obj/item/rig/module
	name = "RIG module"
	icon_state = "module"
	/// How much space it takes up in the RIG
	var/complexity = 0
	/// Power use when idle
	var/idle_power_use = 0
	/// Power use when used
	var/power_use = 0
	/// Linked RIGsuit
	var/obj/item/rig/control/rig
