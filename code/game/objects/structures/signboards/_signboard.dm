#define INVESTIGATE_SIGNBOARD "signboard"
#define SIGNBOARD_WIDTH (ICON_SIZE_X * 3.5)
#define SIGNBOARD_HEIGHT (ICON_SIZE_Y * 2.5)
#define MAX_SIGN_LEN 106

/obj/structure/signboard
	name = "sign"
	desc = "A foldable sign."
	icon = 'icons/obj/signboards.dmi'
	icon_state = "sign"
	base_icon_state = "sign"
	density = TRUE
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_REQUIRES_DEXTERITY
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 5)
	/// The image holding this sign's text
	var/image/text_image
	/// The current text written on the sign
	var/sign_text
	/// The maximum length of text that can be input onto the sign.
	var/max_length = MAX_SIGN_LEN
	/// If true, the text cannot be changed by players.
	var/locked = FALSE
	/// If text should be shown while unanchored.
	var/show_while_unanchored = FALSE
	/// If TRUE, the sign can be edited without a writing utensil.
	var/edit_by_hand = FALSE

/obj/structure/signboard/Initialize(mapload)
	. = ..()
	if(sign_text)
		set_text(sign_text, force = TRUE)
		investigate_log("had its text set on load to \"[sign_text]\"", INVESTIGATE_SIGNBOARD)
	update_appearance()
	register_context()

/obj/structure/signboard/Destroy(force)
	QDEL_NULL(text_image)
	return ..()

/obj/structure/signboard/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(is_locked(user))
		return
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
		return CONTEXTUAL_SCREENTIP_SET
	if((edit_by_hand || istype(held_item, /obj/item/pen)) && (anchored || show_while_unanchored))
		context[SCREENTIP_CONTEXT_LMB] = "Set Displayed Text"
		if(sign_text)
			context[SCREENTIP_CONTEXT_ALT_RMB] = "Clear Sign"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/signboard/examine(mob/user)
	. = ..()
	if(!edit_by_hand)
		. += span_notice("You can write on the sign with a <b>pen or other utensil.</b>")
	if(anchored)
		. += span_notice("It's secured to the floor, you could use a <b>wrench</b> to unsecure and move it.")
	else
		. += span_notice("It's unsecured, you could use a <b>wrench</b> to secure it in place.")
	if(sign_text)
		. += span_boldnotice("<hr>It currently displays the following:")
		. += span_info(html_encode(sign_text))
	else
		. += span_notice("\nIt's blank.")

/obj/structure/signboard/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][sign_text ? "" : "_blank"]"

/obj/structure/signboard/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, sign_text))
		if(!set_text(var_value, force = TRUE))
			return FALSE
		datum_flags |= DF_VAR_EDITED
		return TRUE
	return ..()

/obj/structure/signboard/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/pen))
		return NONE
	try_set_text(user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/signboard/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!edit_by_hand && !user.is_holding_item_of_type(/obj/item/pen))
		balloon_alert(user, "need a pen!")
		return TRUE
	if(try_set_text(user))
		return TRUE

/obj/structure/signboard/proc/try_set_text(mob/living/user)
	. = FALSE
	if(!anchored && !show_while_unanchored)
		return FALSE
	if(check_locked(user))
		return FALSE
	var/new_text = tgui_input_text(
		user,
		message = "What would you like to set this sign's text to?",
		title = full_capitalize(name),
		default = sign_text,
		max_length = max_length,
		multiline = TRUE,
		encode = FALSE,
	)
	if(QDELETED(src) || !new_text || check_locked(user))
		return FALSE
	var/list/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered(new_text)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		return FALSE
	var/list/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered(new_text)
	if(soft_filter_result)
		if(tgui_alert(user, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" when writing to the sign at [ADMIN_VERBOSEJMP(src)], they may be using a disallowed term. Sign text: \"[html_encode(new_text)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" when writing to the sign at [loc_name(src)], they may be using a disallowed term. Sign text: \"[new_text]\"")
	if(set_text(new_text))
		balloon_alert(user, "set text")
		investigate_log("([key_name(user)]) set text to \"[sign_text || "(none)"]\"", INVESTIGATE_SIGNBOARD)
		return TRUE

/obj/structure/signboard/click_alt_secondary(mob/user)
	. = ..()
	if(!sign_text || !can_interact(user) || !user.can_perform_action(src, NEED_DEXTERITY))
		return
	if(!edit_by_hand && !user.is_holding_item_of_type(/obj/item/pen))
		balloon_alert(user, "need a pen!")
		return
	if(check_locked(user))
		return
	if(set_text(null))
		balloon_alert(user, "cleared text")
		investigate_log("([key_name(user)]) cleared the text", INVESTIGATE_SIGNBOARD)

/obj/structure/signboard/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!anchored || !check_locked(user))
		default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/signboard/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(!same_z_layer)
		SET_PLANE_EXPLICIT(text_image, HUD_PLANE, src)
	return ..()

/obj/structure/signboard/set_anchored(anchorvalue)
	. = ..()
	update_text()

/obj/structure/signboard/proc/is_locked(mob/user)
	if(isAdminGhostAI(user))
		return FALSE
	return locked

/obj/structure/signboard/proc/check_locked(mob/user, silent = FALSE)
	. = is_locked(user)
	if(. && !silent)
		balloon_alert(user, "locked!")

/obj/structure/signboard/proc/should_display_text()
	if(QDELETED(src) || !isturf(loc) || !sign_text)
		return FALSE
	if(!anchored && !show_while_unanchored)
		return FALSE
	return TRUE

/obj/structure/signboard/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src) || !should_display_text())
		return
	usr.client.images |= text_image

/obj/structure/signboard/MouseExited(location, control, params)
	. = ..()
	usr.client.images -= text_image

/// Creates [text_image] if it doesn't exist, and sets its maptext to [sign_text]
/obj/structure/signboard/proc/update_text()
	PROTECTED_PROC(TRUE) // Use set_text instead
	var/safe_width = src.bound_width || ICON_SIZE_X
	var/safe_height = src.bound_height || ICON_SIZE_Y
	var/text_html = MAPTEXT_GRAND9K("<span style='text-align: center; line-height: 1'>[html_encode(sign_text)]</span>")
	if(!text_image)
		text_image = new
		SET_PLANE_EXPLICIT(text_image, HUD_PLANE, src)
		text_image.alpha = 192
		text_image.loc = src
	text_image.maptext = text_html
	text_image.maptext_x = (SIGNBOARD_WIDTH - safe_width) * -0.5
	text_image.maptext_y = safe_height
	text_image.maptext_width = SIGNBOARD_WIDTH
	text_image.maptext_height = SIGNBOARD_HEIGHT

/obj/structure/signboard/proc/set_text(new_text, force = FALSE)
	. = FALSE
	if(QDELETED(src) || (locked && !force))
		return
	if(!istext(new_text) && !isnull(new_text))
		CRASH("Attempted to set invalid signtext: [new_text]")
	. = TRUE
	sign_text = trim(new_text, max_length)
	update_text()
	update_appearance()

#undef MAX_SIGN_LEN
#undef SIGNBOARD_HEIGHT
#undef SIGNBOARD_WIDTH
