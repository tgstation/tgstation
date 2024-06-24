SUBSYSTEM_DEF(opposing_force)
	name = "Opposing Force"
	flags = SS_NO_FIRE

	/// A precompiled list of all equipment datums, processed on init
	var/list/equipment_list = list()
	/// A list of all currently active objectives
	var/list/unsubmitted_applications = list()
	/// A list of all currently submitted objectives
	var/list/submitted_applications = list()
	/// A list of all approved applications
	var/list/approved_applications = list()
	/// The max amount of objectives that can be tracked
	var/max_objectives = 5
	/// Are we allowing players to make objectives?
	var/accepting_objectives = TRUE
	/// The status of the subsystem
	var/status = OPFOR_SUBSYSTEM_READY

/datum/controller/subsystem/opposing_force/stat_entry(msg)
	msg = "UNSUB: [LAZYLEN(unsubmitted_applications)] | SUB: [LAZYLEN(submitted_applications)] | APPR: [LAZYLEN(approved_applications)]"
	return ..()

/datum/controller/subsystem/opposing_force/Initialize()
	for(var/datum/opposing_force_equipment/opfor_equipment as anything in subtypesof(/datum/opposing_force_equipment))
		// Set up our categories so we can add items to them
		if(initial(opfor_equipment.category))
			var/category = initial(opfor_equipment.category)
			if(!(category in equipment_list))
				// We instansiate the category list so we can add items to it later
				equipment_list[category] = list()
		// These can be considered abstract types, thus do not need to be added.
		if(isnull(initial(opfor_equipment.item_type)))
			continue
		var/datum/opposing_force_equipment/spawned_opfor_equipment = new opfor_equipment()
		// Datums without a name will assume the items name
		spawned_opfor_equipment.name ||= initial(spawned_opfor_equipment.item_type.name)
		// ditto for the description
		spawned_opfor_equipment.description ||= initial(spawned_opfor_equipment.item_type.desc)
		// Now that we've set up our datum, we can add it to the correct category
		if(spawned_opfor_equipment.category)
			// We have a category, let's add it to the associated list
			equipment_list[spawned_opfor_equipment.category] += spawned_opfor_equipment
		else
			// Because of how the UI system works, categories cannot exist with nothing in them, so we
			// only set the OTHER category if something can go inside it!
			if(!(OPFOR_EQUIPMENT_CATEGORY_OTHER in equipment_list))
				equipment_list[OPFOR_EQUIPMENT_CATEGORY_OTHER] = list()
			// We don't have home :( add us to the other category.
			equipment_list[OPFOR_EQUIPMENT_CATEGORY_OTHER] += spawned_opfor_equipment
	equipment_list = sort_list(equipment_list, GLOBAL_PROC_REF(cmp_num_string_asc))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/opposing_force/proc/check_availability()
	if(get_current_applications() >= max_objectives)
		status = OPFOR_SUBSYSTEM_REJECT_CAP
	if(!accepting_objectives)
		status = OPFOR_SUBSYSTEM_REJECT_CLOSED
	status = OPFOR_SUBSYSTEM_READY
	return status

/datum/controller/subsystem/opposing_force/proc/close_objectives()
	accepting_objectives = FALSE

/datum/controller/subsystem/opposing_force/proc/get_queue_position(datum/opposing_force/opposing_force)
	if(!(opposing_force in submitted_applications))
		return "ERROR"
	var/position = 1
	for(var/opfor as anything in submitted_applications)
		if(opposing_force == opfor)
			break
		position++
	return position

/datum/controller/subsystem/opposing_force/proc/add_to_queue(datum/opposing_force/opposing_force)
	if(!LAZYFIND(unsubmitted_applications, opposing_force))
		CRASH("Opposing_force_subsystem: Attempted to add an opposing force to the queue but it was not registered to the subsystem!")

	submitted_applications += opposing_force
	unsubmitted_applications -= opposing_force

	return LAZYLEN(submitted_applications)

/datum/controller/subsystem/opposing_force/proc/broadcast_queue_change(datum/opposing_force/updating_opposing_force)
	for(var/datum/opposing_force/opposing_force in submitted_applications)
		if(opposing_force == updating_opposing_force)
			continue
		opposing_force.broadcast_queue_change()

