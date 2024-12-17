/obj/machinery/rnd/production/damage_control_fab
	name = "emergency repair lathe"
	desc = "A small little machine with no material insertion ports and no power connectors. \
		Able to use the small trickle of power an internal source creates to slowly create \
		essential damage control equipment."
	icon = 'modular_doppler/damage_control/icons/machines.dmi'
	icon_state = "damage_fab"
	base_icon_state = "damage_fab"
	circuit = null
	production_animation = "damage_fab_working"
	light_color = LIGHT_COLOR_INTENSE_RED
	light_power = 5
	allowed_buildtypes = DAMAGE_FAB
	use_power = FALSE
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine/damage_lathe

/obj/machinery/rnd/production/damage_control_fab/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 5 SECONDS)
	stored_research = locate(/datum/techweb/admin) in SSresearch.techwebs
	if(!mapload)
		flick("damage_fab_deploy", src)

// formerly NO_DECONSTRUCTION
/obj/machinery/rnd/production/damage_control_fab/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/rnd/production/damage_control_fab/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/rnd/production/damage_control_fab/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/rnd/production/damage_control_fab/start_printing_visuals()
	set_light(l_range = 1.5)
	icon_state = "colony_lathe_working"
	update_appearance()

/obj/machinery/rnd/production/damage_control_fab/finalize_build()
	. = ..()
	set_light(l_range = 0)
	icon_state = base_icon_state
	update_appearance()
	flick("colony_lathe_finish_print", src)

/obj/machinery/rnd/production/damage_control_fab/build_efficiency()
	return 1

// We take from all nodes even unresearched ones
/obj/machinery/rnd/production/damage_control_fab/update_designs()
	var/previous_design_count = cached_designs.len

	cached_designs.Cut()

	for(var/design_id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_designs[design_id]

		if((isnull(allowed_department_flags) || (design.departmental_flags & allowed_department_flags)) && (design.build_type & allowed_buildtypes))
			cached_designs |= design

	var/design_delta = cached_designs.len - previous_design_count

	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/beep/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

// Item for carrying the lathe around and building it

/obj/item/flatpacked_machine/damage_lathe
	name = "packed emergency repair lathe"
	/// For all flatpacked machines, set the desc to the type_to_deploy followed by ::desc to reuse the type_to_deploy's description
	desc = /obj/machinery/rnd/production/damage_control_fab::desc
	icon = 'modular_doppler/damage_control/icons/packed_machines.dmi'
	icon_state = "damage_lathe_packed"
	w_class = WEIGHT_CLASS_BULKY
	type_to_deploy = /obj/machinery/rnd/production/damage_control_fab
	deploy_time = 4 SECONDS

/obj/item/flatpacked_machine/damage_lathe/give_manufacturer_examine()
	return
