///Used to make mobs from microbiological samples. Grow grow grow.
/obj/machinery/plumbing/growing_vat
	name = "growing vat"
	desc = "Tastes just like the chef's soup."
	icon_state = "growing_vat"
	buffer = 300
	///List of all microbiological samples in this soup.
	var/datum/biological_sample/biological_sample
	///If the vat will restart the sample upon completion
	var/resampler_active = FALSE

///Add that sexy demnand component
/obj/machinery/plumbing/growing_vat/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)

/obj/machinery/plumbing/growing_vat/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), .proc/on_reagent_change)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/// Handles properly detaching signal hooks.
/obj/machinery/plumbing/growing_vat/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_PARENT_QDELETING))
	return NONE

///When we process, we make use of our reagents to try and feed the samples we have.
/obj/machinery/plumbing/growing_vat/process()
	if(!is_operational)
		return
	if(!biological_sample)
		return
	if(biological_sample.handle_growth(src))
		if(!prob(10))
			return
		playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
		audible_message(pick(list(span_notice("[src] grumbles!"), span_notice("[src] makes a splashing noise!"), span_notice("[src] sloshes!"))))

///Handles the petri dish depositing into the vat.
/obj/machinery/plumbing/growing_vat/attacked_by(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/petri_dish))
		return ..()

	var/obj/item/petri_dish/petri = I

	if(!petri.sample)
		return ..()

	if(biological_sample)
		to_chat(user, span_warning("There is already a sample in the vat!"))
		return
	deposit_sample(user, petri)

///Creates a clone of the supplied sample and puts it in the vat
/obj/machinery/plumbing/growing_vat/proc/deposit_sample(mob/user, obj/item/petri_dish/petri)
	biological_sample = new
	for(var/datum/micro_organism/m in petri.sample.micro_organisms)
		biological_sample.micro_organisms += new m.type()
	biological_sample.sample_layers = petri.sample.sample_layers
	biological_sample.sample_color = petri.sample.sample_color
	to_chat(user, span_warning("You put some of the sample in the vat!"))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	update_appearance()
	RegisterSignal(biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED, .proc/on_sample_growth_completed)

///Adds text for when there is a sample in the vat
/obj/machinery/plumbing/growing_vat/examine(mob/user)
	. = ..()
	if(!biological_sample)
		return
	. += span_notice("It seems to have a sample in it!")
	for(var/i in biological_sample.micro_organisms)
		var/datum/micro_organism/MO = i
		. += MO.get_details(user.research_scanner)

/obj/machinery/plumbing/growing_vat/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	. = ..()
	QDEL_NULL(biological_sample)

/// Call update icon when reagents change to update the reagent content icons. Eats signal args.
/obj/machinery/plumbing/growing_vat/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	update_appearance()
	return NONE

///Adds overlays to show the reagent contents
/obj/machinery/plumbing/growing_vat/update_overlays()
	. = ..()
	var/static/image/on_overlay
	var/static/image/off_overlay
	var/static/image/emissive_overlay
	if(isnull(on_overlay))
		on_overlay = iconstate2appearance(icon, "growing_vat_on")
		off_overlay = iconstate2appearance(icon, "growing_vat_off")
		emissive_overlay = emissive_appearance(icon, "growing_vat_glow", alpha = src.alpha)
	. += emissive_overlay
	if(is_operational)
		if(resampler_active)
			. += on_overlay
		else
			. += off_overlay
	if(!reagents.total_volume)
		return
	var/reagentcolor = mix_color_from_reagents(reagents.reagent_list)
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "vat_reagent")
	base_overlay.appearance_flags = RESET_COLOR
	base_overlay.color = reagentcolor
	. += base_overlay
	if(biological_sample && is_operational)
		var/mutable_appearance/bubbles_overlay = mutable_appearance(icon, "vat_bubbles")
		. += bubbles_overlay

/obj/machinery/plumbing/growing_vat/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	if(obj_flags & EMAGGED)
		return
	resampler_active = !resampler_active
	balloon_alert_to_viewers("resampler [resampler_active ? "activated" : "deactivated"]")
	update_appearance()

/obj/machinery/plumbing/growing_vat/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, span_warning("You overload [src]'s resampling circuit."))
	flick("growing_vat_emagged", src)

/obj/machinery/plumbing/growing_vat/proc/on_sample_growth_completed()
	SIGNAL_HANDLER
	if(resampler_active)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(src), 'sound/effects/servostep.ogg', 100, 1), 1.5 SECONDS)
		biological_sample.reset_sample()
		return SPARE_SAMPLE
	UnregisterSignal(biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED)
