
/// For use with the `color_mode` var. Photos will be printed in greyscale while the var has this value.
#define PHOTO_GREYSCALE "Greyscale"
/// For use with the `color_mode` var. Photos will be printed in full color while the var has this value.
#define PHOTO_COLOR "Color"

/// How much toner is used for making a copy of a paper.
#define PAPER_TONER_USE 0.125
/// How much toner is used for making a copy of a photo.
#define PHOTO_TONER_USE 0.625
/// How much toner is used for making a copy of a document.
#define DOCUMENT_TONER_USE 0.75
/// How much toner is used for making a copy of an ass.
#define ASS_TONER_USE 0.625
/// The maximum amount of copies you can make with one press of the copy button.
#define MAX_COPIES_AT_ONCE 10

/obj/machinery/photocopier
	name = "photocopier"
	desc = "Used to copy important documents and anatomy studies."
	icon = 'icons/obj/library.dmi'
	icon_state = "photocopier"
	density = TRUE
	power_channel = AREA_USAGE_EQUIP
	max_integrity = 300
	integrity_failure = 0.33
	/// A reference to an `/obj/item/paper` inside the copier, if one is inserted. Otherwise null.
	var/obj/item/paper/paper_copy
	/// A reference to an `/obj/item/photo` inside the copier, if one is inserted. Otherwise null.
	var/obj/item/photo/photo_copy
	/// A reference to an `/obj/item/documents` inside the copier, if one is inserted. Otherwise null.
	var/obj/item/documents/document_copy
	/// A reference to a mob on top of the photocopier trying to copy their ass. Null if there is no mob.
	var/mob/living/ass
	/// A reference to the toner cartridge that's inserted into the copier. Null if there is no cartridge.
	var/obj/item/toner/toner_cartridge
	/// How many copies will be printed with one click of the "copy" button.
	var/num_copies = 1
	/// Used with photos. Determines if the copied photo will be in greyscale or color.
	var/color_mode = PHOTO_COLOR
	/// Indicates whether the printer is currently busy copying or not.
	var/busy = FALSE
	/// Variable needed to determine the selected category of forms on Photocopier.js
	var/category

/obj/machinery/photocopier/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/payment, 5, SSeconomy.get_dep_account(ACCOUNT_CIV), PAYMENT_CLINICAL)
	toner_cartridge = new(src)

/obj/machinery/photocopier/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Photocopier")
		ui.open()

/obj/machinery/photocopier/ui_data(mob/user)
	var/list/data = list()
	data["has_item"] = !copier_empty()
	data["num_copies"] = num_copies

	try
		var/list/blanks = json_decode(file2text("config/blanks.json"))
		if (blanks != null)
			data["blanks"] = blanks
			data["category"] = category
			data["forms_exist"] = TRUE
		else
			data["forms_exist"] = FALSE
	catch()
		data["forms_exist"] = FALSE

	if(photo_copy)
		data["is_photo"] = TRUE
		data["color_mode"] = color_mode

	if(isAI(user))
		data["isAI"] = TRUE
		data["can_AI_print"] = toner_cartridge ? toner_cartridge.charges >= PHOTO_TONER_USE : FALSE
	else
		data["isAI"] = FALSE

	if(toner_cartridge)
		data["has_toner"] = TRUE
		data["current_toner"] = toner_cartridge.charges
		data["max_toner"] = toner_cartridge.max_charges
		data["has_enough_toner"] = has_enough_toner()
	else
		data["has_toner"] = FALSE
		data["has_enough_toner"] = FALSE

	return data

