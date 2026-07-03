/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "Интерфейс для взаимодействия экипажа с системами контроля криогенного хранилища."
	icon = 'modular_bandastation/cryosleep/icons/cryogenics.dmi'
	icon_state = "cellconsole_1"
	icon_keyboard = null
	icon_screen = null
	use_power = FALSE
	density = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_COMMAND, ACCESS_ARMORY) // Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	verb_say = "coldly states"
	verb_ask = "queries"
	verb_exclaim = "alarms"

	/// Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	/// The items currently stored in the cryopod control panel.
	var/list/frozen_items = list()

	/// This is what the announcement system uses to make announcements. Make sure to set a radio that has the channel you want to broadcast on.
	var/obj/item/radio/headset/radio = null
	/// The channel to be broadcast on, valid values are the values of any of the "RADIO_CHANNEL_" defines.
	var/announcement_channel = null // RADIO_CHANNEL_COMMON doesn't work here.

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/cryopod, 32)

/obj/machinery/computer/cryopod/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/computer/cryopod/update_icon_state()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "cellconsole"
		return ..()
	icon_state = "cellconsole_1"
	return ..()

/obj/machinery/computer/cryopod/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	add_fingerprint(user)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CryopodConsole", name)
		ui.open()

/obj/machinery/computer/cryopod/ui_data(mob/user)
	var/list/data = list()
	data["frozen_crew"] = frozen_crew

	/// The list of references to the stored items.
	var/list/item_ref_list = list()
	/// The associative list of the reference to an item and its name.
	var/list/item_ref_name = list()

	for(var/obj/item/item in frozen_items)
		var/ref = REF(item)
		item_ref_list += ref
		item_ref_name[ref] = item.declent_ru(NOMINATIVE)

	data["item_ref_list"] = item_ref_list
	data["item_ref_name"] = item_ref_name

	// Check Access for item dropping.
	var/item_retrieval_allowed = allowed(user)
	data["item_retrieval_allowed"] = item_retrieval_allowed

	var/obj/item/card/id/id_card
	if(isliving(user))
		var/mob/living/person = user
		id_card = person.get_idcard()
	if(id_card?.registered_name)
		data["account_name"] = id_card.registered_name

	return data

/obj/machinery/computer/cryopod/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("item_get")
			var/item_get = params["item_get"]
			var/obj/item/item = locate(item_get)
			if(!(item in frozen_items))
				stack_trace("Invalid REF# for ui_act. Not inside internal list!")
				return FALSE

			item.forceMove(drop_location())
			frozen_items.Remove(item_get, item)
			visible_message("[capitalize(declent_ru(NOMINATIVE))] выдаёт [item.declent_ru(NOMINATIVE)].")
			message_admins("[item] was retrieved from cryostorage at [ADMIN_COORDJMP(src)]")
			return TRUE

/// Called when a crew member is frozen by the cryopod
/obj/machinery/computer/cryopod/proc/on_crewmember_frozen(mob/living/mob_to_freeze)
	if(!istype(mob_to_freeze))
		return

	var/occupant_name = mob_to_freeze.real_name
	var/mob_rank = job_title_ru(mob_to_freeze.mind?.assigned_role.title) || "Неизвестная должность"
	frozen_crew += list(list("name" = occupant_name, "job" = mob_rank))

	announce(
		occupant_name,
		mob_rank,
		mob_to_freeze.mind?.assigned_role.departments_bitflags,
		mob_to_freeze.mind?.assigned_role.default_radio_channel,
		mob_to_freeze.gender
	)

/obj/machinery/computer/cryopod/proc/store_item(mob/item_holder, obj/item/item_to_store)
	item_holder.transferItemToLoc(item_to_store, src, force = TRUE, silent = TRUE)
	item_to_store.dropped(item_holder)
	frozen_items += item_to_store

/// Used to broadcast announcements
/obj/machinery/computer/cryopod/proc/announce(user, rank, occupant_departments_bitflags, occupant_job_radio, occupant_gender)
	if(!radio)
		radio = new/obj/item/radio/headset/silicon/ai()

	if(occupant_job_radio)
		if(occupant_departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			if(occupant_job_radio != RADIO_CHANNEL_COMMAND)
				radio.talk_into(src, "[user][rank ? ", [rank]," : ""] был[genderize_ru(occupant_gender, "", "а", "о", "и")] перемещ[genderize_ru(occupant_gender, "ён", "ена", "ено", "ены")] в криогенное хранилище.", RADIO_CHANNEL_COMMAND)
			radio.use_command = TRUE

		radio.talk_into(src, "[user][rank ? ", [rank]," : ""] был[genderize_ru(occupant_gender, "", "а", "о", "и")] перемещ[genderize_ru(occupant_gender, "ён", "ена", "ено", "ены")] в криогенное хранилище.", occupant_job_radio)
		radio.use_command = FALSE

	radio.talk_into(src, "[user][rank ? ", [rank]," : ""] был[genderize_ru(occupant_gender, "", "а", "о", "и")] перемещ[genderize_ru(occupant_gender, "ён", "ена", "ено", "ены")] в криогенное хранилище.", announcement_channel)
