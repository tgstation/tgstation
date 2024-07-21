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

///A list containing users of the Hivemind NIFSoft
GLOBAL_LIST_EMPTY(hivemind_users)

/obj/item/disk/nifsoft_uploader/hivemind
	name = "Hivemind"
	loaded_nifsoft = /datum/nifsoft/hivemind

/datum/nifsoft/hivemind
	name = "Hivemind"
	program_desc = "Hivemind is a program developed as a more reliable simulacrum of the mysterious means of communication that some varieties of slime share. It's built on a specific configuration of the NIF capable of generating a localized subspace network; the content the user's very thoughts, serving as a high-tech means of telepathic communication between NIF users."
	activation_cost = 10
	active_mode = TRUE
	active_cost = 0.2
	purchase_price = 350
	buying_category = NIFSOFT_CATEGORY_UTILITY
	ui_icon = "users"

	///The network that the user is currently hosting
	var/datum/component/mind_linker/active_linking/nif/user_network
	///What networks are the user connected to?
	var/list/network_list = list()
	///What network is the user sending messages to? This is saved from the keyboard so the user doesn't have to change the channel every time.
	var/datum/component/mind_linker/active_linking/nif/active_network
	///The physical keyboard item being used to send messages
	var/obj/item/hivemind_keyboard/linked_keyboard
	///What action is being used to summon the Keyboard?
	var/datum/action/innate/hivemind_keyboard/keyboard_action

/datum/nifsoft/hivemind/New()
	. = ..()

	user_network = linked_mob.AddComponent(/datum/component/mind_linker/active_linking/nif, \
		network_name = "Hivemind Link", \
		linker_action_path = /datum/action/innate/hivemind_config, \
	)

	keyboard_action = new(linked_mob)
	keyboard_action.Grant(linked_mob)

	active_network = user_network
	network_list += user_network
	GLOB.hivemind_users += linked_mob

/datum/nifsoft/hivemind/Destroy()
	if(linked_mob in GLOB.hivemind_users)
		GLOB.hivemind_users -= linked_mob

	if(keyboard_action)
		keyboard_action.Remove()
		QDEL_NULL(keyboard_action)

	if(linked_keyboard)
		qdel(linked_keyboard)

	linked_keyboard = null

	for(var/datum/component/mind_linker/active_linking/nif/hivemind as anything in network_list)
		hivemind.linked_mobs -= linked_mob
		var/mob/living/hivemind_owner = hivemind.parent

		to_chat(hivemind_owner, span_abductor("[linked_mob] has left your Hivemind."))
		to_chat(linked_mob, span_abductor("You have left [hivemind_owner]'s Hivemind."))

	qdel(user_network)
	return ..()

/datum/nifsoft/hivemind/activate()
	. = ..()
	if(!active)
		if(linked_keyboard)
			qdel(linked_keyboard)
			linked_keyboard = null

		return TRUE

	linked_keyboard = new
	linked_keyboard.connected_network = active_network
	linked_mob.put_in_hands(linked_keyboard)
	linked_keyboard.source_user = linked_mob

	linked_mob.visible_message(span_notice("The [linked_keyboard] materializes in [linked_mob]'s hands."), span_notice("The [linked_keyboard] appears in your hands."))
	return TRUE

/datum/action/innate/hivemind_config
	name = "Hivemind Configuration Settings"
	background_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/actions_nif.dmi'
	button_icon_state = "phone_settings"

/datum/action/innate/hivemind_config/Activate()
	. = ..()
	var/datum/component/mind_linker/active_linking/nif/link = target

	var/choice = tgui_input_list(owner, "Chose your option", "Hivemind Configuration Menu", list("Link a user","Remove a user","Change Hivemind color","Change active Hivemind","Leave a Hivemind", "Toggle invites"))
	if(!choice)
		return

	switch(choice)
		if("Link a user")
			link.invite_user()

		if("Remove a user")
			link.remove_user()

		if("Leave a Hivemind")
			leave_hivemind()

		if("Change active Hivemind")
			change_hivemind()

		if("Change Hivemind color")
			link.change_chat_color()

		if("Toggle invites")
			toggle_invites()

