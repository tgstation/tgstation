/datum/design/pod_gun_taser
	name = "Spacepod Equipment (Taser)"
	desc = "Allows for the construction of a spacepod mounted taser."
	id = "podgun_taser"
	build_type = PODFAB
	req_tech = list("materials" = 2, "combat" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/taser
	category = "Pod_Weaponry"
	materials = list(MAT_IRON = 15000)

/datum/design/pod_gun_btaser
	name = "Spacepod Equipment (Burst Taser)"
	desc = "Allows for the construction of a spacepod mounted taser. This is the burst-fire model."
	id = "podgun_btaser"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3)
	build_path = /obj/item/device/spacepod_equipment/weaponry/taser/burst
	category = "Pod_Weaponry"
	materials = list(MAT_IRON = 15000)

/datum/design/pod_gun_laser
	name = "Spacepod Equipment (Laser)"
	desc = "Allows for the construction of a spacepod mounted laser."
	id = "podgun_laser"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3, "plasmatech" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/laser
	category = "Pod_Weaponry"
	materials = list(MAT_IRON = 15000)
	locked = 1
