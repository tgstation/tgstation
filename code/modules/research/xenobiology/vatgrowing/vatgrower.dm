///Used to make mobs from microbiological samples. Grow grow grow.
/obj/machinery/vatgrower
	name = "growing vat"
	desc = "Tastes just like the chef's soup."
	icon = 'icons/obj/science/vatgrowing.dmi'
	icon_state = "growing_vat"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	circuit = /obj/item/circuitboard/machine/vatgrower
	use_power = NO_POWER_USE
	///Soup container reagents
	var/reagent_volume = 300
	var/reagent_flags = OPENCONTAINER | DUNKABLE
	///List of all microbiological samples in this soup.
	var/datum/biological_sample/biological_sample
	///If the vat will restart the sample upon completion
	var/resampler_active = FALSE

/obj/machinery/vatgrower/Initialize(mapload, bolt, layer)
	. = ..()
	create_reagents(reagent_volume, reagent_flags)

	AddComponent(/datum/component/simple_rotation)
	AddComponent(/datum/component/plumbing/simple_demand)

	var/static/list/hovering_item_typechecks = list(
		/obj/item/petri_dish = list(
			SCREENTIP_CONTEXT_LMB = "Add Sample",
		),
		/obj/item/reagent_containers = list(
			SCREENTIP_CONTEXT_LMB = "Pour Reagents",
		),
	)
	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)
	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Toggle Resampler", rmb_text = "Flush Soup")

/obj/machinery/vatgrower/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))

///When we process, we make use of our reagents to try and feed the samples we have.
/obj/machinery/vatgrower/process(seconds_per_tick)
	if(!is_operational)
		return
	if(!biological_sample)
		return
	if(biological_sample.handle_growth(src))
		if(!prob(10))
			return
		playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
		audible_message(pick(list(span_notice("[src] grumbles!"), span_notice("[src] makes a splashing noise!"), span_notice("[src] sloshes!"))))
	use_energy(active_power_usage * seconds_per_tick)

/obj/machinery/vatgrower/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(istype(tool, /obj/item/petri_dish))
		return deposit_sample(user, tool)

/obj/machinery/vatgrower/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/vatgrower/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/vatgrower/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_unfasten_wrench(user, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/vatgrower/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	if(obj_flags & EMAGGED)
		return
	resampler_active = !resampler_active
	balloon_alert(user, "resampler [resampler_active ? "activated" : "deactivated"]")
	update_appearance()

/obj/machinery/vatgrower/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!anchored)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/warning = tgui_alert(user, "Are you sure you want to empty the soup container?","Flush soup container?", list("Flush", "Cancel"))
	if(warning == "Flush" && user.can_perform_action(src))
		reagents.clear_reagents()
		if(biological_sample)
			QDEL_NULL(biological_sample)
		balloon_alert(user, "container empty")
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

///Creates a clone of the supplied sample and puts it in the vat
/obj/machinery/vatgrower/proc/deposit_sample(mob/user, obj/item/petri_dish/petri)
	if(!petri.sample)
		balloon_alert(user, "dish empty")
		return ITEM_INTERACT_FAILURE
	if(biological_sample)
		balloon_alert(user, "already has a sample")
		return ITEM_INTERACT_FAILURE
	biological_sample = new
	for(var/datum/micro_organism/m in petri.sample.micro_organisms)
		biological_sample.micro_organisms += new m.type()
	biological_sample.sample_layers = petri.sample.sample_layers
	biological_sample.sample_color = petri.sample.sample_color
	balloon_alert(user, "added sample")
	playsound(src, 'sound/effects/bubbles/bubbles.ogg', 50, TRUE)
	update_appearance()
	RegisterSignal(biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED, PROC_REF(on_sample_growth_completed))
	return ITEM_INTERACT_SUCCESS

///Adds text for when there is a sample in the vat
/obj/machinery/vatgrower/examine(mob/user)
	. = ..()
	if(!biological_sample)
		return
	. += span_notice("It seems to have a sample in it!")
	for(var/i in biological_sample.micro_organisms)
		var/datum/micro_organism/MO = i
		. += MO.get_details(HAS_TRAIT(user, TRAIT_RESEARCH_SCANNER))

/// Call update icon when reagents change to update the reagent content icons. Eats signal args.
/obj/machinery/vatgrower/proc/on_reagent_change(datum/reagents/holder)
	SIGNAL_HANDLER
	update_appearance()

///Adds overlays to show the reagent contents
/obj/machinery/vatgrower/update_overlays()
	. = ..()
	var/static/image/on_overlay
	var/static/image/off_overlay
	var/static/image/emissive_overlay
	if(isnull(on_overlay))
		on_overlay = iconstate2appearance(icon, "growing_vat_on")
		off_overlay = iconstate2appearance(icon, "growing_vat_off")
		emissive_overlay = emissive_appearance(icon, "growing_vat_glow", src, alpha = src.alpha)
	. += emissive_overlay
	if(is_operational)
		if(resampler_active)
			. += on_overlay
		else
			. += off_overlay
	if(!reagents.total_volume)
		return
	var/reagentcolor = mix_color_from_reagents(reagents.reagent_list)
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "vat_reagent", appearance_flags = RESET_COLOR|KEEP_APART)
	base_overlay.color = reagentcolor
	. += base_overlay
	if(biological_sample && is_operational)
		var/mutable_appearance/bubbles_overlay = mutable_appearance(icon, "vat_bubbles")
		. += bubbles_overlay

/obj/machinery/vatgrower/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "resampling circuit overloaded")
	flick("growing_vat_emagged", src)
	return TRUE

/obj/machinery/vatgrower/proc/on_sample_growth_completed()
	SIGNAL_HANDLER
	if(resampler_active)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(src), 'sound/effects/servostep.ogg', 100, 1), 1.5 SECONDS)
		biological_sample.reset_sample()
	else
		UnregisterSignal(biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED)
		QDEL_NULL(biological_sample)
	update_appearance()
