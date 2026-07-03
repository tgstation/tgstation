#define NEW_CHILD_INSERT_KEY_REGEX new /regex(@"\[child_(\d+)\]", "gm")

/**
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */

/**
 * Paper is now using markdown (like in github pull notes) for ALL rendering
 * so we do loose a bit of functionality but we gain in easy of use of
 * paper and getting rid of that crashing bug
 */
/obj/item/paper
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "paper"
	inhand_icon_state = "paper"
	worn_icon_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	resistance_flags = FLAMMABLE
	max_integrity = 50
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	custom_materials = list(/datum/material/paper = HALF_SHEET_MATERIAL_AMOUNT / 2)
	color = COLOR_WHITE
	item_flags = SKIP_FANTASY_ON_SPAWN
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING

	/// Lazylist of raw, unsanitised, unparsed text inputs that have been made to the paper.
	var/list/datum/paper_input/raw_text_inputs
	/// Lazylist of all raw stamp data to be sent to tgui.
	var/list/datum/paper_stamp/raw_stamp_data

	/// Whether the icon should show little scribbly written words when the paper has some text on it.
	var/show_written_words = TRUE

	/// Helper cache that contains a list of all icon_states that are currently stamped on the paper.
	var/list/stamp_cache

	/// Reagent to transfer to the user when they pick the paper up without proper protection.
	var/contact_poison
	/// Volume of contact_poison to transfer to the user when they pick the paper up without proper protection.
	var/contact_poison_volume = 0

	/// Default raw text to fill this paper with on init.
	var/default_raw_text

	/// Paper can be shown via cameras. When that is done, a deep copy of the paper is made and stored as a var on the camera.
	/// The paper is located in nullspace, and holds a weak ref to the camera that once contained it so the paper can do some
	/// state checking on if it should be shown to a viewer.
	var/datum/weakref/camera_holder

	///If TRUE, staff can read paper everywhere, but usually from requests panel.
	var/request_state = FALSE

	///If this paper can be selected as a candidate for a future message in a bottle when spawned outside of mapload. Doesn't affect manually doing that.
	var/can_become_message_in_bottle = TRUE

	/// Assoc Lazylist of REF()s to mobs that are viewing the paper while holding a writing tool to what that tool's writing implement details are
	VAR_FINAL/list/writers

/obj/item/paper/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-9, 9)
	pixel_y = base_pixel_y + rand(-8, 8)

	if(default_raw_text)
		add_raw_text(replace_text_keys(default_raw_text))

	update_appearance()

	if(can_become_message_in_bottle && !mapload && prob(MESSAGE_BOTTLE_CHANCE))
		LAZYADD(SSpersistence.queued_message_bottles, src)

	AddElement(/datum/element/burn_on_item_ignition)
	RegisterSignal(src, COMSIG_ATOM_IGNITED_BY_ITEM, PROC_REF(close_paper_ui))

/obj/item/paper/Destroy()
	camera_holder = null
	clear_paper()
	LAZYREMOVE(SSpersistence.queued_message_bottles, src)
	return ..()

/obj/item/paper/custom_fire_overlay()
	if (!custom_fire_overlay)
		custom_fire_overlay = mutable_appearance('icons/obj/service/bureaucracy.dmi', "paper_onfire_overlay", appearance_flags = RESET_COLOR|KEEP_APART)
	return custom_fire_overlay

/obj/item/paper/proc/close_paper_ui()
	SIGNAL_HANDLER
	SStgui.close_uis(src)

/// Determines whether this paper has been written or stamped to.
/obj/item/paper/proc/is_empty()
	return !(LAZYLEN(raw_text_inputs) || LAZYLEN(raw_stamp_data))

/// Returns a deep copy list of raw_text_inputs, or null if the list is empty or doesn't exist.
/obj/item/paper/proc/copy_raw_text()
	if(!LAZYLEN(raw_text_inputs))
		return null

	var/list/datum/paper_input/copy_text = list()

	for(var/datum/paper_input/existing_input as anything in raw_text_inputs)
		copy_text += existing_input.make_copy()

	return copy_text

