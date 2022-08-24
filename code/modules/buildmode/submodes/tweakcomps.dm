/datum/buildmode_mode/tweakcomps
	key = "tweakcomps"
	var/rating = null

/datum/buildmode_mode/tweakcomps/show_help(client/target_client)
	to_chat(target_client, span_notice("***********************************************************\n\
		Right Mouse Button on buildmode button = Choose components rating\n\
		Left Mouse Button on machinery = Sets components choosen rating.\n\
		***********************************************************"))

/datum/buildmode_mode/tweakcomps/change_settings(client/target_client)
	var/rating_to_choose = input(target_client, "Enter number of rating", "Number", "1") 
	rating_to_choose = text2num(rating_to_choose)
	if(!isnum(rating_to_choose))
		tgui_alert(target_client, "Input a number.")
		return
	else
		rating = rating_to_choose

/datum/buildmode_mode/tweakcomps/handle_click(client/target_client, params, obj/machinery/object)
	if(!ismachinery(object))
		to_chat(target_client, span_warning("This object is not machinery!"))
		return
	else
		if(object.component_parts)
			for(var/obj/item/stock_parts/P in object.component_parts)
				P.rating = rating
			object.RefreshParts()
			
			SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Machine Upgrade", "[rating]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		else
			to_chat(target_client, span_warning("That machinery don't have components"))
			return