/datum/controller/subsystem/opposing_force/proc/approve(datum/opposing_force/opposing_force, mob/approver)
	if(!is_admin(approver.client))
		message_admins("Oppoding_force_subsystem: [ADMIN_LOOKUPFLW(approver)] attempted to approve an OPFOR application but was not an admin!")
		CRASH("Opposing_force_subsystem: Attempted to approve an opposing force but the approver ([approver?.ckey]) was not an admin!")

	if(!LAZYFIND(unsubmitted_applications, opposing_force))
		unsubmitted_applications -= opposing_force

	if(LAZYFIND(submitted_applications, opposing_force))
		submitted_applications -= opposing_force

	if(LAZYFIND(approved_applications, opposing_force))
		return

	approved_applications += opposing_force

	opposing_force.approve(approver)

	broadcast_queue_change(opposing_force)

	return TRUE

/datum/controller/subsystem/opposing_force/proc/deny(datum/opposing_force/opposing_force, reason, mob/denier)
	if(!is_admin(denier.client))
		message_admins("Oppoding_force_subsystem: [ADMIN_LOOKUPFLW(denier)] attempted to deny an OPFOR application but was not an admin!")
		CRASH("Opposing_force_subsystem: Attempted to deny an opposing force but the denier ([denier?.ckey]) was not an admin!")

	if(LAZYFIND(submitted_applications, opposing_force))
		submitted_applications -= opposing_force

	if(LAZYFIND(approved_applications, opposing_force))
		approved_applications -= opposing_force

	if(!LAZYFIND(unsubmitted_applications, opposing_force))
		unsubmitted_applications += opposing_force

	opposing_force.deny(denier, reason)

	broadcast_queue_change(opposing_force)

	return TRUE

/datum/controller/subsystem/opposing_force/proc/modify_request(datum/opposing_force/opposing_force, changes)
	if(LAZYFIND(submitted_applications, opposing_force))
		submitted_applications -= opposing_force

	if(LAZYFIND(approved_applications, opposing_force))
		approved_applications -= opposing_force

	if(!LAZYFIND(unsubmitted_applications, opposing_force))
		unsubmitted_applications += opposing_force

	broadcast_queue_change(opposing_force)

/datum/controller/subsystem/opposing_force/proc/get_current_applications()
	return LAZYLEN(submitted_applications) + LAZYLEN(approved_applications)

/datum/controller/subsystem/opposing_force/proc/new_opfor(datum/opposing_force/opposing_force)
	unsubmitted_applications += opposing_force

/datum/controller/subsystem/opposing_force/proc/remove_opfor(datum/opposing_force/opposing_force)
	if(LAZYFIND(unsubmitted_applications, opposing_force))
		unsubmitted_applications -= opposing_force
	if(LAZYFIND(submitted_applications, opposing_force))
		submitted_applications -= opposing_force
	if(LAZYFIND(approved_applications, opposing_force))
		approved_applications -= opposing_force

	broadcast_queue_change()

/datum/controller/subsystem/opposing_force/proc/unsubmit_opfor(datum/opposing_force/opposing_force)
	if(LAZYFIND(approved_applications, opposing_force))
		approved_applications -= opposing_force
	if(LAZYFIND(submitted_applications, opposing_force))
		submitted_applications -= opposing_force
	if(!LAZYFIND(unsubmitted_applications, opposing_force))
		unsubmitted_applications += opposing_force


	broadcast_queue_change()

/datum/controller/subsystem/opposing_force/proc/view_opfor(datum/opposing_force/opposing_force, mob/viewer)
	if(!is_admin(viewer.client))
		message_admins("Oppoding_force_subsystem: [ADMIN_LOOKUPFLW(viewer)] attempted to view an OPFOR application but was not an admin!")
		CRASH("Opposing_force_subsystem: Attempted to view an opposing force but the viewer was not an admin!")

	opposing_force.ui_interact(viewer)

/datum/controller/subsystem/opposing_force/proc/get_check_antag_listing()
	var/list/returned_html = list("<br>")

	returned_html += "<b>OPFOR Applications</b>"

	returned_html += "Submitted - FOLLOW QUEUE!"
	var/queue_count = 1
	for(var/datum/opposing_force/opposing_force in submitted_applications)
		returned_html += " - <b>[queue_count].</b> [opposing_force.build_html_panel_entry()]"
		queue_count++

	returned_html += "Approved"
	for(var/datum/opposing_force/opposing_force in approved_applications)
		returned_html += " - [opposing_force.build_html_panel_entry()]"

	returned_html += "Unsubmitted"
	for(var/datum/opposing_force/opposing_force in unsubmitted_applications)
		returned_html += " - [opposing_force.build_html_panel_entry()]"

	return returned_html.Join("<br>")

/// Gives a mind the opfor action button, which calls the opfor verb when pressed
/datum/controller/subsystem/opposing_force/proc/give_opfor_button(mob/living/carbon/human/player)
	var/datum/action/opfor/info_button
	info_button = new(src)
	info_button.Grant(player)
