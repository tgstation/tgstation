#define MAX_PAINTING_ZOOM_OUT 3

///////////
// EASEL //
///////////

/obj/structure/easel
	name = "easel"
	desc = "Only for the finest of art!"
	icon = 'icons/obj/art/artstuff.dmi'
	icon_state = "easel"
	density = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 60
	var/obj/item/canvas/painting = null

//Adding canvases
/obj/structure/easel/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(I, /obj/item/canvas))
		var/obj/item/canvas/canvas = I
		user.transfer_item_to_turf(canvas, get_turf(src), silent = FALSE)
		painting = canvas
		canvas.layer = layer+0.1
		user.visible_message(span_notice("[user] puts \the [canvas] on \the [src]."),span_notice("You place \the [canvas] on \the [src]."))
	else
		return ..()


//Stick to the easel like glue
/obj/structure/easel/Move()
	var/turf/T = get_turf(src)
	. = ..()
	if(painting && painting.loc == T) //Only move if it's near us.
		painting.forceMove(get_turf(src))
	else
		painting = null

/obj/item/canvas
	name = "canvas"
	desc = "Draw out your soul on this canvas!"
	icon = 'icons/obj/art/artstuff.dmi'
	icon_state = "11x11"
	flags_1 = UNPAINTABLE_1
	resistance_flags = FLAMMABLE
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION
	var/width = 11
	var/height = 11
	var/list/grid
	/// empty canvas color
	var/canvas_color = "#ffffff"
	/// Is it clean canvas or was there something painted on it at some point, used to decide when to show wip splotch overlay
	var/used = FALSE
	var/finalized = FALSE //Blocks edits
	/// Whether a grid should be shown in the UI if the canvas is editable and the viewer is holding a painting tool.
	var/show_grid = TRUE
	var/icon_generated = FALSE
	var/icon/generated_icon
	///boolean that blocks persistence from saving it. enabled from printing copies, because we do not want to save copies.
	var/no_save = FALSE

	///reference to the last patron's mind datum, used to allow them (and no others) to change the frame before the round ends.
	var/datum/weakref/last_patron

	var/datum/painting/painting_metadata

	// Painting overlay offset when framed
	var/framed_offset_x = 11
	var/framed_offset_y = 10

	/**
	 * How big the grid cells that compose the painting are in the UI (multiplied by zoom).
	 * This impacts the size of the UI, so smaller values are generally better for bigger canvases and vice-versa
	 */
	var/pixels_per_unit = 9

	///A list that keeps track of the current zoom value for each current viewer.
	var/list/zoom_by_observer

	SET_BASE_PIXEL(11, 10)

	custom_price = PAYCHECK_CREW

/obj/item/canvas/Initialize(mapload)
	. = ..()
	reset_grid()

	painting_metadata = new
	painting_metadata.title = "Untitled Artwork"
	painting_metadata.creation_round_id = GLOB.round_id
	painting_metadata.width = width
	painting_metadata.height = height
	ADD_KEEP_TOGETHER(src, INNATE_TRAIT)

/obj/item/canvas/Destroy()
	last_patron = null
	if(istype(loc,/obj/structure/sign/painting))
		var/obj/structure/sign/painting/frame = loc
		frame.remove_art_element(painting_metadata.credit_value)
	painting_metadata = null
	return ..()

/obj/item/canvas/proc/reset_grid()
	grid = new/list(width,height)
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			grid[x][y] = canvas_color

/obj/item/canvas/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/canvas/ui_host(mob/user)
	if(istype(loc,/obj/structure/sign/painting))
		return loc
	return ..()

/obj/item/canvas/ui_state(mob/user)
	if(isobserver(user))
		return GLOB.observer_state
	if(finalized)
		return GLOB.hold_or_view_state
	return GLOB.default_state

/obj/item/canvas/ui_status(mob/user, datum/ui_state/state)
	if(state == GLOB.default_state || !state)
		return ..()
	//Skip the can_interact() check from atom/ui_status() and let them zoom in/out!
	var/src_object = ui_host(user)
	return state.can_use_topic(src_object, user)

/obj/item/canvas/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canvas", name)
		ui.open()

/obj/item/canvas/attackby(obj/item/I, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!user.combat_mode)
		ui_interact(user)
	else
		return ..()

/obj/item/canvas/ui_static_data(mob/user)
	. = ..()
	.["px_per_unit"] = pixels_per_unit
	.["max_zoom"] = MAX_PAINTING_ZOOM_OUT

/obj/item/canvas/ui_data(mob/user)
	. = ..()
	.["grid"] = grid
	.["zoom"] = LAZYACCESS(zoom_by_observer, user.key) || (finalized ? 1 : MAX_PAINTING_ZOOM_OUT)
	.["name"] = painting_metadata.title
	.["author"] = painting_metadata.creator_name
	.["patron"] = painting_metadata.patron_name
	.["medium"] = painting_metadata.medium
	.["date"] = painting_metadata.creation_date
	.["finalized"] = finalized
	.["editable"] = !finalized //Ideally you should be able to draw moustaches on existing paintings in the gallery but that's not implemented yet
	.["show_plaque"] = istype(loc,/obj/structure/sign/painting)
	.["show_grid"] = show_grid
	.["paint_tool_palette"] = null
	var/obj/item/painting_implement = user.get_active_held_item()
	if(!painting_implement)
		.["paint_tool_color"] = null
		return
	.["paint_tool_color"] = get_paint_tool_color(painting_implement)
	SEND_SIGNAL(painting_implement, COMSIG_PAINTING_TOOL_GET_ADDITIONAL_DATA, .)

