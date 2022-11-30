// Status display
// (formerly Countdown timer display)

#define MAX_STATIC_WIDTH 25
#define FONT_STYLE "5pt 'Small Fonts'"
#define SCROLL_RATE (0.04 SECONDS) // time per pixel
#define LINE1_Y -11
#define LINE2_Y -18

/// Alphas for "projection" mode
#define PROJECTION_FLOOR_ALPHA 128
#define PROJECTION_BEAM_ALPHA 32
#define PROJECTION_TEXT_ALPHA 192

#define SD_BLANK 0  // 0 = Blank
#define SD_EMERGENCY 1  // 1 = Emergency Shuttle timer
#define SD_MESSAGE 2  // 2 = Arbitrary message(s)
#define SD_PICTURE 3  // 3 = alert picture

/// Status display which can show images and scrolling text.
/obj/machinery/status_display
	name = "status display"
	desc = null
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	density = FALSE
	layer = ABOVE_WINDOW_LAYER

	light_range = 1.7
	light_color = LIGHT_COLOR_BLUE

	/// vis_content atom for the top text.
	var/obj/effect/overlay/status_display_text/message1_visual
	/// vis_content atom for the bottom text.
	var/obj/effect/overlay/status_display_text/message2_visual
	var/current_picture = ""
	var/current_mode = SD_BLANK
	var/message1 = ""
	var/message2 = ""

	/// Normal text color
	var/text_color = "#0099FF"
	/// Color for headers, eg. "- ETA -"
	var/header_text_color = "#22CCFF"

	/// Transforms for the projection effects
	var/static/list/matrix/floor_projections = list(
		TEXT_NORTH = matrix(1, 0, 0, 0, 1, 32), // translation. Realistically these should be mirrored but for readability they're not.
		TEXT_EAST = matrix(0, 1, 18, -1, 0, -6), // 90 deg turn, 3/4 squish
		TEXT_WEST = matrix(0, -1, -18, 1, 0, -6), // -90 deg turn, 3/4 squish
	)

	/// Transforms for the beam between the floor projection and the actual screen.
	var/static/list/matrix/beam_projections = list(
		TEXT_NORTH = matrix(1, 0, 0, 0, 1.3125, 30), // stretch towards display.
		TEXT_EAST = matrix(0, 1.3125, 16, -1, -0.45, -5), // Tilted.
		TEXT_WEST = matrix(0, -1.3125, -16, 1, -0.45, -5), // Tilted.
	)

	/// Where to place the emmissive mask for projection mode
	var/static/list/list/projection_emissive_offsets = list(
		TEXT_NORTH = list(0, 32),
		TEXT_EAST = list(18, -4),
		TEXT_WEST = list(-18, -4),
	)

/obj/machinery/status_display/Initialize()
	. = ..()
	AddElement(/datum/element/wall_mount)

/obj/item/wallframe/status_display
	name = "status display frame"
	desc = "Used to build status displays, just secure to the wall."
	icon_state = "unanchoredstatusdisplay"
	custom_materials = list(/datum/material/iron=14000, /datum/material/glass=8000)
	result_path = /obj/machinery/status_display/evac
	pixel_shift = 32

//makes it go on the wall when built
/obj/machinery/status_display/Initialize(mapload, ndir, building)
	. = ..()
	update_appearance()

/obj/machinery/status_display/setDir(newdir)
	. = ..()

	// Force cached visuals to update.
	remove_messages()
	update_appearance()

/obj/machinery/status_display/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "[anchored ? "un" : ""]securing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		balloon_alert(user, "[anchored ? "un" : ""]secured")
		deconstruct()
		return TRUE

/obj/machinery/status_display/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it doesn't need repairs!")
		return TRUE
	user.balloon_alert_to_viewers("repairing display...", "repairing...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume=50))
		return TRUE
	balloon_alert(user, "repaired")
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/obj/machinery/status_display/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!disassembled)
		new /obj/item/stack/sheet/iron(drop_location(), 2)
		new /obj/item/shard(drop_location())
		new /obj/item/shard(drop_location())
	else
		new /obj/item/wallframe/status_display(drop_location())
	qdel(src)

