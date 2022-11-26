GLOBAL_LIST_EMPTY(TabletMessengers) // a list of all active messengers, similar to GLOB.PDAs (used primarily with ntmessenger.dm)

// This is the base type of computer
// Other types expand it - tablets and laptops are subtypes
// consoles use "procssor" item that is held inside it.
/obj/item/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."
	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop-open"
	light_on = FALSE
	integrity_failure = 0.5
	max_integrity = 100
	armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	light_system = MOVABLE_LIGHT_DIRECTIONAL

	/// Starting programs for this computer
	var/list/datum/computer_file/program/starting_programs = list()
	/// The bulk of modular computer code
	var/datum/modular_computer_host/cpu

	/// Icon state when the computer is turned off.
	var/icon_state_unpowered = null
	/// Icon state when the computer is turned on.
	var/icon_state_powered = null
	/// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/icon_state_menu = "menu"
	/// If FALSE, don't draw overlays on this device at all
	var/display_overlays = TRUE

	/// Allow people with chunky fingers to use?
	var/allow_chunky = FALSE


/obj/item/modular_computer/Initialize(mapload)
	. = ..()

	cpu = AddComponent(/datum/modular_computer_host)

	//set_light_color(cpu.comp_light_color)
	//set_light_range(cpu.comp_light_luminosity)
	//if(cpu.looping_sound)
	//	cpu.soundloop = new(src, cpu.powered_on)
	//cpu.UpdateDisplay()

	register_context()
	init_network_id(NETWORK_TABLETS)

	// TODO: host subtype for PDAs
	//cpu.has_light = TRUE

	add_item_action(/datum/action/item_action/toggle_computer_light)

/obj/item/modular_computer/Destroy()
	return ..()

/obj/item/modular_computer/pre_attack_secondary(atom/A, mob/living/user, params)
	return ..()

// shameless copy of newscaster photo saving

/obj/item/modular_computer/proc/save_photo(icon/photo)
	var/photo_file = copytext_char(md5("\icon[photo]"), 1, 6)
	if(!fexists("[GLOB.log_directory]/photos/[photo_file].png"))
		//Clean up repeated frames
		var/icon/clean = new /icon()
		clean.Insert(photo, "", SOUTH, 1, 0)
		fcopy(clean, "[GLOB.log_directory]/photos/[photo_file].png")
	return photo_file

/**
 * Plays a ping sound.
 *
 * Timers runtime if you try to make them call playsound. Yep.
 */
/obj/item/modular_computer/proc/play_ping()
	playsound(loc, 'sound/machines/ping.ogg', get_clamped_volume(), FALSE, -1)

/obj/item/modular_computer/AltClick(mob/user)
	. = ..()

// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs. //guess what
/obj/item/modular_computer/GetAccess()
	if(cpu.computer_id_slot)
		return cpu.computer_id_slot.GetAccess()
	return ..()

/obj/item/modular_computer/GetID()
	if(cpu.computer_id_slot)
		return cpu.computer_id_slot
	return ..()

/obj/item/modular_computer/get_id_examine_strings(mob/user)
	. = ..()
	if(cpu.computer_id_slot)
		. += "\The [src] is displaying [cpu.computer_id_slot]."
		. += cpu.computer_id_slot.get_id_examine_strings(user)

/obj/item/modular_computer/proc/print_text(text_to_print, paper_title = "")
	if(!cpu.stored_paper)
		return FALSE

	var/obj/item/paper/printed_paper = new /obj/item/paper(drop_location())
	printed_paper.add_raw_text(text_to_print)
	if(paper_title)
		printed_paper.name = paper_title
	printed_paper.update_appearance()
	cpu.stored_paper--
	return TRUE

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && usr.canUseTopic(src, be_close = TRUE))
		return attack_self(M)
	return ..()

