/// Name of the blanks file
#define BLANKS_FILE_NAME "config/blanks.json"

/// For use with the `color_mode` var. Photos will be printed in greyscale while the var has this value.
#define PHOTO_GREYSCALE "Greyscale"
/// For use with the `color_mode` var. Photos will be printed in full color while the var has this value.
#define PHOTO_COLOR "Color"

/// How much toner is used for making a copy of a paper.
#define PAPER_TONER_USE 0.125
/// How much toner is used for making a copy of a photo.
#define PHOTO_TONER_USE 0.625
/// How much toner is used for making a copy of a document.
#define DOCUMENT_TONER_USE (PAPER_TONER_USE * DOCUMENT_PAPER_USE)
/// How much toner is used for making a copy of an ass.
#define ASS_TONER_USE PHOTO_TONER_USE
/// How much toner is used for making a copy of paperwork.
#define PAPERWORK_TONER_USE (PAPER_TONER_USE * PAPERWORK_PAPER_USE)

/// At which toner charge amount we start losing color. Toner cartridges are scams.
#define TONER_CHARGE_LOW_AMOUNT 2

// please use integers here
/// How much paper is used for making a copy of paper. What, are you seriously surprised by this?
#define PAPER_PAPER_USE 1
/// How much paper is used for making a copy of a photo.
#define PHOTO_PAPER_USE 1
/// How much paper is used for making a copy of a document.
#define DOCUMENT_PAPER_USE 20
/// How much paper is used for making a copy of a photo.
#define ASS_PAPER_USE PHOTO_PAPER_USE
/// How much paper is used for making a copy of paperwork.
#define PAPERWORK_PAPER_USE 10

/// Paper capacity of a matter bin
#define MATTER_BIN_PAPER_CAPACITY 30
/// The maximum amount of copies you can make with one press of the copy button.
#define MAX_COPIES_AT_ONCE 10

/// Photocopier copy fee.
#define PHOTOCOPIER_FEE 5

/// Paper blanks (form templates, basically). Loaded from `config/blanks.json`.
/// If invalid or not found, set to null.
GLOBAL_LIST_INIT(paper_blanks, init_paper_blanks())

/proc/init_paper_blanks()
	if(!fexists(BLANKS_FILE_NAME))
		return null
	var/list/blanks_json = json_decode(file2text(BLANKS_FILE_NAME))
	if(!length(blanks_json))
		return null

	var/list/parsed_blanks = list()
	for(var/paper_blank in blanks_json)
		parsed_blanks += list("[paper_blank["code"]]" = paper_blank)

	return parsed_blanks

/obj/machinery/photocopier
	name = "photocopier"
	desc = "Used to copy important documents and anatomy studies."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "photocopier"
	density = TRUE
	power_channel = AREA_USAGE_EQUIP
	max_integrity = 300
	integrity_failure = 0.33
	interaction_flags_mouse_drop = NEED_DEXTERITY | ALLOW_RESTING
	circuit = /obj/item/circuitboard/machine/photocopier

	/// The max paper capacity this photocopier can store
	var/max_paper_capacity
	/// How long it takes to print something in seconds
	var/time_to_print
	/// How efficent our toner is when printing
	var/toner_efficiency
	/// A reference to a mob on top of the photocopier trying to copy their ass. Null if there is no mob.
	var/mob/living/ass
	/// A reference to the toner cartridge that's inserted into the copier. Null if there is no cartridge.
	var/obj/item/toner/toner_cartridge
	/// Type path of toner this photocopier should starts with. Null if he should start without it.
	var/obj/item/toner/starting_toner
	/// How many copies will be printed with one click of the "copy" button.
	var/num_copies = 1
	/// Used with photos. Determines if the copied photo will be in greyscale or color.
	var/color_mode = PHOTO_COLOR
	/// Indicates whether the printer is currently busy copying or not.
	var/busy = FALSE
	/// How much does it cost to use this photocopier.
	var/usage_cost = PHOTOCOPIER_FEE
	/// Variable that holds a reference to any object supported for photocopying inside the photocopier
	var/obj/object_copy
	/// Variable for the UI telling us how many copies are in the queue.
	var/copies_left = 0
	/// The amount of paper this photocoper starts with.
	var/starting_paper = 0
	/// The paper loaded into the machine
	var/list/paper_stack = list()
	/// Type path to the paper that's created when we're initalized
	var/created_paper = /obj/item/paper
	/// Typecache of objects that can be inserted and scanned into the photocopier for copying
	var/static/list/whitelist_scannable_objects = typecacheof(list(
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/documents,
		/obj/item/paperwork
	))
	/// List of paper types that can be inserted as blank paper
	var/static/list/valid_paper_types = list(
		/obj/item/paper,
		/obj/item/paper/carbon,
		/obj/item/paper/construction,
		/obj/item/paper/natural,
	)