/datum/action/innate/hivemind_config/proc/change_hivemind()
	var/mob/living/carbon/human/user = owner
	var/datum/nifsoft/hivemind/hivemind = user.find_nifsoft(/datum/nifsoft/hivemind)

	var/datum/component/mind_linker/active_linking/nif/new_active_hivemind = tgui_input_list(user, "Choose a Hivemind to set as active.", "Switch Hivemind", hivemind.network_list)
	if(!new_active_hivemind)
		return FALSE

	hivemind.active_network = new_active_hivemind
	to_chat(user, span_abductor("You are now sending messages to [new_active_hivemind.name]."))

	if(hivemind.active)
		hivemind.activate()
		hivemind.activate()

/datum/action/innate/hivemind_config/proc/leave_hivemind()
	var/mob/living/carbon/human/user = owner
	var/datum/nifsoft/hivemind/hivemind = user.find_nifsoft(/datum/nifsoft/hivemind)

	var/list/network_list = hivemind.network_list
	network_list -= hivemind.user_network

	var/datum/component/mind_linker/active_linking/nif/hivemind_to_leave = tgui_input_list(user, "Choose a Hivemind to disconnect from.", "Remove Hivemind", network_list)
	if(!hivemind_to_leave)
		return FALSE

	to_chat(hivemind_to_leave.parent, span_abductor("[user] has been removed from your Hivemind."))
	to_chat(user, span_abductor("You have left [hivemind_to_leave.parent]'s Hivemind."))

	hivemind.network_list -= hivemind_to_leave
	hivemind_to_leave.linked_mobs -= user


/datum/action/innate/hivemind_config/proc/toggle_invites()
	var/mob/living/carbon/human/user = owner
	if(user in GLOB.hivemind_users)
		GLOB.hivemind_users -= user
		to_chat(user, span_abductor("You are now unable to receive invites."))
		return

	GLOB.hivemind_users += user
	to_chat(user, span_abductor("You are now able to receive invites."))

/datum/action/innate/hivemind_keyboard
	name = "Hivemind Keyboard"
	background_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/actions_nif.dmi'
	button_icon_state = "phone"

/datum/action/innate/hivemind_keyboard/Activate()
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/datum/nifsoft/hivemind/hivemind_nifsoft = user.find_nifsoft(/datum/nifsoft/hivemind)

	if(!hivemind_nifsoft)
		return FALSE

	hivemind_nifsoft.activate()

/datum/component/mind_linker
	///Is does the component give an action to speak? By default, yes
	var/speech_action = TRUE
	///Does the component check to see if the person being linked has a mindshield or anti-magic?
	var/linking_protection = TRUE

/datum/component/mind_linker/active_linking/nif
	speech_action = FALSE
	linking_protection = FALSE

	///What is the name of the hivemind? This is mostly here for the TGUI selection menus.
	var/name = ""

/datum/component/mind_linker/active_linking/nif/New()
	. = ..()

	var/mob/living/owner = parent
	name = owner.name + "'s " + network_name

///Lets the user add someone to their Hivemind through a choice menu that shows everyone that has the Hivemind NIFSoft.
/datum/component/mind_linker/active_linking/nif/proc/invite_user()
	var/list/hivemind_users = GLOB.hivemind_users.Copy()
	var/mob/living/carbon/human/owner = parent

	//This way people already linked don't show up in the selection menu
	for(var/mob/living/user as anything in linked_mobs)
		if(user in hivemind_users)
			hivemind_users -= user

	hivemind_users -= owner

	var/mob/living/carbon/human/person_to_add = tgui_input_list(owner, "Choose a person to invite to your Hivemind.", "Invite User", hivemind_users)
	if(!person_to_add)
		return

	if(tgui_alert(person_to_add, "[owner] wishes to add you to their Hivemind, do you accept?", "Incoming Hivemind Invite", list("Accept", "Reject")) != "Accept")
		to_chat(owner, span_warning("[person_to_add] denied the request to join your Hivemind."))
		return

	linked_mobs += person_to_add

	var/datum/nifsoft/hivemind/target_hivemind = person_to_add.find_nifsoft(/datum/nifsoft/hivemind)

	if(!target_hivemind)
		return FALSE

	target_hivemind.network_list += src
	to_chat(person_to_add, span_abductor("You have now been added to [owner]'s Hivemind"))
	to_chat(owner, span_abductor("[person_to_add] has now been added to your Hivemind"))

