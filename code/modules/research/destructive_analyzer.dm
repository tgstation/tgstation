/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/rnd/destructive_analyzer
	name = "destructive analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	base_icon_state = "d_analyzer"
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

/obj/machinery/rnd/destructive_analyzer/Insert_Item(obj/item/O, mob/living/user)
	if(!user.combat_mode)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!user.transferItemToLoc(O, src))
			to_chat(user, span_warning("\The [O] is stuck to your hand, you cannot put it in the [src.name]!"))
			return
		busy = TRUE
		loaded_item = O
		to_chat(user, span_notice("You add the [O.name] to the [src.name]!"))
		flick("d_analyzer_la", src)
		addtimer(CALLBACK(src, .proc/finish_loading), 10)
		updateUsrDialog()

/obj/machinery/rnd/destructive_analyzer/proc/finish_loading()
	update_appearance()
	reset_busy()

/obj/machinery/rnd/destructive_analyzer/update_icon_state()
	icon_state = "[base_icon_state][loaded_item ? "_l" : null]"
	return ..()

/obj/machinery/rnd/destructive_analyzer/proc/destroy_item(obj/item/thing, innermode = FALSE)
	if(QDELETED(thing) || QDELETED(src))
		return FALSE
	if(!innermode)
		flick("d_analyzer_process", src)
		busy = TRUE
		addtimer(CALLBACK(src, .proc/reset_busy), 24)
		use_power(250)
		if(thing == loaded_item)
			loaded_item = null
		var/list/food = thing.GetDeconstructableContents()
		for(var/obj/item/innerthing in food)
			destroy_item(innerthing, TRUE)
	for(var/mob/living/victim in thing)
		victim.death()

	qdel(thing)
	loaded_item = null
	if (!innermode)
		update_appearance()
	return TRUE

/obj/machinery/rnd/destructive_analyzer/proc/user_try_decon_id(id, mob/user)
	if(!istype(loaded_item))
		return FALSE

	if (id && id != RESEARCH_MATERIAL_DESTROY_ID)
		var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
		if(!istype(TN))
			return FALSE
		var/dpath = loaded_item.type
		var/list/worths = TN.boost_item_paths[dpath]
		var/list/differences = list()
		var/list/already_boosted = stored_research.boosted_nodes[TN.id]
		for(var/i in worths)
			var/used = already_boosted? already_boosted[i] : 0
			var/value = min(worths[i], TN.research_costs[i]) - used
			if(value > 0)
				differences[i] = value
		if(length(worths) && !length(differences))
			return FALSE
		var/choice = input("Are you sure you want to destroy [loaded_item] to [!length(worths) ? "reveal [TN.display_name]" : "boost [TN.display_name] by [json_encode(differences)] point\s"]?") in list("Proceed", "Cancel")
		if(choice == "Cancel")
			return FALSE
		if(QDELETED(loaded_item) || QDELETED(src))
			return FALSE
		SSblackbox.record_feedback("nested tally", "item_deconstructed", 1, list("[TN.id]", "[loaded_item.type]"))
		if(destroy_item(loaded_item))
			stored_research.boost_with_path(SSresearch.techweb_node_by_id(TN.id), dpath)

	else
		var/list/point_value = techweb_item_point_check(loaded_item)
		if(stored_research.deconstructed_items[loaded_item.type])
			point_value = list()
		var/user_mode_string = ""
		if(length(point_value))
			user_mode_string = " for [json_encode(point_value)] points"
		var/choice = tgui_alert(usr, "Are you sure you want to destroy [loaded_item][user_mode_string]?",, list("Proceed", "Cancel"))
		if(choice == "Cancel")
			return FALSE
		if(QDELETED(loaded_item) || QDELETED(src))
			return FALSE
		destroy_item(loaded_item)
	return TRUE

/obj/machinery/rnd/destructive_analyzer/proc/unload_item()
	if(!loaded_item)
		return FALSE
	loaded_item.forceMove(get_turf(src))
	loaded_item = null
	update_appearance()
	return TRUE

/obj/machinery/rnd/destructive_analyzer/ui_interact(mob/user)
	. = ..()
	var/datum/browser/popup = new(user, "destructive_analyzer", name, 900, 600)
	popup.set_content(ui_deconstruct())
	popup.open()

