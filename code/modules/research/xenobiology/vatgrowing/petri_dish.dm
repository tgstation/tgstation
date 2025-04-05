///Holds a biological sample which can then be put into the growing vat
/obj/item/petri_dish
	name = "petri dish"
	desc = "This makes you feel well-cultured."
	icon = 'icons/obj/science/vatgrowing.dmi'
	icon_state = "petri_dish"
	w_class = WEIGHT_CLASS_TINY
	///The sample stored on the dish
	var/datum/biological_sample/sample

/obj/item/petri_dish/Destroy()
	. = ..()
	QDEL_NULL(sample)

/obj/item/petri_dish/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, sample))
		update_appearance()

/obj/item/petri_dish/examine(mob/user)
	. = ..()
	if(!sample)
		return
	. += span_notice("You can see the following micro-organisms:")
	for(var/i in sample.micro_organisms)
		var/datum/micro_organism/MO = i
		. += MO.get_details()

/obj/item/petri_dish/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(!sample || !istype(A, /obj/structure/sink))
		return FALSE
	to_chat(user, span_notice("You wash the sample out of [src]."))
	sample = null
	update_appearance()

/obj/item/petri_dish/update_overlays()
	. = ..()
	if(!sample)
		return
	var/reagentcolor = sample.sample_color
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "petri_dish_overlay", appearance_flags = RESET_COLOR|KEEP_APART)
	base_overlay.color = reagentcolor
	. += base_overlay
	var/mutable_appearance/overlay2 = mutable_appearance(icon, "petri_dish_overlay2")
	. += overlay2

/obj/item/petri_dish/proc/deposit_sample(user, datum/biological_sample/deposited_sample)
	sample = deposited_sample
	to_chat(user, span_notice("You deposit a sample into [src]."))
	update_appearance()

/// Petri dish with random sample already in it.
/obj/item/petri_dish/random
	var/static/list/possible_samples = list(
		list(CELL_LINE_TABLE_CORGI, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5),
		list(CELL_LINE_TABLE_SNAKE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5),
		list(CELL_LINE_TABLE_COCKROACH, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 7),
		list(CELL_LINE_TABLE_BLOBBERNAUT, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	)
	name = "basic sample petri dish"

/obj/item/petri_dish/random/Initialize(mapload)
	. = ..()
	var/list/chosen = pick(possible_samples)
	sample = new
	sample.GenerateSample(chosen[1],chosen[2],chosen[3],chosen[4])
	update_appearance()