/// Returns a deep copy list of raw_stamp_data, or null if the list is empty or doesn't exist. Does not copy overlays or stamp_cache, only the tgui rendered stamps.
/obj/item/paper/proc/copy_raw_stamps()
	if(!LAZYLEN(raw_stamp_data))
		return null

	var/list/datum/paper_stamp/copy_stamps = list()

	for(var/datum/paper_stamp/existing_input as anything in raw_stamp_data)
		copy_stamps += existing_input.make_copy()

	return copy_stamps

/**
 * This proc copies this sheet of paper to a new
 * sheet. Used by carbon papers and the photocopier machine.
 *
 * Arguments
 * * paper_type - Type path of the new paper to create. Can copy anything to anything.
 * * location - Where to spawn in the new copied paper.
 * * colored - If true, the copied paper will be coloured and will inherit all colours.
 * * greyscale_override - If set to a colour string and coloured is false, it will override the default of COLOR_WEBSAFE_DARK_GRAY when copying.
 */
/obj/item/paper/proc/copy(paper_type = /obj/item/paper, atom/location = loc, colored = TRUE, greyscale_override = null)
	var/obj/item/paper/new_paper
	if(ispath(paper_type, /obj/item/paper))
		new_paper = new paper_type(location)
	else if(istype(paper_type, /obj/item/paper))
		new_paper = paper_type
	else
		CRASH("invalid paper_type [paper_type], paper type path or instance expected")

	new_paper.raw_text_inputs = copy_raw_text()

	if(colored)
		new_paper.color = color
	else
		var/new_color = greyscale_override || COLOR_WEBSAFE_DARK_GRAY
		for(var/datum/paper_input/text as anything in new_paper.raw_text_inputs)
			text.apply_colour(new_color)

	new_paper.raw_stamp_data = copy_raw_stamps()
	new_paper.stamp_cache = stamp_cache?.Copy()
	new_paper.update_icon_state()
	new_paper.copy_overlays(src)
	return new_paper

/**
 * This simple helper adds the supplied raw text to the paper, appending to the end of any existing contents.
 *
 * This a God proc that does not care about paper max length and expects sanity checking beforehand if you want to respect it.
 *
 * The caller is expected to handle updating icons and appearance after adding text, to allow for more efficient batch adding loops.
 * * Arguments:
 * * text - The text to append to the paper.
 * * font - The font to use.
 * * color - The font color to use.
 * * bold - Whether this text should be rendered completely bold.
 * * advanced_html - Boolean that is true when the writer has R_FUN permission, which sanitizes less HTML (such as images) from the new paper_input
 * * children - List of all children of new paper input
 */
/obj/item/paper/proc/add_raw_text(text, font, color, bold, advanced_html, list/children)
	var/datum/paper_input/new_input_datum = new /datum/paper_input(
		text,
		font,
		color,
		bold,
		advanced_html,
		children
	)

	LAZYADD(raw_text_inputs, new_input_datum)
	return TRUE

/**
 * This simple helper adds the supplied stamp to the paper, appending to the end of any existing stamps.
 *
 * This a God proc that does not care about stamp max count and expects sanity checking beforehand if you want to respect it.
 *
 * It does however respect the overlay limit and will not apply any overlays past the cap.
 *
 * The caller is expected to handle updating icons and appearance after adding text, to allow for more efficient batch adding loops.
 * * Arguments:
 * * stamp_class - Div class for the stamp.
 * * stamp_x - X coordinate to render the stamp in tgui.
 * * stamp_y - Y coordinate to render the stamp in tgui.
 * * rotation - Degrees of rotation for the stamp to be rendered with in tgui.
 * * stamp_icon_state - Icon state for the stamp as part of overlay rendering.
* * stamp_icon_state - An alternate Icon file can be passed for the stamp as part of overlay rendering if desired
 */
/obj/item/paper/proc/add_stamp(stamp_class, stamp_x, stamp_y, rotation, stamp_icon_state, stamp_icon = 'icons/obj/service/bureaucracy.dmi')
	var/new_stamp_datum = new /datum/paper_stamp(stamp_class, stamp_x, stamp_y, rotation)
	LAZYADD(raw_stamp_data, new_stamp_datum);

	if(LAZYLEN(stamp_cache) > MAX_PAPER_STAMPS_OVERLAYS)
		return

	var/mutable_appearance/stamp_overlay = mutable_appearance(stamp_icon, "paper_[stamp_icon_state]", appearance_flags = KEEP_APART | RESET_COLOR)
	stamp_overlay.pixel_w = rand(-2, 2)
	stamp_overlay.pixel_z = rand(-3, 2)
	add_overlay(stamp_overlay)
	LAZYADD(stamp_cache, stamp_icon_state)

