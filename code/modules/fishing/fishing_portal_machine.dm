/obj/machinery/fishing_portal_generator
	name = "fish-porter 3000"
	desc = "Fishing anywhere, anytime... anyway what was I talking about?"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "portal"
	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2
	anchored = FALSE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/fishing_portal_generator

	///The current fishing spot loaded in
	var/datum/component/fishing_spot/active

/obj/machinery/fishing_portal_generator/on_set_panel_open()
	update_appearance()
	return ..()

/obj/machinery/fishing_portal_generator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/fishing_portal_generator/examine(mob/user)
	. = ..()
	. += span_notice("You can unlock further portal settings by completing fish scanning experiments.")

/obj/machinery/fishing_portal_generator/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "syndicate setting loaded")
	playsound(src, SFX_SPARKS, 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/machinery/fishing_portal_generator/interact(mob/user)
	. = ..()
	if(active)
		deactivate()
	else
		select_fish_source(user)

/obj/machinery/fishing_portal_generator/update_overlays()
	. = ..()
	if(panel_open)
		. += "portal_open"
	if(!active)
		return
	. += "portal_on"
	var/datum/fish_source/portal/portal = active.fish_source
	. += portal.overlay_state
	. += emissive_appearance(icon, "portal_emissive", src)

/obj/machinery/fishing_portal_generator/proc/activate(datum/fish_source/selected_source)
	active = AddComponent(/datum/component/fishing_spot, selected_source)
	use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/fishing_portal_generator/proc/deactivate()
	QDEL_NULL(active)
	use_power = IDLE_POWER_USE
	update_icon()

/obj/machinery/fishing_portal_generator/on_set_is_operational(old_value)
	if(old_value)
		deactivate()

///Create a radial menu from a list of available fish sources. If only the default is available, activate it right away.
/obj/machinery/fishing_portal_generator/proc/select_fish_source(mob/user)
	var/datum/fish_source/portal/default = GLOB.preset_fish_sources[/datum/fish_source/portal]
	var/list/available_fish_sources = list(default.radial_name = default)
	if(obj_flags & EMAGGED)
		var/datum/fish_source/portal/syndicate = GLOB.preset_fish_sources[/datum/fish_source/portal/syndicate]
		available_fish_sources[syndicate.radial_name] = syndicate
	for (var/datum/techweb/techweb as anything in SSresearch.techwebs)
		var/get_fish_sources = FALSE
		for(var/obj/machinery/rnd/server/server as anything in techweb.techweb_servers)
			if(!is_valid_z_level(get_turf(server), get_turf(src)))
				continue
			get_fish_sources = TRUE
			break
		if(!get_fish_sources)
			continue
		for(var/experiment_type in typesof(/datum/experiment/scanning/fish))
			var/datum/experiment/scanning/fish/experiment = techweb.completed_experiments[experiment_type]
			if(!experiment)
				continue
			var/datum/fish_source/portal/reward = GLOB.preset_fish_sources[experiment.fish_source_reward]
			available_fish_sources[reward.radial_name] = reward

	if(length(available_fish_sources) == 1)
		activate(default)
		return
	var/list/choices = list()
	for(var/radial_name in available_fish_sources)
		var/datum/fish_source/portal/source = available_fish_sources[radial_name]
		choices[radial_name] = image(icon = 'icons/hud/radial_fishing.dmi', icon_state = source.radial_state)

	var/choice = show_radial_menu(user, src, choices, radius = 38, custom_check = CALLBACK(src, TYPE_PROC_REF(/atom, can_interact), user), tooltips = TRUE)
	if(!choice || !can_interact(user))
		return
	activate(available_fish_sources[choice])

/obj/machinery/fishing_portal_generator/emagged
	obj_flags = parent_type::obj_flags | EMAGGED
	circuit = /obj/item/circuitboard/machine/fishing_portal_generator/emagged
