
/obj/item/universal_scanner
	name = "universal scanner"
	desc = "A device used to check objects against Nanotrasen exports database, assign price tags, or ready an item for a custom vending machine."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "export scanner"
	worn_icon_state = "electronic"
	inhand_icon_state = "export_scanner"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	/// Which mode is the scanner currently on?
	var/scanning_mode = SCAN_EXPORTS
	/// A list of all available export scanner modes.
	var/list/scale_mode = list()

	/// The price of the item used by price tagger mode.
	var/new_custom_price = 1

	/// The account which is receiving the split profits in sales tagger mode.
	var/datum/bank_account/payments_acc = null
	/// The person who tagged this will receive the sale value multiplied by this number in sales tagger mode.
	var/cut_multiplier = 0.5
	/// Maximum value for cut_multiplier in sales tagger mode.
	var/cut_max = 0.5
	/// Minimum value for cut_multiplier in sales tagger mode.
	var/cut_min = 0.01

/obj/item/universal_scanner/Initialize(mapload)
	. = ..()
	scale_mode = sort_list(list(
		"export scanner" = image(icon = src.icon, icon_state = "export scanner"),
		"price tagger" = image(icon = src.icon, icon_state = "price tagger"),
))
	register_context()

/obj/item/universal_scanner/attack_self(mob/user, modifiers)
	. = ..()
	var/choice = show_radial_menu(user, src, scale_mode, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	if(icon_state == "[choice]")
		return FALSE
	switch(choice)
		if("export scanner")
			scanning_mode = SCAN_EXPORTS
		if("price tagger")
			scanning_mode = SCAN_PRICE_TAG
	icon_state = "[choice]"
	playsound(src, 'sound/machines/click.ogg', 40, TRUE)

/obj/item/universal_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isobj(interacting_with))
		return NONE
	if(scanning_mode == SCAN_EXPORTS)
		export_scan(interacting_with, user)
		return ITEM_INTERACT_SUCCESS
	if(scanning_mode == SCAN_PRICE_TAG)
		price_tag(interacting_with, user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/universal_scanner/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(scanning_mode == SCAN_PRICE_TAG)
		if(loc != user)
			to_chat(user, span_warning("You must be holding \the [src] to continue!"))
			return
		var/chosen_price = tgui_input_number(user, "Set price", "Price", new_custom_price)
		if(!chosen_price || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || loc != user)
			return
		new_custom_price = chosen_price
		to_chat(user, span_notice("[src] will now give things a [new_custom_price] [MONEY_SYMBOL] tag."))

/obj/item/universal_scanner/examine(mob/user)
	. = ..()
	if(scanning_mode == SCAN_PRICE_TAG)
		. += span_notice("The current custom price is set to [new_custom_price] [MONEY_SYMBOL]. <b>Right-click</b> to change.")

/obj/item/universal_scanner/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	switch(scanning_mode)
		if(SCAN_PRICE_TAG)
			context[SCREENTIP_CONTEXT_LMB] = "Price item"
			context[SCREENTIP_CONTEXT_RMB] = "Set price"
		if(SCAN_EXPORTS)
			context[SCREENTIP_CONTEXT_LMB] = "Scan for export value"
	return CONTEXTUAL_SCREENTIP_SET
/**
 * Scans an object, target, and provides its export value based on selling to the cargo shuttle, to mob/user.
 */
/obj/item/universal_scanner/proc/export_scan(obj/target, mob/user)
	var/datum/export_report/report = export_item_and_contents(target, dry_run = TRUE)
	var/price = 0
	for(var/exported_datum in report.total_amount)
		price += report.total_value[exported_datum]

	var/message = "Scanned [target]"
	var/warning = FALSE
	if(length(target.contents))
		message = "Scanned [target] and its contents"
		if(price)
			message += ", total value: <b>[price]</b> [MONEY_NAME]"
		else
			message += ", no export values"
			warning = TRUE
		if(!report.all_contents_scannable)
			message += " (Undeterminable value detected, final value may differ)"
		message += "."
	else
		if(!report.all_contents_scannable)
			message += ", unable to determine value."
			warning = TRUE
		else if(price)
			message += ", value: <b>[price]</b> [MONEY_NAME]."
		else
			message += ", no export value."
			warning = TRUE
	if(warning)
		to_chat(user, span_warning(message))
	else
		to_chat(user, span_notice(message))

	if(price)
		playsound(src, 'sound/machines/terminal/terminal_select.ogg', 50, vary = TRUE)

	if(istype(target, /obj/item/delivery))
		var/obj/item/delivery/parcel = target
		if(!parcel.sticker)
			return
		var/obj/item/barcode/our_code = parcel.sticker
		to_chat(user, span_notice("Export barcode detected! This parcel, upon export, will pay out to [our_code.payments_acc.account_holder], \
			with a [our_code.cut_multiplier * 100]% split to them (already reflected in above recorded value)."))

	if(istype(target, /obj/item/barcode))
		var/obj/item/barcode/our_code = target
		to_chat(user, span_notice("Export barcode detected! This barcode, if attached to a parcel, will pay out to [our_code.payments_acc.account_holder], \
			with a [our_code.cut_multiplier * 100]% split to them."))

	if(ishuman(user))
		var/mob/living/carbon/human/scan_human = user
		if(istype(target, /obj/item/bounty_cube))
			var/obj/item/bounty_cube/cube = target
			var/datum/bank_account/scanner_account = scan_human.get_bank_account()

			if(!istype(get_area(cube), /area/shuttle/supply))
				to_chat(user, span_warning("Shuttle placement not detected. Handling tip not registered."))

			else if(cube.bounty_handler_account)
				to_chat(user, span_warning("Bank account for handling tip already registered!"))

			else if(scanner_account)
				cube.AddComponent(/datum/component/pricetag, scanner_account, cube.handler_tip, FALSE)

				cube.bounty_handler_account = scanner_account
				cube.bounty_handler_account.bank_card_talk("Bank account for [price ? "<b>[price * cube.handler_tip]</b> [MONEY_NAME_SINGULAR] " : ""]handling tip successfully registered.")

				if(cube.bounty_holder_account != cube.bounty_handler_account) //No need to send a tracking update to the person scanning it
					cube.bounty_holder_account.bank_card_talk("<b>[cube]</b> was scanned in \the <b>[get_area(cube)]</b> by <b>[scan_human] ([scan_human.job])</b>.")

			else
				to_chat(user, span_warning("Bank account not detected. Handling tip not registered."))

/**
 * Scans an object, target, and sets its custom_price variable to new_custom_price, presenting it to the user.
 */
/obj/item/universal_scanner/proc/price_tag(obj/target, mob/user)
	if(isitem(target))
		var/obj/item/selected_target = target
		selected_target.custom_price = new_custom_price
		to_chat(user, span_notice("You set the price of [selected_target] to [new_custom_price] [MONEY_SYMBOL]."))

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/item/universal_scanner/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	return TRUE

/obj/item/barcode
	name = "barcode tag"
	desc = "Pass your ID over the tag. Press the barcode onto a wrapped item. Once it's sold on the cargo shuttle, you'll get a cut of the profit. These are the words of the TERMS AND CONDITIONS."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "barcode"
	w_class = WEIGHT_CLASS_TINY
	//All values inherited from the sales tagger it came from.
	///The bank account assigned to pay out to from the sales tagger.
	var/datum/bank_account/payments_acc = null
	///The percentage of profit to give to the payments_acc, from 0 to 1.
	var/cut_multiplier = 0.2

/obj/item/barcode/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(istype(interacting_with, /obj/item/card/id))
		var/obj/item/card/id/id_card = interacting_with
		if(!id_card?.registered_account)
			return
		payments_acc = id_card.registered_account
		to_chat(user, "[span_notice("You register [id_card] to the barcode.")]")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/barcode/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	//Basically the same as the above, but for the reverse interaction chain.
	if(istype(tool, /obj/item/card/id))
		var/obj/item/card/id/id_card = tool
		if(!id_card?.registered_account)
			return
		payments_acc = id_card.registered_account
		to_chat(user, "[span_notice("You register [id_card] to the barcode.")]")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/barcode/gold
	name = "golden barcode tag"
	icon_state = "barcode_gold"
	desc = "Pass your ID over the tag. Press the barcode onto a wrapped item. Experience profit like never before (once it's sold on the cargo shuttle). SO IT IS WRITTEN ON THE BACK."
	cut_multiplier = 0.5