/// Removes all input and all stamps from the paper, clearing it completely.
/obj/item/paper/proc/clear_paper()
	LAZYNULL(raw_text_inputs)
	LAZYNULL(raw_stamp_data)
	LAZYNULL(stamp_cache)

	cut_overlays()
	update_appearance()

/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || !(G.body_parts_covered & HANDS) || HAS_TRAIT(G, TRAIT_FINGERPRINT_PASSTHROUGH) || HAS_TRAIT(H, TRAIT_FINGERPRINT_PASSTHROUGH))
			H.reagents.add_reagent(contact_poison,contact_poison_volume)
			contact_poison = null
	. = ..()

/obj/item/paper/update_icon_state()
	if(LAZYLEN(raw_text_inputs) && show_written_words)
		icon_state = "[initial(icon_state)]_words"
	else
		icon_state = initial(icon_state)
	return ..()

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set src in usr

	if(!usr.can_read(src) || usr.is_blind() || INCAPACITATED_IGNORING(usr, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB) || (isobserver(usr) && !isAdminGhostAI(usr)))
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(HAS_TRAIT(H, TRAIT_CLUMSY) && prob(25))
			to_chat(H, span_warning("You cut yourself on the paper! Ahhhh! Ahhhhh!"))
			H.damageoverlaytemp = 9001
			H.update_damage_hud()
			return
	var/n_name = tgui_input_text(usr, "Enter a paper label", "Paper Labelling", max_length = MAX_NAME_LEN)
	if(isnull(n_name) || n_name == "")
		return
	if(((loc == usr || istype(loc, /obj/item/clipboard)) && usr.stat == CONSCIOUS))
		name = "paper[(n_name ? "- '[n_name]'" : null)]"
	add_fingerprint(usr)
	update_static_data()

/obj/item/paper/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return BRUTELOSS

/obj/item/paper/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to fold it into a paper plane.")
	if(!in_range(user, src) && !isobserver(user))
		. += span_warning("You're too far away to read it!")
		return

	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return

	if(user.can_read(src))
		ui_interact(user)
		return
	. += span_warning("You cannot read it!")

/obj/item/paper/ui_status(mob/user, datum/ui_state/state)
	// Are we on fire?  Hard to read if so
	if(resistance_flags & ON_FIRE)
		return UI_CLOSE
	if(camera_holder && can_show_to_mob_through_camera(user) || request_state)
		return UI_UPDATE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	if(INCAPACITATED_IGNORING(user, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB) || (isobserver(user) && !isAdminGhostAI(user)))
		return UI_UPDATE
	// Even harder to read if your blind...braile? humm
	// .. or if you cannot read
	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return UI_CLOSE
	if(!user.can_read(src))
		return UI_CLOSE
	if(ismovable(loc) && loc.IsContainedAtomAccessible(src, user))
		return UI_INTERACTIVE
	return ..()

/obj/item/paper/can_interact(mob/user)
	if(ismovable(loc) && loc.IsContainedAtomAccessible(src, user))
		return TRUE
	return ..()

/obj/item/paper/click_alt(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_PAPER_MASTER))
		make_plane(user, /obj/item/paperplane/syndicate)
		return CLICK_ACTION_SUCCESS
	make_plane(user, /obj/item/paperplane)
	return CLICK_ACTION_SUCCESS



/**
 * Paper plane folding
 * Makes a paperplane depending on args and returns it.
 *
 * Arguments:
 * * mob/living/user - who's folding
 * * plane_type - what it will be folded into (path)
 */
/obj/item/paper/proc/make_plane(mob/living/user, plane_type = /obj/item/paperplane)
	loc.balloon_alert(user, "folded into a plane")
	user.temporarilyRemoveItemFromInventory(src)
	var/obj/item/paperplane/new_plane = new plane_type(loc, src)
	if(user.Adjacent(new_plane))
		user.put_in_hands(new_plane)
	return new_plane