/obj/machinery/photocopier/prebuilt
	starting_toner = /obj/item/toner
	starting_paper = 30

/obj/machinery/photocopier/get_save_vars()
	. = ..()
	. += NAMEOF(src, paper_stack)
	return .

/obj/machinery/photocopier/Initialize(mapload)
	. = ..()
	setup_components()
	AddElement(/datum/element/elevation, pixel_shift = 8) //enough to look like your bums are on the machine.
	if(starting_paper)
		paper_stack[created_paper] = starting_paper
	if(starting_toner)
		toner_cartridge = new starting_toner(src)

/// Simply adds the necessary components for this to function.
/obj/machinery/photocopier/proc/setup_components()
	AddComponent(/datum/component/payment, usage_cost, SSeconomy.get_dep_account(ACCOUNT_CIV), PAYMENT_CLINICAL)

/obj/machinery/photocopier/RefreshParts()
	. = ..()
	max_paper_capacity = 0
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_paper_capacity += MATTER_BIN_PAPER_CAPACITY * matter_bin.tier

	toner_efficiency = 1
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		toner_efficiency += micro_laser.tier

	time_to_print = 5 SECONDS
	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		time_to_print -= (scanning_module.tier SECONDS)

/obj/machinery/photocopier/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == object_copy)
		object_copy = null
	if(gone == toner_cartridge)
		toner_cartridge = null

/obj/machinery/photocopier/dump_contents()
	var/dump_location = drop_location()

	// object_copy can be a traitor objective, don't qdel
	object_copy?.forceMove(dump_location)
	toner_cartridge?.forceMove(dump_location)

	for(var/paper_path in paper_stack)
		var/paper_amount = paper_stack[paper_path]
		if(paper_amount <= 0)
			stack_trace("Detected zero or negative [paper_path] amount inside photocopier. There should be at least 1 or more of paper amount inside the list")
			continue

		for(var/i in 1 to paper_amount)
			var/obj/item/paper/new_paper = new paper_path(dump_location)
			if(!new_paper.pixel_y)
				new_paper.pixel_y = rand(-3,3)
			if(!new_paper.pixel_x)
				new_paper.pixel_x = rand(-3,3)

		paper_stack.Remove(paper_path)

	update_appearance()

/obj/machinery/photocopier/Destroy()
	// object_copy can be a traitor objective, don't qdel
	object_copy?.forceMove(drop_location())

	QDEL_NULL(toner_cartridge)
	paper_stack = null
	ass = null //the mob isn't actually contained and just referenced, no need to delete it.
	return ..()

/obj/machinery/photocopier/on_deconstruction(disassembled)
	if(disassembled)
		dump_contents()
	return ..()

/obj/machinery/photocopier/examine(mob/user)
	. = ..()
	if(object_copy)
		. += span_notice("There is something inside the scanner tray.")
	. += span_notice("You can put any type of blank paper inside to print a form onto it or to copy something onto it.")

/obj/machinery/photocopier/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Photocopier")
		ui.open()

/obj/machinery/photocopier/ui_static_data(mob/user)
	var/list/static_data = list()

	var/list/blank_infos = list()
	var/list/category_names = list()
	if(GLOB.paper_blanks)
		for(var/blank_id in GLOB.paper_blanks)
			var/list/paper_blank = GLOB.paper_blanks[blank_id]
			blank_infos += list(list(
				name = paper_blank["name"],
				category = paper_blank["category"],
				code = blank_id,
			))
			category_names |= paper_blank["category"]

	static_data["blanks"] = blank_infos
	static_data["categories"] = category_names
	static_data["max_paper_count"] = max_paper_capacity
	static_data["max_copies"] = MAX_COPIES_AT_ONCE

	return static_data

