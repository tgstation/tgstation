/datum/storage/drone
	max_total_storage = 40
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 10
	do_rustle = FALSE

/datum/storage/drone/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	var/static/list/drone_builtins = list(
		/obj/item/crowbar/drone,
		/obj/item/screwdriver/drone,
		/obj/item/wrench/drone,
		/obj/item/weldingtool/drone,
		/obj/item/wirecutters/drone,
		/obj/item/multitool/drone,
		/obj/item/pipe_dispenser/drone,
		/obj/item/t_scanner/drone,
		/obj/item/analyzer/drone,
		/obj/item/soap/drone,
	)

	set_holdable(drone_builtins)

/datum/storage/drone/dump_content_at(atom/dest_object, dump_loc, mob/user)
	return //no dumping of contents allowed