/obj/item/paper/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	// Enable picking paper up by clicking on it with the clipboard or paper bin
	if(istype(attacking_item, /obj/item/clipboard) || istype(attacking_item, /obj/item/paper_bin))
		attacking_item.attackby(src, user)
		return

	// Handle writing items.
	var/writing_stats = attacking_item.get_writing_implement_details()

	if(!writing_stats)
		ui_interact(user)
		return ..()

	if(writing_stats["interaction_mode"] == MODE_WRITING)
		if(!user.can_write(attacking_item))
			return
		if(get_total_length() >= MAX_PAPER_LENGTH)
			to_chat(user, span_warning("This sheet of paper is full!"))
			return

		ui_interact(user)
		return

	// Handle stamping items.
	if(writing_stats["interaction_mode"] == MODE_STAMPING)
		if(!user.can_read(src) || user.is_blind())
			//The paper's stampable window area is assumed approx 300x400
			add_stamp(writing_stats["stamp_class"], rand(0, 300), rand(0, 400), rand(0, 360), writing_stats["stamp_icon_state"], stamp_icon = writing_stats["stamp_icon"])
			user.visible_message(span_notice("[user] blindly stamps [src] with \the [attacking_item]!"))
			to_chat(user, span_notice("You stamp [src] with \the [attacking_item] the best you can!"))
			playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
		else
			to_chat(user, span_notice("You ready your stamp over the paper! "))
			ui_interact(user)
		return

	ui_interact(user)
	return ..()

/// Secondary right click interaction to quickly stamp things
/obj/item/paper/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	var/list/writing_stats = tool.get_writing_implement_details()

	if(!length(writing_stats))
		return NONE
	if(writing_stats["interaction_mode"] != MODE_STAMPING)
		return NONE
	if(!user.can_read(src) || user.is_blind()) // Just leftclick instead
		return NONE

	add_stamp(writing_stats["stamp_class"], rand(1, 300), rand(1, 400), stamp_icon_state = writing_stats["stamp_icon_state"], stamp_icon = writing_stats["stamp_icon"])
	user.visible_message(
		span_notice("[user] quickly stamps [src] with [tool] without looking."),
		span_notice("You quickly stamp [src] with [tool] without looking."),
	)
	playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)

	return ITEM_INTERACT_BLOCKING // Stop the UI from opening.
/**
 * Attempts to ui_interact the paper to the given user, with some sanity checking
 * to make sure the camera still exists via the weakref and that this paper is still
 * attached to it.
 */
/obj/item/paper/proc/show_through_camera(mob/living/user)
	if(!can_show_to_mob_through_camera(user))
		return

	return ui_interact(user)

/obj/item/paper/proc/can_show_to_mob_through_camera(mob/living/user)
	var/obj/machinery/camera/held_to_camera = camera_holder.resolve()

	if(!held_to_camera)
		return FALSE

	if(isAI(user))
		var/mob/living/silicon/ai/ai_user = user
		if(ai_user.control_disabled || (ai_user.stat == DEAD))
			return FALSE

		return TRUE

	if(user.client?.eye != held_to_camera)
		return FALSE

	return TRUE

/obj/item/paper/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/stamps),
		get_asset_datum(/datum/asset/simple/logos),
		get_asset_datum(/datum/asset/simple/paper_logos),
	)

/obj/item/paper/ui_interact(mob/user, datum/tgui/ui)
	if(resistance_flags & ON_FIRE)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		/**
		 * these signals are for checking whether the ui viewer is holding a writing tool.
		 * (whether they are holding a writing tool matters for the state of the ui)
		 *
		 * we have to do this rigamarole, rather than just checking on ui_data calls,
		 * because if we set this ui to autoupdate, it causes weird rendering issues.
		 * rather than figure out why those are happening, it was easier to just turn off autoupdate.
		 */
		RegisterSignals(user, list(
			COMSIG_MOB_UNEQUIPPED_ITEM,
			COMSIG_MOB_EQUIPPED_ITEM,
			COMSIG_MOB_SWAP_HANDS,
			COMSIG_MOB_TRANSFORMING_ITEM, // specifically for pens
		), PROC_REF(viewer_writing_state_change))
		var/list/writing_info = get_viewer_writing_implement_details(user)
		if(writing_info)
			add_writer(user, writing_info, update = FALSE)

		ui = new(user, src, "PaperSheet", name)
		ui.open()
		// please see the above comment if you want to re-enable autoupdate
		ui.set_autoupdate(FALSE)