/obj/machinery/photocopier/ui_data(mob/user)
	var/list/data = list()
	data["has_item"] = !copier_empty()
	data["num_copies"] = num_copies
	data["copies_left"] = copies_left

	if(istype(object_copy, /obj/item/photo))
		data["is_photo"] = TRUE
		data["color_mode"] = color_mode

	if(HAS_AI_ACCESS(user))
		data["isAI"] = TRUE
		data["can_AI_print"] = toner_cartridge && (toner_cartridge.charges >= PHOTO_TONER_USE) && (get_paper_count(created_paper) >= PHOTO_PAPER_USE)
	else
		data["isAI"] = FALSE

	if(toner_cartridge)
		data["has_toner"] = TRUE
		data["current_toner"] = toner_cartridge.charges
		data["max_toner"] = toner_cartridge.max_charges
	else
		data["has_toner"] = FALSE

	data["created_paper"] = created_paper
	data["paper_stack"] = paper_stack
	data["paper_count"] = get_paper_count()

	var/list/paper_types = list()
	for(var/obj/item/paper/paper as anything in valid_paper_types)
		paper_types += list(list(
			name = paper::name,
			icon = paper::icon,
			icon_state = paper::icon_state,
			amount = paper_stack[paper::type] || 0,
			type = paper::type,
		))
	data["paper_types"] = paper_types

	return data

/obj/machinery/photocopier/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(machine_stat & (BROKEN|NOPOWER))
		return

	switch(action)
		// Copying paper, photos, documents and asses.
		if("make_copy")
			if(check_busy(usr))
				return FALSE
			// ASS COPY. By Miauw
			if(ass)
				if(ishuman(ass) && (ass.get_item_by_slot(ITEM_SLOT_ICLOTHING) || ass.get_item_by_slot(ITEM_SLOT_OCLOTHING)))
					if(ass == usr)
						to_chat(usr, span_notice("You feel kind of silly, copying your ass with your clothes on."))
					else
						to_chat(usr, span_notice("You feel kind of silly, copying [ass]\'s ass with [ass.p_their()] clothes on."))
					return FALSE
				do_copies(CALLBACK(src, PROC_REF(make_ass_copy)), usr, ASS_PAPER_USE, ASS_TONER_USE, num_copies)
				return TRUE
			else
				// Basic paper
				if(istype(object_copy, /obj/item/paper))
					do_copies(CALLBACK(src, PROC_REF(make_paper_copy), object_copy), usr, PAPER_PAPER_USE, PAPER_TONER_USE, num_copies)
					return TRUE
				// Copying photo.
				if(istype(object_copy, /obj/item/photo))
					var/obj/item/photo/photo_copy = object_copy
					do_copies(CALLBACK(src, PROC_REF(make_photo_copy), photo_copy.picture, color_mode), usr, PHOTO_PAPER_USE, PHOTO_TONER_USE, num_copies)
					return TRUE
				// Copying Documents.
				if(istype(object_copy, /obj/item/documents))
					do_copies(CALLBACK(src, PROC_REF(make_document_copy), object_copy), usr, DOCUMENT_PAPER_USE, DOCUMENT_TONER_USE, num_copies)
					return TRUE
				// Copying paperwork
				if(istype(object_copy, /obj/item/paperwork))
					do_copies(CALLBACK(src, PROC_REF(make_paperwork_copy), object_copy), usr, PAPERWORK_PAPER_USE, PAPERWORK_TONER_USE, num_copies)
					return TRUE

		// Remove the paper/photo/document from the photocopier.
		if("remove")
			if(object_copy)
				remove_photocopy(usr, object_copy)
				object_copy = null
			else if(check_ass())
				to_chat(ass, span_notice("You feel a slight pressure on your ass."))
			return TRUE

		// AI printing photos from their saved images.
		if("ai_photo")
			if(check_busy(usr))
				return FALSE
			var/mob/living/silicon/ai/tempAI = usr
			if(!length(tempAI.aicamera.stored))
				balloon_alert(usr, "no images saved!")
				return FALSE
			var/datum/picture/selection = tempAI.aicamera.selectpicture(usr)
			do_copies(CALLBACK(src, PROC_REF(make_photo_copy), selection, PHOTO_COLOR), usr, PHOTO_PAPER_USE, PHOTO_TONER_USE, 1)
			return TRUE

		// Switch between greyscale and color photos
		if("color_mode")
			if(params["mode"] in list(PHOTO_GREYSCALE, PHOTO_COLOR))
				color_mode = params["mode"]
			return TRUE

		// Remove the toner cartridge from the copier.
		if("remove_toner")
			if(check_busy(usr))
				return FALSE
			var/success = usr.put_in_hands(toner_cartridge)
			if(!success)
				toner_cartridge.forceMove(drop_location())

			toner_cartridge = null
			return TRUE

		// Set the number of copies to be printed with 1 click of the "copy" button.
		if("set_copies")
			num_copies = clamp(text2num(params["num_copies"]), 1, MAX_COPIES_AT_ONCE)
			return TRUE
		// Called when you press print blank
		if("print_blank")
			if(check_busy(usr))
				return FALSE
			if(!(params["code"] in GLOB.paper_blanks))
				return FALSE
			var/list/blank = GLOB.paper_blanks[params["code"]]
			do_copies(CALLBACK(src, PROC_REF(make_blank_print), blank), usr, PAPER_PAPER_USE, PAPER_TONER_USE, num_copies)
			return TRUE
		if("select_paper_type")
			if(check_busy(usr))
				return FALSE

			var/paper_path = text2path(params["created_paper"])

			if(!ispath(paper_path, /obj/item/paper))
				return FALSE

			if(!paper_stack[paper_path])
				return FALSE

			created_paper = paper_path
			return TRUE

