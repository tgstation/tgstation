

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/rnd/destructive_analyzer
	name = "destructive analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/rnd/destructive_analyzer/Initialize()
	. = ..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/destructive_analyzer(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer (Machine Board)"
	build_path = /obj/machinery/rnd/destructive_analyzer
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)

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
	if(!id || !istype(TN) || !istype(loaded_item))
		return FALSE
	var/list/pos1 = techweb_item_boost_check(loaded_item)
	if(!pos1[TN])
		return FALSE



	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(!linked_destroy || linked_destroy.busy || !linked_destroy.loaded_item)
			updateUsrDialog()
			return
		var/choice = input("Are you sure you want to destroy [linked_destroy.loaded_item.name]?") in list("Proceed", "Cancel")
		if(choice == "Cancel" || !linked_destroy || !linked_destroy.loaded_item)
			return
		linked_destroy.busy = 1
		screen = SCICONSOLE_UPDATE_DATABASE
		updateUsrDialog()
		flick("d_analyzer_process", linked_destroy)
		spawn(24)
			stored_research.boost_with_path(SSresearch.techweb_nodes[href_list["destroy"]], linked_destroy.loaded_item.type)
			if(linked_destroy)
				linked_destroy.busy = 0
				if(!linked_destroy.loaded_item)
					screen = SCICONSOLE_MENU
					return
				//TODO: Add boost checking.
				if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
					for(var/material in linked_destroy.loaded_item.materials)
						linked_lathe.materials.insert_amount(min((linked_lathe.materials.max_amount - linked_lathe.materials.total_amount), (linked_destroy.loaded_item.materials[material]*(linked_destroy.decon_mod/10))), material)
					SSblackbox.add_details("item_deconstructed","[linked_destroy.loaded_item.type]")
				linked_destroy.loaded_item = null
				for(var/obj/I in linked_destroy.contents)
					for(var/mob/M in I.contents)
						M.death()
					if(istype(I,/obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
						var/obj/item/stack/sheet/S = I
						if(S.amount > 1)
							S.amount--
							linked_destroy.loaded_item = S
						else
							qdel(S)
							linked_destroy.icon_state = "d_analyzer"
					else
						if(!(I in linked_destroy.component_parts))
							qdel(I)
							linked_destroy.icon_state = "d_analyzer"
			screen = SCICONSOLE_MENU
			use_power(250)
			updateUsrDialog()

