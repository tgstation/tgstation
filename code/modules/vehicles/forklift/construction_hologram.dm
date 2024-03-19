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
	/// Have we begun building?
	var/building = FALSE
	/// Our building effect once construction begins.
	var/obj/effect/constructing_effect/construction_effect
	/// Our construction beam.
	var/datum/beam/construction_beam
	/// What effect to feed to the RCD hologram.
	var/rcd_effect_status = RCD_STRUCTURE
	/// Is the beam reversed?
	var/reverse_beam = FALSE

/obj/structure/building_hologram/proc/begin_building()
	building = TRUE
	construction_effect = new(get_turf(src), build_length, rcd_effect_status, null)
	if(!reverse_beam)
		construction_beam = my_forklift.Beam(src, icon_state = "rped_upgrade", time = build_length)
	else
		construction_beam = Beam(my_forklift, icon_state = "rped_upgrade", time = build_length)
	addtimer(CALLBACK(src, PROC_REF(finish_construction)), build_length)

/obj/structure/building_hologram/proc/finish_construction()
	if(!construction_effect)
		building = FALSE
		return // our build attempt was interrupted
	if(ispath(typepath_to_build, /turf))
		var/turf/turf_to_replace = get_turf(src)
		if(!turf_place_on_top)
			turf_to_replace.ChangeTurf(typepath_to_build)
		else
			turf_to_replace.place_on_top(typepath_to_build)
	else
		var/atom/built_atom = new typepath_to_build(get_turf(src))
		after_build(built_atom)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	give_refund = FALSE
	construction_effect.end_animation()
	qdel(src)

/obj/structure/building_hologram/Destroy()
	. = ..()
	qdel(construction_effect)
	qdel(construction_beam)
	if(my_forklift)
		LAZYREMOVE(my_forklift.holograms, src)
		if(give_refund)
			var/datum/component/material_container/forklift_container = my_forklift.GetComponent(/datum/component/material_container)
			if(forklift_container.add_materials(material_price))
				playsound(my_forklift, 'sound/effects/cashregister.ogg', 30, TRUE)
				my_forklift.balloon_alert_to_viewers("refunded materials")
			else
				playsound(my_forklift, 'sound/machines/buzz-two.ogg', 30, TRUE)
				my_forklift.balloon_alert_to_viewers("not enough space to refund!")

/obj/structure/building_hologram/deconstruction
	name = "deconstruction hologram"
	desc = "Indicates a Forklift is trying to deconstruct this. Follow the beam for the source!"
	reverse_beam = TRUE
	rcd_effect_status = RCD_DECONSTRUCT
	icon = 'icons/effects/buymode.dmi'
	icon_state = "deconstruction_warning"
	give_refund = FALSE
	var/atom/targeted_atom

/obj/structure/building_hologram/deconstruction/finish_construction()
	if(!construction_effect)
		building = FALSE
		return // our deconstruction attempt was interrupted
	if(istype(targeted_atom, /turf))
		var/turf/turf_to_replace = get_turf(src)
		turf_to_replace.ScrapeAway()
	else
		qdel(targeted_atom)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	give_refund = TRUE
	construction_effect.end_animation()
	qdel(src)


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