/// Returns the color used for the printing operation. If the color is below TONER_LOW_PERCENTAGE, it returns a gray color.
/obj/machinery/photocopier/proc/get_toner_color()
	return toner_cartridge.charges > TONER_CHARGE_LOW_AMOUNT ? COLOR_FULL_TONER_BLACK : COLOR_GRAY


/// Will invoke `do_copy_loop` asynchronously. Passes the supplied arguments on to it.
/obj/machinery/photocopier/proc/do_copies(datum/callback/copy_cb, mob/user, paper_use, toner_use, copies_amount)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	busy = TRUE
	update_use_power(ACTIVE_POWER_USE)
	// fucking god proc
	INVOKE_ASYNC(src, PROC_REF(do_copy_loop), user, copy_cb, paper_use, toner_use, copies_amount)

/obj/machinery/photocopier/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED

	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	visible_message(span_warning("Sparks fly out of [src]!"))
	balloon_alert(user, "payment system shorted")
	return TRUE

/**
 * Will invoke the passed in `copy_cb` callback in 4 second intervals, and charge the user 5 credits for each copy made.
 *
 * Arguments:
 * * user - the mob who clicked copy.
 * * copy_cb - a callback for which proc to call. Should only be one of the `make_x_copy()` procs, such as `make_paper_copy()`.
 * * paper_use - the amount of paper used in this operation
 * * toner_use - the amount of toner used in this operation
 * * copies_amount - the amount of copies we should make
 */
/obj/machinery/photocopier/proc/do_copy_loop(mob/user, datum/callback/copy_cb, paper_use, toner_use, copies_amount)
	var/error_message = null
	if(!toner_cartridge)
		copies_amount = 0
		error_message = span_warning("An error message flashes across \the [src]'s screen: \"No toner cartridge found. Aborting.\"")
	else if(toner_cartridge.charges < (toner_use / toner_efficiency) * copies_amount)
		copies_amount = FLOOR(toner_cartridge.charges / (toner_use / toner_efficiency), 1)
		error_message = span_warning("An error message flashes across \the [src]'s screen: \"Not enough toner to perform [copies_amount >= 1 ? "full " : ""]operation.\"")
	if(get_paper_count(created_paper) < paper_use * copies_amount)
		copies_amount = FLOOR(get_paper_count(created_paper) / paper_use, 1)
		error_message = span_warning("An error message flashes across \the [src]'s screen: \"Not enough paper to perform [copies_amount >= 1 ? "full " : ""]operation.\"")
	if(!(obj_flags & EMAGGED) && (copies_amount > 0) && (attempt_charge(src, user, (copies_amount - 1) * usage_cost) & COMPONENT_OBJ_CANCEL_CHARGE))
		copies_amount = 0
		error_message = span_warning("An error message flashes across \the [src]'s screen: \"Failed to charge bank account. Aborting.\"")

	copies_left = copies_amount

	if(copies_amount <= 0)
		to_chat(user, error_message)
		reset_busy()
		return

	if(error_message)
		to_chat(user, error_message)

	// if you managed to cancel the copy operation, tough luck. you aren't getting your money back.
	for(var/i in 1 to copies_amount)
		if(machine_stat & (BROKEN|NOPOWER))
			break

		if(!toner_cartridge)
			break

		// arguments to copy_cb have been set at callback instantiation
		var/atom/movable/copied_obj = copy_cb.Invoke()
		if(isnull(copied_obj)) // something went wrong, so other copies will go wrong too
			break

		playsound(src, 'sound/machines/printer.ogg', 50, vary = FALSE)
		sleep(time_to_print)

		// reveal our copied item
		copied_obj.forceMove(drop_location())
		give_pixel_offset(copied_obj)
		copies_left--

	copies_left = 0
	reset_busy()