/obj/item/canvas/examine(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/canvas/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	//this is here to allow observers and viewers to zoom in and out regardless of adjacency.
	//observers need this special check because we allow them to operate the UI in ui_state
	if((action != "zoom_in" && action != "zoom_out") && (isobserver(user) || !can_interact(user)))
		return
	switch(action)
		if("paint", "fill")
			if(finalized)
				return TRUE
			var/obj/item/I = user.get_active_held_item()
			var/tool_color = get_paint_tool_color(I)
			if(!tool_color)
				return FALSE
			if(action == "fill")
				var/x = params["x"]
				var/y = params["y"]
				if(!canvas_fill(x, y, tool_color))
					return FALSE
			else
				var/list/data = params["data"]
				for(var/point in data)
					var/x = text2num(point["x"])
					var/y = text2num(point["y"])
					grid[x][y] = tool_color
			var/medium = get_paint_tool_medium(I)
			if(medium && painting_metadata.medium && painting_metadata.medium != medium)
				painting_metadata.medium = "Mixed medium"
			else
				painting_metadata.medium = medium
			used = TRUE
			update_appearance()
			. = TRUE
		if("select_color")
			var/obj/item/painting_implement = user.get_active_held_item()
			painting_implement?.set_painting_tool_color(params["selected_color"])
			. = TRUE
		if("select_color_from_coords")
			var/obj/item/painting_implement = user.get_active_held_item()
			if(!painting_implement)
				return FALSE
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			painting_implement.set_painting_tool_color(grid[x][y])
			. = TRUE
		if("change_palette")
			var/obj/item/painting_implement = user.get_active_held_item()
			if(!painting_implement)
				return FALSE
			//I'd have this done inside the signal, but that'd have to be asynced,
			//while we want the UI to be updated after the color is chosen, not before.
			var/chosen_color = input(user, "Pick new color", painting_implement, params["old_color"]) as color|null
			if(!chosen_color || IS_DEAD_OR_INCAP(user) || !user.is_holding(painting_implement))
				return FALSE
			SEND_SIGNAL(painting_implement, COMSIG_PAINTING_TOOL_PALETTE_COLOR_CHANGED, chosen_color, params["color_index"])
			. = TRUE
		if("toggle_grid")
			. = TRUE
			show_grid = !show_grid
		if("finalize")
			. = TRUE
			finalize(user)
		if("patronage")
			. = TRUE
			patron(user)
		if("zoom_in")
			. = TRUE
			LAZYINITLIST(zoom_by_observer)
			if(!zoom_by_observer[user.key])
				zoom_by_observer[user.key] = 2
			else
				zoom_by_observer[user.key] = min(zoom_by_observer[user.key] + 1, MAX_PAINTING_ZOOM_OUT)
		if("zoom_out")
			. = TRUE
			LAZYINITLIST(zoom_by_observer)
			if(!zoom_by_observer[user.key])
				zoom_by_observer[user.key] = MAX_PAINTING_ZOOM_OUT - 1
			else
				zoom_by_observer[user.key] = max(zoom_by_observer[user.key] - 1, 1)

/obj/item/canvas/ui_close(mob/user)
	. = ..()
	LAZYREMOVE(zoom_by_observer, user.key)

/obj/item/canvas/proc/finalize(mob/user)
	if(painting_metadata.loaded_from_json || finalized)
		return
	if(!try_rename(user))
		return

	painting_metadata.creator_ckey = user.ckey
	painting_metadata.creator_name = user.real_name
	painting_metadata.creation_date = time2text(world.realtime, "DDD MMM DD hh:mm:ss YYYY", TIMEZONE_UTC)
	painting_metadata.creation_round_id = GLOB.round_id
	generate_proper_overlay()
	finalized = TRUE

	SStgui.update_uis(src)

#define CURATOR_PERCENTILE_CUT 0.225
#define SERVICE_PERCENTILE_CUT 0.125

/obj/item/canvas/proc/patron(mob/living/user)
	if(!finalized || !isliving(user))
		return
	if(!painting_metadata.loaded_from_json)
		if(tgui_alert(user, "The painting hasn't been archived yet and will be lost at the end of the shift if not placed in an elegible frame. Continue?","Unarchived Painting",list("Yes","No")) != "Yes")
			return
	var/mob/living/living_user = user
	var/obj/item/card/id/id_card = living_user.get_idcard(TRUE)
	if(!id_card)
		to_chat(user, span_warning("You don't even have a id and you want to be an art patron?"))
		return
	if(!id_card.can_be_used_in_payment(user))
		to_chat(user, span_warning("No valid non-departmental account found."))
		return
	var/datum/bank_account/account = id_card.registered_account
	if(!account.has_money(painting_metadata.credit_value))
		to_chat(user, span_warning("You can't afford this."))
		return
	var/sniped_amount = painting_metadata.credit_value
	var/offer_amount = tgui_input_number(user, "How much do you want to offer?", "Patronage Amount", (painting_metadata.credit_value + 1), account.account_balance, painting_metadata.credit_value)
	if(!offer_amount || QDELETED(user) || QDELETED(src) || !istype(loc, /obj/structure/sign/painting) || !user.can_perform_action(loc, FORBID_TELEKINESIS_REACH))
		return
	if(sniped_amount != painting_metadata.credit_value)
		return
	if(!account.adjust_money(-offer_amount, "Painting: Patron of [painting_metadata.title]"))
		to_chat(user, span_warning("Transaction failure. Please try again."))
		return

	var/datum/bank_account/service_account = SSeconomy.get_dep_account(ACCOUNT_SRV)
	service_account.adjust_money(offer_amount * SERVICE_PERCENTILE_CUT)
	///We give the curator(s) a cut (unless they're themselves the patron), as it's their job to curate and promote art among other things.
	if(SSeconomy.bank_accounts_by_job[/datum/job/curator])
		var/list/curator_accounts = SSeconomy.bank_accounts_by_job[/datum/job/curator] - account
		var/curators_length = length(curator_accounts)
		if(curators_length)
			var/curator_cut = round(offer_amount * CURATOR_PERCENTILE_CUT / curators_length)
			if(curator_cut)
				for(var/datum/bank_account/curator as anything in curator_accounts)
					curator.adjust_money(curator_cut, "Painting: Patronage cut")
					curator.bank_card_talk("Cut on patronage received, account now holds [curator.account_balance] cr.")

	if(istype(loc, /obj/structure/sign/painting))
		var/obj/structure/sign/painting/frame = loc
		frame.remove_art_element(painting_metadata.credit_value)
		frame.add_art_element(offer_amount)

	painting_metadata.patron_ckey = user.ckey
	painting_metadata.patron_name = user.real_name
	painting_metadata.credit_value = offer_amount
	last_patron = WEAKREF(user.mind)

	to_chat(user, span_notice("Nanotrasen Trust Foundation thanks you for your contribution. You're now an official patron of this painting."))
	if(HAS_PERSONALITY(user, /datum/personality/creative))
		user.add_mood_event("creative_patronage", /datum/mood_event/creative_patronage)
	if(HAS_PERSONALITY(user, /datum/personality/unimaginative))
		user.add_mood_event("unimaginative_patronage", /datum/mood_event/unimaginative_patronage)
	var/list/possible_frames = SSpersistent_paintings.get_available_frames(offer_amount)
	if(possible_frames.len <= 1) // Not much room for choices here.
		return
	if(tgui_alert(user, "Do you want to change the frame appearance now? You can do so later this shift with Alt-Click as long as you're a patron.","Patronage Frame",list("Yes","No")) != "Yes")
		return
	if(!can_select_frame(user))
		return
	SStgui.close_uis(src) // Close the examine ui so that the radial menu doesn't end up covered by it and people don't get confused.
	select_new_frame(user, possible_frames)

#undef CURATOR_PERCENTILE_CUT
#undef SERVICE_PERCENTILE_CUT

/obj/item/canvas/proc/select_new_frame(mob/user, list/candidates)
	var/possible_frames = candidates || SSpersistent_paintings.get_available_frames(painting_metadata.credit_value)
	var/list/radial_options = list()
	for(var/frame_name in possible_frames)
		radial_options[frame_name] = image(icon, "[icon_state]frame_[frame_name]")
	var/result = show_radial_menu(user, loc, radial_options, radius = 60, custom_check = CALLBACK(src, PROC_REF(can_select_frame), user), tooltips = TRUE)
	if(!result)
		return
	painting_metadata.frame_type = result
	var/obj/structure/sign/painting/our_frame = loc
	our_frame.balloon_alert(user, "frame set to [result]")
	our_frame.update_appearance()

/obj/item/canvas/proc/can_select_frame(mob/user)
	if(!istype(loc, /obj/structure/sign/painting))
		return FALSE
	if(!user?.CanReach(loc) || IS_DEAD_OR_INCAP(user))
		return FALSE
	if(!last_patron || !IS_WEAKREF_OF(user?.mind, last_patron))
		return FALSE
	return TRUE

/obj/item/canvas/update_overlays()
	. = ..()
	if(icon_generated)
		var/mutable_appearance/detail = mutable_appearance(generated_icon)
		detail.pixel_w = 1
		detail.pixel_z = 1
		. += detail
		return
	if(!used)
		return

	var/mutable_appearance/detail = mutable_appearance(icon, "[icon_state]wip")
	detail.pixel_w = 1
	detail.pixel_z = 1
	. += detail

/obj/item/canvas/proc/generate_proper_overlay()
	if(icon_generated)
		return
	var/png_filename = "data/paintings/temp_painting.png"
	var/image_data = get_data_string()
	var/result = rustg_dmi_create_png(png_filename, "[width]", "[height]", image_data)
	if(result)
		CRASH("Error generating painting png : [result]")
	painting_metadata.md5 = md5(LOWER_TEXT(image_data))
	generated_icon = new(png_filename)
	icon_generated = TRUE
	update_appearance()

/obj/item/canvas/proc/get_data_string()
	var/list/data = list()
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			data += grid[x][y]
	return data.Join("")

//Todo make this element ?
/obj/item/canvas/proc/get_paint_tool_color(obj/item/painting_implement)
	if(!painting_implement)
		return
	if(istype(painting_implement, /obj/item/paint_palette))
		var/obj/item/paint_palette/palette = painting_implement
		return palette.current_color
	if(istype(painting_implement, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = painting_implement
		return crayon.paint_color
	else if(istype(painting_implement, /obj/item/pen))
		var/obj/item/pen/pen = painting_implement
		return pen.colour
	else if(istype(painting_implement, /obj/item/soap) || istype(painting_implement, /obj/item/rag))
		return canvas_color

/// Generates medium description
/obj/item/canvas/proc/get_paint_tool_medium(obj/item/painting_implement)
	if(!painting_implement)
		return
	if(istype(painting_implement, /obj/item/paint_palette))
		return "Oil on canvas"
	else if(istype(painting_implement, /obj/item/toy/crayon/spraycan))
		return "Spraycan on canvas"
	else if(istype(painting_implement, /obj/item/toy/crayon))
		return "Crayon on canvas"
	else if(istype(painting_implement, /obj/item/pen))
		return "Ink on canvas"
	else if(istype(painting_implement, /obj/item/soap) || istype(painting_implement, /obj/item/rag))
		return //These are just for cleaning, ignore them
	else
		return "Unknown medium"

/obj/item/canvas/proc/try_rename(mob/user)
	if(painting_metadata.loaded_from_json) // No renaming old paintings
		return TRUE
	var/new_name = tgui_input_text(user, "What do you want to name the painting?", "Title Your Masterpiece", max_length = MAX_NAME_LEN)
	new_name = reject_bad_name(new_name, allow_numbers = TRUE, ascii_only = FALSE, strict = TRUE, cap_after_symbols = FALSE)
	if(isnull(new_name))
		return FALSE
	if(new_name != painting_metadata.title && user.can_perform_action(src))
		painting_metadata.title = new_name
	switch(tgui_alert(user, "Do you want to sign it or remain anonymous?", "Sign painting?", list("Yes", "No", "Cancel")))
		if("Yes")
			return TRUE
		if("No")
			painting_metadata.creator_name = "Anonymous"
			return TRUE

	return FALSE

///The pixel to the right matches the previous color we're flooding over
#define CANVAS_FILL_R_MATCH (1<<0)
///The pixel to the left matches the previous color we're flooding over
#define CANVAS_FILL_L_MATCH (1<<1)

//a macro for the stringized key for coordinates to check later
#define CANVAS_COORD(x, y) "[x]-[y]"
///queues a coordinate on the canvas for future cycles.
#define QUEUE_CANVAS_COORD(x, y, queue) \
	if(y && !queue[CANVAS_COORD(x, y)]) {\
		queue[CANVAS_COORD(x, y)] = list(x, y);\
	}

/**
 * A proc that adopts a span-based, 4-dir (correct me if I'm wrong) flood fill algorithm used
 * by the bucked tool in the UI, to facilitate coloring larger portions of the canvas.
 * If you have never used the bucket/flood tool on an image editor, I suggest you do it
 * now so you know what I'm basically talking about.
 *
 * @ param x The point on the x axys where we start flooding our canvas. The arg is later used to store the current x
 * @ param y The point on the y axys where we start flooding the canvas. The arg is later used to store the current y
 * @ param new_color The new color that floods over the old one
 */
/obj/item/canvas/proc/canvas_fill(x, y, new_color)
	var/prev_color = grid[x][y]
	//If the colors are the same, don't do anything.
	if(prev_color == new_color)
		return FALSE

	//The queue for coordinates to the right of the current line
	var/list/queue_right = list()
	//Inversely for those to our left
	var/list/queue_left = list()
	//Whether we're currently checking the right or left queue.
	var/go_right = TRUE

	//The current coordinates. The only reason this is outside the loop
	//is because we first go up, then reset our vertical position to just below
	//the starting position and go down from there.
	var/list/coords = list(x, y)

	//Basically, the way it works is that each cycle we first go up, then down until we
	//either reach the vertical borders of the raster or find a pixel that is not of the color we want
	//to flood. As we do this, we try to queue a minimum of coordinates to our
	//left and right to use for future cycles, moving horizontally in one direction until there are no
	//more queued coordinates for that dir. Then we turn around and repeat
	//until both left and right queues are completely empty.
	while(coords)
		//The current vertical line, the right and the left ones.
		var/list/curr_line = grid[x]
		var/list/right_line = x < width ? grid[x+1] : null
		var/list/left_line = x > 1 ? grid[x-1] : null
		//the queue we're on, depending on direction
		var/list/curr_queue = go_right ? queue_right : queue_left
		//Instead of queueing every point to our left and right that shares our prevous color,
		//Causing a lot of empty cycles, we only queue an extremity of a vertical segment
		//delimited by pixels of other colors or the y boundaries of the raster. To do this,
		//we need to track where the segment (called line for simplicity) starts (or ends).
		var/r_line_start
		var/l_line_start

		//go up first (y = 1 is the upper border is)
		while(y >= 1 && curr_line[y] == prev_color)
			var/return_flags = canvas_scan_step(x, y, queue_left, queue_right, left_line, right_line, l_line_start, r_line_start, prev_color)
			if(return_flags & CANVAS_FILL_R_MATCH)
				r_line_start = y
			else
				r_line_start = null
			if(return_flags & CANVAS_FILL_L_MATCH)
				l_line_start = y
			else
				l_line_start = null
			curr_line[y] = new_color
			curr_queue -= CANVAS_COORD(x, y) //remove it from the queue if possible.
			y--

		//Any unqueued coordinate is queued and cleared before the next half of the cycle
		QUEUE_CANVAS_COORD(x + 1, r_line_start, queue_right)
		QUEUE_CANVAS_COORD(x - 1, l_line_start, queue_left)
		r_line_start = l_line_start = null

		//set y to the pixel immediately below the starting y
		y = coords[2] + 1

		//then go down (y = height is the bottom border)
		while(y <= height && curr_line[y] == prev_color)
			var/return_flags = canvas_scan_step(x, y, queue_left, queue_right, left_line, right_line, l_line_start, r_line_start, prev_color)
			if(!(return_flags & CANVAS_FILL_R_MATCH))
				r_line_start = null
			else if(!r_line_start)
				r_line_start = y
			if(!(return_flags & CANVAS_FILL_L_MATCH))
				l_line_start = null
			else if(!l_line_start)
				l_line_start = y
			curr_line[y] = new_color
			curr_queue -= CANVAS_COORD(x, y)
			y++

		QUEUE_CANVAS_COORD(x + 1, r_line_start, queue_right)
		QUEUE_CANVAS_COORD(x - 1, l_line_start, queue_left)

		//Pick the next set of coords from the queue (and change direction if necessary)
		if(!length(curr_queue))
			var/list/other_queue = go_right ? queue_left : queue_right
			coords = other_queue[other_queue[1]]
			other_queue.Cut(1, 2)
			go_right = !go_right
		else
			coords = curr_queue[curr_queue[1]]
			curr_queue.Cut(1, 2)

		x = coords?[1]
		y = coords?[2]

	return TRUE

/**
 * The step of canvas_fill() that scans the pixels to the immediate right and left of our coord and see if they need to be queue'd or not.
 * Kept as a separate proc to reduce copypasted code.
 */
/proc/canvas_scan_step(x, y, list/queue_left, list/queue_right, list/left_line, list/right_line, left_pos, right_pos, prev_color)
	if(left_line)
		if(left_line[y] == prev_color)
			. += CANVAS_FILL_L_MATCH
		else
			QUEUE_CANVAS_COORD(x - 1, left_pos, queue_left)

	if(!right_line)
		return

	if(right_line[y] == prev_color)
		. += CANVAS_FILL_R_MATCH
	else
		QUEUE_CANVAS_COORD(x + 1, right_pos, queue_right)

#undef CANVAS_FILL_R_MATCH
#undef CANVAS_FILL_L_MATCH
#undef CANVAS_COORD
#undef QUEUE_CANVAS_COORD

/obj/item/canvas/nineteen_nineteen
	name = "canvas (19x19)"
	icon_state = "19x19"
	width = 19
	height = 19
	SET_BASE_PIXEL(7, 7)
	framed_offset_x = 7
	framed_offset_y = 7

/obj/item/canvas/twentythree_nineteen
	name = "canvas (23x19)"
	icon_state = "23x19"
	width = 23
	height = 19
	SET_BASE_PIXEL(5, 7)
	framed_offset_x = 5
	framed_offset_y = 7
	pixels_per_unit = 8

/obj/item/canvas/twentythree_twentythree
	name = "canvas (23x23)"
	icon_state = "23x23"
	width = 23
	height = 23
	SET_BASE_PIXEL(5, 5)
	framed_offset_x = 5
	framed_offset_y = 5
	pixels_per_unit = 8

/obj/item/canvas/twentyfour_twentyfour
	name = "canvas (24x24) (AI Universal Standard)"
	desc = "Besides being almost too large for a standard frame, the AI can accept these as a display from their internal database after you've hung it up."
	icon_state = "24x24"
	width = 24
	height = 24
	SET_BASE_PIXEL(4, 4)
	framed_offset_x = 4
	framed_offset_y = 4
	pixels_per_unit = 8

/obj/item/canvas/thirtysix_twentyfour
	name = "canvas (36x24)"
	desc = "A very large canvas to draw out your soul on. You'll need a larger frame to put it on a wall."
	icon_state = "24x24" //The vending spritesheet needs the icons to be 32x32. We'll set the actual icon on Initialize.
	width = 36
	height = 24
	SET_BASE_PIXEL(-4, 4)
	framed_offset_x = 14
	framed_offset_y = 4
	pixels_per_unit = 7
	w_class = WEIGHT_CLASS_BULKY

	custom_price = PAYCHECK_CREW * 1.25

/obj/item/canvas/thirtysix_twentyfour/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/item_scaling, 1, 0.8)
	icon = 'icons/obj/art/artstuff_64x64.dmi'
	icon_state = "36x24"

/obj/item/canvas/fortyfive_twentyseven
	name = "canvas (45x27)"
	desc = "The largest canvas available on the space market. You'll need a larger frame to put it on a wall."
	icon_state = "24x24" //Ditto
	width = 45
	height = 27
	SET_BASE_PIXEL(-8, 2)
	framed_offset_x = 9
	framed_offset_y = 4
	pixels_per_unit = 6
	w_class = WEIGHT_CLASS_BULKY

	custom_price = PAYCHECK_CREW * 1.75

/obj/item/canvas/fortyfive_twentyseven/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/item_scaling, 1, 0.7)
	icon = 'icons/obj/art/artstuff_64x64.dmi'
	icon_state = "45x27"

/obj/item/wallframe/painting
	name = "painting frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/signs.dmi'
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting
	pixel_shift = 30

/obj/structure/sign/painting
	name = "Painting"
	desc = "Art or \"Art\"? You decide."
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	base_icon_state = "frame"
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	///Canvas we're currently displaying.
	var/obj/item/canvas/current_canvas
	///Description set when canvas is added.
	var/desc_with_canvas
	var/persistence_id
	/// The list of canvas types accepted by this frame
	var/list/accepted_canvas_types = list(
		/obj/item/canvas,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/twentythree_nineteen,
		/obj/item/canvas/twentythree_twentythree,
		/obj/item/canvas/twentyfour_twentyfour,
	)
	/// the type of wallframe it 'disassembles' into
	var/wallframe_type = /obj/item/wallframe/painting

/obj/structure/sign/painting/get_save_vars()
	return ..() - NAMEOF(src, icon)

/obj/structure/sign/painting/Initialize(mapload, dir, building)
	. = ..()
	SSpersistent_paintings.painting_frames += src
	if(dir)
		setDir(dir)

/obj/structure/sign/painting/Destroy()
	. = ..()
	SSpersistent_paintings.painting_frames -= src

/obj/structure/sign/painting/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!current_canvas && istype(I, /obj/item/canvas))
		frame_canvas(user,I)
	else if(current_canvas && current_canvas.painting_metadata.title == initial(current_canvas.painting_metadata.title) && istype(I,/obj/item/pen))
		if(try_rename(user))
			SStgui.update_uis(src)
	else
		return ..()