/// Immediately change the display to the given picture.
/obj/machinery/status_display/proc/set_picture(state)
	if(state != current_picture)
		current_picture = state
		message1 = ""
		message2 = ""

	update_appearance()

/// Immediately change the display to the given two lines.
/obj/machinery/status_display/proc/set_messages(line1, line2)
	line1 = uppertext(line1)
	line2 = uppertext(line2)

	var/should_update = FALSE

	if(line1 != message1 || !message1_visual)
		message1 = line1
		should_update = TRUE

	if(line2 != message2 || !message2_visual)
		message2 = line2
		should_update = TRUE

	if(!should_update)
		return

	update_appearance()

/**
 * Remove both message objs and null the fields.
 * Don't call this in subclasses.
 */
/obj/machinery/status_display/proc/remove_messages()
	QDEL_NULL(message1_visual)
	QDEL_NULL(message2_visual)

/**
 * Create/update message overlay.
 * They must be handled as real objects for the animation to run.
 * Don't call this in subclasses.
 * Arguments:
 * * old_status_display_text - the current /obj/effect/overlay/status_display_text instance
 * * line_y - The Y offset to render the text.
 * * message - the new message text.
 * Returns new /obj/effect/overlay/status_display_text or null if unchanged.
 */
/obj/machinery/status_display/proc/update_message(obj/effect/overlay/status_display_text/old_status_display_text, line_y, message)
	if(old_status_display_text && message == old_status_display_text.message)
		return null

	qdel(old_status_display_text)

	var/obj/effect/overlay/status_display_text/new_status_display_text = new(src, line_y, message, text_color, header_text_color)
	vis_contents += new_status_display_text
	return new_status_display_text

/obj/machinery/status_display/update_appearance(updates=ALL)
	. = ..()
	if( \
		(machine_stat & (NOPOWER|BROKEN)) || \
		(current_mode == SD_BLANK) || \
		(current_mode != SD_PICTURE && message1 == "" && message2 == "") \
	)
		set_light(l_on = FALSE)
		return

	set_light(l_color = text_color, l_on = TRUE)

/obj/machinery/status_display/update_overlays()
	. = ..()

	// Facing south, we render traditionally.
	if(dir == SOUTH)
		add_screen_visuals(.)
		return

	// Otherwise, we render a projection on the floor.

	// Get screen overlays and return if it's off.
	var/list/projected_overlays = list()
	var/anything_displayed = add_screen_visuals(projected_overlays, projection_only = TRUE)

	if(!anything_displayed)
		return

	// Both of these are vis contents that will receive 1 or more overlays themselves.

	// Matrices to transform the content given the direction
	var/matrix/floor_matrix = floor_projections["[dir]"]
	var/matrix/beam_matrix = beam_projections["[dir]"]

	// Make the 2 vis overlays.
	generate_projection_overlay(floor_matrix, projected_overlays, alpha = PROJECTION_FLOOR_ALPHA)
	generate_projection_overlay(beam_matrix, projected_overlays, alpha = PROJECTION_BEAM_ALPHA)

	// Impossible for this to look good as an actual emissive since the emissive plane crushes alpha to all or nothing.
	// We don't really want anything blocking it anyway since the projection would shine over people.
	var/mutable_appearance/projection_emissive = mutable_appearance(icon, "projection-mask", offset_spokesman = src, plane = LIGHTING_PLANE)
	var/list/emissive_offsets = projection_emissive_offsets["[dir]"]
	projection_emissive.pixel_x = emissive_offsets[1]
	projection_emissive.pixel_y = emissive_offsets[2]
	projection_emissive.blend_mode = BLEND_ADD
	. += projection_emissive

	// Translate the text seperately, since they are vis_contents.
	message1_visual?.transform = floor_matrix
	message1_visual?.alpha = PROJECTION_TEXT_ALPHA
	message2_visual?.transform = floor_matrix
	message2_visual?.alpha = PROJECTION_TEXT_ALPHA