/// Sets busy to `FALSE`.
/obj/machinery/photocopier/proc/reset_busy()
	update_use_power(IDLE_POWER_USE)
	busy = FALSE

/// Determines if the printer is currently busy, informs the user if it is.
/obj/machinery/photocopier/proc/check_busy(mob/user)
	if(busy)
		balloon_alert(user, "printer is busy!")
		return TRUE
	return FALSE

/**
 * Gives items a random x and y pixel offset, between -10 and 10 for each.
 *
 * This is done that when someone prints multiple papers, we dont have them all appear to be stacked in the same exact location.
 *
 * Arguments:
 * * copied_item - The paper, document, or photo that was just spawned on top of the printer.
 */
/obj/machinery/photocopier/proc/give_pixel_offset(obj/item/copied_item)
	copied_item.pixel_x = copied_item.base_pixel_x + rand(-10, 10)
	copied_item.pixel_y = copied_item.base_pixel_y + rand(-10, 10)

/**
 * Gets the total amount of paper this printer has stored
 *
 * Returns the amount of paper stored in the photocopier if passed with no args
 * If paper_type is supplied will only return the amount of that paper type
 *
 * Arguments:
 * * paper_type - The paper type to check to see quantity stored
 */
/obj/machinery/photocopier/proc/get_paper_count(paper_type)
	if(paper_type)
		return paper_stack[paper_type] || 0

	var/total_amount = 0
	for(var/paper_path in paper_stack)
		var/paper_amount = paper_stack[paper_path]
		if(paper_amount <= 0)
			stack_trace("Detected zero or negative [paper_path] amount inside photocopier. There should be at least 1 or more of paper amount inside the list")
			continue

		total_amount += paper_amount

	return total_amount

/**
 * Returns an empty paper, used for blanks and paper copies.
 * Prioritizes `paper_stack`, creates new paper in case `paper_stack` is empty.
 */
/obj/machinery/photocopier/proc/get_empty_paper(paper_type)
	var/obj/item/paper/new_paper = new paper_type()
	return new_paper

/**
 * Removes an amount of paper from the printer's storage.
 * This lets us pretend we actually consumed paper when we were actually printing something that wasn't paper.
 */
/obj/machinery/photocopier/proc/delete_paper(number)
	if(!paper_stack[created_paper] || (number > paper_stack[created_paper]))
		CRASH("Trying to delete more paper than is stored in the photocopier")

	paper_stack[created_paper] -= number
	if(paper_stack[created_paper] <= 0)
		paper_stack.Remove(created_paper)

/**
 * Handles the copying of paper. Transfers all the text, stamps and so on from the old paper, to the copy.
 *
 * Checks first if `paper_copy` exists. Since this proc is called from a timer, it's possible that it was removed.
 */
/obj/machinery/photocopier/proc/make_paper_copy(obj/item/paper/paper_copy)
	if(isnull(paper_copy))
		return null

	var/obj/item/paper/empty_paper = get_empty_paper(created_paper)
	delete_paper(PAPER_PAPER_USE)
	use_toner(PAPER_TONER_USE)

	var/copy_colour = get_toner_color()

	var/obj/item/paper/copied_paper = paper_copy.copy(empty_paper, src, FALSE, copy_colour)
	copied_paper.name = paper_copy.name
	return copied_paper

/**
 * Handles the copying of photos, which can be printed in either color or greyscale.
 *
 * Checks first if `picture` exists. Since this proc is called from a timer, it's possible that it was removed.
 */
/obj/machinery/photocopier/proc/make_photo_copy(datum/picture/photo, photo_color)
	if(isnull(photo))
		return null
	var/obj/item/photo/copied_pic = new(src, photo.Copy(photo_color == PHOTO_GREYSCALE ? TRUE : FALSE))
	delete_paper(PHOTO_PAPER_USE)
	use_toner(PHOTO_TONER_USE)
	return copied_pic

