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
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	inhand_icon_state = "paper"
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	worn_icon_state = "paper"
	custom_fire_overlay = "paper_onfire_overlay"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	dog_fashion = /datum/dog_fashion/head
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	grind_results = list(/datum/reagent/cellulose = 3)
	color = COLOR_WHITE

	/// Lazylist of raw, unsanitised, unparsed text inputs that have been made to the paper.
	var/list/datum/paper_input/raw_text_inputs
	/// Lazylist of all raw stamp data to be sent to tgui.
	var/list/datum/paper_stamp/raw_stamp_data
	/// Lazylist of all fields that have had some input added to them.
	var/list/datum/paper_field/raw_field_input_data

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

	/// The number of input fields
	var/input_field_count = 0

	/// Paper can be shown via cameras. When that is done, a deep copy of the paper is made and stored as a var on the camera.
	/// The paper is located in nullspace, and holds a weak ref to the camera that once contained it so the paper can do some
	/// state checking on if it should be shown to a viewer.
	var/datum/weakref/camera_holder

	///If TRUE, staff can read paper everywhere, but usually from requests panel.
	var/request_state = FALSE

/obj/item/paper/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-9, 9)
	pixel_y = base_pixel_y + rand(-8, 8)

	if(default_raw_text)
		add_raw_text(default_raw_text)

	update_appearance()

/obj/item/paper/Destroy()
	. = ..()
	camera_holder = null
	clear_paper()

/// Returns a deep copy list of raw_text_inputs, or null if the list is empty or doesn't exist.
/obj/item/paper/proc/copy_raw_text()
	if(!LAZYLEN(raw_text_inputs))
		return null

	var/list/datum/paper_input/copy_text = list()

	for(var/datum/paper_input/existing_input as anything in raw_text_inputs)
		copy_text += existing_input.make_copy()

	return copy_text

/// Returns a deep copy list of raw_field_input_data, or null if the list is empty or doesn't exist.
/obj/item/paper/proc/copy_field_text()
	if(!LAZYLEN(raw_field_input_data))
		return null

	var/list/datum/paper_field/copy_text = list()

	for(var/datum/paper_field/existing_input as anything in raw_field_input_data)
		copy_text += existing_input.make_copy()

	return copy_text

/// Returns a deep copy list of raw_stamp_data, or null if the list is empty or doesn't exist. Does not copy overlays or stamp_cache, only the tgui rendered stamps.
/obj/item/paper/proc/copy_raw_stamps()
	if(!LAZYLEN(raw_stamp_data))
		return null

	var/list/datum/paper_field/copy_stamps = list()

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
	var/obj/item/paper/new_paper = new paper_type(location)

	new_paper.raw_text_inputs = copy_raw_text()
	new_paper.raw_field_input_data = copy_field_text()

	if(colored)
		new_paper.color = color
	else
		var/new_color = greyscale_override || COLOR_WEBSAFE_DARK_GRAY
		for(var/datum/paper_input/text as anything in new_paper.raw_text_inputs)
			text.colour = new_color

		for(var/datum/paper_field/text as anything in new_paper.raw_field_input_data)
			text.field_data.colour = new_color

	new_paper.input_field_count = input_field_count
	new_paper.raw_stamp_data = copy_raw_stamps()
	new_paper.stamp_cache = stamp_cache?.Copy()
	new_paper.update_icon_state()
	copy_overlays(new_paper, TRUE)
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
 */
/obj/item/paper/proc/add_raw_text(text, font, color, bold, advanced_html)
	var/new_input_datum = new /datum/paper_input(
		text,
		font,
		color,
		bold,
		advanced_html,
	)

	input_field_count += get_input_field_count(text)

	LAZYADD(raw_text_inputs, new_input_datum)

/**
 * This simple helper adds the supplied input field data to the paper.
 *
 * It will not overwrite any existing input field data by default and will early return FALSE if this scenario happens unless overwrite is
 * set properly.
 *
 * Other than that, this is a God proc that does not care about max length or out-of-range IDs and expects sanity checking beforehand if
 * you want to respect it.
 *
 * * Arguments:
 * * field_id - The ID number of the field to which this data applies.
 * * text - The text to append to the paper.
 * * font - The font to use.
 * * color - The font color to use.
 * * bold - Whether this text should be rendered completely bold.
 * * overwrite - If TRUE, will overwrite existing field ID's data if it exists.
 */