/**
 * Generate a set of vis contents objects for the overlays.
 *
 * Needs to be vis contents so that they're mouse transparent.
 *
 * Arguments:
 * * overlay_transform - The matrix transform to apply.
 * * sub_overlays - The list of sub-overlays to apply.
 * * alpha - the alpha for the mutable appearance.
 */
/obj/machinery/status_display/proc/generate_projection_overlay(matrix/overlay_transform, list/sub_overlays, alpha)
	PRIVATE_PROC(TRUE)

	var/obj/effect/overlay/new_overlay = SSvis_overlays.add_vis_overlay(
		src,
		layer = layer - 0.01, // make sure we're under the text vis objects
		plane = plane,
		alpha = alpha,
		add_appearance_flags = KEEP_TOGETHER,
		unique = TRUE
	)

	new_overlay.transform = overlay_transform
	new_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	new_overlay.add_overlay(sub_overlays)

	return new_overlay

/**
 * Generate mutable_appearances for the screen. Has an optional offset to shift it around.
 *
 * Returns whether the the screen is conceptually on.
 *
 * Arguments:
 * * screen_overlays - the overlays list to add to
 * * projection_only - only add overlays that are transformed for the projection effect
 */
/obj/machinery/status_display/proc/add_screen_visuals(list/screen_overlays, projection_only = FALSE)
	// Always have a base screen, or frame.
	var/screen_icon_state = "outline"
	// Is this screen emissive?
	var/backlight_on = TRUE

	if(machine_stat & (NOPOWER|BROKEN))
		remove_messages()
		backlight_on = FALSE

	switch(current_mode)
		if(SD_BLANK)
			remove_messages()
			backlight_on = FALSE
		if(SD_PICTURE)
			remove_messages()
			screen_icon_state = current_picture
			if(current_picture in list("ai_off", "outline"))
				backlight_on = FALSE
		else
			var/atom/new_visual = update_message(message1_visual, LINE1_Y, message1)
			if(new_visual)
				new_visual.alpha = alpha
				message1_visual = new_visual
			new_visual = update_message(message2_visual, LINE2_Y, message2)
			if(new_visual)
				new_visual.alpha = alpha
				message2_visual = new_visual

			// Turn off backlight if message is blank
			if(message1 == "" && message2 == "")
				backlight_on = FALSE

	var/mutable_appearance/mutable_screen = mutable_appearance(icon, screen_icon_state)
	screen_overlays += mutable_screen

	if(!backlight_on || projection_only)
		return backlight_on

	var/mutable_appearance/emissive_screen = emissive_appearance(icon, "outline", src)
	screen_overlays += emissive_screen

	return TRUE

// Timed process - performs nothing in the base class
/obj/machinery/status_display/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()

	return PROCESS_KILL

/// Update the display and, if necessary, re-enable processing.
/obj/machinery/status_display/proc/update()
	if (process(SSMACHINES_DT) != PROCESS_KILL)
		START_PROCESSING(SSmachines, src)

/obj/machinery/status_display/power_change()
	. = ..()
	update()

/obj/machinery/status_display/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return
	current_mode = SD_PICTURE
	set_picture("ai_bsod")

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if (message1 || message2)
		. += "The display says:"
		if (message1)
			. += "\t<tt>[html_encode(message1)]</tt>"
		if (message2)
			. += "\t<tt>[html_encode(message2)]</tt>"

// Helper procs for child display types.
/obj/machinery/status_display/proc/display_shuttle_status(obj/docking_port/mobile/shuttle)
	if(!shuttle)
		// the shuttle is missing - no processing
		set_messages("shutl?","")
		return PROCESS_KILL
	else if(shuttle.timer)
		var/line1 = "- [shuttle.getModeStr()] -"
		var/line2 = shuttle.getTimerStr()

		set_messages(line1, line2)
	else
		// don't kill processing, the timer might turn back on
		set_messages("", "")

/obj/machinery/status_display/Destroy()
	remove_messages()
	return ..()

/**
 * Nice overlay to make text smoothly scroll with no client updates after setup.
 */