/**
 * Handles the copying of documents.
 *
 * Checks first if `document_copy` exists. Since this proc is called from a timer, it's possible that it was removed.
 */
/obj/machinery/photocopier/proc/make_document_copy(obj/item/documents/document_copy)
	if(isnull(document_copy))
		return null
	var/obj/item/documents/photocopy/copied_doc = new(src, document_copy)
	delete_paper(DOCUMENT_PAPER_USE)
	use_toner(DOCUMENT_TONER_USE)
	return copied_doc

/**
 * Handles the copying of documents.
 *
 * Checks first if `paperwork_copy` exists. Since this proc is called from a timer, it's possible that it was removed.
 * Copies the stamp from a given piece of paperwork if it is already stamped, allowing for you to sell photocopied paperwork at the risk of losing budget money.
 */
/obj/machinery/photocopier/proc/make_paperwork_copy(obj/item/paperwork/paperwork_copy)
	if(isnull(paperwork_copy))
		return null
	var/obj/item/paperwork/photocopy/copied_paperwork = new(src, paperwork_copy)
	copied_paperwork.copy_stamp_info(paperwork_copy)
	if(paperwork_copy.stamped)
		copied_paperwork.stamp_icon = "paper_stamp-pc" //Override with the photocopy overlay sprite
		copied_paperwork.add_stamp()
	delete_paper(PAPERWORK_PAPER_USE)
	use_toner(PAPERWORK_TONER_USE)
	return copied_paperwork

/// Handles the copying of blanks. No mutating state, so this should not fail.
/obj/machinery/photocopier/proc/make_blank_print(list/blank)
	var/copy_colour = get_toner_color()
	var/obj/item/paper/printblank = get_empty_paper(created_paper)

	var/printname = blank["name"]
	var/list/printinfo
	for(var/infoline in blank["info"])
		printinfo += infoline

	printblank.name = "paper - '[printname]'"
	printblank.add_raw_text(printinfo, color = copy_colour)
	printblank.update_appearance()
	use_toner(PAPER_TONER_USE)
	return printblank

/**
 * Handles the copying of an ass photo.
 *
 * Calls `check_ass()` first to make sure that `ass` exists, among other conditions. Since this proc is called from a timer, it's possible that it was removed.
 * Additionally checks that the mob has their clothes off.
 */
/obj/machinery/photocopier/proc/make_ass_copy()
	if(!check_ass())
		return null
	var/icon/temp_img = ass.get_butt_sprite()
	if(isnull(temp_img))
		return null
	var/obj/item/photo/copied_ass = new /obj/item/photo(src)
	var/datum/picture/toEmbed = new(name = "[ass]'s Ass", desc = "You see [ass]'s ass on the photo.", image = temp_img)
	toEmbed.psize_x = 128
	toEmbed.psize_y = 128
	copied_ass.set_picture(toEmbed, TRUE, TRUE)
	delete_paper(ASS_PAPER_USE)
	use_toner(ASS_TONER_USE)
	return copied_ass

/**
 * Called when someone hits the "remove item" button on the copier UI.
 *
 * If the user is a silicon, it drops the object at the location of the copier. If the user is not a silicon, it tries to put the object in their hands first.
 * Sets `busy` to `FALSE` because if the inserted item is removed, the copier should halt copying.
 *
 * Arguments:
 * * object - the item we're trying to remove.
 * * user - the user removing the item.
 */
/obj/machinery/photocopier/proc/remove_photocopy(mob/user, obj/item/object)
	if(issilicon(user))
		object.forceMove(drop_location())
		return

	object.forceMove(user.loc)
	user.put_in_hands(object)

	to_chat(user, span_notice("You take [object] out of [src]. [busy ? "The [src] comes to a halt." : ""]"))

