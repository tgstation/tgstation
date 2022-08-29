/obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "fax"
	density = TRUE
	power_channel = AREA_USAGE_EQUIP
	max_integrity = 100
	pass_flags = PASSTABLE
	circuit = /obj/item/circuitboard/machine/fax
	/// The unique ID by which the fax will build a list of existing faxes.
	var/fax_id
	/// The name of the fax displayed in the list. Not necessarily unique to some EMAG jokes.
	var/fax_name
	/// A reference to an `/obj/item/paper` inside the copier, if one is inserted. Otherwise null.
	var/obj/item/paper/paper_contain
	/// Necessary to hide syndicate faxes from the general list. Doesn't mean he's EMAGGED!
	var/syndicate_network = FALSE
	/// This is where the dispatch and reception history for each fax is stored.
	var/list/fax_history = list()

/obj/machinery/fax/Initialize(mapload)
	. = ..()
	if (!fax_id)
		fax_id = SSnetworks.assign_random_name()
	if (!fax_name)
		fax_name = "Unregistered fax " + fax_id

/obj/machinery/fax/Destroy()
	QDEL_NULL(paper_contain)
	return ..()

/obj/machinery/fax/update_icon_state()
	if(paper_contain)
		icon_state = "fax_contain"
	else
		icon_state = "fax"
	return ..()

//Emag does not bring you into the syndicate network, but makes it visible to you.
/obj/machinery/fax/emag_act(mob/user)
	if(!(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		playsound(src, 'sound/creatures/dog/growl2.ogg', 50, FALSE)
		to_chat(user, span_warning("An image appears on [src] screen for a moment with Ian in the cap of a Syndicate officer."))

/obj/machinery/fax/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

// Using the multi-tool causes the fax network name to be renamed
/obj/machinery/fax/multitool_act(mob/living/user, obj/item/I)
	var/new_fax_name = tgui_input_text(user, "Enter a new name for the fax machine.", "New Fax Name", , 128)
	if(!new_fax_name)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (new_fax_name != fax_name)
		if (fax_name_exist(new_fax_name))
			// Being able to set the same name as another fax machine will give a lot of gimmicks for the traitor.
			if (syndicate_network != TRUE && obj_flags != EMAGGED)
				to_chat(user, span_warning("There is already a fax machine with this name on the network."))
				return TOOL_ACT_TOOLTYPE_SUCCESS
		fax_name = new_fax_name
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/fax/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/paper))
		if(!paper_contain)
			paper_contain = item
			item.forceMove(src)
			update_appearance()
		return
	return ..()

/obj/machinery/fax/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fax")
		ui.open()

/obj/machinery/fax/ui_data(mob/user)
	var/list/data = list()
	//Record a list of all existing faxes.
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		if(FAX.fax_id == fax_id) //skip yourself
			continue
		var/list/fax_data = list()
		fax_data["fax_name"] = FAX.fax_name
		fax_data["fax_id"] = FAX.fax_id
		fax_data["has_paper"] = !!FAX.paper_contain
		// Hacked doesn't mean on the syndicate network.
		fax_data["syndicate_network"] = FAX.syndicate_network
		data["faxes"] += list(fax_data)

	// Own data
	data["fax_id"] = fax_id
	data["fax_name"] = fax_name
	// In this case, we don't care if the fax is hacked or in the syndicate's network. The main thing is to check the visibility of other faxes.
	data["syndicate_network"] = (syndicate_network || (obj_flags & EMAGGED))
	data["has_paper"] = !!paper_contain
	data["fax_history"] = fax_history
	return data

/obj/machinery/fax/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		// Pulls the paper out of the fax machine
		if("remove")
			var/obj/item/paper/paper = paper_contain
			paper.forceMove(drop_location())
			paper_contain = null
			playsound(src, 'sound/machines/eject.ogg', 50, FALSE)
			update_appearance()
			return TRUE
		if("send")
			if(send(paper_contain, params["id"]))
				paper_contain = null
				update_appearance()
				return TRUE
		if("history_clear")
			history_clear()
			return TRUE

/**
 * The procedure for sending a paper to another fax machine.
 *
 * The object is called inside /obj/machinery/fax to send the paper to another fax machine.
 * The procedure searches among all faxes for the desired fax ID and calls proc/receive() on that fax.
 * If the paper is sent successfully, it returns TRUE.
 * Arguments:
 * * paper - The object of the paper to be sent.
 * * id - The network ID of the fax machine you want to send the paper to.
 */
/obj/machinery/fax/proc/send(obj/item/paper/paper, id)
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		if (FAX.fax_id == id)
			FAX.receive(paper, fax_name)
			history_add("Send", FAX.fax_name)
			flick("fax_send", src)
			playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)
			return TRUE
	return FALSE

/**
 * Procedure for accepting papers from another fax machine.
 *
 * The procedure is called in proc/send() of the other fax. It receives a paper object and "prints" it.
 * Arguments:
 * * paper - The object of the paper to be printed.
 * * sender_name - The sender's name, which will be displayed in the message and recorded in the history of operations.
 */
/obj/machinery/fax/proc/receive(obj/item/paper/paper, sender_name)
	playsound(src, 'sound/machines/printer.ogg', 50, FALSE)
	flick(paper_contain ? "fax_contain_receive" : "fax_receive", src)
	say("Received correspondence from [sender_name].")
	history_add("Receive", sender_name)
	paper.forceMove(drop_location())

/**
 * A procedure that makes entries in the history of fax transactions.
 *
 * Called to record the operation in the fax history list.
 * Records the type of operation, the name of the fax machine with which the operation was performed, and the station time.
 * Arguments:
 * * history_type - Type of operation. By default, "Send" and "Receive" should be used.
 * * history_fax_name - The name of the fax machine that performed the operation.
 */
/obj/machinery/fax/proc/history_add(history_type = "Send", history_fax_name)
	var/list/history_data = list()
	history_data["history_type"] = history_type
	history_data["history_fax_name"] = history_fax_name
	history_data["history_time"] = station_time_timestamp()
	fax_history += list(history_data)

// Clears the history of fax operations.
/obj/machinery/fax/proc/history_clear()
	fax_history = null

/**
 * Checks fax names for a match.
 *
 * Called to check the new fax name against the names of other faxes to prevent the use of identical names.
 * Arguments:
 * * new_fax_name - The text of the name to be checked for a match.
 */
/obj/machinery/fax/proc/fax_name_exist(new_fax_name)
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		if (FAX.fax_name == new_fax_name)
			return TRUE
	return FALSE