/obj/machinery/rnd/destructive_analyzer/proc/ui_deconstruct() //Legacy code
	var/list/l = list()
	if(!loaded_item)
		l += "<div class='statusDisplay'>No item loaded. Standing-by...</div>"
	else
		l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
		l += "<table><tr><td>[icon2html(loaded_item, usr)]</td><td><b>[loaded_item.name]</b> <A href='?src=[REF(src)];eject_item=1'>Eject</A></td></tr></table>[RDSCREEN_NOBREAK]"
		l += "Select a node to boost by deconstructing this item. This item can boost:"

		var/anything = FALSE
		var/list/boostable_nodes = techweb_item_boost_check(loaded_item)
		for(var/id in boostable_nodes)
			anything = TRUE
			var/list/worth = boostable_nodes[id]
			var/datum/techweb_node/N = SSresearch.techweb_node_by_id(id)

			l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
			if (stored_research.researched_nodes[N.id])  // already researched
				l += "<span class='linkOff'>[N.display_name]</span>"
				l += "This node has already been researched."
			else if(!length(worth))  // reveal only
				if (stored_research.hidden_nodes[N.id])
					l += "<A href='?src=[REF(src)];deconstruct=[N.id]'>[N.display_name]</A>"
					l += "This node will be revealed."
				else
					l += "<span class='linkOff'>[N.display_name]</span>"
					l += "This node has already been revealed."
			else  // boost by the difference
				var/list/differences = list()
				var/list/already_boosted = stored_research.boosted_nodes[N.id]
				for(var/i in worth)
					var/already_boosted_amount = already_boosted? stored_research.boosted_nodes[N.id][i] : 0
					var/amt = min(worth[i], N.research_costs[i]) - already_boosted_amount
					if(amt > 0)
						differences[i] = amt
				if (length(differences))
					l += "<A href='?src=[REF(src)];deconstruct=[N.id]'>[N.display_name]</A>"
					l += "This node will be boosted with the following:<BR>[techweb_point_display_generic(differences)]"
				else
					l += "<span class='linkOff'>[N.display_name]</span>"
					l += "This node has already been boosted.</span>"
			l += "</div>[RDSCREEN_NOBREAK]"

		var/list/point_values = techweb_item_point_check(loaded_item)
		if(point_values)
			anything = TRUE
			l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
			if (stored_research.deconstructed_items[loaded_item.type])
				l += "<span class='linkOff'>Point Deconstruction</span>"
				l += "This item's points have already been claimed."
			else
				l += "<A href='?src=[REF(src)];deconstruct=[RESEARCH_MATERIAL_DESTROY_ID]'>Point Deconstruction</A>"
				l += "This item is worth: <BR>[techweb_point_display_generic(point_values)]!"
			l += "</div>[RDSCREEN_NOBREAK]"

		if(!(loaded_item.resistance_flags & INDESTRUCTIBLE))
			l += "<div class='statusDisplay'><A href='?src=[REF(src)];deconstruct=[RESEARCH_MATERIAL_DESTROY_ID]'>Destroy Item</A>"
			l += "</div>[RDSCREEN_NOBREAK]"
			anything = TRUE

		if (!anything)
			l += "Nothing!"

		l += "</div>"

	for(var/i in 1 to length(l))
		if(!findtextEx(l[i], RDSCREEN_NOBREAK))
			l[i] += "<br>"
	. = l.Join("")
	return replacetextEx(., RDSCREEN_NOBREAK, "")

/obj/machinery/rnd/destructive_analyzer/Topic(raw, ls)
	. = ..()
	if(.)
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	if(ls["eject_item"]) //Eject the item inside the destructive analyzer.
		if(busy)
			to_chat(usr, span_danger("The destructive analyzer is busy at the moment."))
			return
		if(loaded_item)
			unload_item()
	if(ls["deconstruct"])
		if(!user_try_decon_id(ls["deconstruct"], usr))
			say("Destructive analysis failed!")

	updateUsrDialog()

/obj/machinery/rnd/destructive_analyzer/screwdriver_act(mob/living/user, obj/item/tool)
	return FALSE
