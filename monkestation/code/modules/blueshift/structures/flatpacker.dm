/obj/machinery/rnd/production/colony_lathe
	name = "rapid construction fabricator"
	desc = "These bad boys are seen just about anywhere someone would want or need to build fast, damn the consequences. \
		That tends to be colonies, especially on dangerous worlds, where the influences of this one machine can be seen \
		in every bit of architecture."
	icon = 'monkestation/code/modules/blueshift/icons/machines.dmi'
	icon_state = "colony_lathe"
	base_icon_state = "colony_lathe"
	production_animation = null
	circuit = null
	production_animation = "colony_lathe_n"
	light_color = LIGHT_COLOR_BRIGHT_YELLOW
	light_power = 5
	allowed_buildtypes = COLONY_FABRICATOR
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine
	/// The sound loop played while the fabricator is making something
	var/datum/looping_sound/colony_fabricator_running/soundloop

/obj/machinery/rnd/production/colony_lathe/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 5 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	// We don't get new designs but can't print stuff if something's not researched, so we use the web that has everything researched
	stored_research = locate(/datum/techweb/admin) in SSresearch.techwebs
	soundloop = new(src, FALSE)
	if(!mapload)
		flick("colony_lathe_deploy", src) // Sick ass deployment animation

/obj/machinery/rnd/production/colony_lathe/Destroy()
	QDEL_NULL(soundloop)
	return ..()

// previously NO_DECONSTRUCTION
/obj/machinery/rnd/production/colony_lathe/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/rnd/production/colony_lathe/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/rnd/production/colony_lathe/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/rnd/production/colony_lathe/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if (. && action == "build")
		soundloop.start()
		set_light(l_outer_range = 1.5)
		icon_state = "colony_lathe_working"
		update_appearance()

/obj/machinery/rnd/production/colony_lathe/finalize_build()
	. = ..()
	soundloop.stop()
	set_light(l_outer_range = 0)
	icon_state = base_icon_state
	update_appearance()
	flick("colony_lathe_finish_print", src)

// We take from all nodes even unresearched ones
/obj/machinery/rnd/production/colony_lathe/update_designs()
	var/previous_design_count = cached_designs.len

	cached_designs.Cut()

	for(var/design_id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_designs[design_id]

		if((isnull(allowed_department_flags) || (design.departmental_flags & allowed_department_flags)) && (design.build_type & allowed_buildtypes))
			cached_designs |= design

	var/design_delta = cached_designs.len - previous_design_count

	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

// Item for carrying the lathe around and building it

/obj/item/flatpacked_machine
	name = "flat-packed rapid construction fabricator"
	icon = 'monkestation/code/modules/blueshift/icons/packed_machines.dmi'
	icon_state = "colony_lathe_packed"
	w_class = WEIGHT_CLASS_BULKY
	/// What structure is created by this item.
	var/obj/type_to_deploy = /obj/machinery/rnd/production/colony_lathe
	/// How long it takes to create the structure in question.
	var/deploy_time = 4 SECONDS
	var/skips_deployable_component = FALSE

/obj/item/flatpacked_machine/Initialize(mapload)
	. = ..()
	if(!skips_deployable_component)
		desc = initial(type_to_deploy.desc)
		give_deployable_component()
		give_manufacturer_examine()

/// Adds the deployable component, so that it can be overridden in case that's wanted
/obj/item/flatpacked_machine/proc/give_deployable_component()
	AddComponent(/datum/component/deployable, deploy_time, type_to_deploy)

/// Adds the manufacturer examine element to the flatpack machine, but can be overridden in the future
/obj/item/flatpacked_machine/proc/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/item/borg/apparatus/sheet_manipulator/Initialize(mapload)
	. = ..()
	storable += /obj/item/flatpacked_machine

/obj/item/borg/apparatus/circuit/Initialize(mapload)
	. = ..()
	storable += /obj/item/flatpacked_machine


/obj/item/flatpacked_machine/generic
	name = "generic flat-packed machine"
	skips_deployable_component = TRUE

/obj/item/flatpacked_machine/generic/proc/after_set()
	name = "flat-packed [initial(type_to_deploy.name)]"
	desc = initial(type_to_deploy.desc)
	give_deployable_component()