/obj/structure/sign/painting/knock_down(mob/living/user)
	var/turf/drop_turf
	if(user)
		drop_turf = get_turf(user)
	else
		drop_turf = drop_location()
	current_canvas?.forceMove(drop_turf)
	var/obj/item/wallframe/frame = new wallframe_type(drop_turf)
	frame.update_integrity(get_integrity()) //Transfer how damaged it is.

/obj/structure/sign/painting/examine(mob/user)
	. = ..()
	if(persistence_id)
		. += span_notice("Any painting placed here will be archived at the end of the shift.")
	if(current_canvas)
		current_canvas.ui_interact(user)
		. += span_notice("Use wirecutters to remove the painting.")
		if(IS_WEAKREF_OF(user?.mind, current_canvas.last_patron))
			. += span_notice("<b>Alt-Click</b> to change select a new appearance for the frame of this painting.")

/obj/structure/sign/painting/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(current_canvas)
		current_canvas.forceMove(drop_location())
		to_chat(user, span_notice("You remove the painting from the frame."))
		return TRUE

/obj/structure/sign/painting/Exited(atom/movable/movable, atom/newloc)
	. = ..()
	if(movable == current_canvas)
		if(!QDELETED(current_canvas))
			remove_art_element(current_canvas.painting_metadata.credit_value)
		current_canvas = null
		update_appearance()