/obj/item/paper/ui_close(mob/user)
	. = ..()
	if(LAZYACCESS(writers, REF(user)))
		remove_writer(user, update = FALSE)
	UnregisterSignal(user, list(
		COMSIG_MOB_UNEQUIPPED_ITEM,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_SWAP_HANDS,
		COMSIG_MOB_TRANSFORMING_ITEM,
	))

/// Generically check if we are holding a writing tool to update our writer status
/obj/item/paper/proc/viewer_writing_state_change(mob/living/source)
	SIGNAL_HANDLER

	var/list/writing_info = get_viewer_writing_implement_details(source)
	if(writing_info)
		if(!LAZYACCESS(writers, REF(source)))
			add_writer(source, writing_info)

	else
		if(LAZYACCESS(writers, REF(source)))
			remove_writer(source)

/// Add passed mob with passed writing info to the list of writers, then updates their ui
/obj/item/paper/proc/add_writer(mob/living/user, list/writing_info, update = TRUE)
	PRIVATE_PROC(TRUE)
	set waitfor = FALSE

	LAZYSET(writers, REF(user), writing_info)
	if(update)
		ui_interact(user)

/// Remove passed mob from the list of writers, then updates their ui
/obj/item/paper/proc/remove_writer(mob/living/user, update = TRUE)
	PRIVATE_PROC(TRUE)
	set waitfor = FALSE

	LAZYREMOVE(writers, REF(user))
	if(update)
		ui_interact(user)

/obj/item/paper/proc/get_viewer_writing_implement_details(mob/living/user)
	if(istype(loc, /obj/structure/noticeboard))
		var/obj/structure/noticeboard/noticeboard = loc
		if(!noticeboard.allowed(user))
			return null

	var/obj/item/holding = user.get_active_held_item()
	. = holding?.get_writing_implement_details()

	// Use a clipboard's pen, if applicable
	if(istype(loc, /obj/item/clipboard))
		var/obj/item/clipboard/clipboard = loc
		. ||= clipboard.pen?.get_writing_implement_details()

	return .

/obj/item/paper/ui_data(mob/user)
	var/list/data = list()

	data["held_item_details"] = LAZYACCESS(writers, REF(user))

	return data

/obj/item/paper/ui_static_data(mob/user)
	var/list/static_data = list()

	static_data["user_name"] = user.real_name

	static_data += convert_to_data(include_ref = TRUE)

	static_data["max_length"] = MAX_PAPER_LENGTH

	static_data["default_pen_font"] = PEN_FONT
	static_data["default_pen_color"] = COLOR_BLACK
	static_data["signature_font"] = FOUNTAIN_PEN_FONT
	static_data["replacements"] = get_paper_placements_data(user)

	return static_data

/obj/item/paper/proc/get_paper_placements_data(mob/user)
	var/list/data = list()
	for(var/replacement_key in GLOB.paper_replacements)
		var/datum/paper_replacement/replacer = GLOB.paper_replacements[replacement_key]
		UNTYPED_LIST_ADD(data, list(
			"key" = replacement_key,
			"name" = replacer.name,
			"value" = replacer.get_replacement(user),
		))

	return data

/obj/item/paper/proc/convert_to_data(include_ref = FALSE)
	var/list/data = list()

	data[LIST_PAPER_RAW_TEXT_INPUT] = list()
	for(var/datum/paper_input/text_input as anything in raw_text_inputs)
		data[LIST_PAPER_RAW_TEXT_INPUT] += list(text_input.to_list(include_ref))

	data[LIST_PAPER_RAW_STAMP_INPUT] = list()
	for(var/datum/paper_stamp/stamp_input as anything in raw_stamp_data)
		data[LIST_PAPER_RAW_STAMP_INPUT] += list(stamp_input.to_list())

	data[LIST_PAPER_COLOR] = color ? color : COLOR_WHITE
	data[LIST_PAPER_NAME] = name

	return data

/obj/item/paper/proc/convert_paper_input_from_data(list/input)
	var/list/child_inputs
	if(length(input[LIST_PAPER_CHILDREN]))
		child_inputs = list()
		for(var/list/child_data as anything in input[LIST_PAPER_CHILDREN])
			child_inputs += convert_paper_input_from_data(child_data)
	return new /datum/paper_input(
		input[LIST_PAPER_RAW_TEXT],
		input[LIST_PAPER_FONT],
		input[LIST_PAPER_FIELD_COLOR],
		input[LIST_PAPER_BOLD],
		input[LIST_PAPER_ADVANCED_HTML],
		child_inputs
	)

