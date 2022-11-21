/**
 * Survey scanner
 *
 * A machine that generates research points, at the cost of power, instead of forcing
 * people to waste their time standing idle with an item in their hand.
 * Meant to be a stable way of generating points while encouraging moving to different planets
 * Without the cost of doing the same thing on repeat (like dissections).
 */
/obj/machinery/survey_scanner
	name = "survey scanner"
	desc = "A machine that, when powered on, will scan the planet and generate research points at the cost of power."
	icon = 'voidcrew/modules/research/icons/objects.dmi'
	icon_state = "hivebot_fab"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/survey_scanner
	processing_flags = START_PROCESSING_MANUALLY
	idle_power_usage = NONE
	active_power_usage = (BASE_MACHINE_ACTIVE_CONSUMPTION * 20) //VERY expensive, you should upgrade it.

	///Whether the machine is currently running or not.
	var/enabled = FALSE
	///Looping sound that plays when active.
	var/datum/looping_sound/oven/survey_audio
	///The strength of the machine, decreasing point penalty.
	var/research_power
	///The base research points you get, before taking penalty into account.
	var/research_gain
	///Amount of research points we've generated from processing.
	var/stored_points
	///List of all Z levels scanned and how many times.
	var/static/list/z_level_history = list()

/obj/machinery/survey_scanner/Initialize(mapload)
	. = ..()
	survey_audio = new(src)
	register_context()

/obj/machinery/survey_scanner/Destroy()
	QDEL_NULL(survey_audio)
	return ..()

/obj/machinery/survey_scanner/examine(mob/user)
	. = ..()
	if(stored_points)
		. += "It currently has [stored_points] points. You can Right-Click to print it."

/obj/machinery/survey_scanner/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!isnull(held_item))
		return

	if(enabled)
		context[SCREENTIP_CONTEXT_LMB] = "Turn off"
	else
		context[SCREENTIP_CONTEXT_LMB] = "Turn on"
	context[SCREENTIP_CONTEXT_RMB] = "Extract Points"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/survey_scanner/update_icon_state()
	. = ..()
	if(!is_operational || !enabled)
		icon_state = "hivebot_fab"
	else
		icon_state = "hivebot_fab_on"

/obj/machinery/survey_scanner/set_is_operational(new_value)
	. = ..()
	if(enabled && new_value) //Turned off
		disable()

/obj/machinery/survey_scanner/RefreshParts()
	. = ..()
	for(var/obj/item/stock_parts/matter_bin/matterbins in component_parts)
		research_power = matterbins.rating
	for(var/obj/item/stock_parts/manipulator/manipulators in component_parts)
		research_gain = ((manipulators.rating * 100) / 2) //50, 100, 150, 200

	//power usage is cut, not increased.
	var/parts_energy_rating = 0
	for(var/obj/item/stock_parts/micro_laser/micro_lasers in component_parts)
		parts_energy_rating += micro_lasers.rating
	active_power_usage = initial(active_power_usage) / (1 + parts_energy_rating)

/obj/machinery/survey_scanner/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!is_operational)
		return

	if(enabled)
		disable()
	else
		enable()

/obj/machinery/survey_scanner/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!stored_points)
		say("No research points found, nothing to dispense.")
		return

	var/obj/item/research_notes/new_notes = new /obj/item/research_notes(src, stored_points, pick(list("astronomy", "physics", "planets", "space")))
	//check for existing notes
	var/obj/item/research_notes/existing_notes = locate() in user
	if(existing_notes)
		existing_notes.attackby(existing_notes, new_notes)
	else
		try_put_in_hand(new_notes, user)
	stored_points = 0 //empty it now
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/survey_scanner/process()
	var/penalty = (research_power - (z_level_history["[z]"] - 1) * 0.01) // You lose one percent of value each scan.
	if(!penalty || penalty < 0.20) // If you are below 20% value, do nothing and abort
		say("Unable to locate valuable information in current sector, scanning stopped.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20)
		disable()
		return

	playsound(src, 'sound/machines/ding.ogg', 20)
	z_level_history["[z]"]++
	stored_points += (research_gain * penalty)

/obj/machinery/survey_scanner/wrench_act(mob/living/user, obj/item/tool)
	if(enabled)
		return FALSE
	tool.play_tool_sound(src, 15)
	set_anchored(!anchored)
	return TRUE

/obj/machinery/survey_scanner/screwdriver_act(mob/living/user, obj/item/tool)
	if(enabled)
		return FALSE
	if(!default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), tool))
		return FALSE
	return TRUE

/obj/machinery/survey_scanner/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return FALSE
	return TRUE

/**
 * enable()
 *
 * Turns the machine on to start generating points and consuming power.
 */
/obj/machinery/survey_scanner/proc/enable()
	if(!anchored)
		say("Unable to operate, not anchored properly to the floor!")
		return
	//don't have a history here, create one.
	if(!z_level_history["[z]"])
		z_level_history["[z]"] = 1
	enabled = TRUE
	balloon_alert_to_viewers("begins to rumble...")
	begin_processing()
	update_use_power(ACTIVE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	survey_audio.start()
	// copied from janiborgs lmao
	var/base_x = base_pixel_x
	var/base_y = base_pixel_y
	animate(src, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
	for(var/i in 1 to 15) //Startup rumble
		var/x_offset = base_x + rand(-1, 1)
		var/y_offset = base_y + rand(-1, 1)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)

/**
 * disable()
 *
 * ends the processing and power usage, and spits out the points if there's any.
 */
/obj/machinery/survey_scanner/proc/disable()
	enabled = FALSE
	end_processing()
	update_use_power(IDLE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	survey_audio.stop()
	animate(src, pixel_x = base_pixel_x, pixel_y = base_pixel_y, time = 2)

/**
 * Design
 */
/datum/design/board/survey_scanner
	name = "Survey Scaner Machine Board"
	desc = "The Machine Circuit board for a Survey scanner which allows research generation through power."
	id = "surveyscanner"
	build_path = /obj/item/circuitboard/machine/survey_scanner
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/**
 * Board
 */
/obj/item/circuitboard/machine/survey_scanner
	name = "Survey Scanner"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/survey_scanner
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 5,
	)
