/obj/structure/signboard/holosign
	name = "holographic sign"
	desc = "A holographic signboard, projecting text above it."
	icon_state = "holographic_sign"
	base_icon_state = "holographic_sign"
	layer = ABOVE_MOB_LAYER
	density = FALSE
	edit_by_hand = TRUE
	show_while_unanchored = TRUE
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_power = 0.3
	light_color = COLOR_CARP_TEAL
	light_on = FALSE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5.05, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.7)
	/// If set, only IDs with this name can (un)lock the sign.
	var/registered_owner
	/// The current color of the sign.
	/// The sign will be greyscale if this is set.
	var/current_color

/obj/structure/signboard/holosign/Initialize(mapload)
	. = ..()
	if(current_color)
		INVOKE_ASYNC(src, PROC_REF(set_color), current_color)
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/holo_signboard,
	))

/obj/structure/signboard/holosign/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	var/locked = is_locked(user)
	if(istype(held_item, /obj/item/card/emag))
		context[SCREENTIP_CONTEXT_LMB] = "Short Out Locking Mechanisms"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(!locked && istype(held_item?.GetID(), /obj/item/usb_cable))
		context[SCREENTIP_CONTEXT_LMB] = "Connect USB Cable"
	else if(!locked && istype(held_item?.GetID(), /obj/item/card/id))
		context[SCREENTIP_CONTEXT_LMB] = registered_owner ? "Remove ID Lock" : "Lock To ID"
		. = CONTEXTUAL_SCREENTIP_SET
	if(!locked)
		context[SCREENTIP_CONTEXT_RMB] = "Set Sign Color"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/structure/signboard/holosign/update_icon_state()
	base_icon_state = current_color ? "[initial(base_icon_state)]_greyscale" : initial(base_icon_state)
	. = ..()
	if(obj_flags & EMAGGED)
		icon_state += "_emag"

/obj/structure/signboard/holosign/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_warning("<br>Its locking mechanisms appear to be shorted out!")
	else if(registered_owner)
		. += span_info("<br>It is locked to the ID of [span_name(registered_owner)].")

/obj/structure/signboard/holosign/update_overlays()
	. = ..()
	if(sign_text)
		. += emissive_appearance(icon, "holographic_sign_e", src)

/obj/structure/signboard/holosign/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, color) || var_name == NAMEOF(src, current_color))
		INVOKE_ASYNC(src, PROC_REF(set_color), var_value)
		datum_flags |= DF_VAR_EDITED
		return TRUE
	return ..()

/obj/structure/signboard/holosign/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/item = astype(tool, /obj/item)
	var/obj/item/card/id/id = item?.GetID()
	if(!istype(id) || !can_interact(user) || !user.can_perform_action(src, NEED_DEXTERITY))
		return NONE

	var/trimmed_id_name = trimtext(id.registered_name)
	if(!trimmed_id_name)
		balloon_alert(user, "no name on id!")
		return ITEM_INTERACT_BLOCKING
	if(obj_flags & EMAGGED)
		balloon_alert(user, "lock shorted out!")
		return ITEM_INTERACT_BLOCKING
	if(registered_owner)
		if(!check_locked(user))
			registered_owner = null
			balloon_alert(user, "id lock removed")
			investigate_log("([key_name(user)]) removed id lock", INVESTIGATE_SIGNBOARD)
	else
		registered_owner = trimmed_id_name
		balloon_alert(user, "locked to id")
		investigate_log("([key_name(user)]) added id lock for \"[registered_owner]\"", INVESTIGATE_SIGNBOARD)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/structure/signboard/holosign/is_locked(mob/living/user)
	. = ..()
	if(.)
		return
	if(registered_owner && isliving(user))
		var/obj/item/card/id/id = user.get_idcard()
		if(!istype(id) || QDELING(id))
			return TRUE
		return !cmptext(trimtext(id.registered_name), registered_owner)

/obj/structure/signboard/holosign/set_text(new_text, force)
	. = ..()
	set_light(l_on = !!sign_text)