/obj/structure/sign/painting/click_alt(mob/user)
	if(!current_canvas?.can_select_frame(user))
		return CLICK_ACTION_BLOCKING

	INVOKE_ASYNC(current_canvas, TYPE_PROC_REF(/obj/item/canvas, select_new_frame), user)
	return CLICK_ACTION_SUCCESS

/obj/structure/sign/painting/proc/frame_canvas(mob/living/user, obj/item/canvas/new_canvas)
	if(!(new_canvas.type in accepted_canvas_types))
		to_chat(user, span_warning("[new_canvas] won't fit in this frame."))
		return FALSE
	if(user.transferItemToLoc(new_canvas,src))
		current_canvas = new_canvas
		if(!current_canvas.finalized)
			current_canvas.finalize(user)
		to_chat(user,span_notice("You frame [current_canvas]."))
		add_art_element()
		update_appearance()
		if(HAS_PERSONALITY(user, /datum/personality/creative))
			user.add_mood_event("creative_framing", /datum/mood_event/creative_framing)
		if(HAS_PERSONALITY(user, /datum/personality/unimaginative))
			user.add_mood_event("unimaginative_framing", /datum/mood_event/unimaginative_framing)
		return TRUE
	return FALSE

/obj/structure/sign/painting/proc/try_rename(mob/user)
	if(current_canvas.painting_metadata.title != initial(current_canvas.painting_metadata.title))
		return
	if(!current_canvas.try_rename(user))
		return
	SStgui.update_uis(current_canvas)