/obj/machinery/photocopier/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		// Copying paper, photos, documents and asses.
		if("make_copy")
			if(busy)
				to_chat(usr, span_warning("[src] is currently busy copying something. Please wait until it is finished."))
				return FALSE
			if(paper_copy)
				if(!paper_copy.get_total_length())
					to_chat(usr, span_warning("An error message flashes across [src]'s screen: \"The supplied paper is blank. Aborting.\""))
					return FALSE
				// Basic paper
				if(istype(paper_copy, /obj/item/paper))
					do_copy_loop(CALLBACK(src, .proc/make_paper_copy), usr)
					return TRUE
			// Copying photo.
			if(photo_copy)
				do_copy_loop(CALLBACK(src, .proc/make_photo_copy), usr)
				return TRUE
			// Copying Documents.
			if(document_copy)
				do_copy_loop(CALLBACK(src, .proc/make_document_copy), usr)
				return TRUE
			// ASS COPY. By Miauw
			if(ass)
				do_copy_loop(CALLBACK(src, .proc/make_ass_copy), usr)
				return TRUE

		// Remove the paper/photo/document from the photocopier.
		if("remove")
			if(paper_copy)
				remove_photocopy(paper_copy, usr)
				paper_copy = null
			else if(photo_copy)
				remove_photocopy(photo_copy, usr)
				photo_copy = null
			else if(document_copy)
				remove_photocopy(document_copy, usr)
				document_copy = null
			else if(check_ass())
				to_chat(ass, span_notice("You feel a slight pressure on your ass."))
			return TRUE

		// AI printing photos from their saved images.
		if("ai_photo")
			if(busy)
				to_chat(usr, span_warning("[src] is currently busy copying something. Please wait until it is finished."))
				return FALSE
			var/mob/living/silicon/ai/tempAI = usr
			if(!length(tempAI.aicamera.stored))
				to_chat(usr, span_boldannounce("No images saved."))
				return
			var/datum/picture/selection = tempAI.aicamera.selectpicture(usr)
			var/obj/item/photo/photo = new(loc, selection) // AI prints color photos only.
			give_pixel_offset(photo)
			toner_cartridge.charges -= PHOTO_TONER_USE
			return TRUE

		// Switch between greyscale and color photos
		if("color_mode")
			if(params["mode"] in list(PHOTO_GREYSCALE, PHOTO_COLOR))
				color_mode = params["mode"]
			return TRUE

		// Remove the toner cartridge from the copier.
		if("remove_toner")
			if(issilicon(usr) || (ishuman(usr) && !usr.put_in_hands(toner_cartridge)))
				toner_cartridge.forceMove(drop_location())
			toner_cartridge = null
			return TRUE

		// Set the number of copies to be printed with 1 click of the "copy" button.
		if("set_copies")
			num_copies = clamp(text2num(params["num_copies"]), 1, MAX_COPIES_AT_ONCE)
			return TRUE
		// Changes the forms displayed on Photocopier.js when you switch categories
		if("choose_category")
			category = params["category"]
			return TRUE
		// Called when you press print blank
		if("print_blank")
			if(busy)
				to_chat(usr, span_warning("[src] is currently busy copying something. Please wait until it is finished."))
				return FALSE
			if (toner_cartridge.charges - PAPER_TONER_USE < 0)
				to_chat(usr, span_warning("There is not enough toner in [src] to print the form, please replace the cartridge."))
				return FALSE
			do_copy_loop(CALLBACK(src, .proc/make_blank_print), usr)
			var/obj/item/paper/printblank = new /obj/item/paper (loc)
			var/printname = sanitize(params["name"])
			var/list/printinfo
			for(var/infoline as anything in params["info"])
				printinfo += infoline
			printblank.name = printname
			printblank.add_raw_text(printinfo)
			printblank.update_appearance()
			return printblank

/**
 * Determines if the photocopier has enough toner to create `num_copies` amount of copies of the currently inserted item.
 */
/obj/machinery/photocopier/proc/has_enough_toner()
	if(paper_copy)
		return toner_cartridge.charges >= (PAPER_TONER_USE * num_copies)
	else if(document_copy)
		return toner_cartridge.charges >= (DOCUMENT_TONER_USE * num_copies)
	else if(photo_copy)
		return toner_cartridge.charges >= (PHOTO_TONER_USE * num_copies)
	else if(ass)
		return toner_cartridge.charges >= (ASS_TONER_USE * num_copies)
	return FALSE

/**
 * Will invoke the passed in `copy_cb` callback in 1 second intervals, and charge the user 5 credits for each copy made.
 *
 * Arguments:
 * * copy_cb - a callback for which proc to call. Should only be one of the `make_x_copy()` procs, such as `make_paper_copy()`.
 * * user - the mob who clicked copy.
 */
/obj/machinery/photocopier/proc/do_copy_loop(datum/callback/copy_cb, mob/user)
	busy = TRUE
	update_use_power(ACTIVE_POWER_USE)
	var/i
	for(i in 1 to num_copies)
		if(attempt_charge(src, user) & COMPONENT_OBJ_CANCEL_CHARGE)
			break
		addtimer(copy_cb, i SECONDS)
	addtimer(CALLBACK(src, .proc/reset_busy), i SECONDS)

/**
 * Sets busy to `FALSE`. Created as a proc so it can be used in callbacks.
 */
/obj/machinery/photocopier/proc/reset_busy()
	update_use_power(IDLE_POWER_USE)
	busy = FALSE

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
 * Handles the copying of paper. Transfers all the text, stamps and so on from the old paper, to the copy.
 *
 * Checks first if `paper_copy` exists. Since this proc is called from a timer, it's possible that it was removed.
 */
/obj/machinery/photocopier/proc/make_paper_copy()
	if(!paper_copy)
		return

	var/copy_colour = toner_cartridge.charges > 10 ? COLOR_FULL_TONER_BLACK : COLOR_GRAY;

	var/obj/item/paper/copied_paper = paper_copy.copy(/obj/item/paper, loc, FALSE, copy_colour)

	give_pixel_offset(copied_paper)

	copied_paper.name = paper_copy.name

	toner_cartridge.charges -= PAPER_TONER_USE