/obj/structure/signboard/holosign/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(try_set_color(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/signboard/holosign/proc/try_set_color(mob/user)
	. = TRUE
	if(!can_interact(user) || !user.can_perform_action(src, NEED_DEXTERITY))
		return FALSE
	if(check_locked(user))
		return
	var/new_color = sanitize_color(tgui_color_picker(user, "Set Sign Color", full_capitalize(name), current_color))
	if(new_color && is_color_dark_with_saturation(new_color, 25))
		balloon_alert(user, "color too dark!")
		return
	if(check_locked(user))
		return
	INVOKE_ASYNC(src, PROC_REF(set_color), new_color)
	if(new_color)
		balloon_alert(user, "set color to [new_color]")
		investigate_log("([key_name(user)]) set the color to [new_color || "(none)"]", INVESTIGATE_SIGNBOARD)
	else
		balloon_alert(user, "unset color")
		investigate_log("([key_name(user)]) cleared the color", INVESTIGATE_SIGNBOARD)

/obj/structure/signboard/holosign/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	playsound(src, SFX_SPARKS, vol = 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	balloon_alert(user, "lock broken")
	investigate_log("was emagged by [key_name(user)] (previous owner: [registered_owner || "(none)"])", INVESTIGATE_SIGNBOARD)
	registered_owner = null
	obj_flags |= EMAGGED
	update_appearance()

/obj/structure/signboard/holosign/proc/sanitize_color(color)
	. = sanitize_hexcolor(color)
	if(!. || . == COLOR_BLACK)
		return null

/obj/structure/signboard/holosign/proc/set_color(new_color)
	new_color = sanitize_color(new_color)
	if(!new_color)
		current_color = null
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	else
		current_color = new_color
		add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	set_light(l_color = current_color || src::light_color)
	update_appearance()

/obj/item/circuit_component/holo_signboard
	display_name = "Holographic Signboard"
	desc = "Output text to a signboard, insert <br> in the message field to linebreak. Set the color to 0, 0, 0 to reset to default."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/message
	var/datum/port/input/clear

	var/datum/port/output/fail_reason
	var/datum/port/output/on_fail

	var/datum/port/input/red
	var/datum/port/input/green
	var/datum/port/input/blue
	var/datum/port/input/set_color

	var/obj/structure/signboard/holosign/connected_display

/obj/item/circuit_component/holo_signboard/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING)
	clear = add_input_port("Clear", PORT_TYPE_SIGNAL, trigger = PROC_REF(clear_received))

	fail_reason = add_output_port("Fail Reason", PORT_TYPE_STRING)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

	red = add_input_port("Red", PORT_TYPE_NUMBER)
	green = add_input_port("Green", PORT_TYPE_NUMBER)
	blue = add_input_port("Blue", PORT_TYPE_NUMBER)
	set_color = add_input_port("Set Color", PORT_TYPE_SIGNAL, trigger = PROC_REF(color_received))

/obj/item/circuit_component/holo_signboard/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/structure/signboard/holosign))
		connected_display = shell

/obj/item/circuit_component/holo_signboard/input_received(datum/port/input/port)
	if(!connected_display)
		return
	if(length(message.value) > connected_display.max_length) //5000 is a hell of a lot longer than 144.
		fail_reason.set_output("Too long ([length(message.value)]/[connected_display.max_length]).")
		on_fail.set_output(COMPONENT_SIGNAL)
		return
	if(is_ic_filtered(message.value))
		fail_reason.set_output("Prohibited content.")
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/edited_message = replacetextEx_char(message.value, "<br>", "\n")
	if(connected_display.set_text(edited_message))
		investigate_log("Circuit USB ([parent.get_creator()]) set text to \"[connected_display.sign_text || "(none)"]\"", INVESTIGATE_SIGNBOARD)
		if(is_soft_ic_filtered(message.value))
			message_admins("A circuit component (by [parent.get_creator_admin()]) added a soft filtered message to a signboard. [ADMIN_COORDJMP(src)]")
	else
		fail_reason.set_output("Connection refused by external endpoint.")
		on_fail.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/holo_signboard/proc/clear_received(datum/port/input/port)
	if(!connected_display.set_text(null))
		fail_reason.set_output("Connection refused by external endpoint.")
		on_fail.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/holo_signboard/proc/color_received(datum/port/input/port)
	red.set_value(clamp(red.value, 0, 255))
	blue.set_value(clamp(blue.value, 0, 255))
	green.set_value(clamp(green.value, 0, 255))
	var/signboard_color = rgb(red.value, green.value, blue.value)
	if(signboard_color && signboard_color != rgb(0, 0, 0) && is_color_dark_with_saturation(signboard_color, 25))
		fail_reason.set_output("Color too dark to display.")
		on_fail.set_output(COMPONENT_SIGNAL)
		return
	connected_display.set_color(signboard_color) //doesnt have a return so no need to check and error
	investigate_log("Circuit USB ([parent.get_creator()]) set the color to [signboard_color || "(none)"]", INVESTIGATE_SIGNBOARD)

/// Given a color in the format of "#RRGGBB", will return if the color
/// is dark. Value is mixed with Saturation and Brightness from HSV.
/proc/is_color_dark_with_saturation(color, threshold = 25)
	var/hsl = rgb2num(color, COLORSPACE_HSL)
	return hsl[3] < threshold