/obj/structure/sign/painting/update_icon_state(updates=ALL)
	. = ..()
	// Stops the frame icon_state from poking out behind the paintings. we have proper frame overlays in artstuff.dmi.
	icon = current_canvas?.generated_icon ? null : initial(icon)

/obj/structure/sign/painting/update_name(updates)
	name = current_canvas ? "painting - [current_canvas.painting_metadata.title]" : initial(name)
	return ..()

/obj/structure/sign/painting/update_desc(updates)
	desc = current_canvas ? desc_with_canvas : initial(desc)
	return ..()

/obj/structure/sign/painting/update_overlays()
	. = ..()
	if(!current_canvas?.generated_icon)
		return

	var/mutable_appearance/painting = mutable_appearance(current_canvas.generated_icon)
	painting.pixel_w = current_canvas.framed_offset_x
	painting.pixel_z = current_canvas.framed_offset_y
	. += painting
	var/frame_type = current_canvas.painting_metadata.frame_type
	. += mutable_appearance(current_canvas.icon,"[current_canvas.icon_state]frame_[frame_type]") //add the frame

/**
 * Loads a painting from SSpersistence. Called globally by said subsystem when it inits
 *
 * Deleting paintings leaves their json, so this proc will remove the json and try again if it finds one of those.
 */