/obj/machinery/photocopier/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_screwdriver(user, "photocopier2", "photocopier", tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/photocopier/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/photocopier/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/photocopier/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	// No infinite paper chain. You need the original paperwork to make more copies.
	if(istype(tool, /obj/item/paperwork/photocopy))
		balloon_alert(user, "too blurry!")
		to_chat(user, span_warning("The [tool] is far too messy to produce a good copy!"))
		return ITEM_INTERACT_FAILURE

	if(istype(tool, /obj/item/paper/paperslip))
		balloon_alert(user, "too small!")
		return ITEM_INTERACT_FAILURE

	if(istype(tool, /obj/item/blueprints))
		balloon_alert(user, "too large!")
		to_chat(user, span_warning("\The [tool] is too large to put into the copier. You need to find something else to record the document."))
		return ITEM_INTERACT_FAILURE

	if(istype(tool, /obj/item/toner))
		if(toner_cartridge)
			balloon_alert(user, "another cartridge inside!")
			return ITEM_INTERACT_FAILURE

		tool.forceMove(src)
		toner_cartridge = tool
		balloon_alert(user, "cartridge inserted")
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/paperplane))
		balloon_alert(user, "flatten paper first!")
		return ITEM_INTERACT_FAILURE

	if(istype(tool, /obj/item/paper))
		var/obj/item/paper/paper = tool

		if(paper.resistance_flags & ON_FIRE)
			balloon_alert(user, "paper on fire!")
			return ITEM_INTERACT_FAILURE

		if(paper.is_empty()) // if not empty it gets inserted as an object to be copied
			if(!has_room_for_paper())
				balloon_alert(user, "cannot hold more paper!")
				return ITEM_INTERACT_FAILURE

			insert_empty_paper(user, paper.type)
			qdel(paper)
			return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/paper_bin))
		var/obj/item/paper_bin/paper_bin = tool

		if(!paper_bin.total_paper)
			balloon_alert(user, "paper bin empty!")
			return ITEM_INTERACT_FAILURE

		var/paper_inserted = 0
		for(var/obj/item/paper/stacked_paper in paper_bin.paper_stack) // insert all paper that is already initialized
			var/is_empty = stacked_paper.is_empty()
			var/is_room = has_room_for_paper()
			if(!is_empty || !is_room)
				continue

			insert_empty_paper(user, stacked_paper.type, silent=TRUE)
			paper_bin.paper_stack -= stacked_paper
			paper_bin.total_paper -= 1
			paper_inserted++
			qdel(stacked_paper)

		if(paper_bin.total_paper) // then insert non-initialized paper that is always considered empty paper
			var/noninitialized_paper_total = paper_bin.total_paper - length(paper_bin.paper_stack)
			var/paper_to_take = min(max_paper_capacity - get_paper_count(), noninitialized_paper_total)
			if(paper_to_take)
				insert_empty_paper(user, paper_bin.papertype, paper_to_take, silent=TRUE)
				paper_inserted += paper_to_take
				paper_bin.total_paper -= (paper_to_take)

		if(!paper_inserted && !has_room_for_paper()) // no paper was inserted because it was full
			balloon_alert(user, "cannot hold more paper!")
			return ITEM_INTERACT_FAILURE

		paper_bin.update_appearance()
		// we use silent for insert_empty_paper() so that we don't spam balloon_alerts and instead condense them into one alert here
		balloon_alert(user, "[paper_inserted] paper inserted")
		return ITEM_INTERACT_SUCCESS

	if(is_type_in_typecache(tool, whitelist_scannable_objects))
		insert_copy_object(user, tool)
		return ITEM_INTERACT_SUCCESS

	return NONE

/// Check if there is enough room to insert paper
/obj/machinery/photocopier/proc/has_room_for_paper(mob/user, amount = 1)
	return get_paper_count() < max_paper_capacity

/// Proc that handles insertion of empty paper, useful for copying later.
/obj/machinery/photocopier/proc/insert_empty_paper(mob/user, paper_type, amount = 1, silent = FALSE)
	if(!paper_stack[paper_type])
		paper_stack[paper_type] = 0
	paper_stack[paper_type] += amount
	if(!silent)
		balloon_alert(user, "paper inserted")

/obj/machinery/photocopier/proc/insert_copy_object(mob/user, obj/item/object)
	if(!copier_empty())
		balloon_alert(user, "scanner tray occupied!")
		return
	if(!user.temporarilyRemoveItemFromInventory(object))
		return
	object_copy = object
	object.forceMove(src)
	balloon_alert(user, "copy object inserted")
	flick("photocopier1", src)

/obj/machinery/photocopier/atom_break(damage_flag)
	. = ..()
	if(. && toner_cartridge?.charges)
		new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
		toner_cartridge.charges = 0

