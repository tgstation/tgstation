GLOBAL_VAR_INIT(nt_fax_department, pick("NT HR Department", "NT Legal Department", "NT Complaint Department", "NT Customer Relations", "Nanotrasen Tech Support", "NT Internal Affairs Dept"))

/obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	density = TRUE
	anchored_tabletop_offset = 6
	power_channel = AREA_USAGE_EQUIP
	max_integrity = 100
	pass_flags = PASSTABLE
	circuit = /obj/item/circuitboard/machine/fax
	/// The unique ID by which the fax will build a list of existing faxes.
	var/fax_id
	/// The name of the fax displayed in the list. Not necessarily unique to some EMAG jokes.
	var/fax_name
	/// A weak reference to an inserted object.
	var/datum/weakref/loaded_item_ref
	/// World ticks the machine is electified for.
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If true, the fax machine is jammed and needs cleaning
	var/jammed = FALSE
	/// Necessary to hide syndicate faxes from the general list. Doesn't mean he's EMAGGED!
	var/syndicate_network = FALSE
	/// True if the fax machine should be visible to other fax machines in general.
	var/visible_to_network = TRUE
	/// If true we will eject faxes at speed rather than sedately place them into a tray.
	var/hurl_contents = FALSE
	/// If true you can fax things which strictly speaking are not paper.
	var/allow_exotic_faxes = FALSE
	/// This is where the dispatch and reception history for each fax is stored.
	var/list/fax_history = list()
	/// List of types which should always be allowed to be faxed
	var/static/list/allowed_types = list(
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/tcgcard
	)
	/// List of types which should be allowed to be faxed if hacked
	var/static/list/exotic_types = list(
		/obj/item/food/pizzaslice,
		/obj/item/food/root_flatbread,
		/obj/item/food/pizza/flatbread,
		/obj/item/food/breadslice,
		/obj/item/food/salami,
		/obj/item/throwing_star,
		/obj/item/stack/spacecash,
		/obj/item/holochip,
		/obj/item/card,
		/obj/item/folder/biscuit,
	)
	/// List with a fake-networks(not a fax actually), for request manager.
	var/list/special_networks = list(
		nanotrasen = list(fax_name = "NT HR Department", fax_id = "central_command", color = "teal", emag_needed = FALSE),
		syndicate = list(fax_name = "Sabotage Department", fax_id = "syndicate", color = "red", emag_needed = TRUE),
	)

/obj/machinery/fax/Initialize(mapload)
	. = ..()
	if (!fax_id)
		fax_id = assign_random_name()
	if (!fax_name)
		fax_name = "Unregistered fax " + fax_id
	set_wires(new /datum/wires/fax(src))
	register_context()
	special_networks["nanotrasen"]["fax_name"] = GLOB.nt_fax_department

/obj/machinery/fax/Destroy()
	QDEL_NULL(loaded_item_ref)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/fax/update_overlays()
	. = ..()
	if (panel_open)
		. += "fax_panel"
	var/obj/item/loaded = loaded_item_ref?.resolve()
	if (loaded)
		. += mutable_appearance(icon, find_overlay_state(loaded, "contain"))

/obj/machinery/fax/examine()
	. = ..()
	if(jammed)
		. += span_notice("Its output port is jammed and needs cleaning.")


/obj/machinery/fax/on_set_is_operational(old_value)
	if (old_value == FALSE)
		START_PROCESSING(SSmachines, src)
		return
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/fax/process(seconds_per_tick)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified -= seconds_per_tick

/obj/machinery/fax/attack_hand(mob/user, list/modifiers)
	if(seconds_electrified && !(machine_stat & NOPOWER))
		if(shock(user, 100))
			return
	return ..()

/***
 * Emag the device if the panel is open.
 * Emag does not bring you into the syndicate network, but makes it visible to you.
 */