///Removes a user from the list of connected people within a hivemind
/datum/component/mind_linker/active_linking/nif/proc/remove_user()
	var/mob/living/carbon/human/owner = parent
	var/mob/living/carbon/human/person_to_remove = tgui_input_list(owner, "Choose a person to remove from your Hivemind.", "Remove User", linked_mobs)

	if(!person_to_remove)
		return

	var/datum/nifsoft/hivemind/target_hivemind
	target_hivemind = person_to_remove.find_nifsoft(/datum/nifsoft/hivemind)

	if(!target_hivemind)
		return FALSE

	linked_mobs -= person_to_remove
	target_hivemind.network_list -= src
	to_chat(person_to_remove, span_abductor("You have now been removed from [owner]'s Hivemind."))
	to_chat(owner, span_abductor("[person_to_remove] has now been removed from your Hivemind."))

/datum/component/mind_linker/active_linking/nif/proc/change_chat_color()
	var/mob/living/carbon/human/owner = parent
	var/new_chat_color = tgui_color_picker(owner, "", "Choose Color", COLOR_ASSEMBLY_GREEN)

	if(!new_chat_color)
		return FALSE

	chat_color = new_chat_color

/obj/item/hivemind_keyboard
	name = "Hivemind Interface Device"
	desc = "A holographic gesture controller, hooked to hand and finger signals of the user's own choice. This is paired with the Hivemind program itself, used as a means of filtering out unwanted thoughts from being added to the network, ensuring that only intentional thoughts of communication can go through."
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "generic_delivery"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	inhand_icon_state = "electronic"
	///What Hivemind are messages being sent to?
	var/datum/component/mind_linker/active_linking/nif/connected_network
	//Who owns the controller?
	var/datum/weakref/source_user

/obj/item/hivemind_keyboard/Destroy(force)
	. = ..()
	connected_network = null

/obj/item/hivemind_keyboard/attack_self(mob/user, modifiers)
	. = ..()
	send_message(user)

/obj/item/hivemind_keyboard/proc/send_message(mob/living/carbon/human/user)
	var/mob/living/carbon/human/kebyoard_owner = source_user
	var/mob/living/carbon/human/network_owner = connected_network.parent
	var/message = tgui_input_text(user, "Enter a message to transmit.", "[connected_network.network_name] Telepathy")
	if(!message || QDELETED(src) || QDELETED(user) || user.stat == DEAD)
		return

	if(QDELETED(connected_network))
		to_chat(user, span_warning("The link seems to have been severed."))
		return

	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/chat)
	var/tag = sheet.icon_tag("nif-phone")
	var/hivemind_icon = ""

	if(tag)
		hivemind_icon = tag

	var/formatted_message = "<i><font color=[connected_network.chat_color]>\ [hivemind_icon][network_owner.real_name]'s [connected_network.network_name]\] <b>[kebyoard_owner]:</b> [message]</font></i>"
	log_directed_talk(user, network_owner, message, LOG_SAY, "mind link ([connected_network.network_name])")

	var/list/all_who_can_hear = assoc_to_keys(connected_network.linked_mobs) + network_owner

	for(var/mob/living/recipient as anything in all_who_can_hear)
		var/avoid_highlighting = (recipient == user) || (network_owner == user)
		to_chat(recipient, formatted_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = avoid_highlighting)

	for(var/mob/recipient as anything in GLOB.dead_mob_list)
		to_chat(recipient, "[FOLLOW_LINK(recipient, user)] [formatted_message]", type = MESSAGE_TYPE_RADIO)

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