/obj/structure/sign/painting/proc/load_persistent()
	if(!persistence_id)
		return FALSE
	var/list/valid_paintings = SSpersistent_paintings.get_paintings_with_tag(persistence_id)
	if(!length(valid_paintings))
		return FALSE //aborts loading anything this category has no usable paintings
	var/datum/painting/painting = pick(valid_paintings)
	var/png = "data/paintings/images/[painting.md5].png"
	var/icon/I = new(png)
	var/obj/item/canvas/new_canvas
	var/w = I.Width()
	var/h = I.Height()
	for(var/T in typesof(/obj/item/canvas))
		new_canvas = T
		if(initial(new_canvas.width) == w && initial(new_canvas.height) == h)
			if(!(new_canvas in accepted_canvas_types))
				CRASH("Found painting with canvas size not compatible with this frame. Canvas type: [new_canvas]")
			new_canvas = new T(src)
			break
	if(!istype(new_canvas))
		CRASH("Found painting size with no matching canvas type")
	new_canvas.painting_metadata = painting
	new_canvas.fill_grid_from_icon(I)
	new_canvas.generated_icon = I
	new_canvas.icon_generated = TRUE
	new_canvas.finalized = TRUE
	new_canvas.name = "painting - [painting.title]"
	current_canvas = new_canvas
	add_art_element()
	current_canvas.update_appearance()
	update_appearance()
	return TRUE