/obj/machinery/fax/emag_act(mob/user, obj/item/card/emag/emag_card)
	if (!panel_open && !allow_exotic_faxes)
		balloon_alert(user, "open panel first!")
		return FALSE
	if (!(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		playsound(src, 'sound/creatures/dog/growl2.ogg', 50, FALSE)
		balloon_alert(user, "migrated to syndienet 2.0")
		to_chat(user, span_warning("An image appears on [src] screen for a moment with Ian in the cap of a Syndicate officer."))
		return TRUE
	return FALSE

/obj/machinery/fax/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/**
 * Open and close the wire panel.
 */
/obj/machinery/fax/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ..()
	default_deconstruction_screwdriver(user, icon_state, icon_state, screwdriver)
	update_appearance()
	return TRUE

/**
 * Using the multi-tool with the panel closed causes the fax network name to be renamed.
 */
/obj/machinery/fax/multitool_act(mob/living/user, obj/item/I)
	if (panel_open)
		return
	var/new_fax_name = tgui_input_text(user, "Enter a new name for the fax machine.", "New Fax Name", , 128)
	if (!new_fax_name)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (new_fax_name != fax_name)
		if (fax_name_exist(new_fax_name))
			// Being able to set the same name as another fax machine will give a lot of gimmicks for the traitor.
			if (syndicate_network != TRUE && !(obj_flags & EMAGGED))
				to_chat(user, span_warning("There is already a fax machine with this name on the network."))
				return TOOL_ACT_TOOLTYPE_SUCCESS
		user.log_message("renamed [fax_name] (fax machine) to [new_fax_name].", LOG_GAME)
		fax_name = new_fax_name
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/fax/attackby(obj/item/item, mob/user, params)
	if (jammed && clear_jam(item, user))
		return
	if (panel_open)
		if (is_wire_tool(item))
			wires.interact(user)
		return
	if (can_load_item(item))
		if (!loaded_item_ref?.resolve())
			loaded_item_ref = WEAKREF(item)
			item.forceMove(src)
			update_appearance()
		return
	return ..()

/**
 * Attempts to clean out a jammed machine using a passed item.
 * Returns true if successful.
 */
/obj/machinery/fax/proc/clear_jam(obj/item/item, mob/user)
	if (istype(item, /obj/item/reagent_containers/spray))
		var/obj/item/reagent_containers/spray/clean_spray = item
		if(!clean_spray.reagents.has_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this))
			return FALSE
		clean_spray.reagents.remove_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this, 1)
		playsound(loc, 'sound/effects/spray3.ogg', 50, TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)
		user.visible_message(span_notice("[user] cleans \the [src]."), span_notice("You clean \the [src]."))
		jammed = FALSE
		return TRUE
	if (istype(item, /obj/item/soap) || istype(item, /obj/item/reagent_containers/cup/rag))
		var/cleanspeed = 50
		if (istype(item, /obj/item/soap))
			var/obj/item/soap/used_soap = item
			cleanspeed = used_soap.cleanspeed
		user.visible_message(span_notice("[user] starts to clean \the [src]."), span_notice("You start to clean \the [src]..."))
		if (do_after(user, cleanspeed, target = src))
			user.visible_message(span_notice("[user] cleans \the [src]."), span_notice("You clean \the [src]."))
			jammed = FALSE
		return TRUE
	return FALSE

/**
 * Returns true if an item can be loaded into the fax machine.
 */
/obj/machinery/fax/proc/can_load_item(obj/item/item)
	if(!is_allowed_type(item))
		return FALSE
	if (!istype(item, /obj/item/stack))
		return TRUE
	var/obj/item/stack/stack_item = item
	return stack_item.amount == 1

/**
 * Returns true if an item is of a type which can currently be loaded into this fax machine.
 * This list expands if you snip a particular wire.
 */
/obj/machinery/fax/proc/is_allowed_type(obj/item/item)
	if (is_type_in_list(item, allowed_types))
		return TRUE
	if (!allow_exotic_faxes)
		return FALSE
	return is_type_in_list(item, exotic_types)

/obj/machinery/fax/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fax")
		ui.open()

