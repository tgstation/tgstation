/datum/buildmode_mode/tweakcomps
	key = "tweakcomps"
	/// This variable is responsible for the rating of the components themselves. Literally tiers of components, where 1 is standard, 4 is bluespace.
	var/rating = null

/datum/buildmode_mode/tweakcomps/show_help(client/target_client)
	to_chat(target_client, span_notice("***********************************************************\n\
		Right Mouse Button on buildmode button = Choose the rating of the components.\n\
		Left Mouse Button on machinery = Sets the chosen rating of the components on the machinery.\n\
		***********************************************************"))

/datum/buildmode_mode/tweakcomps/change_settings(client/target_client)
	var/rating_to_choose = input(target_client, "Enter number of rating", "Number", "1") 
	rating_to_choose = text2num(rating_to_choose)
	if(!isnum(rating_to_choose))
		tgui_alert(target_client, "Input a number.")
		return
	
	rating = rating_to_choose

/datum/buildmode_mode/tweakcomps/handle_click(client/target_client, params, obj/machinery/object)
	if(!ismachinery(object))
		to_chat(target_client, span_warning("This isn't machinery!"))
		return

	if(!object.component_parts)
		to_chat(target_client, span_warning("This machinery doesn't have components!"))
		return

	for(var/obj/item/stock_parts/P in object.component_parts)
		P.rating = rating
	object.RefreshParts()

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Machine Upgrade", "[rating]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

			