/obj/structure/sign/painting/proc/add_art_element()
	var/artistic_value = get_art_value(current_canvas.painting_metadata.credit_value)
	if(artistic_value)
		AddElement(/datum/element/art, artistic_value)

/obj/structure/sign/painting/proc/remove_art_element(patronage)
	var/artistic_value = get_art_value(patronage)
	if(artistic_value)
		RemoveElement(/datum/element/art, artistic_value)

/obj/structure/sign/painting/proc/get_art_value(patronage)
	switch(patronage)
		if(PATRONAGE_SUPERB_FRAME to INFINITY)
			return GREAT_ART
		if(PATRONAGE_EXCELLENT_FRAME to PATRONAGE_SUPERB_FRAME)
			return GOOD_ART
		if(PATRONAGE_NICE_FRAME to PATRONAGE_EXCELLENT_FRAME)
			return OK_ART
	return 0

/obj/structure/sign/painting/proc/save_persistent()
	if(!persistence_id || !current_canvas || current_canvas.no_save || current_canvas.painting_metadata.loaded_from_json)
		return
	if(SANITIZE_FILENAME(persistence_id) != persistence_id)
		stack_trace("Invalid persistence_id - [persistence_id]")
		return
	var/data = current_canvas.get_data_string()
	var/md5 = md5(LOWER_TEXT(data))
	var/list/current = SSpersistent_paintings.paintings[persistence_id]
	if(!current)
		current = list()
	for(var/datum/painting/entry in SSpersistent_paintings.paintings)
		if(entry.md5 == md5) // No duplicates
			return
	current_canvas.painting_metadata.md5 = md5
	if(!current_canvas.painting_metadata.tags)
		current_canvas.painting_metadata.tags = list(persistence_id)
	else
		current_canvas.painting_metadata.tags |= persistence_id
	var/png_directory = "data/paintings/images/"
	var/png_path = png_directory + "[md5].png"
	var/result = rustg_dmi_create_png(png_path,"[current_canvas.width]","[current_canvas.height]",data)
	if(result)
		CRASH("Error saving persistent painting: [result]")
	SSpersistent_paintings.paintings += current_canvas.painting_metadata

/obj/item/canvas/proc/fill_grid_from_icon(icon/I)
	var/h = I.Height() + 1
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			grid[x][y] = I.GetPixel(x,h-y)

/obj/item/wallframe/painting/large
	name = "large painting frame"
	desc = "The perfect showcase for your favorite deathtrap memories. Make sure you have enough space to mount this one to the wall."
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT*2)
	icon_state = "frame-large-empty"
	result_path = /obj/structure/sign/painting/large
	pixel_shift = 0 //See [/obj/structure/sign/painting/large/proc/finalize_size]
	custom_price = PAYCHECK_CREW * 1.25

/obj/item/wallframe/painting/large/try_build(turf/on_wall, mob/user)
	. = ..()
	if(!.)
		return
	var/our_dir = get_dir(user, on_wall)
	var/check_dir = our_dir & (EAST|WEST) ? NORTH : EAST
	var/turf/closed/wall/second_wall = get_step(on_wall, check_dir)
	if(!istype(second_wall) || !user.CanReach(second_wall))
		to_chat(user, span_warning("You need a reachable wall to the [check_dir == EAST ? "right" : "left"] of this one to mount this frame!"))
		return FALSE
	if(check_wall_item(second_wall, our_dir, wall_external))
		to_chat(user, span_warning("There's already an item on the wall to the [check_dir == EAST ? "right" : "left"] of this one!"))
		return FALSE