/obj/effect/overlay/status_display_text
	icon = 'icons/obj/status_display.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID

	/// The message this overlay is displaying.
	var/message

	// If the line is short enough to not marquee, and it matches this, it's a header.
	var/static/regex/header_regex = regex("^-.*-$")

	/// Width of each character, including kerning gap afterwards.
	/// We don't use rich text or anything fancy, so we can bake these values.
	var/static/list/char_widths = list(
		//   ! " # $ % & ' ( ) * + , - . /
		1, 2, 3, 5, 4, 5, 5, 2, 3, 3, 3, 4, 2, 3, 2, 3,
		// 0 1 2 3 4 5 6 7 8 9 : ; < = > ?
		4, 3, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 3, 3, 3, 3,
		// @ A B C D E F G H I J K L M N O
		7, 5, 5, 5, 5, 4, 4, 5, 5, 2, 4, 5, 4, 6, 5, 5,
		// P Q R S T U V W X Y Z [ \ ] ^ _
		5, 5, 5, 5, 4, 5, 4, 6, 4, 4, 4, 3, 3, 3, 4, 4,
		// ` a b c d e f g h i j k l m n o
		3, 5, 5, 5, 5, 4, 4, 5, 5, 2, 4, 5, 4, 6, 5, 5,
		// p q r s t u v w x y z { | } ~
		5, 5, 5, 5, 4, 5, 4, 6, 4, 4, 4, 3, 2, 3, 4,
	)

/obj/effect/overlay/status_display_text/Initialize(mapload, yoffset, line, text_color, header_text_color)
	. = ..()

	maptext_y = yoffset
	message = line

	var/line_width = measure_width(line)

	if(line_width > MAX_STATIC_WIDTH)
		// Marquee text
		var/marquee_message = "[line]  -  [line]  -  [line]"

		// Width of full content. Must of these is never revealed unless the user inputted a single character.
		var/full_marquee_width = measure_width(marquee_message)
		// We loop after only this much has passed.
		var/looping_marquee_width = measure_width("[line]  -  ")

		maptext = generate_text(marquee_message, center = FALSE, text_color = text_color)
		maptext_width = full_marquee_width
		maptext_x = 0

		// Mask off to fit in screen.
		add_filter("mask", 1, alpha_mask_filter(icon = icon(icon, "outline")))

		// Scroll.
		var/time = looping_marquee_width * SCROLL_RATE
		animate(src, maptext_x = -looping_marquee_width, time = time, loop = -1)
		animate(maptext_x = 0, time = 0)
	else
		// Centered text
		var/color = header_regex.Find(line) ? header_text_color : text_color
		maptext = generate_text(line, center = TRUE, text_color = color)
		maptext_x = 0

/**
 * A hyper-streamlined version of MeasureText that doesn't support different fonts, rich formatting, or multiline.
 * But it also doesn't require a client.
 *
 * Returns the width in pixels
 *
 * Arguments:
 * * text - the text to measure
 */
/obj/effect/overlay/status_display_text/proc/measure_width(text)
	var/width = 0
	for(var/text_idx in 1 to length(text))
		var/ascii = text2ascii(text, text_idx)
		if(!(ascii in 0x20 to 0x7E))
			// So we can't possibly runtime, even though the input should be in range already.
			width += 3
			continue
		width += char_widths[ascii - 0x1F]

	return width

/**
 * Generate the actual maptext.
 * Arguments:
 * * text - the text to display
 * * center - center the text if TRUE, otherwise left-align
 * * text_color - the text color
 */
/obj/effect/overlay/status_display_text/proc/generate_text(text, center, text_color)
	return {"<div style="color:[text_color];font:[FONT_STYLE][center ? ";text-align:center" : ""]" valign="top">[text]</div>"}

/// Evac display which shows shuttle timer or message set by Command.
/obj/machinery/status_display/evac
	current_mode = SD_EMERGENCY
	var/frequency = FREQ_STATUS_DISPLAYS
	var/friendc = FALSE      // track if Friend Computer mode
	var/last_picture  // For when Friend Computer mode is undone

INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/evac, 32)

/obj/machinery/status_display/evac/Initialize(mapload)
	. = ..()
	// register for radio system
	SSradio.add_object(src, frequency)
	// Circuit USB
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/status_display,
	))

/obj/machinery/status_display/evac/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/status_display/evac/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	if(friendc) //Makes all status displays except supply shuttle timer display the eye -- Urist
		current_mode = SD_PICTURE
		set_picture("ai_friend")
		return PROCESS_KILL

	switch(current_mode)
		if(SD_BLANK)
			return PROCESS_KILL

		if(SD_EMERGENCY)
			return display_shuttle_status(SSshuttle.emergency)

		if(SD_MESSAGE)
			return PROCESS_KILL

		if(SD_PICTURE)
			set_picture(last_picture)
			return PROCESS_KILL

/obj/machinery/status_display/evac/receive_signal(datum/signal/signal)
	switch(signal.data["command"])
		if("blank")
			current_mode = SD_BLANK
			update_appearance()
		if("shuttle")
			current_mode = SD_EMERGENCY
			set_messages("", "")
		if("message")
			current_mode = SD_MESSAGE
			set_messages(signal.data["top_text"] || "", signal.data["bottom_text"] || "")
		if("alert")
			current_mode = SD_PICTURE
			last_picture = signal.data["picture_state"]
			set_picture(last_picture)
		if("friendcomputer")
			friendc = !friendc
	update()


/// Supply display which shows the status of the supply shuttle.
/obj/machinery/status_display/supply
	name = "supply display"
	current_mode = SD_MESSAGE
	text_color = "#FF9900"
	header_text_color = "#FFCC22"

/obj/machinery/status_display/supply/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	var/line1
	var/line2
	if(!SSshuttle.supply)
		// Might be missing in our first update on initialize before shuttles
		// have loaded. Cross our fingers that it will soon return.
		line1 = "CARGO"
		line2 = "shutl?"
	else if(SSshuttle.supply.mode == SHUTTLE_IDLE)
		if(is_station_level(SSshuttle.supply.z))
			line1 = "CARGO"
			line2 = "Docked"
		else
			line1 = ""
			line2 = ""
	else
		line1 = "- [SSshuttle.supply.getModeStr()] -"
		line2 = SSshuttle.supply.getTimerStr()
	set_messages(line1, line2)


/// General-purpose shuttle status display.
/obj/machinery/status_display/shuttle
	name = "shuttle display"
	current_mode = SD_MESSAGE
	var/shuttle_id

	text_color = "#00FF55"
	header_text_color = "#22FFCC"

/obj/machinery/status_display/shuttle/process()
	if(!shuttle_id || (machine_stat & NOPOWER))
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	return display_shuttle_status(SSshuttle.getShuttle(shuttle_id))

/obj/machinery/status_display/shuttle/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	switch(var_name)
		if(NAMEOF(src, shuttle_id))
			update()

/obj/machinery/status_display/shuttle/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(port)
		shuttle_id = port.shuttle_id
	update()


/// Pictograph display which the AI can use to emote.
/obj/machinery/status_display/ai
	name = "\improper AI display"
	desc = "A small screen which the AI can use to present itself."
	current_mode = SD_PICTURE

	var/emotion = AI_EMOTION_BLANK

	/// A mapping between AI_EMOTION_* string constants, which also double as user readable descriptions, and the name of the iconfile.
	var/static/list/emotion_map = list(
		AI_EMOTION_BLANK = "ai_off",
		AI_EMOTION_VERY_HAPPY = "ai_veryhappy",
		AI_EMOTION_HAPPY = "ai_happy",
		AI_EMOTION_NEUTRAL = "ai_neutral",
		AI_EMOTION_UNSURE = "ai_unsure",
		AI_EMOTION_CONFUSED = "ai_confused",
		AI_EMOTION_SAD = "ai_sad",
		AI_EMOTION_BSOD = "ai_bsod",
		AI_EMOTION_PROBLEMS = "ai_trollface",
		AI_EMOTION_AWESOME = "ai_awesome",
		AI_EMOTION_DORFY = "ai_urist",
		AI_EMOTION_THINKING = "ai_thinking",
		AI_EMOTION_FACEPALM = "ai_facepalm",
		AI_EMOTION_FRIEND_COMPUTER = "ai_friend",
		AI_EMOTION_BLUE_GLOW = "ai_sal",
		AI_EMOTION_RED_GLOW = "ai_hal",
	)