/obj/item/paper/proc/add_field_input(field_id, text, font, color, bold, signature_name, overwrite = FALSE)
	var/datum/paper_field/field_data_datum = null

	var/is_signature = ((text == "%sign") || (text == "%s"))

	var/field_text = is_signature ? signature_name : text
	var/field_font = is_signature ? SIGNATURE_FONT : font

	for(var/datum/paper_field/field_input in raw_field_input_data)
		if(field_input.field_index == field_id)
			if(!overwrite)
				return FALSE
			field_data_datum = field_input
			break

	if(!field_data_datum)
		var/new_field_input_datum = new /datum/paper_field(
			field_id,
			field_text,
			field_font,
			color,
			bold,
			is_signature,
		)
		LAZYADD(raw_field_input_data, new_field_input_datum)
		return TRUE

	var/new_input_datum = new /datum/paper_input(
		field_text,
		field_font,
		color,
		bold,
	)

	field_data_datum.field_data = new_input_datum;
	field_data_datum.is_signature = is_signature;

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
 */
/obj/item/paper/proc/add_stamp(stamp_class, stamp_x, stamp_y, rotation, stamp_icon_state)
	var/new_stamp_datum = new /datum/paper_stamp(stamp_class, stamp_x, stamp_y, rotation)
	LAZYADD(raw_stamp_data, new_stamp_datum);

	if(LAZYLEN(stamp_cache) > MAX_PAPER_STAMPS_OVERLAYS)
		return

	var/mutable_appearance/stamp_overlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[stamp_icon_state]")
	stamp_overlay.pixel_x = rand(-2, 2)
	stamp_overlay.pixel_y = rand(-3, 2)
	add_overlay(stamp_overlay)
	LAZYADD(stamp_cache, stamp_icon_state)

/// Removes all input and all stamps from the paper, clearing it completely.
/obj/item/paper/proc/clear_paper()
	LAZYNULL(raw_text_inputs)
	LAZYNULL(raw_stamp_data)
	LAZYNULL(raw_field_input_data)
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
	return ..()

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if(!usr.can_read(src) || usr.is_blind() || usr.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB) || (isobserver(usr) && !isAdminGhostAI(usr)))
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
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	update_static_data()

/obj/item/paper/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return BRUTELOSS

/obj/item/paper/examine(mob/user)
	. = ..()
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

/obj/item/paper/extinguish()
	..()
	update_appearance()

/obj/item/paper/ui_status(mob/user,/datum/ui_state/state)
	// Are we on fire?  Hard to read if so
	if(resistance_flags & ON_FIRE)
		return UI_CLOSE
	if(camera_holder && can_show_to_mob_through_camera(user) || request_state)
		return UI_UPDATE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	if(user.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB) || (isobserver(user) && !isAdminGhostAI(user)))
		return UI_UPDATE
	// Even harder to read if your blind...braile? humm
	// .. or if you cannot read
	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return UI_CLOSE
	if(!user.can_read(src))
		return UI_CLOSE
	if(in_contents_of(/obj/machinery/door/airlock) || in_contents_of(/obj/item/clipboard))
		return UI_INTERACTIVE
	return ..()

/obj/item/paper/can_interact(mob/user)
	if(in_contents_of(/obj/machinery/door/airlock))
		return TRUE
	return ..()

/obj/item/proc/burn_paper_product_attackby_check(obj/item/I, mob/living/user, bypass_clumsy)
	var/ignition_message = I.ignition_effect(src, user)
	if(!ignition_message)
		return
	. = TRUE
	if(!bypass_clumsy && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10) && Adjacent(user))
		user.visible_message(span_warning("[user] accidentally ignites [user.p_them()]self!"), \
							span_userdanger("You miss [src] and accidentally light yourself on fire!"))
		if(user.is_holding(I)) //checking if they're holding it in case TK is involved
			user.dropItemToGround(I)
		user.adjust_fire_stacks(1)
		user.ignite_mob()
		return

	if(user.is_holding(src)) //no TK shit here.
		user.dropItemToGround(src)
	user.visible_message(ignition_message)
	add_fingerprint(user)
	fire_act(I.get_temperature())

