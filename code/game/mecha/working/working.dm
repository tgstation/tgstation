/obj/mecha/working
	deflect_chance = 10
	health = 500
	req_access = access_heads
	var/datum/mecha_tool/selected_tool
	var/list/tools = new
	operation_req_access = list(access_engine,access_robotics)
	internals_req_access = list(access_engine,access_robotics)
	var/add_req_access = 1
	internal_damage_threshold = 70


/obj/mecha/working/melee_action(atom/target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = pick(oview(1,src))
	if(selected_tool)
		selected_tool.action(target)
	return

/obj/mecha/working/range_action(atom/target as obj|mob|turf)
	return

/obj/mecha/working/Topic(href, href_list)
	..()
	if (href_list["select_tool"])
		var/tool = locate(href_list["select_tool"])
		if(tool)
			src.selected_tool = tool
	if (href_list["add_req_access"])
		if(!add_req_access) return
		var/access = text2num(href_list["add_req_access"])
		operation_req_access += access
		output_access_dialog(locate(href_list["id_card"]),locate(href_list["user"]))
	if (href_list["del_req_access"])
		operation_req_access -= text2num(href_list["del_req_access"])
		output_access_dialog(locate(href_list["id_card"]),locate(href_list["user"]))
	if (href_list["finish_req_access"])
		add_req_access = 0
		var/mob/user = locate(href_list["user"])
		user << browse(null,"window=exosuit_add_access")
	return

/obj/mecha/working/get_stats_part()
	var/output = ..()
	output += "<b>[src.name] Tools:</b><div style=\"margin-left: 15px;\">"
	if(tools.len)
		for(var/datum/mecha_tool/MT in tools)
			output += "[selected_tool==MT?"<b>":"<a href='?src=\ref[src];select_tool=\ref[MT]'>"][MT.get_tool_info()][selected_tool==MT?"</b>":"</a>"]<br>"
	else
		output += "None"
	output += "</div>"
	return output


/obj/mecha/working/check_for_internal_damage(var/list/possible_int_damage,var/ignore_threshold=null)
	..()
	if(prob(5) && (ignore_threshold || (src.health*100/initial(src.health))<src.internal_damage_threshold))
		if(tools.len)
			var/datum/mecha_tool/destr_tool = pick(tools)
			if(destr_tool)
				tools -= destr_tool
				destr_tool.destroy()
				src.occupant_message("<font color='red'>The [destr_tool] is destroyed!</font>")
				src.log_append_to_last("[destr_tool] is destroyed.")
				src.occupant << sound('critdestr.ogg',volume=50)
	return


/obj/mecha/working/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(add_req_access && (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda)))
		var/obj/item/weapon/card/id/id_card
		if(istype(W, /obj/item/weapon/card/id))
			id_card = W
		else
			var/obj/item/device/pda/pda = W
			id_card = pda.id
		output_access_dialog(id_card, user)
	else
		return ..()


/obj/mecha/working/proc/output_access_dialog(obj/item/weapon/card/id/id_card, mob/user)
	if(!id_card || !user) return
	var/output = "<html><head></head><body><b>Following keycodes are present in this system:</b><br>"
	for(var/a in operation_req_access)
		output += "[get_access_desc(a)] - <a href='?src=\ref[src];del_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Delete</a><br>"
	output += "<hr><b>Following keycodes were detected on portable device:</b><br>"
	for(var/a in id_card.access)
		if(a in operation_req_access) continue
		var/a_name = get_access_desc(a)
		if(!a_name) continue
		output += "[a_name] - <a href='?src=\ref[src];add_req_access=[a];user=\ref[user];id_card=\ref[id_card]'>Add</a><br>"
	output += "<hr><a href='?src=\ref[src];finish_req_access=1;user=\ref[user]'>Finish</a>"
	output += "</body></html>"
	user << browse(output, "window=exosuit_add_access")
	onclose(user, "exosuit_add_access")
	return