/**
 * Handles the copying of photos, which can be printed in either color or greyscale.
 *
 * Checks first if `photo_copy` exists. Since this proc is called from a timer, it's possible that it was removed.
 */
/obj/machinery/photocopier/proc/make_photo_copy()
	if(!photo_copy)
		return
	var/obj/item/photo/copied_pic = new(loc, photo_copy.picture.Copy(color_mode == PHOTO_GREYSCALE ? TRUE : FALSE))
	give_pixel_offset(copied_pic)
	toner_cartridge.charges -= PHOTO_TONER_USE

/**
 * Handles the copying of documents.
 *
 * Checks first if `document_copy` exists. Since this proc is called from a timer, it's possible that it was removed.
 */
/obj/machinery/photocopier/proc/make_document_copy()
	if(!document_copy)
		return
	var/obj/item/documents/photocopy/copied_doc = new(loc, document_copy)
	give_pixel_offset(copied_doc)
	toner_cartridge.charges -= DOCUMENT_TONER_USE

/**
 * The procedure is called when printing a blank to write off toner consumption.
 */
/obj/machinery/photocopier/proc/make_blank_print()
	toner_cartridge.charges -= PAPER_TONER_USE

/**
 * Handles the copying of an ass photo.
 *
 * Calls `check_ass()` first to make sure that `ass` exists, among other conditions. Since this proc is called from a timer, it's possible that it was removed.
 * Additionally checks that the mob has their clothes off.
 */
/obj/machinery/photocopier/proc/make_ass_copy()
	if(!check_ass())
		return
	if(ishuman(ass) && (ass.get_item_by_slot(ITEM_SLOT_ICLOTHING) || ass.get_item_by_slot(ITEM_SLOT_OCLOTHING)))
		to_chat(usr, span_notice("You feel kind of silly, copying [ass == usr ? "your" : ass][ass == usr ? "" : "\'s"] ass with [ass == usr ? "your" : "[ass.p_their()]"] clothes on.") )
		return

	var/icon/temp_img
	if(ishuman(ass))
		var/mob/living/carbon/human/H = ass
		var/datum/species/spec = H.dna.species
		if(spec.ass_image)
			temp_img = icon(spec.ass_image)
		else
			temp_img = icon(ass.gender == FEMALE ? 'icons/ass/assfemale.png' : 'icons/ass/assmale.png')
	else if(isalienadult(ass)) //Xenos have their own asses, thanks to Pybro.
		temp_img = icon('icons/ass/assalien.png')
	else if(issilicon(ass))
		temp_img = icon('icons/ass/assmachine.png')
	else if(isdrone(ass)) //Drones are hot
		temp_img = icon('icons/ass/assdrone.png')

	var/obj/item/photo/copied_ass = new /obj/item/photo(loc)
	var/datum/picture/toEmbed = new(name = "[ass]'s Ass", desc = "You see [ass]'s ass on the photo.", image = temp_img)
	give_pixel_offset(copied_ass)
	toEmbed.psize_x = 128
	toEmbed.psize_y = 128
	copied_ass.set_picture(toEmbed, TRUE, TRUE)
	toner_cartridge.charges -= ASS_TONER_USE

/**
 * Inserts the item into the copier. Called in `attackby()` after a human mob clicked on the copier with a paper, photo, or document.
 *
 * Arugments:
 * * object - the object that got inserted.
 * * user - the mob that inserted the object.
 */
/obj/machinery/photocopier/proc/do_insertion(obj/item/object, mob/user)
	object.forceMove(src)
	to_chat(user, span_notice("You insert [object] into [src]."))
	flick("photocopier1", src)

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
/obj/machinery/photocopier/proc/remove_photocopy(obj/item/object, mob/user)
	if(!issilicon(user)) //surprised this check didn't exist before, putting stuff in AI's hand is bad
		object.forceMove(user.loc)
		user.put_in_hands(object)
	else
		object.forceMove(drop_location())
	to_chat(user, span_notice("You take [object] out of [src]. [busy ? "The [src] comes to a halt." : ""]"))

/obj/machinery/photocopier/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/photocopier/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/paper))
		if(copier_empty())
			if(!user.temporarilyRemoveItemFromInventory(O))
				return
			paper_copy = O
			do_insertion(O, user)
		else
			to_chat(user, span_warning("There is already something in [src]!"))

	else if(istype(O, /obj/item/photo))
		if(copier_empty())
			if(!user.temporarilyRemoveItemFromInventory(O))
				return
			photo_copy = O
			do_insertion(O, user)
		else
			to_chat(user, span_warning("There is already something in [src]!"))

	else if(istype(O, /obj/item/documents))
		if(copier_empty())
			if(!user.temporarilyRemoveItemFromInventory(O))
				return
			document_copy = O
			do_insertion(O, user)
		else
			to_chat(user, span_warning("There is already something in [src]!"))

	else if(istype(O, /obj/item/toner))
		if(toner_cartridge)
			to_chat(user, span_warning("[src] already has a toner cartridge inserted. Remove that one first."))
			return
		O.forceMove(src)
		toner_cartridge = O
		to_chat(user, span_notice("You insert [O] into [src]."))

	else if(istype(O, /obj/item/areaeditor/blueprints))
		to_chat(user, span_warning("The Blueprint is too large to put into the copier. You need to find something else to record the document."))
	else
		return ..()

