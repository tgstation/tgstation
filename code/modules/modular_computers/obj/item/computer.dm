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
	/// Our modular computer
	var/datum/modular_computer_host/item/cpu = /datum/modular_computer_host/item

	/// Icon state when the computer is turned off.
	var/icon_state_unpowered = null
	/// Icon state when the computer is turned on.
	var/icon_state_powered = null
	/// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/icon_state_menu = "menu"
	/// If FALSE, don't draw overlays on this device at all
	var/display_overlays = TRUE
	/// If FALSE, do not let wrenches deconstruct this item
	var/deconstructible = TRUE

	/// Allow people with chunky fingers to use?
	var/allow_chunky = FALSE

	///Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/steel_sheet_cost = 5

/obj/item/modular_computer/Initialize(mapload)
	. = ..()

	cpu = new cpu(src)

	//set_light_color(cpu.comp_light_color)
	//set_light_range(cpu.comp_light_luminosity)
	//if(cpu.looping_sound)
	//	cpu.soundloop = new(src, cpu.powered_on)
	//cpu.UpdateDisplay()

	register_context()

	add_item_action(/datum/action/item_action/toggle_computer_light)

/obj/item/modular_computer/Destroy()
	if(istype(cpu))
		QDEL_NULL(cpu)
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

// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs. //guess what
/obj/item/modular_computer/GetAccess()
	if(cpu.inserted_id)
		return cpu.inserted_id.GetAccess()
	return ..()

/obj/item/modular_computer/GetID()
	if(cpu.inserted_id)
		return cpu.inserted_id
	return ..()

/obj/item/modular_computer/get_id_examine_strings(mob/user)
	. = ..()
	if(cpu.inserted_id)
		. += "\The [src] is displaying [cpu.inserted_id]."
		. += cpu.inserted_id.get_id_examine_strings(user)

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && usr.canUseTopic(src, be_close = TRUE))
		return attack_self(M)
	return ..()

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

/obj/item/modular_computer/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		. = CONTEXTUAL_SCREENTIP_SET
	return . || NONE

/obj/item/modular_computer/update_icon_state()
	if(!icon_state_powered || !icon_state_unpowered) //no valid icon, don't update.
		return ..()
	icon_state = cpu.powered_on ? icon_state_powered : icon_state_unpowered
	return ..()

/obj/item/modular_computer/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return

	if(cpu.powered_on)
		. += cpu.active_program ? mutable_appearance(init_icon, cpu.active_program.program_icon_state) : mutable_appearance(init_icon, icon_state_menu)
	if(atom_integrity <= integrity_failure * max_integrity)
		. += mutable_appearance(init_icon, "bsod")
		. += mutable_appearance(init_icon, "broken")

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
	update_item_action_buttons(force = TRUE) //force it because we added an overlay, not changed its icon
	return TRUE

/obj/item/modular_computer/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!deconstructable)
		return ..()
	tool.play_tool_sound(src, user, 20, volume=20)
	new /obj/item/stack/sheet/iron(get_turf(loc), steel_sheet_cost)
	user.balloon_alert(user, "disassembled")
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
		visible_message(span_notice("\The [src] breaks apart!"))
		var/turf/newloc = get_turf(src)
		new /obj/item/stack/sheet/iron(newloc, round(steel_sheet_cost / 2))
