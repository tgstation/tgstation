/obj/structure/building_hologram
	name = "construction hologram"
	desc = "A construction hologram. Can be destroyed with one hit to cancel the construction and refund the materials."
	max_integrity = 1
	movement_type = FLYING
	anchored = TRUE
	///What path are we building when done?
	var/typepath_to_build
	///What was spent on us?
	var/list/material_price = list()
	///What's my forklift?
	var/obj/vehicle/ridden/forklift/my_forklift
	///How long do we take to build?
	var/build_length = 2 SECONDS
	///Do we want to PlaceOnTop or ChangeTurf when we finish construction, if we're a turf?
	var/turf_place_on_top = FALSE
	///Should we give a refund when we're destroyed?
	var/give_refund = TRUE

/obj/structure/building_hologram/Destroy()
	. = ..()
	if(my_forklift && give_refund)
		var/datum/component/material_container/forklift_container = my_forklift.GetComponent(/datum/component/material_container)
		if(forklift_container.add_materials(material_price))
			playsound(my_forklift, 'sound/effects/cashregister.ogg', 30, TRUE)
			my_forklift.balloon_alert_to_viewers("refunded materials")
		else
			playsound(my_forklift, 'sound/machines/buzz-two.ogg', 30, TRUE)
			my_forklift.balloon_alert_to_viewers("not enough space to refund!")

/obj/structure/building_hologram/proc/setup_icon(set_typepath, direction)
	typepath_to_build = set_typepath
	var/atom/atom_typepath_to_build = set_typepath
	icon = initial(atom_typepath_to_build.icon)
	icon_state = initial(atom_typepath_to_build.icon_state)
	dir = direction
	color = COLOR_BLUE_LIGHT
	alpha = 128

/obj/structure/building_hologram/proc/before_build(datum/forklift_module/forklift_module_ref)
	return

/obj/structure/building_hologram/proc/after_build(atom/built_atom)
	built_atom.dir = dir
	return

/obj/structure/building_hologram/airlock
	///What access should the airlock have?
	var/access_to_require = "None"

/obj/structure/building_hologram/airlock/after_build(atom/built_atom)
	built_atom.dir = dir
	if(access_to_require != "None")
		var/obj/machinery/door/airlock/airlock = built_atom
		airlock.req_access += list(access_to_require)

/obj/structure/building_hologram/airlock/before_build(datum/forklift_module/airlocks/airlock_module)
	access_to_require = airlock_module.selected_access

