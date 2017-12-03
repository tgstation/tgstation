

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/rnd/destructive_analyzer
	name = "destructive analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	circuit = /obj/item/circuitboard/machine/destructive_analyzer
	var/decon_mod = 0

/obj/machinery/rnd/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/rnd/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/rnd/destructive_analyzer/disconnect_console()
	linked_console.linked_destroy = null
	..()

/obj/machinery/rnd/destructive_analyzer/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != INTENT_HARM)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!user.transferItemToLoc(O, src))
			to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
			return
		busy = TRUE
		loaded_item = O
		to_chat(user, "<span class='notice'>You add the [O.name] to the [src.name]!</span>")
		flick("d_analyzer_la", src)
		addtimer(CALLBACK(src, .proc/finish_loading), 10)
		if (linked_console)
			linked_console.updateUsrDialog()

/obj/machinery/rnd/destructive_analyzer/proc/finish_loading()
	update_icon()
	reset_busy()

/obj/machinery/rnd/destructive_analyzer/update_icon()
	if(loaded_item)
		icon_state = "d_analyzer_l"
	else
		icon_state = initial(icon_state)

/obj/machinery/rnd/destructive_analyzer/proc/reclaim_materials_from(obj/item/thing)
	. = 0
	if(linked_console && linked_console.linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
		for(var/material in thing.materials)
			var/can_insert = min((linked_console.linked_lathe.materials.max_amount - linked_console.linked_lathe.materials.total_amount), (max(thing.materials[material]*(decon_mod/10), thing.materials[material])))
			linked_console.linked_lathe.materials.insert_amount(can_insert, material)
			. += can_insert

/obj/machinery/rnd/destructive_analyzer/proc/destroy_item(obj/item/thing, innermode = FALSE)
	if(QDELETED(thing) || QDELETED(src) || QDELETED(linked_console))
		return FALSE
	if(!innermode)
		flick("d_analyzer_process", src)
		busy = TRUE
		addtimer(CALLBACK(src, .proc/reset_busy), 24)
		use_power(250)
		if(thing == loaded_item)
			loaded_item = null
		update_icon()
		var/list/food = thing.GetDeconstructableContents()
		for(var/obj/item/innerthing in food)
			destroy_item(innerthing, TRUE)
	reclaim_materials_from(thing)
	for(var/mob/M in thing)
		M.death()
	if(istype(thing, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = thing
		if(S.amount > 1 && !innermode)
			S.amount--
		else
			qdel(S)
	else
		qdel(thing)
	return TRUE

/obj/machinery/rnd/destructive_analyzer/proc/user_try_decon_id(id, mob/user)
	if(!istype(loaded_item) || !istype(linked_console))
		return FALSE

	if (id && id != RESEARCH_MATERIAL_RECLAMATION_ID)
		var/datum/techweb_node/TN = get_techweb_node_by_id(id)
		if(!istype(TN))
			return FALSE
		var/list/can_boost = techweb_item_boost_check(loaded_item)
		if(isnull(can_boost[id]))
			return FALSE
		var/dpath = loaded_item.type
		var/worth = TN.boost_item_paths[dpath]
		if(isnull(worth))
			return FALSE
		var/difference = min(worth, TN.research_cost) - linked_console.stored_research.boosted_nodes[TN.id]
		if(worth && difference <= 0)
			return FALSE
		var/choice = input("Are you sure you want to destroy [loaded_item] to [!worth ? "reveal [TN.display_name]" : "boost [TN.display_name] by [difference] point\s"]?") in list("Proceed", "Cancel")
		if(choice == "Cancel")
			return FALSE
		if(QDELETED(loaded_item) || QDELETED(linked_console) || !user.Adjacent(linked_console) || QDELETED(src))
			return FALSE
		SSblackbox.record_feedback("nested_tally", "item_deconstructed", 1, list("[TN.id]", "[loaded_item.type]"))
		if(destroy_item(loaded_item))
			linked_console.stored_research.boost_with_path(SSresearch.techweb_nodes[TN.id], dpath)

	else
		var/point_value = techweb_item_point_check(loaded_item)
		if(linked_console.stored_research.deconstructed_items[loaded_item.type])
			point_value = 0
		var/choice = input("Are you sure you want to destroy [loaded_item] for [point_value ? "[point_value] research points" : "material reclamation"]?") in list("Proceed", "Cancel")
		if(choice == "Cancel")
			return FALSE
		if(QDELETED(loaded_item) || QDELETED(linked_console) || !user.Adjacent(linked_console) || QDELETED(src))
			return FALSE
		if(destroy_item(loaded_item))
			linked_console.stored_research.research_points += point_value
			linked_console.stored_research.deconstructed_items[loaded_item.type] = point_value

	return TRUE

/obj/machinery/rnd/destructive_analyzer/proc/unload_item()
	if(!loaded_item)
		return FALSE
	loaded_item.forceMove(get_turf(src))
	loaded_item = null
	update_icon()
	return TRUE