/obj/item/paper/attackby(obj/item/attacking_item, mob/living/user, params)
	if(burn_paper_product_attackby_check(attacking_item, user))
		SStgui.close_uis(src)
		return

	// Enable picking paper up by clicking on it with the clipboard or folder
	if(istype(attacking_item, /obj/item/clipboard) || istype(attacking_item, /obj/item/folder) || istype(attacking_item, /obj/item/paper_bin))
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
			//The paper's stampable window area is assumed approx 400x500
			add_stamp(writing_stats["stamp_class"], rand(0, 400), rand(0, 500), rand(0, 360), writing_stats["stamp_icon_state"])
			user.visible_message(span_notice("[user] blindly stamps [src] with \the [attacking_item]!"))
			to_chat(user, span_notice("You stamp [src] with \the [attacking_item] the best you can!"))
			playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
		else
			to_chat(user, span_notice("You ready your stamp over the paper! "))
			ui_interact(user)
		return

	ui_interact(user)
	return ..()

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
		get_asset_datum(/datum/asset/spritesheet/simple/paper),
	)

/obj/item/paper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaperSheet", name)
		ui.open()

/obj/item/paper/ui_static_data(mob/user)
	var/list/static_data = list()

	static_data["user_name"] = user.real_name

	static_data["raw_text_input"] = list()
	for(var/datum/paper_input/text_input as anything in raw_text_inputs)
		static_data["raw_text_input"] += list(text_input.to_list())

	static_data["raw_field_input"] = list()
	for(var/datum/paper_field/field_input as anything in raw_field_input_data)
		static_data["raw_field_input"] += list(field_input.to_list())

	static_data["raw_stamp_input"] = list()
	for(var/datum/paper_stamp/stamp_input as anything in raw_stamp_data)
		static_data["raw_stamp_input"] += list(stamp_input.to_list())

	static_data["max_length"] = MAX_PAPER_LENGTH
	static_data["max_input_field_length"] = MAX_PAPER_INPUT_FIELD_LENGTH
	static_data["paper_color"] = color ? color : COLOR_WHITE
	static_data["paper_name"] = name

	static_data["default_pen_font"] = PEN_FONT
	static_data["default_pen_color"] = COLOR_BLACK
	static_data["signature_font"] = FOUNTAIN_PEN_FONT

	return static_data;

/obj/item/paper/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/holding = user.get_active_held_item()
	// Use a clipboard's pen, if applicable
	if(istype(loc, /obj/item/clipboard))
		var/obj/item/clipboard/clipboard = loc
		// This is just so you can still use a stamp if you're holding one. Otherwise, it'll
		// use the clipboard's pen, if applicable.
		if(!istype(holding, /obj/item/stamp) && clipboard.pen)
			holding = clipboard.pen

	data["held_item_details"] = holding?.get_writing_implement_details()

	// If the paper is on an unwritable noticeboard, clear the held item details so it's read-only.
	if(istype(loc, /obj/structure/noticeboard))
		var/obj/structure/noticeboard/noticeboard = loc
		if(!noticeboard.allowed(user))
			data["held_item_details"] = null;

	return data

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

			if (LAZYLEN(raw_stamp_data) >= MAX_PAPER_STAMPS)
				to_chat(usr, pick("You try to stamp but you miss!", "There is no where else you can stamp!"))
				return TRUE

			add_stamp(stamp_class, stamp_x, stamp_y, stamp_rotation, stamp_icon_state)
			user.visible_message(span_notice("[user] stamps [src] with \the [holding.name]!"), span_notice("You stamp [src] with \the [holding.name]!"))
			playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)

			update_appearance()
			update_static_data_for_all_viewers()
			return TRUE
		if("add_text")
			var/paper_input = params["text"]
			var/this_input_length = length(paper_input)

			if(this_input_length == 0)
				to_chat(user, pick("Writing block strikes again!", "You forgot to write anthing!"))
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

			add_raw_text(paper_input, writing_implement_data["font"], writing_implement_data["color"], writing_implement_data["use_bold"], check_rights_for(user?.client, R_FUN))

			log_paper("[key_name(user)] wrote to [name]: \"[paper_input]\"")
			to_chat(user, "You have added to your paper masterpiece!");

			update_static_data_for_all_viewers()
			update_appearance()
			return TRUE
		if("fill_input_field")
			// If the paper is on an unwritable noticeboard, this usually shouldn't be possible.
			if(istype(loc, /obj/structure/noticeboard))
				var/obj/structure/noticeboard/noticeboard = loc
				if(!noticeboard.allowed(user))
					log_paper("[key_name(user)] tried to write to the input fields of [name] when it was on an unwritable noticeboard!")
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

			// Safe to assume there are writing implement details as user.can_write(...) fails with an invalid writing implement.
			var/writing_implement_data = holding.get_writing_implement_details()
			var/list/field_data = params["field_data"]

			for(var/field_key in field_data)
				var/field_text = field_data[field_key]
				var/text_length = length(field_text)
				if(text_length > MAX_PAPER_INPUT_FIELD_LENGTH)
					log_paper("[key_name(user)] tried to write to field [field_key] with text over the max limit ([text_length] out of [MAX_PAPER_INPUT_FIELD_LENGTH]) with the following text: [field_text]")
					return TRUE
				if(text2num(field_key) >= input_field_count)
					log_paper("[key_name(user)] tried to write to invalid field [field_key] (when the paper only has [input_field_count] fields) with the following text: [field_text]")
					return TRUE

				if(!add_field_input(field_key, field_text, writing_implement_data["font"], writing_implement_data["color"], writing_implement_data["use_bold"], user.real_name))
					log_paper("[key_name(user)] tried to write to field [field_key] when it already has data, with the following text: [field_text]")

			update_static_data_for_all_viewers()
			return TRUE

