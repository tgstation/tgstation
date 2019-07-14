/obj/machinery/plumbing/fountain
	name = "fountain"
	desc = "A fountain, you can drink from here."
	icon_state = "fountain"
	density = TRUE
	capacity = 200
	deployable = /obj/item/deployable/fountain
	///fluid overlay that appears over the fountain when there are liquids inside, it changes color
	var/mutable_appearance/fluid_overlay
	///if it has the overlay already
	var/has_fluid = FALSE

/obj/machinery/plumbing/fountain/Initialize()
	. = ..()
	create_reagents(capacity, DRAINABLE|AMOUNT_VISIBLE)
	AddComponent(/datum/component/plumbing/output)

	fluid_overlay = fluid_overlay || mutable_appearance('icons/obj/plumbing/plumbers.dmi')
	fluid_overlay.icon_state = "fountain_grey"
	fluid_overlay.plane = BELOW_MOB_LAYER

/obj/machinery/plumbing/fountain/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/plumbing/fountain/process()
	update_icon()

/obj/machinery/plumbing/fountain/default_unfasten_wrench(mob/user, obj/item/I, time = 5)
	. = ..()
	if(anchored)
		START_PROCESSING(SSobj, src)
		return
	STOP_PROCESSING(SSobj, src)

/obj/machinery/plumbing/fountain/update_icon()
	..()
	if(reagents && reagents.total_volume && powered())
		var/col = mix_color_from_reagents(reagents.reagent_list)
		fluid_overlay.color = col
		if(!has_fluid)
			add_overlay(fluid_overlay)
			has_fluid = TRUE
	else
		cut_overlay(fluid_overlay)
		has_fluid = FALSE

/obj/machinery/plumbing/fountain/attack_hand(mob/user)
	. = ..()
	if(!has_fluid)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	reagents.trans_to(user, 5, transfered_by = user, method = INGEST)
	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)

/obj/machinery/plumbing/fountain/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/item/deployable/fountain
	name = "deployable fountain"
	desc = "A self-deploying fountain, just press the button to activate it."
	icon_state = "fountain_d"
	result = /obj/machinery/plumbing/fountain