/obj/machinery/fax/ui_data(mob/user)
	var/list/data = list()
	//Record a list of all existing faxes.
	for(var/obj/machinery/fax/FAX as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/fax))
		if(FAX.fax_id == fax_id) //skip yourself
			continue
		var/list/fax_data = list()
		fax_data["fax_name"] = FAX.fax_name
		fax_data["fax_id"] = FAX.fax_id
		fax_data["visible"] = FAX.visible_to_network
		fax_data["has_paper"] = !!FAX.loaded_item_ref?.resolve()
		// Hacked doesn't mean on the syndicate network.
		fax_data["syndicate_network"] = FAX.syndicate_network
		data["faxes"] += list(fax_data)

	// Own data
	data["fax_id"] = fax_id
	data["fax_name"] = fax_name
	data["visible"] = visible_to_network
	// In this case, we don't care if the fax is hacked or in the syndicate's network. The main thing is to check the visibility of other faxes.
	data["syndicate_network"] = (syndicate_network || (obj_flags & EMAGGED))
	data["has_paper"] = !!loaded_item_ref?.resolve()
	data["fax_history"] = fax_history
	var/list/special_networks_data = list()
	for(var/key in special_networks)
		special_networks_data += list(special_networks[key])
	data["special_faxes"] = special_networks_data
	return data

/obj/machinery/fax/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		// Pulls the paper out of the fax machine
		if("remove")
			var/obj/item/loaded = loaded_item_ref?.resolve()
			if (!loaded)
				return
			loaded.forceMove(drop_location())
			loaded_item_ref = null
			playsound(src, 'sound/machines/eject.ogg', 50, FALSE)
			update_appearance()
			return TRUE

		if("send")
			var/obj/item/loaded = loaded_item_ref?.resolve()
			if (!loaded)
				return
			var/destination = params["id"]
			if(send(loaded, destination))
				log_fax(loaded, destination, params["name"])
				loaded_item_ref = null
				update_appearance()
				return TRUE

		if("send_special")
			var/obj/item/paper/fax_paper = loaded_item_ref?.resolve()
			if(!istype(fax_paper))
				to_chat(usr, icon2html(src.icon, usr) + span_warning("Fax cannot send all above paper on this protected network, sorry."))
				return

			fax_paper.request_state = TRUE
			fax_paper.loc = null

			INVOKE_ASYNC(src, PROC_REF(animate_object_travel), fax_paper, "fax_receive", find_overlay_state(fax_paper, "send"))
			playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, vary = FALSE)

			history_add("Send", params["name"])

			GLOB.requests.fax_request(usr.client, "sent a fax message from [fax_name]/[fax_id] to [params["name"]]", fax_paper)
			to_chat(GLOB.admins, span_adminnotice("[icon2html(src.icon, GLOB.admins)]<b><font color=green>FAX REQUEST: </font>[ADMIN_FULLMONTY(usr)]:</b> [span_linkify("sent a fax message from [fax_name]/[fax_id][ADMIN_FLW(src)] to [html_encode(params["name"])]")] [ADMIN_SHOW_PAPER(fax_paper)]"), confidential = TRUE)
			for(var/client/staff as anything in GLOB.admins)
				if(staff?.prefs.read_preference(/datum/preference/toggle/comms_notification))
					SEND_SOUND(staff, sound('sound/misc/server-ready.ogg'))
			log_fax(fax_paper, params["id"], params["name"])
			loaded_item_ref = null
			update_appearance()

		if("history_clear")
			history_clear()
			return TRUE

/**
 * Records logs of bureacratic action
 * Arguments:
 * * sent - The object being sent
 * * destination_id - The unique ID of the fax machine
 * * name - The friendly name of the fax machine, but these can be spoofed so the ID is also required
 */
/obj/machinery/fax/proc/log_fax(obj/item/sent, destination_id, name)
	if (istype(sent, /obj/item/paper))
		var/obj/item/paper/sent_paper = sent
		log_paper("[usr] has sent a fax with the message \"[sent_paper.get_raw_text()]\" to [name]/[destination_id].")
		return
	log_game("[usr] has faxed [sent] to [name]/[destination_id].]")

