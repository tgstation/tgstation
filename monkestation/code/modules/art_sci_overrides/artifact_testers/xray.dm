/obj/machinery/artifact_xray
	name = "artifact x-ray machine"
	desc = "An x-ray machine, used to scan artifacts for what they do and research them."
	icon = 'icons/obj/machines/artifact_machines.dmi'
	icon_state = "xray-0"
	base_icon_state = "xray"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/artifactxray
	use_power = IDLE_POWER_USE
	///max radiation level
	var/max_radiation = 3
	///chosen radiation level
	var/chosen_level = 1
	var/pulse_time = 4 SECONDS
	var/pulse_cooldown_time = 3 SECONDS
	var/list/last_results = list("NO DATA")
	var/pulsing = FALSE
	var/datum/techweb/stored_research
	COOLDOWN_DECLARE(message_cooldown)
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/machinery/artifact_xray/Initialize(mapload)
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		connect_techweb(SSresearch.science_tech)
	RefreshParts()

/obj/machinery/artifact_xray/Destroy()
	if(stored_research)
		log_research("[src] disconnected from techweb [stored_research] (destroyed).")
		QDEL_NULL(stored_research)
	QDEL_NULL(wires)
	return ..()


/obj/machinery/artifact_xray/proc/connect_techweb(datum/techweb/new_techweb)
	if(stored_research)
		log_research("[src] disconnected from techweb [stored_research] when connected to [new_techweb].")
	stored_research = new_techweb

/obj/machinery/artifact_xray/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		connect_techweb(tool.buffer)
		return TRUE
	return FALSE
/obj/machinery/artifact_xray/RefreshParts()
	. = ..()
	var/power_usage = 250
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		max_radiation = round(2.5 * laser.rating)
	for(var/datum/stock_part/capacitor/capac in component_parts)
		power_usage -= 30 * capac.tier
	update_mode_power_usage(ACTIVE_POWER_USE, power_usage)

/obj/machinery/artifact_xray/update_icon_state()
	icon_state = "[base_icon_state]-[state_open]"
	return ..()

/obj/machinery/artifact_xray/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	toggle_open()
/obj/machinery/artifact_xray/proc/toggle_open()
	if(!COOLDOWN_FINISHED(src,pulse_cooldown))
		return
	if(state_open)
		flick("xray-closing", src)
		close_machine()
	else
		flick("xray-opening", src)
		open_machine()

/obj/machinery/artifact_xray/attackby(obj/item/item, mob/living/user, params)
	if(HAS_TRAIT(item, TRAIT_NODROP))
		to_chat(user, span_warning("[item] is stuck to your hand, you can't put it inside [src]!"))
		return
	if(state_open && COOLDOWN_FINISHED(src,pulse_cooldown))
		close_machine(item)
		return
	..()
/obj/machinery/artifact_xray/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtifactXray", name)
		ui.open()

/obj/machinery/artifact_xray/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggleopen")
			toggle_open()
			. = TRUE
			return
		if("change_rate")
			chosen_level = clamp(params["target"], 0, max_radiation)
			. = TRUE
			return
		if("pulse")
			pulse()
			return
	update_appearance()

/obj/machinery/artifact_xray/proc/pulse()
	if(!COOLDOWN_FINISHED(src,pulse_cooldown) || pulsing || !occupant)
		return
	if(state_open)
		return
	if(isliving(occupant))
		if(!(obj_flags & EMAGGED))
			say("Cannot pulse with a living being inside!")
			return
	var/datum/component/artifact/component = occupant.GetComponent(/datum/component/artifact)
	if(component)
		component.process_stimuli(STIMULUS_RADIATION, chosen_level)
	else
		if(!HAS_TRAIT(occupant, TRAIT_IRRADIATED) && SSradiation.can_irradiate_basic(occupant))
			occupant.AddComponent(/datum/component/irradiated)
	pulsing = TRUE
	update_use_power(ACTIVE_POWER_USE)
	addtimer(CALLBACK(src, PROC_REF(post_pulse), component), pulse_time)

