

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/rnd/destructive_analyzer
	name = "destructive analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	circuit = /obj/item/weapon/circuitboard/machine/destructive_analyzer
	var/decon_mod = 0

/obj/machinery/rnd/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in component_parts)
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
		if(!techweb_item_boost_check(O))
			to_chat(user, "<span class='warning'>This item is of no value to research!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
			return
		busy = TRUE
		loaded_item = O
		O.forceMove(src)
		to_chat(user, "<span class='notice'>You add the [O.name] to the [src.name]!</span>")
		flick("d_analyzer_la", src)
		addtimer(CALLBACK(src, .proc/finish_loading), 10)

/obj/machinery/rnd/destructive_analyzer/proc/finish_loading()
	update_icon()
	reset_busy()

/obj/machinery/rnd/destructive_analyzer/update_icon()
	if(loaded_item)
		icon_state = "d_analyzer_l"
	else
		icon_state = initial(icon_state)

/obj/machinery/rnd/destructive_analyzer/proc/user_try_decon_id(id)
	var/datum/techweb_node/TN = get_techweb_node_by_id(id)
	if(!id || !istype(TN) || !istype(loaded_item) || !linked_console)
		return FALSE
	var/list/pos1 = techweb_item_boost_check(loaded_item)
	if(!pos1[TN])
		return FALSE
	var/dpath = loaded_item.type
	if(!TN[dpath])
		return FALSE
	var/dboost = TN[dpath]
	var/choice = input("Are you sure you want to destroy [loaded_item.name] for a boost of [dboost] in node [TN.display_name]") in list("Proceed", "Cancel")
	if(choice == "Cancel")
		return FALSE
	busy = TRUE
	addtimer(CALLBACK(src, .proc/reset_busy), 24)
	flick("d_analyzer_process", src)
	if(QDELETED(loaded_item) || QDELETED(src) || QDELETED(linked_console))
		return FALSE
	linked_console.stored_research.boost_with_path(SSresearch.techweb_nodes[TN.id], loaded_item.type)
	SSblackbox.add_details("item_deconstructed","[loaded_item.type] - [TN.id]")
	if(linked_console && linked_console.linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
		for(var/material in loaded_item.materials)
			linked_console.linked_lathe.materials.insert_amount(min((linked_console.linked_lathe.materials.max_amount - linked_console.linked_lathe.materials.total_amount), (loaded_item.materials[material]*(decon_mod/10))), material)
	for(var/mob/M in loaded_item.contents)
		M.death()
	if(istype(loaded_item, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = loaded_item
		if(S.amount > 1)
			S.amount--
		else
			qdel(S)
	else
		qdel(loaded_item)
	use_power(250)
	update_icon()

/obj/machinery/rnd/destructive_analyzer/proc/unload_item()
	if(!loaded_item)
		return FALSE
	loaded_item.forceMove(get_turf(src))
	loaded_item = null
	return TRUE