/obj/item/paper/proc/write_from_data(list/data)
	for(var/list/input as anything in data[LIST_PAPER_RAW_TEXT_INPUT])
		LAZYADD(raw_text_inputs, convert_paper_input_from_data(input))

	for(var/list/stamp as anything in data[LIST_PAPER_RAW_STAMP_INPUT])
		add_stamp(stamp[LIST_PAPER_CLASS], stamp[LIST_PAPER_STAMP_X], stamp[LIST_PAPER_STAMP_Y], stamp[LIST_PAPER_ROTATION])

	var/new_color = data[LIST_PAPER_COLOR]
	if(new_color != COLOR_WHITE)
		add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)

	name = data[LIST_PAPER_NAME]

/obj/item/paper/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	switch(action)
		if("add_stamp")
			var/obj/item/holding = user.get_active_held_item()
			var/stamp_info = holding?.get_writing_implement_details()
			if(!stamp_info || (stamp_info["interaction_mode"] != MODE_STAMPING))
				to_chat(src, span_warning("You can't stamp with the [holding]!"))
				return TRUE

			var/stamp_class = stamp_info["stamp_class"];

			// If the paper is on an unwritable noticeboard, this usually shouldn't be possible.
			if(istype(loc, /obj/structure/noticeboard))
				var/obj/structure/noticeboard/noticeboard = loc
				if(!noticeboard.allowed(user))
					log_paper("[key_name(user)] tried to add stamp to [name] when it was on an unwritable noticeboard: \"[stamp_class]\"")
					return TRUE

			var/stamp_x = text2num(params["x"])
			var/stamp_y = text2num(params["y"])
			var/stamp_rotation = text2num(params["rotation"])
			var/stamp_icon_state = stamp_info["stamp_icon_state"]
			var/stamp_icon = stamp_info["stamp_icon"]

			if (LAZYLEN(raw_stamp_data) >= MAX_PAPER_STAMPS)
				to_chat(usr, pick("You try to stamp but you miss!", "There is nowhere else you can stamp!"))
				return TRUE

			add_stamp(stamp_class, stamp_x, stamp_y, stamp_rotation, stamp_icon_state, stamp_icon)
			user.visible_message(span_notice("[user] stamps [src] with \the [holding.name]!"), span_notice("You stamp [src] with \the [holding.name]!"))
			playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)

			update_appearance()
			update_static_data_for_all_viewers()
			return TRUE
		if("add_text")
			var/paper_input = params["text"]
			var/this_input_length = length_char(paper_input)

			if(this_input_length == 0)
				to_chat(user, pick("Writing block strikes again!", "You forgot to write anything!"))
				return TRUE

			// If the paper is on an unwritable noticeboard, this usually shouldn't be possible.
			if(istype(loc, /obj/structure/noticeboard))
				var/obj/structure/noticeboard/noticeboard = loc
				if(!noticeboard.allowed(user))
					log_paper("[key_name(user)] tried to write to [name] when it was on an unwritable noticeboard: \"[paper_input]\"")
					return TRUE

			var/obj/item/holding = user.get_active_held_item()
			// Use a clipboard's pen, if applicable
			if(istype(loc, /obj/item/clipboard))
				var/obj/item/clipboard/clipboard = loc
				// This is just so you can still use a stamp if you're holding one. Otherwise, it'll
				// use the clipboard's pen, if applicable.
				if(!istype(holding, /obj/item/stamp) && clipboard.pen)
					holding = clipboard.pen

			// As of the time of writing, can_write outputs a message to the user so we don't have to.
			if(!user.can_write(holding))
				return TRUE

			var/current_length = get_total_length()
			var/new_length = current_length + this_input_length

			// tgui should prevent this outcome.
			if(new_length > MAX_PAPER_LENGTH)
				log_paper("[key_name(user)] tried to write to [name] when it would exceed the length limit by [new_length - MAX_PAPER_LENGTH] characters: \"[paper_input]\"")
				return TRUE

			// Safe to assume there are writing implement details as user.can_write(...) fails with an invalid writing implement.
			var/writing_implement_data = holding.get_writing_implement_details()

			var/datum/paper_input/target_paper_input = locate(params["paper_input_ref"])
			var/field_id = text2num(params["field_id"])

			var/successful_input = FALSE
			if(istype(target_paper_input) && field_id)
				successful_input = add_raw_text_to_input_field(target_paper_input, field_id, paper_input, writing_implement_data, user)
			else
				successful_input = add_raw_text(
					paper_input,
					writing_implement_data["font"],
					writing_implement_data["color"],
					writing_implement_data["use_bold"],
					check_rights_for(user?.client, R_FUN)
				)

			if(!successful_input)
				return FALSE

			playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)

			log_paper("[key_name(user)] wrote to [name]: \"[paper_input]\"")
			to_chat(user, "You have added to your paper masterpiece!");

			update_static_data_for_all_viewers()
			update_appearance()
			return TRUE

