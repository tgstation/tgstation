///Used to make mobs from microbiological samples. Grow grow grow.
/obj/machinery/plumbing/growing_vat
	name = "growing vat"
	desc = "Tastes just like the chef's soup."
	icon_state = "growing_vat"
	buffer = 200
	///List of all microbiological samples in this soup.
	var/datum/biological_sample/biological_sample

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
		audible_message(pick(list("<span class='notice'>[src] grumbles!</span>", "<span class='notice'>[src] makes a splashing noise!</span>", "<span class='notice'>[src] sloshes!</span>")))

///Handles the petri dish depositing into the vat.
/obj/machinery/plumbing/growing_vat/attacked_by(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/petri_dish))
		return ..()

	var/obj/item/petri_dish/petri = I

	if(!petri.sample)
		return ..()

	if(biological_sample)
		to_chat(user, "<span class='warning'>There is already a sample in the vat!</span>")
		return
	deposit_sample(user, petri)

///Creates a clone of the supplied sample and puts it in the vat
/obj/machinery/plumbing/growing_vat/proc/deposit_sample(mob/user, obj/item/petri_dish/petri)
	biological_sample = new
	for(var/datum/micro_organism/m in petri.sample.micro_organisms)
		biological_sample.micro_organisms += new m.type()
	biological_sample.sample_layers = petri.sample.sample_layers
	biological_sample.sample_color = petri.sample.sample_color
	to_chat(user, "<span class='warning'>You put some of the sample in the vat!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	update_appearance()

///Adds text for when there is a sample in the vat
/obj/machinery/plumbing/growing_vat/examine(mob/user)
	. = ..()
	if(!biological_sample)
		return
	. += "<span class='notice'>It seems to have a sample in it!</span>"
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