/**
 * The procedure for sending a paper to another fax machine.
 *
 * The object is called inside /obj/machinery/fax to send the thing to another fax machine.
 * The procedure searches among all faxes for the desired fax ID and calls proc/receive() on that fax.
 * If the item is sent successfully, it returns TRUE.
 * Arguments:
 * * loaded - The object to be sent.
 * * id - The network ID of the fax machine you want to send the item to.
 */
/obj/machinery/fax/proc/send(obj/item/loaded, id)
	for(var/obj/machinery/fax/FAX as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/fax))
		if (FAX.fax_id != id)
			continue
		if (FAX.jammed)
			do_sparks(5, TRUE, src)
			balloon_alert(usr, "destination port jammed")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			return FALSE
		FAX.receive(loaded, fax_name)
		history_add("Send", FAX.fax_name)
		INVOKE_ASYNC(src, PROC_REF(animate_object_travel), loaded, "fax_receive", find_overlay_state(loaded, "send"))
		playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)
		return TRUE
	return FALSE

/**
 * Procedure for accepting papers from another fax machine.
 *
 * The procedure is called in proc/send() of the other fax. It receives a paper-like object and "prints" it.
 * Arguments:
 * * loaded - The object to be printed.
 * * sender_name - The sender's name, which will be displayed in the message and recorded in the history of operations.
 */
/obj/machinery/fax/proc/receive(obj/item/loaded, sender_name)
	playsound(src, 'sound/machines/printer.ogg', 50, FALSE)
	INVOKE_ASYNC(src, PROC_REF(animate_object_travel), loaded, "fax_receive", find_overlay_state(loaded, "receive"))
	say("Received correspondence from [sender_name].")
	history_add("Receive", sender_name)
	addtimer(CALLBACK(src, PROC_REF(vend_item), loaded), 1.9 SECONDS)

/**
 * Procedure for animating an object entering or leaving the fax machine.
 * Arguments:
 * * item - The object which is travelling.
 * * animation_state - An icon state to apply to the fax machine.
 * * overlay_state - An icon state to apply as an overlay to the fax machine.
 */
/obj/machinery/fax/proc/animate_object_travel(obj/item/item, animation_state, overlay_state)
	icon_state = animation_state
	var/mutable_appearance/overlay = mutable_appearance(icon, overlay_state)
	overlays += overlay
	addtimer(CALLBACK(src, PROC_REF(travel_animation_complete), overlay), 2 SECONDS)

/**
 * Called when the travel animation should end. Reset animation and overlay states.
 * Arguments:
 * * remove_overlay - Overlay to remove.
 */
/obj/machinery/fax/proc/travel_animation_complete(mutable_appearance/remove_overlay)
	icon_state = "fax"
	overlays -= remove_overlay

/**
 * Returns an appropriate icon state to represent a passed item.
 * Arguments:
 * * item - Item to interrogate.
 * * state_prefix - Icon state action prefix to mutate.
 */
/obj/machinery/fax/proc/find_overlay_state(obj/item/item, state_prefix)
	if (istype(item, /obj/item/paper))
		return "[state_prefix]_paper"
	if (istype(item, /obj/item/photo))
		return "[state_prefix]_photo"
	if (iscash(item))
		return "[state_prefix]_cash"
	if (istype(item, /obj/item/card))
		return "[state_prefix]_id"
	if (istype(item, /obj/item/food))
		return "[state_prefix]_food"
	if (istype(item, /obj/item/throwing_star))
		return "[state_prefix]_star"
	if (istype(item, /obj/item/tcgcard))
		return "[state_prefix]_tcg"
	if (istype(item, /obj/item/folder/biscuit))
		return "[state_prefix]_pbiscuit"
	return "[state_prefix]_paper"

/**
 * Actually vends an item out of the fax machine.
 * Moved into its own proc to allow a delay for the animation.
 * This will either deposit the item on the fax machine, or throw it if you have hacked a wire.
 * Arguments:
 * * vend - Item to vend from the fax machine.
 */