/obj/item/paper/ui_host(mob/user)
	if(istype(loc, /obj/structure/noticeboard))
		return loc
	return ..()

/obj/item/paper/proc/get_total_length()
	var/total_length = 0
	for(var/datum/paper_input/entry as anything in raw_text_inputs)
		total_length += entry.get_raw_text_length()

	return total_length

/// Get a single string representing the text on a page
/obj/item/paper/proc/get_raw_text()
	var/paper_contents = ""
	for(var/datum/paper_input/line as anything in raw_text_inputs)
		paper_contents += line.get_raw_text() + "/"
	return paper_contents

/obj/item/paper/proc/add_raw_text_to_input_field(datum/paper_input/field_holder, input_field_id, raw_text, list/writing_implement_data, mob/user)
	PRIVATE_PROC(TRUE)

	if(!istype(field_holder))
		return FALSE

	var/datum/paper_input/field_input = new /datum/paper_input(
		raw_text,
		writing_implement_data["font"],
		writing_implement_data["color"],
		writing_implement_data["use_bold"],
		check_rights_for(user?.client, R_FUN)
	)

	return field_holder.add_child_to_field(field_input, input_field_id)

/// A single instance of a saved raw input onto paper.
/datum/paper_input
	/// Raw, unsanitised, unparsed text for an input.
	var/raw_text = ""
	/// Font to draw the input with.
	var/font = ""
	/// Colour to draw the input with.
	var/colour = ""
	/// Whether to render the font bold or not.
	var/bold = FALSE
	/// Whether the creator of this input field has the R_FUN permission, thus allowing less sanitization
	var/advanced_html = FALSE
	/// Lazy list of other paper inputs that will be displayed inside of this one.
	var/list/datum/paper_input/children

/datum/paper_input/New(_raw_text, _font, _colour, _bold, _advanced_html, _children)
	raw_text = _raw_text
	font = _font
	colour = _colour
	bold = _bold
	advanced_html = _advanced_html
	children = _children

/datum/paper_input/proc/make_copy()
	return new /datum/paper_input(raw_text, font, colour, bold, advanced_html, copy_children())

/datum/paper_input/proc/copy_children()
	if(!length(children))
		return null

	var/list/children_copies = list()
	for(var/datum/paper_input/child as anything in children)
		children_copies += child.make_copy()

	return children_copies

/datum/paper_input/proc/to_list(include_ref = FALSE)
	var/list/data = list(
		LIST_PAPER_RAW_TEXT = raw_text,
		LIST_PAPER_FONT = font,
		LIST_PAPER_FIELD_COLOR = colour,
		LIST_PAPER_BOLD = bold,
		LIST_PAPER_ADVANCED_HTML = advanced_html,
		LIST_PAPER_CHILDREN = children_to_list(include_ref),
	)
	if(include_ref)
		data["ref"] = REF(src)
	return data

/datum/paper_input/proc/children_to_list(include_ref = FALSE)
	PRIVATE_PROC(TRUE)

	var/list/children_as_lists = list()
	for(var/datum/paper_input/child as anything in children)
		UNTYPED_LIST_ADD(children_as_lists, child.to_list(include_ref))

	return children_as_lists

