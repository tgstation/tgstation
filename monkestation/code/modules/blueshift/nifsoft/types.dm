/// This type of NIFSoft grants the user an action when active.
/datum/nifsoft/action_granter
	active_mode = TRUE
	activation_cost = 10
	active_cost = 1
	/// What is the path of the action that we want to grant?
	var/action_to_grant = /datum/action/innate
	/// What action are we giving the user of the NIFSoft?
	var/datum/action/innate/granted_action

/datum/nifsoft/action_granter/activate()
	. = ..()
	if(active)
		granted_action = new action_to_grant(linked_mob)
		granted_action.Grant(linked_mob)
		return

	if(granted_action)
		granted_action.Remove(linked_mob)

/datum/nifsoft/action_granter/Destroy()
	if(granted_action)
		QDEL_NULL(granted_action)
	return ..()

/obj/item/disk/nifsoft_uploader/money_sense
	name = "Automatic Apprasial"
	loaded_nifsoft = /datum/nifsoft/money_sense

/datum/nifsoft/money_sense
	name = "Automatic Appraisal"
	program_desc = "Connects the user's brain to a database containing the current monetary values for most items, allowing them to determine their value in realtime"
	active_mode = TRUE
	active_cost = 0.5
	compatible_nifs = list(/obj/item/organ/internal/cyberimp/brain/nif/standard)
	buying_category = NIFSOFT_CATEGORY_UTILITY
	ui_icon = "coins"

/datum/nifsoft/money_sense/activate()
	. = ..()
	if(active)
		linked_mob.AddComponent(/datum/component/money_sense)
		return

	var/found_component = linked_mob.GetComponent(/datum/component/money_sense)
	if(found_component)
		qdel(found_component)

///Added whenever the money_sense NIFSoft is active
/datum/component/money_sense

/datum/component/money_sense/New()
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_MOB_EXAMINATE, PROC_REF(add_examine))

/datum/component/money_sense/Destroy(force)
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_EXAMINATE)

///Scans the item the user is looking at and generates the cargo value of it.
/datum/component/money_sense/proc/add_examine(mob/user, atom/target)
	SIGNAL_HANDLER

	var/obj/item/examined_item = target
	if(!examined_item || !isobj(examined_item))
		return FALSE

	//This is the code from the cargo scanner, but without the ability to scan and get tips from items.
	var/datum/export_report/export = export_item_and_contents(examined_item, dry_run = TRUE)
	var/price = 0
	var/export_text

	for(var/x in export.total_amount)
		price += export.total_value[x]
	if(price)
		export_text = span_noticealien("This item has an export value of: <b>[price] credits.")
	else
		export_text = span_warning("This item has no export value.")

	to_chat(parent, export_text)


/// This cell is only meant for use in items temporarily created by a NIF. Do not let players extract this from devices.
/obj/item/stock_parts/cell/infinite/nif_cell
	name = "Nanite Cell"
	desc = "If you see this, please make an issue on GitHub."


/obj/item/disk/nifsoft_uploader/soul_poem
	name = "Soul Poem"
	loaded_nifsoft = /datum/nifsoft/soul_poem

//Modular Persistence variables for the soul_poem NIFSoft
/datum/modular_persistence
	///What name is saved to the station pass NIFSoft?
	var/soul_poem_nifsoft_name
	///What message is saved to the station pass NIFSoft?
	var/soul_poem_nifsoft_message

/datum/nifsoft/soul_poem
	name = "Poem of Communal Souls"
	program_desc = "The Poem of Communal Souls was the first commission the Altspace Coven ever took; a rare occasion for their involvement in NIFSoft development. This program was originally commissioned by a then-underground group of ravers as a sort of 'social contagion' for the purpose of spreading peace, love, unity, and respect. The software operates by allowing different users running it to ambiently share 'Verses' with each other, small portions of their unique nanomachine fields that carry user-set messages; sometimes actual poetry, short biographies, or simple hope to meet and bond with other NIF users. Each trade of nanomachine packets represents a physical memory of the user who traded it, some long-time 'Poets' surrounded with a dazzling rainbow of different past messages."
	persistence = TRUE
	purchase_price = 0 //It came free with your NIF.
	buying_category = NIFSOFT_CATEGORY_FUN
	ui_icon = "scroll"

	///Is the NIFSoft transmitting data?
	var/transmitting_data = TRUE
	///Is the NIFSoft receiving data?
	var/receiving_data = TRUE
	///What username is being sent out?
	var/transmitted_name = ""
	///What message is being sent to other users?
	var/transmitted_message = ""
	///What ckey is being used by the owner? This is mostly here so that messages can't get spammed
	var/transmitted_identifier = ""

	///What messages has the user received?
	var/list/message_list = list()
	///The datum that is being used to receive messages
	var/datum/proximity_monitor/advanced/soul_poem/proximity_datum

/datum/nifsoft/soul_poem/New()
	. = ..()

	if(!transmitted_name)
		transmitted_name = linked_mob.name

	if(!transmitted_message)
		transmitted_message = "Hello, I am [transmitted_name], it's nice to meet you!"

	transmitted_identifier = linked_mob.ckey

	add_message("soul_poem_nifsoft", name, "Hello World")
	proximity_datum = new(linked_mob, 1)
	proximity_datum.parent_nifsoft = WEAKREF(src)

