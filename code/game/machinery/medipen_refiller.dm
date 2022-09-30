/obj/machinery/medipen_refiller
	name = "Medipen Refiller"
	desc = "A machine that refills used medipens with chemicals."
	icon = 'icons/obj/machines/medipen_refiller.dmi'
	icon_state = "medipen_refiller"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/medipen_refiller
	idle_power_usage = 100
	/// list of medipen subtypes it can refill
	var/list/allowed = list(/obj/item/reagent_containers/hypospray/medipen = /datum/reagent/medicine/epinephrine,
						    /obj/item/reagent_containers/hypospray/medipen/atropine = /datum/reagent/medicine/atropine,
						    /obj/item/reagent_containers/hypospray/medipen/salbutamol = /datum/reagent/medicine/salbutamol,
						    /obj/item/reagent_containers/hypospray/medipen/oxandrolone = /datum/reagent/medicine/oxandrolone,
						    /obj/item/reagent_containers/hypospray/medipen/salacid = /datum/reagent/medicine/sal_acid,
						    /obj/item/reagent_containers/hypospray/medipen/penacid = /datum/reagent/medicine/pen_acid)
	/// var to prevent glitches in the animation
	var/busy = FALSE

/obj/machinery/medipen_refiller/Initialize(mapload)
	. = ..()
	create_reagents(100, TRANSPARENT)
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		reagents.maximum_volume += 100 * B.rating
	AddComponent(/datum/component/plumbing/simple_demand)


/obj/machinery/medipen_refiller/RefreshParts()
	var/new_volume = 100
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		new_volume += 100 * B.rating
	if(!reagents)
		create_reagents(new_volume, TRANSPARENT)
	reagents.maximum_volume = new_volume
	return TRUE

///  handles the messages and animation, calls refill to end the animation
/obj/machinery/medipen_refiller/attackby(obj/item/I, mob/user, params)
	if(busy)
		to_chat(user, span_danger("The machine is busy."))
		return
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		var/obj/item/reagent_containers/RC = I
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this, transfered_by = user)
		if(units)
			to_chat(user, span_notice("You transfer [units] units of the solution to the [name]."))
			return
		else
			to_chat(user, span_danger("The [name] is full."))
			return
	if(istype(I, /obj/item/reagent_containers/hypospray/medipen))
		var/obj/item/reagent_containers/hypospray/medipen/P = I
		if(!(LAZYFIND(allowed, P.type)))
			to_chat(user, span_danger("Error! Unknown schematics."))
			return
		if(P.reagents?.reagent_list.len)
			to_chat(user, span_notice("The medipen is already filled."))
			return
		if(reagents.has_reagent(allowed[P.type], 10))
			busy = TRUE
			add_overlay("active")
			addtimer(CALLBACK(src, .proc/refill, P, user), 20)
			qdel(P)
			return
		to_chat(user, span_danger("There aren't enough reagents to finish this operation."))
		return
	..()

/obj/machinery/medipen_refiller/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, span_notice("You start furiously plunging [name]."))
	if(do_after(user, 30, target = src))
		to_chat(user, span_notice("You finish plunging the [name]."))
		reagents.expose(get_turf(src), TOUCH)
		reagents.clear_reagents()

/obj/machinery/medipen_refiller/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/medipen_refiller/crowbar_act(mob/user, obj/item/I)
	..()
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/medipen_refiller/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "medipen_refiller_open", "medipen_refiller", I)

/// refills the medipen
/obj/machinery/medipen_refiller/proc/refill(obj/item/reagent_containers/hypospray/medipen/P, mob/user)
	new P.type(loc)
	reagents.remove_reagent(allowed[P.type], 10)
	cut_overlays()
	busy = FALSE
	to_chat(user, span_notice("Medipen refilled."))