/obj/machinery/photocopier/mouse_drop_receive(mob/target, mob/user, params)
	if(!istype(target) || target.anchored || target.buckled || target == ass || copier_blocked())
		return
	add_fingerprint(user)
	if(target == user)
		user.visible_message(span_notice("[user] starts climbing onto the photocopier!"), span_notice("You start climbing onto the photocopier..."))
	else
		user.visible_message(span_warning("[user] starts putting [target] onto the photocopier!"), span_notice("You start putting [target] onto the photocopier..."))

	if(do_after(user, 2 SECONDS, target = src))
		if(!target || QDELETED(target) || QDELETED(src) || !Adjacent(target)) //check if the photocopier/target still exists.
			return

		if(target == user)
			user.visible_message(span_notice("[user] climbs onto the photocopier!"), span_notice("You climb onto the photocopier."))
		else
			user.visible_message(span_warning("[user] puts [target] onto the photocopier!"), span_notice("You put [target] onto the photocopier."))

		target.forceMove(drop_location())
		ass = target

		if(!isnull(object_copy))
			object_copy.forceMove(drop_location())
			visible_message(span_warning("[object_copy] is shoved out of the way by [ass]!"))
			object_copy = null

/**
 * Checks the living mob `ass` exists and its location is the same as the photocopier.
 *
 * Returns FALSE if `ass` doesn't exist or is not at the copier's location. Returns TRUE otherwise.
 */
/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!isliving(ass))
		return FALSE
	if(ass.loc != loc)
		ass = null
		return FALSE
	return TRUE

/**
 * Checks if the copier is deleted, or has something dense at its location. Called in `mouse_drop_receive()`
 */
/obj/machinery/photocopier/proc/copier_blocked()
	if(QDELETED(src))
		return
	if(loc.density)
		return TRUE
	for(var/atom/movable/AM in loc)
		if(AM == src)
			continue
		if(AM.density)
			return TRUE
	return FALSE

/**
 * Removes a certain amount of toner that is affected by the efficiency of stock parts
 */
/obj/machinery/photocopier/proc/use_toner(amount)
	toner_cartridge.charges -= (amount / toner_efficiency)

/**
 * Checks if there is an item inserted into the copier or a mob sitting on top of it.
 *
 * Return `FALSE` is the copier has something inside of it. Returns `TRUE` if it doesn't.
 */
/obj/machinery/photocopier/proc/copier_empty()
	if(object_copy || check_ass())
		return FALSE
	else
		return TRUE

/// Subtype of photocopier that is free to use.
/obj/machinery/photocopier/gratis
	desc = "Does the same important paperwork, but it's free to use! The best type of free."
	usage_cost = 0 // it's free! no charge! very cool and gratis-pilled.

/obj/machinery/photocopier/gratis/prebuilt
	starting_toner = /obj/item/toner
	starting_paper = 30

/*
 * Toner cartridge
 */
/obj/item/toner
	name = "toner cartridge"
	desc = "A small, lightweight cartridge of Nanotrasen ValueBrand toner. Fits photocopiers and autopainters alike."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "tonercartridge"
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/iodine = 40, /datum/reagent/iron = 10)
	var/charges = 5
	var/max_charges = 5

/obj/item/toner/examine(mob/user)
	. = ..()
	. += span_notice("The ink level gauge on the side reads [round(charges / max_charges * 100)]%")

/obj/item/toner/large
	name = "large toner cartridge"
	desc = "A hefty cartridge of Nanotrasen ValueBrand toner. Fits photocopiers and autopainters alike."
	grind_results = list(/datum/reagent/iodine = 90, /datum/reagent/iron = 10)
	charges = 25
	max_charges = 25

/obj/item/toner/extreme
	name = "extremely large toner cartridge"
	desc = "Why would ANYONE need THIS MUCH TONER?"
	charges = 200
	max_charges = 200

#undef PHOTOCOPIER_FEE
#undef BLANKS_FILE_NAME
#undef PAPER_PAPER_USE
#undef PHOTO_PAPER_USE
#undef DOCUMENT_PAPER_USE
#undef ASS_PAPER_USE
#undef PAPERWORK_PAPER_USE
#undef MATTER_BIN_PAPER_CAPACITY
#undef TONER_CHARGE_LOW_AMOUNT
#undef PHOTO_GREYSCALE
#undef PHOTO_COLOR
#undef PAPER_TONER_USE
#undef PHOTO_TONER_USE
#undef DOCUMENT_TONER_USE
#undef ASS_TONER_USE
#undef MAX_COPIES_AT_ONCE
#undef PAPERWORK_TONER_USE