/obj/machinery/photocopier/atom_break(damage_flag)
	. = ..()
	if(. && toner_cartridge.charges)
		new /obj/effect/decal/cleanable/oil(get_turf(src))
		toner_cartridge.charges = 0

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	check_ass() //Just to make sure that you can re-drag somebody onto it after they moved off.
	if(!istype(target) || target.anchored || target.buckled || !Adjacent(target) || !user.canUseTopic(src, BE_CLOSE) || target == ass || copier_blocked())
		return
	add_fingerprint(user)
	if(target == user)
		user.visible_message(span_notice("[user] starts climbing onto the photocopier!"), span_notice("You start climbing onto the photocopier..."))
	else
		user.visible_message(span_warning("[user] starts putting [target] onto the photocopier!"), span_notice("You start putting [target] onto the photocopier..."))

	if(do_after(user, 20, target = src))
		if(!target || QDELETED(target) || QDELETED(src) || !Adjacent(target)) //check if the photocopier/target still exists.
			return

		if(target == user)
			user.visible_message(span_notice("[user] climbs onto the photocopier!"), span_notice("You climb onto the photocopier."))
		else
			user.visible_message(span_warning("[user] puts [target] onto the photocopier!"), span_notice("You put [target] onto the photocopier."))

		target.forceMove(drop_location())
		ass = target

		if(photo_copy)
			photo_copy.forceMove(drop_location())
			visible_message(span_warning("[photo_copy] is shoved out of the way by [ass]!"))
			photo_copy = null

		else if(paper_copy)
			paper_copy.forceMove(drop_location())
			visible_message(span_warning("[paper_copy] is shoved out of the way by [ass]!"))
			paper_copy = null

		else if(document_copy)
			document_copy.forceMove(drop_location())
			visible_message(span_warning("[document_copy] is shoved out of the way by [ass]!"))
			document_copy = null

/obj/machinery/photocopier/Exited(atom/movable/gone, direction)
	check_ass() // There was potentially a person sitting on the copier, check if they're still there.
	return ..()

/**
 * Checks the living mob `ass` exists and its location is the same as the photocopier.
 *
 * Returns FALSE if `ass` doesn't exist or is not at the copier's location. Returns TRUE otherwise.
 */
/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!ass)
		return FALSE
	if(ass.loc != loc)
		ass = null
		return FALSE
	return TRUE

/**
 * Checks if the copier is deleted, or has something dense at its location. Called in `MouseDrop_T()`
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
 * Checks if there is an item inserted into the copier or a mob sitting on top of it.
 *
 * Return `FALSE` is the copier has something inside of it. Returns `TRUE` if it doesn't.
 */
/obj/machinery/photocopier/proc/copier_empty()
	if(paper_copy || photo_copy || document_copy || check_ass())
		return FALSE
	else
		return TRUE

/*
 * Toner cartridge
 */
/obj/item/toner
	name = "toner cartridge"
	desc = "A small, lightweight cartridge of NanoTrasen ValueBrand toner. Fits photocopiers and autopainters alike."
	icon = 'icons/obj/device.dmi'
	icon_state = "tonercartridge"
	grind_results = list(/datum/reagent/iodine = 40, /datum/reagent/iron = 10)
	var/charges = 5
	var/max_charges = 5

/obj/item/toner/examine(mob/user)
	. = ..()
	. += span_notice("The ink level gauge on the side reads [round(charges / max_charges * 100)]%")

/obj/item/toner/large
	name = "large toner cartridge"
	desc = "A hefty cartridge of NanoTrasen ValueBrand toner. Fits photocopiers and autopainters alike."
	grind_results = list(/datum/reagent/iodine = 90, /datum/reagent/iron = 10)
	charges = 25
	max_charges = 25

/obj/item/toner/extreme
	name = "extremely large toner cartridge"
	desc = "Why would ANYONE need THIS MUCH TONER?"
	charges = 200
	max_charges = 200

#undef PHOTO_GREYSCALE
#undef PHOTO_COLOR
#undef PAPER_TONER_USE
#undef PHOTO_TONER_USE
#undef DOCUMENT_TONER_USE
#undef ASS_TONER_USE
#undef MAX_COPIES_AT_ONCE