/obj/item/paper/proc/get_input_field_count(raw_text)
	var/static/regex/field_regex = new(@"\[_+\]","g")

	var/counter = 0
	while(field_regex.Find(raw_text))
		counter++

	return counter

/obj/item/paper/ui_host(mob/user)
	if(istype(loc, /obj/structure/noticeboard))
		return loc
	return ..()

/obj/item/paper/proc/get_total_length()
	var/total_length = 0
	for(var/datum/paper_input/entry as anything in raw_text_inputs)
		total_length += length(entry.raw_text)

	return total_length

/// Get a single string representing the text on a page
/obj/item/paper/proc/get_raw_text()
	var/paper_contents = ""
	for(var/datum/paper_input/line as anything in raw_text_inputs)
		paper_contents += line.raw_text + "/"
	return paper_contents

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

/datum/paper_input/New(_raw_text, _font, _colour, _bold, _advanced_html)
	raw_text = _raw_text
	font = _font
	colour = _colour
	bold = _bold
	advanced_html = _advanced_html

/datum/paper_input/proc/make_copy()
	return new /datum/paper_input(raw_text, font, colour, bold, advanced_html)

/datum/paper_input/proc/to_list()
	return list(
		raw_text = raw_text,
		font = font,
		color = colour,
		bold = bold,
		advanced_html = advanced_html,
	)

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
		class = class,
		x = stamp_x,
		y = stamp_y,
		rotation = rotation,
	)

/// A reference to some data that replaces a modifiable input field at some given index in paper raw input parsing.
/datum/paper_field
	/// When tgui parses the raw input, if it encounters a field_index matching the nth user input field, it will disable it and replace it with the field_data.
	var/field_index = -1
	/// The data that tgui should substitute in-place of the input field when parsing.
	var/datum/paper_input/field_data = null
	/// If TRUE, requests tgui to render this field input in a more signature-y style.
	var/is_signature = FALSE

/datum/paper_field/New(_field_index, raw_text, font, colour, bold, _is_signature)
	field_index = _field_index
	field_data = new /datum/paper_input(raw_text, font, colour, bold)
	is_signature = _is_signature

/datum/paper_field/proc/make_copy()
	return new /datum/paper_field(field_index, field_data.raw_text, field_data.font, field_data.colour, field_data.bold, is_signature)

/datum/paper_field/proc/to_list()
	return list(
		field_index = field_index,
		field_data = field_data.to_list(),
		is_signature = is_signature,
	)

/obj/item/paper/construction

/obj/item/paper/construction/Initialize(mapload)
	. = ..()
	color = pick(COLOR_RED, COLOR_LIME, COLOR_LIGHT_ORANGE, COLOR_DARK_PURPLE, COLOR_FADED_PINK, COLOR_BLUE_LIGHT)

/obj/item/paper/natural
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