/datum/nifsoft/soul_poem/Destroy()
	qdel(proximity_datum)
	proximity_datum = null

	return ..()

/**
* Adds a message to the message_list of the parent NIFSoft based off the sender_identifier, received_name, and received_message.
*
* * sender_identifier - This variable is used to determine the identity of the sender. This is mostly just here so that the same person can't send multiple messages.
* * received_name - What name is attached to the associated message?
* * received_message - The contents of the added message.
*/

/datum/nifsoft/soul_poem/proc/add_message(sender_identifier, received_name, received_message)
	if(!received_message || !receiving_data)
		return FALSE

	var/message_name = "Unkown User"
	if(received_name)
		message_name = received_name

	for(var/message in message_list)
		if(message["identifier"] == sender_identifier)
			message["sender_name"] = message_name
			message["message"] = received_message
			message["timestamp"] = station_time_timestamp()
			return TRUE

	message_list.Insert(1, list(list(identifier = sender_identifier, sender_name = received_name, message = received_message, timestamp = station_time_timestamp())))
	return TRUE

/// Removes the message_to_remove from the message_list, If the message cannot be found the proc will return FALSE, otherwise it will delete the message_to_remove and return TRUE.
/datum/nifsoft/soul_poem/proc/remove_message(list/message_to_remove)
	if(!message_to_remove)
		return FALSE

	var/list/removed_message = message_to_remove[1]
	for(var/list/message in message_list)
		if(message["identifier"] == removed_message["identifier"])
			message_list -= list(message)
			return TRUE

	return FALSE

/datum/nifsoft/soul_poem/activate()
	. = ..()
	ui_interact(linked_mob)


/datum/nifsoft/soul_poem/load_persistence_data()
	. = ..()
	var/datum/modular_persistence/persistence = .
	if(!persistence)
		return FALSE

	transmitted_name = persistence.soul_poem_nifsoft_name
	transmitted_message = persistence.soul_poem_nifsoft_message
	return TRUE

/datum/nifsoft/soul_poem/save_persistence_data(datum/modular_persistence/persistence)
	. = ..()
	if(!.)
		return FALSE

	persistence.soul_poem_nifsoft_message = transmitted_message
	persistence.soul_poem_nifsoft_name = transmitted_name
	return TRUE

/// Attempts to send a message to the target_nifsoft, if it exists. Returns FALSE if the message fails to send.
/datum/nifsoft/soul_poem/proc/send_message(datum/nifsoft/soul_poem/target_nifsoft)
	if(!transmitting_data || !target_nifsoft || !transmitted_message)
		return FALSE

	if(!target_nifsoft.add_message(transmitted_identifier, transmitted_name,  transmitted_message))
		return FALSE

	return TRUE

/// The proximty_monitor datum used by the soul_poem NIFSoft
/datum/proximity_monitor/advanced/soul_poem
	/// What NIFSoft is this currently attached to?
	var/datum/weakref/parent_nifsoft

/datum/proximity_monitor/advanced/soul_poem/on_entered(turf/source, atom/movable/entered)
	. = ..()
	if(host == entered)
		return FALSE

	var/datum/nifsoft/soul_poem/receiving_nifsoft = parent_nifsoft.resolve()
	if(!receiving_nifsoft || (!receiving_nifsoft.transmitting_data && !receiving_nifsoft.receiving_data))
		return FALSE

	var/mob/living/carbon/human/entered_human = entered
	if(!ishuman(entered_human))
		return FALSE

	var/datum/nifsoft/soul_poem/sending_nifsoft = entered_human.find_nifsoft(/datum/nifsoft/soul_poem)
	if(!sending_nifsoft)
		return FALSE

	sending_nifsoft.send_message(receiving_nifsoft)
	receiving_nifsoft.send_message(sending_nifsoft)

	return TRUE

//TGUI
/datum/nifsoft/soul_poem/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(linked_mob, src, ui)

	if(!ui)
		ui = new(linked_mob, src, "NifSoulPoem", name)
		ui.open()

/datum/nifsoft/soul_poem/ui_data(mob/user)
	var/list/data = list()
	data["messages"] = message_list

	data["theme"] = ui_theme
	data["receiving_data"] = receiving_data
	data["transmitting_data"] = transmitting_data

	return data

/datum/nifsoft/soul_poem/ui_static_data(mob/user)
	var/list/data = list()

	data["name_to_send"] = transmitted_name
	data["text_to_send"] = transmitted_message

	return data

/datum/nifsoft/soul_poem/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_message")
			if(!params["new_message"])
				return FALSE

			transmitted_message = params["new_message"]
			return TRUE

		if("change_name")
			if(!params["new_name"])
				return FALSE

			transmitted_name = params["new_name"]
			return TRUE

		if("remove_message")
			if(!params["message_to_remove"])
				return FALSE

			if(!remove_message(list(params["message_to_remove"])))
				return FALSE

			return TRUE

		if("toggle_transmitting")
			transmitting_data = !transmitting_data
			return TRUE

		if("toggle_receiving")
			receiving_data = !receiving_data
			return TRUE
