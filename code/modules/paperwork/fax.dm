/obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "fax"
	density = TRUE
	power_channel = AREA_USAGE_EQUIP
	max_integrity = 100
	pass_flags = PASSTABLE
	/// The unique ID by which the fax will build a list of existing faxes.
	var/fax_id
	/// The name of the fax displayed in the list. Not necessarily unique to some EMAG jokes.
	var/fax_name
	/// A reference to an `/obj/item/paper` inside the copier, if one is inserted. Otherwise null.
	var/obj/item/paper/paper_contain
	/// Necessary to hide syndicate faxes from the general list
	var/syndicate_network = FALSE

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

/obj/machinery/fax/emag_act(mob/user)
	if(!(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		playsound(src, 'sound/creatures/dog/growl2.ogg', 50, FALSE)
		to_chat(user, span_warning("An image appears on [src] screen for a moment with Ian in the cap of a Syndicate officer."))

/obj/machinery/fax/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/fax/multitool_act(mob/living/user, obj/item/I)
	var/new_fax_name = tgui_input_text(user, "Enter a new name for the fax machine.", "New Fax Name", , 128)
	if(!new_fax_name)
		return
	if (new_fax_name != fax_name)
		if (fax_name_exist(new_fax_name))
			// Being able to set the same name as another fax machine will give a lot of gimmicks for the traitor.
			if (syndicate_network != TRUE && obj_flags != EMAGGED)
				to_chat(user, span_warning("There is already a fax machine with this name on the network."))
				return
			fax_name = new_fax_name
		return

/obj/machinery/fax/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper))
		if(!paper_contain)
			paper_contain = I
			I.forceMove(src)
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
	var/faxes[0]
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		// To avoid putting yourself on the list
		if(FAX.fax_id != fax_id)
			if(FAX.syndicate_network != TRUE)
				faxes.Add(list(list("id" = FAX.fax_id, "name" = FAX.fax_name)))
			else if (syndicate_network == TRUE || obj_flags & EMAGGED)
				faxes.Add(list(list("id" = FAX.fax_id, "name" = FAX.fax_name)))

	data["faxes"] = faxes
	data["fax_id"] = fax_id
	data["fax_name"] = fax_name
	data["has_paper"] = paper_contain ? TRUE : FALSE

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

/obj/machinery/fax/proc/send(obj/item/paper/paper, id)
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		if (FAX.fax_id == id)
			FAX.receive(paper, fax_name)
			flick("fax_send", src)
			playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)
			return TRUE
	return FALSE

/obj/machinery/fax/proc/receive(obj/item/paper/paper, sender_name)
	playsound(src, 'sound/machines/printer.ogg', 50, FALSE)
	flick(paper_contain ? "fax_contain_receive" : "fax_contain", src)
	say("Received correspondence from [sender_name]")
	paper.forceMove(drop_location())

/obj/machinery/fax/proc/fax_name_exist(new_fax_name)
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		if (FAX.fax_name == new_fax_name)
			return TRUE
	return FALSE