/obj/machinery/fax/proc/vend_item(obj/item/vend)
	vend.forceMove(drop_location())
	if (hurl_contents)
		vend.throw_at(get_edge_target_turf(drop_location(), pick(GLOB.alldirs)), rand(1, 4), EMBED_THROWSPEED_THRESHOLD)
	if (is_type_in_list(vend, exotic_types) && prob(20))
		do_sparks(5, TRUE, src)
		jammed = TRUE

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

/// Clears the history of fax operations.
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
	for(var/obj/machinery/fax/FAX as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/fax))
		if (FAX.fax_name == new_fax_name)
			return TRUE
	return FALSE

/**
 * Attempts to shock the passed user, returns true if they are shocked.
 *
 * Arguments:
 * * user - the user to shock
 * * chance - probability the shock happens
 */
/obj/machinery/fax/proc/shock(mob/living/user, chance)
	if(!istype(user) || machine_stat & (BROKEN|NOPOWER))
		return FALSE
	if(!prob(chance))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_area(src), src, 0.7, check_range)


/obj/machinery/fax/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if (!held_item)
		if (!panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Open interface"
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Manipulate wires"
		return CONTEXTUAL_SCREENTIP_SET

	switch (held_item.tool_behaviour)
		if (TOOL_SCREWDRIVER)
			if (panel_open)
				context[SCREENTIP_CONTEXT_LMB] = "Close maintenance panel"
				return CONTEXTUAL_SCREENTIP_SET
			context[SCREENTIP_CONTEXT_LMB] = "Open maintenance panel"
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WRENCH)
			if (anchored)
				context[SCREENTIP_CONTEXT_LMB] = "Unsecure"
				return CONTEXTUAL_SCREENTIP_SET
			context[SCREENTIP_CONTEXT_LMB] = "Secure"
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_MULTITOOL)
			if (panel_open)
				context[SCREENTIP_CONTEXT_LMB] = "Pulse wires"
				return CONTEXTUAL_SCREENTIP_SET
			context[SCREENTIP_CONTEXT_LMB] = "Rename in network"
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WIRECUTTER)
			if (!panel_open)
				return .
			context[SCREENTIP_CONTEXT_LMB] = "Manipulate wires"
			return CONTEXTUAL_SCREENTIP_SET

	if (jammed && is_type_in_list(held_item, list(/obj/item/reagent_containers/spray, /obj/item/soap, /obj/item/reagent_containers/cup/rag)))
		context[SCREENTIP_CONTEXT_LMB] = "Clean output tray"
		return CONTEXTUAL_SCREENTIP_SET

	if (panel_open)
		if (istype(held_item, /obj/item/card/emag))
			context[SCREENTIP_CONTEXT_LMB] = "Remove network safeties"
			return CONTEXTUAL_SCREENTIP_SET
		return .

	if (is_allowed_type(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Insert into fax machine"
		return CONTEXTUAL_SCREENTIP_SET

	return .

/// Sends a fax to a fax machine in an area! fax_area is a type, where all subtypes are also queried. If multiple machines, one is randomly picked
/// If force is TRUE, we send a droppod with a fax machine and fax the message to that fax machine
/proc/send_fax_to_area(obj/item/fax_item, area_type, sender, force = FALSE, force_pod_type)
	var/list/fax_machines = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/fax)
	var/list/valid_fax_machines = list()

	for(var/obj/machinery/fax as anything in fax_machines) //get valid fax machines
		var/area/fax_area = get_area(fax)
		if(istype(fax_area, area_type))
			valid_fax_machines += fax

	// Pick a fax machine and send the fax
	if(valid_fax_machines.len)
		var/obj/machinery/fax/target_fax = pick(valid_fax_machines)
		target_fax.receive(fax_item, sender)

	else if(force) //no fax machines but we really gotte send? SEND A FAX MACHINE
		var/obj/machinery/fax/new_fax_machine = new ()
		send_supply_pod_to_area(new_fax_machine, area_type, force_pod_type)
		addtimer(CALLBACK(new_fax_machine, TYPE_PROC_REF(/obj/machinery/fax, receive), fax_item, sender), 10 SECONDS)

	else
		return FALSE
	return TRUE