/datum/paper_input/proc/add_child_to_field(datum/paper_input/new_child, input_field_id)
	var/regex/input_field_regex = new(@"\[input_field(?:\]|\s+autofill_type=\w+\])", "gm")
	var/field_counter = 0
	while(input_field_regex.Find(raw_text))
		field_counter++
		if(field_counter < input_field_id)
			continue

		var/new_child_index = add_child(new_child)
		var/text_before_child_input = copytext(raw_text, 1, input_field_regex.index)
		var/text_after_child_input = splicetext(copytext(raw_text, input_field_regex.index), 1, length(input_field_regex.match) + 1, "\[input_field\]");

		raw_text = text_before_child_input +  "\[child_[new_child_index]\]" + text_after_child_input
		return TRUE

	return FALSE

/datum/paper_input/proc/get_raw_text()
	var/final_raw_text = raw_text
	if(length(children))
		var/regex/child_insert_key_regex = NEW_CHILD_INSERT_KEY_REGEX
		while(child_insert_key_regex.Find(final_raw_text))
			var/matched_text = child_insert_key_regex.match
			var/child_index = child_insert_key_regex.group[1]
			var/replacement_text = children[child_index].get_raw_text()
			final_raw_text = splicetext(final_raw_text, child_insert_key_regex.index, child_insert_key_regex.index + length(matched_text), replacement_text)

	return final_raw_text

/datum/paper_input/proc/get_raw_text_length()
	var/static/child_key_base_length = 8
	var/total_length = length_char(raw_text)
	for(var/index = 1, index <= length(children), index++)
		var/datum/paper_input/child = children[index]
		var/key_total_length = child_key_base_length + length("[index]")
		total_length += child.get_raw_text_length() - key_total_length

	return total_length

/datum/paper_input/proc/apply_colour(new_colour)
	colour = new_colour
	for(var/datum/paper_input/child as anything in children)
		child.apply_colour(new_colour)

/datum/paper_input/proc/add_child(datum/paper_input/new_child)
	LAZYADD(children, new_child)
	return length(children)

/// Returns the raw contents of the input as html, with **ZERO SANITIZATION**
/datum/paper_input/proc/to_raw_html()
	var/final = raw_text
	if(font || colour)
		final = "<font[" color='[colour]'"][" face='[font]'"]>[final]</font>"
	if(bold)
		final = "<b>[final]</b>"

	if(length(children))
		var/regex/child_insert_key_regex = NEW_CHILD_INSERT_KEY_REGEX
		while(child_insert_key_regex.Find(final))
			var/matched_text = child_insert_key_regex.match
			var/child_index = child_insert_key_regex.group[1]
			var/replacement_text = children[child_index].to_raw_html()
			final = splicetext(final, child_insert_key_regex.index, child_insert_key_regex.index + length(matched_text), replacement_text)

	return final

/// A single instance of a saved stamp on paper.
/datum/paper_stamp
	/// Asset class of the for rendering in tgui
	var/class = ""
	/// X position of stamp.
	var/stamp_x = 0
	/// Y position of stamp.
	var/stamp_y = 0
	/// Rotation of stamp in degrees. 0 to 359.
	var/rotation = 0

/datum/paper_stamp/New(_class, _stamp_x, _stamp_y, _rotation)
	class = _class
	stamp_x = _stamp_x
	stamp_y = _stamp_y
	rotation = _rotation

/datum/paper_stamp/proc/make_copy()
	return new /datum/paper_stamp(class, stamp_x, stamp_y, rotation)

/datum/paper_stamp/proc/to_list()
	return list(
		LIST_PAPER_CLASS = class,
		LIST_PAPER_STAMP_X = stamp_x,
		LIST_PAPER_STAMP_Y = stamp_y,
		LIST_PAPER_ROTATION = rotation,
	)

/obj/item/paper/construction
	name = "construction paper"
	icon = 'icons/effects/random_spawners.dmi'

/obj/item/paper/construction/Initialize(mapload)
	. = ..()
	icon = 'icons/obj/service/bureaucracy.dmi'
	color = pick(COLOR_RED, COLOR_LIME, COLOR_LIGHT_ORANGE, COLOR_DARK_PURPLE, COLOR_FADED_PINK, COLOR_BLUE_LIGHT)
	update_appearance()

/obj/item/paper/natural
	name = "natural paper"
	color = COLOR_OFF_WHITE

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"
	slot_flags = null
	show_written_words = FALSE

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/crumpled/muddy
	icon_state = "scrap_mud"

#undef NEW_CHILD_INSERT_KEY_REGEX