/obj/item/modular_computer/attack_ai(mob/user)
	return attack_self(user)

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(cpu.powered_on)
		cpu.ui_interact(user)
	else if(isAdminGhostAI(user))
		var/response = tgui_alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", list("Yes", "No"))
		if(response == "Yes")
			cpu.turn_on(user)

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	var/healthpercent = round((atom_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += span_info("It looks slightly damaged.")
		if(25 to 50)
			. += span_info("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")

	if(cpu.ntnet_bypass_rangelimit)
		. += "It is upgraded with an experimental long-ranged network capabilities, picking up NTNet frequencies while further away."
	. += span_notice("It has [cpu.max_capacity] GQ of storage capacity.")

	if(cpu.computer_id_slot)
		if(Adjacent(user))
			. += "It has \the [cpu.computer_id_slot] card installed in its card slot."
		else
			. += "Its identification card slot is currently occupied."
		. += span_info("Alt-click [src] to eject the identification card.")

/obj/item/modular_computer/examine_more(mob/user)
	. = ..()
	. += "Storage capacity: [cpu.used_capacity]/[cpu.max_capacity]GQ"

	for(var/datum/computer_file/app_examine as anything in cpu.stored_files)
		if(app_examine.on_examine(src, user))
			. += app_examine.on_examine(src, user)

	if(Adjacent(user))
		. += span_notice("Paper level: [cpu.stored_paper] / [cpu.max_paper].")

/obj/item/modular_computer/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		. = CONTEXTUAL_SCREENTIP_SET
	if(cpu.computer_id_slot) // ID get removed first before pAIs
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove ID"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(cpu.inserted_pai)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove pAI"
		. = CONTEXTUAL_SCREENTIP_SET

	if(cpu.inserted_disk)
		context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = "Remove SSD"
		. = CONTEXTUAL_SCREENTIP_SET
	return . || NONE

/obj/item/modular_computer/update_icon_state()
	if(!cpu.bypass_state)
		icon_state = cpu.powered_on ? icon_state_powered : icon_state_unpowered
	return ..()

/obj/item/modular_computer/update_overlays()
	. = ..()
	var/init_icon = initial(icon)

	if(!init_icon)
		return
	if(!display_overlays)
		return

	if(cpu.powered_on)
		. += cpu.active_program ? mutable_appearance(init_icon, cpu.active_program.program_icon_state) : mutable_appearance(init_icon, icon_state_menu)
	if(atom_integrity <= integrity_failure * max_integrity)
		. += mutable_appearance(init_icon, "bsod")
		. += mutable_appearance(init_icon, "broken")

/obj/item/modular_computer/Exited(atom/movable/gone, direction)
	if(cpu.internal_cell == gone)
		cpu.internal_cell = null
		if(cpu.powered_on && !cpu.use_power())
			cpu.shutdown_computer()
	if(cpu.computer_id_slot == gone)
		cpu.computer_id_slot = null
		update_slot_icon()
		if(ishuman(loc))
			var/mob/living/carbon/human/human_wearer = loc
			human_wearer.sec_hud_set_ID()
	if(inserted_pai == gone)
		inserted_pai = null
	if(inserted_disk == gone)
		inserted_disk = null
	return ..()


/obj/item/modular_computer/CtrlShiftClick(mob/user)
	. = ..()
	if(.)
		return
	if(!cpu.inserted_disk)
		return
	user.put_in_hands(cpu.inserted_disk)
	cpu.inserted_disk = null
	playsound(src, 'sound/machines/card_slide.ogg', 50)


// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	data["PC_device_theme"] = cpu.device_theme
	data["PC_showbatteryicon"] = !!cpu.internal_cell

	if(cpu.internal_cell)
		switch(cpu.internal_cell.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(cpu.internal_cell.percent())]%"
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"

	switch(cpu.get_ntnet_status())
		if(NTNET_NO_SIGNAL)
			data["PC_ntneticon"] = "sig_none.gif"
		if(NTNET_LOW_SIGNAL)
			data["PC_ntneticon"] = "sig_low.gif"
		if(NTNET_GOOD_SIGNAL)
			data["PC_ntneticon"] = "sig_high.gif"
		if(NTNET_ETHERNET_SIGNAL)
			data["PC_ntneticon"] = "sig_lan.gif"

	if(length(cpu.idle_threads))
		var/list/program_headers = list()
		for(var/datum/computer_file/program/idle_programs as anything in cpu.idle_threads)
			if(!idle_programs.ui_header)
				continue
			program_headers.Add(list(list("icon" = idle_programs.ui_header)))

		data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = station_time_timestamp()
	data["PC_stationdate"] = "[time2text(world.realtime, "DDD, Month DD")], [CURRENT_STATION_YEAR]"
	data["PC_showexitprogram"] = !!cpu.active_program // Hides "Exit Program" button on mainscreen
	return data


/obj/item/modular_computer/proc/add_log(text)
	if(!cpu.get_ntnet_status())
		return FALSE

	return SSnetworks.add_log(text, network_id)

/obj/item/modular_computer/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_computer_light))
		toggle_flashlight()
		return

	return ..()

/**
 * Toggles the computer's flashlight, if it has one.
 *
 * Called from ui_act(), does as the name implies.
 * It is separated from ui_act() to be overwritten as needed.
*/
/obj/item/modular_computer/proc/toggle_flashlight()
	if(!cpu.has_light)
		return FALSE
	set_light_on(!light_on)
	update_appearance()
	update_action_buttons(force = TRUE) //force it because we added an overlay, not changed its icon
	return TRUE