INVERT_MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ai, 32)

/obj/machinery/status_display/ai/Initialize(mapload)
	. = ..()
	GLOB.ai_status_displays.Add(src)

/obj/machinery/status_display/ai/Destroy()
	GLOB.ai_status_displays.Remove(src)
	. = ..()

/obj/machinery/status_display/ai/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	var/list/choices = list()
	for(var/emotion_const in emotion_map)
		var/icon_state = emotion_map[emotion_const]
		choices[emotion_const] = image(icon = 'icons/obj/status_display.dmi', icon_state = icon_state)

	var/emotion_result = show_radial_menu(user, src, choices, tooltips = TRUE)
	for(var/_emote in typesof(/datum/emote/ai/emotion_display))
		var/datum/emote/ai/emotion_display/emote = _emote
		if(initial(emote.emotion) == emotion_result)
			user.emote(initial(emote.key))
			break

/obj/machinery/status_display/ai/process()
	if(machine_stat & NOPOWER)
		update_appearance()
		return PROCESS_KILL

	set_picture(emotion_map[emotion])
	return PROCESS_KILL

/obj/item/circuit_component/status_display
	display_name = "Status Display"
	desc = "Output text and pictures to a status display."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/option/command
	var/datum/port/input/option/picture
	var/datum/port/input/message1
	var/datum/port/input/message2

	var/obj/machinery/status_display/connected_display

	var/list/command_map
	var/list/picture_map

/obj/item/circuit_component/status_display/populate_ports()
	message1 = add_input_port("Message 1", PORT_TYPE_STRING)
	message2 = add_input_port("Message 2", PORT_TYPE_STRING)

/obj/item/circuit_component/status_display/populate_options()
	var/static/list/command_options = list(
		"Blank" = "blank",
		"Shuttle" = "shuttle",
		"Message" = "message",
		"Alert" = "alert"
	)

	var/static/list/picture_options = list(
		"Default" = "default",
		"Red Alert" = "redalert",
		"Biohazard" = "biohazard",
		"Lockdown" = "lockdown",
		"Happy" = "ai_happy",
		"Neutral" = "ai_neutral",
		"Very Happy" = "ai_veryhappy",
		"Sad" = "ai_sad",
		"Unsure" = "ai_unsure",
		"Confused" = "ai_confused",
		"Surprised" = "ai_surprised",
		"BSOD" = "ai_bsod"
	)

	command = add_option_port("Command", command_options)
	command_map = command_options

	picture = add_option_port("Picture", picture_options)
	picture_map = picture_options

/obj/item/circuit_component/status_display/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/status_display))
		connected_display = shell

/obj/item/circuit_component/status_display/unregister_usb_parent(atom/movable/parent)
	connected_display = null
	return ..()

/obj/item/circuit_component/status_display/input_received(datum/port/input/port)
	// Just use command handling built into status display.
	// The option inputs thankfully sanitize command and picture for us.

	if(!connected_display)
		return

	var/command_value = command_map[command.value]
	var/datum/signal/status_signal = new(list("command" = command_value))
	switch(command_value)
		if("message")
			status_signal.data["top_text"] = message1.value
			status_signal.data["bottom_text"] = message2.value
		if("alert")
			status_signal.data["picture_state"] = picture_map[picture.value]

	connected_display.receive_signal(status_signal)

#undef MAX_STATIC_WIDTH
#undef FONT_STYLE
#undef SCROLL_RATE
#undef LINE1_Y
#undef LINE2_Y
#undef PROJECTION_FLOOR_ALPHA
#undef PROJECTION_BEAM_ALPHA