/obj/machinery/artifact_xray/proc/post_pulse(datum/component/artifact/artifact)
	update_use_power(IDLE_POWER_USE)
	playsound(loc, 'sound/machines/chime.ogg', 30, FALSE)
	COOLDOWN_START(src,pulse_cooldown,pulse_cooldown_time)
	pulsing = FALSE
	if(artifact && stored_research)
		var/research_added = 0
		if(!artifact.fault_discovered && artifact.chosen_fault)
			artifact.freebies = 0 //No more freebies, you know what it does now.
			artifact.fault_discovered = TRUE
			research_added += artifact.chosen_fault.research_value
			stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = artifact.chosen_fault.research_value))
		if(artifact.chosen_fault)
			last_results = list("ARTIFACT FAULT DISCOVERED: [artifact.chosen_fault.name]", "SIZE: [artifact.artifact_size < ARTIFACT_SIZE_LARGE ? "SMALL" : "LARGE" ]")
		else
			research_added += 2500
			stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = 2500))
			last_results = list("FLAWLESS ARTIFACT. NO FAULTS.", "SIZE: [artifact.artifact_size < ARTIFACT_SIZE_LARGE ? "SMALL" : "LARGE" ]")
		if(length(artifact.discovered_effects) != length(artifact.artifact_effects))
			for(var/datum/artifact_effect/eff in artifact.artifact_effects)
				artifact.discovered_effects += eff.type
				research_added += eff.research_value
				stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = eff.research_value))
			last_results += "ARTIFACT EFFECTS REVEALED."
		if(!length(artifact.artifact_effects))
			last_results += "MUNDANE ARTIFACT DETECTED. NO NOTEABLE EFFECTS."
		if(length(artifact.activators) != length(artifact.activators))
			for(var/datum/artifact_activator/activator in artifact.activators)
				artifact.discovered_activators += activator.type
				stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = activator.research_value))
				research_added += activator.research_value
			last_results += "ARTIFACT ACTIVATORS REVEALED."
		last_results+= "WARNING: ARTIFACT FAULT NOW ACTIVE."
		if(research_added > 0 )
			src.visible_message(span_notice("The [src] blares: ") + span_robot("ARTIFACT RESEARCHED:[research_added] ADDED TO LINKED CONSOLE"))
	else
		last_results = list("INCONCLUSIVE;", "NO SPECIAL PROPERTIES DETECTED OR NO RESEARCH CONSOLE LINKED.")


/obj/machinery/artifact_xray/ui_data(mob/user)
	. = ..()
	.["is_open"] = state_open
	if(occupant)
		.["artifact_name"] = occupant.name
	.["pulsing"] = pulsing
	.["current_strength"] = chosen_level
	.["max_strength"] = max_radiation
	.["results"] = last_results
	return .

/obj/machinery/artifact_xray/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user,span_notice("You short out the safety sensors on the [src]."))
	playsound(src, SFX_SPARKS, 75, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/machinery/artifact_xray/relaymove(mob/living/user, direction)
	if(user.stat)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 4 SECONDS)
			to_chat(user, span_warning("[src]'s door won't budge while it's processing!"))
		return
	open_machine()

/obj/machinery/artifact_xray/can_be_occupant(atom/movable/occupant_atom)
	. = ..()
	if(isitem(occupant_atom))
		return TRUE
	else if(!occupant_atom.anchored)
		return TRUE

/obj/machinery/artifact_xray/screwdriver_act(mob/living/user, obj/item/tool)
	if(pulsing)
		return TOOL_ACT_SIGNAL_BLOCKING
	. = default_deconstruction_screwdriver(user, base_icon_state, base_icon_state, tool)


/obj/machinery/artifact_xray/crowbar_act(mob/living/user, obj/item/tool)
	return pulsing ? TOOL_ACT_SIGNAL_BLOCKING : default_deconstruction_crowbar(tool)