/obj/item/wallframe/painting/large/after_attach(obj/object)
	. = ..()
	var/obj/structure/sign/painting/large/our_frame = object
	our_frame.finalize_size()

/obj/structure/sign/painting/large
	icon = 'icons/obj/art/artstuff_64x64.dmi'
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT*2)
	accepted_canvas_types = list(
		/obj/item/canvas/thirtysix_twentyfour,
		/obj/item/canvas/fortyfive_twentyseven,
	)
	wallframe_type = /obj/item/wallframe/painting/large

/obj/structure/sign/painting/large/Initialize(mapload)
	. = ..()
	// Necessary so that the painting is framed correctly by the frame overlay when flipped.
	ADD_KEEP_TOGETHER(src, INNATE_TRAIT)
	if(mapload)
		finalize_size()

/**
 * This frame is visually put between two wall turfs and it has an icon that's bigger than 32px, and because
 * of the way it's designed, the pixel_shift variable from the wallframe item won't do.
 * Also we want higher bounds so it actually covers an extra wall turf, so that it can count toward check_wall_item calls for
 * that wall turf.
 */
/obj/structure/sign/painting/large/proc/finalize_size()
	switch(dir)
		if(SOUTH)
			pixel_y = -32
			bound_width = 64
		if(NORTH)
			bound_width = 64
		if(WEST)
			// Totally intended so that the frame sprite doesn't spill behind the wall and get partly covered by the darkness plane.
			// Ditto for the ones below.
			pixel_x = -29
			bound_height = 64
		if(EAST)
			bound_height = 64

/obj/structure/sign/painting/large/frame_canvas(mob/living/user, obj/item/canvas/new_canvas)
	. = ..()
	if(.)
		set_painting_offsets()

/obj/structure/sign/painting/large/load_persistent()
	. = ..()
	if(.)
		set_painting_offsets()

/obj/structure/sign/painting/large/proc/set_painting_offsets()
	switch(dir)
		if(EAST)
			transform = transform.Turn(90)
			pixel_x += 29
			pixel_y += 29
		if(WEST)
			transform = transform.Turn(-90)
		if(NORTH)
			pixel_y += 29

/obj/structure/sign/painting/large/Exited(atom/movable/movable, atom/newloc)
	if(movable == current_canvas)
		switch(dir)
			if(EAST)
				transform = transform.Turn(-90)
				pixel_x -= 29
				pixel_y -= 29
			if(WEST)
				transform = transform.Turn(90)
			if(NORTH)
				pixel_y -= 29
	return ..()

//Presets for art gallery mapping, for paintings to be shared across stations
/obj/structure/sign/painting/library
	name = "\improper Public Painting Exhibit mounting"
	desc = "For art pieces hung by the public."
	desc_with_canvas = "A piece of art (or \"art\"). Anyone could've hung it."
	persistence_id = "library"

/obj/structure/sign/painting/library_secure
	name = "\improper Curated Painting Exhibit mounting"
	desc = "For masterpieces hand-picked by the curator."
	desc_with_canvas = "A masterpiece hand-picked by the curator, supposedly."
	persistence_id = "library_secure"

/obj/structure/sign/painting/library_private // keep your smut away from prying eyes, or non-librarians at least
	name = "\improper Private Painting Exhibit mounting"
	desc = "For art pieces deemed too subversive or too illegal to be shared outside of curators."
	desc_with_canvas = "A painting hung away from lesser minds."
	persistence_id = "library_private"

/obj/structure/sign/painting/large/library
	name = "\improper Large Painting Exhibit mounting"
	desc = "For the bulkier art pieces, hand-picked by the curator."
	desc_with_canvas = "A curated, large piece of art (or \"art\"). Hopefully the price of the canvas was worth it."
	persistence_id = "library_large"

/obj/structure/sign/painting/large/library_private
	name = "\improper Private Painting Exhibit mounting"
	desc = "For the privier and less tasteful compositions that oughtn't to be shown in a parlor nor to the masses."
	desc_with_canvas = "A painting that oughn't to be shown to the less open-minded commoners."
	persistence_id = "library_large_private"


#define AVAILABLE_PALETTE_SPACE 14 // Enough to fill two radial menu pages

/// Simple painting utility.
/obj/item/paint_palette
	name = "paint palette"
	desc = "paintbrush included"
	icon = 'icons/obj/art/artstuff.dmi'
	icon_state = "palette"
	lefthand_file = 'icons/mob/inhands/equipment/palette_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/palette_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	///Chosen paint color
	var/current_color = COLOR_BLACK

/obj/item/paint_palette/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/palette, AVAILABLE_PALETTE_SPACE, current_color)

/obj/item/paint_palette/attack_self(mob/user, modifiers)
	. = ..()
	pick_painting_tool_color(user, current_color)

/obj/item/paint_palette/set_painting_tool_color(chosen_color)
	. = ..()
	current_color = chosen_color

#undef AVAILABLE_PALETTE_SPACE
#undef MAX_PAINTING_ZOOM_OUT