/**
 * Sets the computer's light color, if it has a light.
 *
 * Called from ui_act(), this proc takes a color string and applies it.
 * It is separated from ui_act() to be overwritten as needed.
 * Arguments:
 ** color is the string that holds the color value that we should use. Proc auto-fails if this is null.
*/

/obj/item/modular_computer/attackby(obj/item/attacking_item, mob/user, params)
/*	// Check for ID first
	if(isidcard(attacking_item) && InsertID(attacking_item, user))
		return

	// Check for cash next
	if(cpu.computer_id_slot && iscash(attacking_item))
		var/obj/item/card/id/inserted_id = cpu.computer_id_slot.GetID()
		if(inserted_id)
			inserted_id.attackby(attacking_item, user) // If we do, try and put that attacking object in
			return

	// Inserting a pAI
	if(istype(attacking_item, /obj/item/pai_card) && !cpu.inserted_pai)
		if(!user.transferItemToLoc(attacking_item, src))
			return
		cpu.inserted_pai = attacking_item
		balloon_alert(user, "inserted pai")
		return

	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(ismachinery(loc))
			return
		if(cpu.internal_cell)
			to_chat(user, span_warning("You try to connect \the [attacking_item] to \the [src], but its connectors are occupied."))
			return
		if(user && !user.transferItemToLoc(attacking_item, src))
			return
		cpu.internal_cell = attacking_item
		to_chat(user, span_notice("You plug \the [attacking_item] to \the [src]."))
		return

	// Check if any Applications need it
	for(var/datum/computer_file/item_holding_app as anything in cpu.stored_files)
		if(item_holding_app.application_attackby(attacking_item, user))
			return

	if(istype(attacking_item, /obj/item/paper))
		if(cpu.stored_paper >= cpu.max_paper)
			balloon_alert(user, "no more room!")
			return
		if(!user.temporarilyRemoveItemFromInventory(attacking_item))
			return FALSE
		balloon_alert(user, "inserted paper")
		qdel(attacking_item)
		cpu.stored_paper++
		return
	if(istype(attacking_item, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = attacking_item
		if(bin.total_paper <= 0)
			balloon_alert(user, "empty bin!")
			return
		var/papers_added //just to keep track
		while((bin.total_paper > 0) && (cpu.stored_paper < cpu.max_paper))
			papers_added++
			stored_paper++
			bin.remove_paper()
		if(!papers_added)
			return
		balloon_alert(user, "inserted paper")
		to_chat(user, span_notice("Added in [papers_added] new sheets. You now have [stored_paper] / [max_paper] printing paper stored."))
		bin.update_appearance()
		return

	// Insert a data disk
	if(istype(attacking_item, /obj/item/computer_disk))
		if(!user.transferItemToLoc(attacking_item, src))
			return
		inserted_disk = attacking_item
		playsound(src, 'sound/machines/card_slide.ogg', 50)
		return
*/
	return ..()

/obj/item/modular_computer/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src, user, 20, volume=20)
	internal_cell?.forceMove(drop_location())
	computer_id_slot?.forceMove(drop_location())
	inserted_disk?.forceMove(drop_location())
	inserted_pai?.forceMove(drop_location())
	new /obj/item/stack/sheet/iron(get_turf(loc), steel_sheet_cost)
	user.balloon_alert(user, "disassembled")
	relay_qdel()
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/modular_computer/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("\The [src] does not require repairs."))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!tool.tool_start_check(user, amount=1))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	to_chat(user, span_notice("You begin repairing damage to \the [src]..."))
	if(!tool.use_tool(src, user, 20, volume=50, amount=1))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	atom_integrity = max_integrity
	to_chat(user, span_notice("You repair \the [src]."))
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/modular_computer/deconstruct(disassembled = TRUE)
	break_apart()
	return ..()

/obj/item/modular_computer/proc/break_apart()
	if(!(flags_1 & NODECONSTRUCT_1))
		physical.visible_message(span_notice("\The [src] breaks apart!"))
		var/turf/newloc = get_turf(src)
		new /obj/item/stack/sheet/iron(newloc, round(steel_sheet_cost / 2))
	relay_qdel()

// Used by processor to relay qdel() to machinery type.
/obj/item/modular_computer/proc/relay_qdel()
	return

/obj/item/modular_computer/attack_self(mob/user)
	. = ..()
	ui_interact(user)
