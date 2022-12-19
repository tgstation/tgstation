/obj/machinery/medipen_refiller
	name = "Medipen Refiller"
	desc = "A machine that refills used medipens with chemicals."
	icon = 'icons/obj/machines/medipen_refiller.dmi'
	icon_state = "medipen_refiller"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/medipen_refiller

	///List of medipen subtypes it can refill and the chems needed for it to work.
	var/static/list/allowed = list(
		/obj/item/reagent_containers/hypospray/medipen = /datum/reagent/medicine/epinephrine,
		/obj/item/reagent_containers/hypospray/medipen/atropine = /datum/reagent/medicine/atropine,
		/obj/item/reagent_containers/hypospray/medipen/salbutamol = /datum/reagent/medicine/salbutamol,
		/obj/item/reagent_containers/hypospray/medipen/oxandrolone = /datum/reagent/medicine/oxandrolone,
		/obj/item/reagent_containers/hypospray/medipen/salacid = /datum/reagent/medicine/sal_acid,
		/obj/item/reagent_containers/hypospray/medipen/penacid = /datum/reagent/medicine/pen_acid,
	)

/obj/machinery/medipen_refiller/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand)
	CheckParts()

/obj/machinery/medipen_refiller/RefreshParts()
	. = ..()
	var/new_volume = 100
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		new_volume += (100 * bin.rating)
	if(!reagents)
		create_reagents(new_volume, TRANSPARENT)
	reagents.maximum_volume = new_volume
	return TRUE

/obj/machinery/medipen_refiller/attackby(obj/item/weapon, mob/user, params)
	if(DOING_INTERACTION(user, src))
		balloon_alert(user, "already interacting!")
		return
	if(is_reagent_container(weapon) && weapon.is_open_container())
		var/obj/item/reagent_containers/reagent_container = weapon
		var/units = reagent_container.reagents.trans_to(src, reagent_container.amount_per_transfer_from_this, transfered_by = user)
		if(units)
			balloon_alert(user, "[units] units transfered")
		else
			balloon_alert(user, "reagent storage full!")
		return
	if(istype(weapon, /obj/item/reagent_containers/hypospray/medipen))
		var/obj/item/reagent_containers/hypospray/medipen/medipen = weapon
		if(!(LAZYFIND(allowed, medipen.type)))
			balloon_alert(user, "medipen incompatible!")
			return
		if(medipen.reagents?.reagent_list.len)
			balloon_alert(user, "medipen full!")
			return
		if(!reagents.has_reagent(allowed[medipen.type], 10))
			balloon_alert(user, "not enough reagents!")
			return
		add_overlay("active")
		if(!do_after(user, 2 SECONDS, src))
			cut_overlays()
			return
		medipen.reagents.maximum_volume = initial(medipen.reagents.maximum_volume)
		medipen.add_initial_reagents()
		reagents.remove_reagent(allowed[medipen.type], 10)
		balloon_alert(user, "refilled")
		use_power(active_power_usage)
		cut_overlays()
		return
	return ..()

/obj/machinery/medipen_refiller/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, span_notice("You start furiously plunging [name]."))
	if(do_after(user, 30, target = src))
		to_chat(user, span_notice("You finish plunging the [name]."))
		reagents.expose(get_turf(src), TOUCH)
		reagents.clear_reagents()

/obj/machinery/medipen_refiller/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/medipen_refiller/crowbar_act(mob/living/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return TRUE

/obj/machinery/medipen_refiller/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "medipen_refiller_open", "medipen_refiller", tool)
