/**
 * x1, y1, x2, y2 - Represents the bounding box for the ID card's non-transparent portion of its various icon_states.
 * Used to crop the ID card's transparency away when chaching the icon for better use in tgui chat.
 */
#define ID_ICON_BORDERS 1, 9, 32, 24

/// Fallback time if none of the config entries are set for USE_LOW_LIVING_HOUR_INTERN
#define INTERN_THRESHOLD_FALLBACK_HOURS 15

/* Cards
 * Contains:
 * DATA CARD
 * ID CARD
 * FINGERPRINT CARD HOLDER
 * FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the IC data card reader
 */

/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	atom_size = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to swipe [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/*
 * ID CARDS
 */

/// "Retro" ID card that renders itself as the icon state with no overlays.
/obj/item/card/id
	name = "retro identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "card_grey"
	worn_icon_state = "card_retro"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF

	/// Cached icon that has been built for this card. Intended for use in chat.
	var/icon/cached_flat_icon

	/// How many magical mining Disney Dollars this card has for spending at the mining equipment vendors.
	var/mining_points = 0
	/// The name registered on the card (for example: Dr Bryan See)
	var/registered_name = null
	/// Linked bank account.
	var/datum/bank_account/registered_account
	/// Linked paystand.
	var/obj/machinery/paystand/my_store
	/// Registered owner's age.
	var/registered_age = 30

	/// The job name registered on the card (for example: Assistant).
	var/assignment

	/// Trim datum associated with the card. Controls which job icon is displayed on the card and which accesses do not require wildcards.
	var/datum/id_trim/trim

	/// Access levels held by this card.
	var/list/access = list()

	/// List of wildcard slot names as keys with lists of wildcard data as values.
	var/list/wildcard_slots = list()

	/// Boolean value. If TRUE, the [Intern] tag gets prepended to this ID card when the label is updated.
	var/is_intern = FALSE

/obj/item/card/id/Initialize(mapload)
	. = ..()

	// Applying the trim updates the label and icon, so don't do this twice.
	if(ispath(trim))
		SSid_access.apply_trim_to_card(src, trim)
	else
		update_label()
		update_icon()

	RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, .proc/update_in_wallet)

/obj/item/card/id/Destroy()
	if (registered_account)
		registered_account.bank_cards -= src
	if (my_store && my_store.my_card == src)
		my_store.my_card = null
	return ..()

/obj/item/card/id/get_id_examine_strings(mob/user)
	. = ..()
	. += list("[icon2html(get_cached_flat_icon(), user, extra_classes = "bigicon")]")

/obj/item/card/id/update_overlays()
	. = ..()

	cached_flat_icon = null

/// If no cached_flat_icon exists, this proc creates it and crops it. This proc then returns the cached_flat_icon. Intended only for use displaying ID card icons in chat.
/obj/item/card/id/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
		cached_flat_icon.Crop(ID_ICON_BORDERS)
	return cached_flat_icon

/obj/item/card/id/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(get_cached_flat_icon(), user)] [thats? "That's ":""][get_examine_name(user)]"

/**
 * Helper proc, checks whether the ID card can hold any given set of wildcards.
 *
 * Returns TRUE if the card can hold the wildcards, FALSE otherwise.
 * Arguments:
 * * wildcard_list - List of accesses to check.
 * * try_wildcard - If not null, will attempt to add wildcards for this wildcard specifically and will return FALSE if the card cannot hold all wildcards in this slot.
 */
/obj/item/card/id/proc/can_add_wildcards(list/wildcard_list, try_wildcard = null)
	if(!length(wildcard_list))
		return TRUE

	var/list/new_wildcard_limits = list()

	for(var/flag_name in wildcard_slots)
		if(try_wildcard && !(flag_name == try_wildcard))
			continue
		var/list/wildcard_info = wildcard_slots[flag_name]
		new_wildcard_limits[flag_name] = wildcard_info["limit"] - length(wildcard_info["usage"])

	if(!length(new_wildcard_limits))
		return FALSE

	var/wildcard_allocated
	for(var/wildcard in wildcard_list)
		var/wildcard_flag = SSid_access.get_access_flag(wildcard)
		wildcard_allocated = FALSE
		for(var/flag_name in new_wildcard_limits)
			var/limit_flags = SSid_access.wildcard_flags_by_wildcard[flag_name]
			if(!(wildcard_flag & limit_flags))
				continue
			// Negative limits mean infinite slots. Positive limits mean limited slots still available. 0 slots means no slots.
			if(new_wildcard_limits[flag_name] == 0)
				continue
			new_wildcard_limits[flag_name]--
			wildcard_allocated = TRUE
			break
		if(!wildcard_allocated)
			return FALSE

	return TRUE

/**
 * Attempts to add the given wildcards to the ID card.
 *
 * Arguments:
 * * wildcard_list - List of accesses to add.
 * * try_wildcard - If not null, will attempt to add all wildcards to this wildcard slot only.
 * * mode - The method to use when adding wildcards. See define for ERROR_ON_FAIL
 */
/obj/item/card/id/proc/add_wildcards(list/wildcard_list, try_wildcard = null, mode = ERROR_ON_FAIL)
	var/wildcard_allocated
	// Iterate through each wildcard in our list. Get its access flag. Then iterate over wildcard slots and try to fit it in.
	for(var/wildcard in wildcard_list)
		var/wildcard_flag = SSid_access.get_access_flag(wildcard)
		wildcard_allocated = FALSE
		for(var/flag_name in wildcard_slots)
			if(flag_name == WILDCARD_NAME_FORCED)
				continue

			if(try_wildcard && !(flag_name == try_wildcard))
				continue

			var/limit_flags = SSid_access.wildcard_flags_by_wildcard[flag_name]

			if(!(wildcard_flag & limit_flags))
				continue

			var/list/wildcard_info = wildcard_slots[flag_name]
			var/wildcard_limit = wildcard_info["limit"]
			var/list/wildcard_usage = wildcard_info["usage"]

			var/wildcard_count = wildcard_limit - length(wildcard_usage)

			// Negative limits mean infinite slots. Positive limits mean limited slots still available. 0 slots means no slots.
			if(wildcard_count == 0)
				continue

			wildcard_usage |= wildcard
			access |= wildcard
			wildcard_allocated = TRUE
			break
		// Fallback for if we couldn't allocate the wildcard for some reason.
		if(!wildcard_allocated)
			if(mode == ERROR_ON_FAIL)
				CRASH("Wildcard ([wildcard]) could not be added to [src].")

			if(mode == TRY_ADD_ALL)
				continue

			// If the card has no info for historic forced wildcards, create the list.
			if(!wildcard_slots[WILDCARD_NAME_FORCED])
				wildcard_slots[WILDCARD_NAME_FORCED] = list(limit = 0, usage = list())

			var/list/wildcard_info = wildcard_slots[WILDCARD_NAME_FORCED]
			var/list/wildcard_usage = wildcard_info["usage"]
			wildcard_usage |= wildcard
			access |= wildcard
			wildcard_info["limit"] = length(wildcard_usage)

/**
 * Removes wildcards from the ID card.
 *
 * Arguments:
 * * wildcard_list - List of accesses to remove.
 */
/obj/item/card/id/proc/remove_wildcards(list/wildcard_list)
	var/wildcard_removed
	// Iterate through each wildcard in our list. Get its access flag. Then iterate over wildcard slots and try to remove it.
	for(var/wildcard in wildcard_list)
		wildcard_removed = FALSE
		for(var/flag_name in wildcard_slots)
			if(flag_name == WILDCARD_NAME_FORCED)
				continue

			var/list/wildcard_info = wildcard_slots[flag_name]
			var/wildcard_usage = wildcard_info["usage"]

			if(!(wildcard in wildcard_usage))
				continue

			wildcard_usage -= wildcard
			access -= wildcard
			wildcard_removed = TRUE
			break
		// Fallback to see if this was a force-added wildcard.
		if(!wildcard_removed)
			// If the card has no info for historic forced wildcards, that's an error state.
			if(!wildcard_slots[WILDCARD_NAME_FORCED])
				stack_trace("Wildcard ([wildcard]) could not be removed from [src]. This card has no forced wildcard data and the wildcard is not in this card's wildcard lists.")

			var/list/wildcard_info = wildcard_slots[WILDCARD_NAME_FORCED]
			var/wildcard_usage = wildcard_info["usage"]

			if(!(wildcard in wildcard_usage))
				stack_trace("Wildcard ([wildcard]) could not be removed from [src]. This access is not a wildcard on this card.")

			wildcard_usage -= wildcard
			access -= wildcard
			wildcard_info["limit"] = length(wildcard_usage)

			if(!wildcard_info["limit"])
				wildcard_slots -= WILDCARD_NAME_FORCED

/**
 * Attempts to add the given accesses to the ID card as non-wildcards.
 *
 * Depending on the mode, may add accesses as wildcards or error if it can't add them as non-wildcards.
 * Arguments:
 * * add_accesses - List of accesses to check.
 * * try_wildcard - If not null, will attempt to add all accesses that require wildcard slots to this wildcard slot only.
 * * mode - The method to use when adding accesses. See define for ERROR_ON_FAIL
 */
/obj/item/card/id/proc/add_access(list/add_accesses, try_wildcard = null, mode = ERROR_ON_FAIL)
	var/list/wildcard_access = list()
	var/list/normal_access = list()

	build_access_lists(add_accesses, normal_access, wildcard_access)

	// Check if we can add the wildcards.
	if(mode == ERROR_ON_FAIL)
		if(!can_add_wildcards(wildcard_access, try_wildcard))
			CRASH("Cannot add wildcards from \[[add_accesses.Join(",")]\] to [src]")

	// All clear to add the accesses.
	access |= normal_access
	if(mode != TRY_ADD_ALL_NO_WILDCARD)
		add_wildcards(wildcard_access, try_wildcard, mode = mode)

	return TRUE

/**
 * Removes the given accesses from the ID Card.
 *
 * Will remove the wildcards if the accesses given are on the card as wildcard accesses.
 * Arguments:
 * * rem_accesses - List of accesses to remove.
 */
/obj/item/card/id/proc/remove_access(list/rem_accesses)
	var/list/wildcard_access = list()
	var/list/normal_access = list()

	build_access_lists(rem_accesses, normal_access, wildcard_access)

	access -= normal_access
	remove_wildcards(wildcard_access)

/**
 * Attempts to set the card's accesses to the given accesses, clearing all accesses not in the given list.
 *
 * Depending on the mode, may add accesses as wildcards or error if it can't add them as non-wildcards.
 * Arguments:
 * * new_access_list - List of all accesses that this card should hold exclusively.
 * * mode - The method to use when setting accesses. See define for ERROR_ON_FAIL
 */
/obj/item/card/id/proc/set_access(list/new_access_list, mode = ERROR_ON_FAIL)
	var/list/wildcard_access = list()
	var/list/normal_access = list()

	build_access_lists(new_access_list, normal_access, wildcard_access)

	// Check if we can add the wildcards.
	if(mode == ERROR_ON_FAIL)
		if(!can_add_wildcards(wildcard_access))
			CRASH("Cannot add wildcards from \[[new_access_list.Join(",")]\] to [src]")

	clear_access()

	access = normal_access.Copy()

	if(mode != TRY_ADD_ALL_NO_WILDCARD)
		add_wildcards(wildcard_access, mode = mode)

	return TRUE

/// Clears all accesses from the ID card - both wildcard and normal.
/obj/item/card/id/proc/clear_access()
	// Go through the wildcards and reset them.
	for(var/flag_name in wildcard_slots)
		var/list/wildcard_info = wildcard_slots[flag_name]
		var/list/wildcard_usage = wildcard_info["usage"]
		wildcard_usage.Cut()

	// Hard reset access
	access.Cut()

/// Clears the economy account from the ID card.
/obj/item/card/id/proc/clear_account()
	registered_account = null


/**
 * Helper proc. Creates access lists for the access procs.
 *
 * Takes the accesses list and compares it with the trim. Any basic accesses that match the trim are
 * added to basic_access_list and the rest are added to wildcard_access_list.

 * This proc directly modifies the lists passed in as args. It expects these lists to be instantiated.
 * There is no return value.
 * Arguments:
 * * accesses - List of accesses you want to stort into basic_access_list and wildcard_access_list. Should not be null.
 * * basic_access_list - Mandatory argument. The proc modifies the list passed in this argument and adds accesses the trim supports to it.
 * * wildcard_access_list - Mandatory argument. The proc modifies the list passed in this argument and adds accesses the trim does not support to it.
 */
/obj/item/card/id/proc/build_access_lists(list/accesses, list/basic_access_list, list/wildcard_access_list)
	if(!length(accesses) || isnull(basic_access_list) || isnull(wildcard_access_list))
		CRASH("Invalid parameters passed to build_access_lists")

	var/list/trim_accesses = trim?.access

	// Populate the lists.
	for(var/new_access in accesses)
		if(new_access in trim_accesses)
			basic_access_list |= new_access
			continue

		wildcard_access_list |= new_access

/obj/item/card/id/attack_self(mob/user)
	if(Adjacent(user))
		var/minor
		if(registered_name && registered_age && registered_age < AGE_MINOR)
			minor = " <b>(MINOR)</b>"
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [src.name][minor]."), span_notice("You show \the [src.name][minor]."))
	add_fingerprint(user)

/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, assignment), NAMEOF(src, registered_name), NAMEOF(src, registered_age))
				update_label()
				update_icon()
			if(NAMEOF(src, trim))
				if(ispath(trim))
					SSid_access.apply_trim_to_card(src, trim)

/obj/item/card/id/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rupee))
		to_chat(user, span_warning("Your ID smartly rejects the strange shard of glass. Who knew, apparently it's not ACTUALLY valuable!"))
		return
	else if(iscash(W))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/storage/bag/money))
		var/obj/item/storage/bag/money/money_bag = W
		var/list/money_contained = money_bag.contents
		var/money_added = mass_insert_money(money_contained, user)
		if (money_added)
			to_chat(user, span_notice("You stuff the contents into the card! They disappear in a puff of bluespace smoke, adding [money_added] worth of credits to the linked account."))
		return
	else
		return ..()

/**
 * Insert credits or coins into the ID card and add their value to the associated bank account.
 *
 * Arguments:
 * money - The item to attempt to convert to credits and insert into the card.
 * user - The user inserting the item.
 * physical_currency - Boolean, whether this is a physical currency such as a coin and not a holochip.
 */
/obj/item/card/id/proc/insert_money(obj/item/money, mob/user)
	var/physical_currency
	if(istype(money, /obj/item/stack/spacecash) || istype(money, /obj/item/coin))
		physical_currency = TRUE

	if(!registered_account)
		to_chat(user, span_warning("[src] doesn't have a linked account to deposit [money] into!"))
		return
	var/cash_money = money.get_item_credit_value()
	if(!cash_money)
		to_chat(user, span_warning("[money] doesn't seem to be worth anything!"))
		return
	registered_account.adjust_money(cash_money)
	SSblackbox.record_feedback("amount", "credits_inserted", cash_money)
	log_econ("[cash_money] credits were inserted into [src] owned by [src.registered_name]")
	if(physical_currency)
		to_chat(user, span_notice("You stuff [money] into [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the linked account."))
	else
		to_chat(user, span_notice("You insert [money] into [src], adding [cash_money] credits to the linked account."))

	to_chat(user, span_notice("The linked account now reports a balance of [registered_account.account_balance] cr."))
	qdel(money)

/**
 * Insert multiple money or money-equivalent items at once.
 *
 * Arguments:
 * money - List of items to attempt to convert to credits and insert into the card.
 * user - The user inserting the items.
 */
/obj/item/card/id/proc/mass_insert_money(list/money, mob/user)
	if(!registered_account)
		to_chat(user, span_warning("[src] doesn't have a linked account to deposit into!"))
		return FALSE

	if (!money || !money.len)
		return FALSE

	var/total = 0

	for (var/obj/item/physical_money in money)
		total += physical_money.get_item_credit_value()
		CHECK_TICK

	registered_account.adjust_money(total)
	SSblackbox.record_feedback("amount", "credits_inserted", total)
	log_econ("[total] credits were inserted into [src] owned by [src.registered_name]")
	QDEL_LIST(money)

	return total

/// Helper proc. Can the user alt-click the ID?
/obj/item/card/id/proc/alt_click_can_use_id(mob/living/user)
	if(!isliving(user))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	return TRUE

/// Attempts to set a new bank account on the ID card.
/obj/item/card/id/proc/set_new_account(mob/living/user)
	. = FALSE
	var/datum/bank_account/old_account = registered_account

	var/new_bank_id = input(user, "Enter your account ID number.", "Account Reclamation", 111111) as num | null

	if (isnull(new_bank_id))
		return

	if(!alt_click_can_use_id(user))
		return
	if(!new_bank_id || new_bank_id < 111111 || new_bank_id > 999999)
		to_chat(user, span_warning("The account ID number needs to be between 111111 and 999999."))
		return
	if (registered_account && registered_account.account_id == new_bank_id)
		to_chat(user, span_warning("The account ID was already assigned to this card."))
		return

	var/datum/bank_account/B = SSeconomy.bank_accounts_by_id["[new_bank_id]"]
	if(B)
		if (old_account)
			old_account.bank_cards -= src

		B.bank_cards += src
		registered_account = B
		to_chat(user, span_notice("The provided account has been linked to this ID card."))

		return TRUE

	to_chat(user, span_warning("The account ID number provided is invalid."))
	return

/obj/item/card/id/AltClick(mob/living/user)
	if(!alt_click_can_use_id(user))
		return

	if(!registered_account)
		set_new_account(user)
		return

	if (registered_account.being_dumped)
		registered_account.bank_card_talk(span_warning("内部服务器错误"), TRUE)
		return

	var/amount_to_remove = FLOOR(input(user, "How much do you want to withdraw? Current Balance: [registered_account.account_balance]", "Withdraw Funds", 5) as num|null, 1)

	if(!amount_to_remove || amount_to_remove < 0)
		return
	if(!alt_click_can_use_id(user))
		return
	if(registered_account.adjust_money(-amount_to_remove))
		var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
		user.put_in_hands(holochip)
		to_chat(user, span_notice("You withdraw [amount_to_remove] credits into a holochip."))
		SSblackbox.record_feedback("amount", "credits_removed", amount_to_remove)
		log_econ("[amount_to_remove] credits were removed from [src] owned by [src.registered_name]")
		return
	else
		var/difference = amount_to_remove - registered_account.account_balance
		registered_account.bank_card_talk(span_warning("ERROR: The linked account requires [difference] more credit\s to perform that withdrawal."), TRUE)

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(registered_account)
		. += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
	. += span_notice("<i>There's more information below, you can look again to take a closer look...</i>")

/obj/item/card/id/examine_more(mob/user)
	var/list/msg = list(span_notice("<i>You examine [src] closer, and note the following...</i>"))

	if(registered_age)
		msg += "The card indicates that the holder is [registered_age] years old. [(registered_age < AGE_MINOR) ? "There's a holographic stripe that reads <b>[span_danger("'MINOR: DO NOT SERVE ALCOHOL OR TOBACCO'")]</b> along the bottom of the card." : ""]"
	if(mining_points)
		msg += "There's [mining_points] mining equipment redemption point\s loaded onto this card."
	if(registered_account)
		msg += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
		if(registered_account.account_job)
			var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
			if(D)
				msg += "The [D.account_holder] reports a balance of [D.account_balance] cr."
		msg += span_info("Alt-Click the ID to pull money from the linked account in the form of holochips.")
		msg += span_info("You can insert credits into the linked account by pressing holochips, cash, or coins against the ID.")
		if(registered_account.civilian_bounty)
			msg += "<span class='info'><b>There is an active civilian bounty.</b>"
			msg += span_info("<i>[registered_account.bounty_text()]</i>")
			msg += span_info("Quantity: [registered_account.bounty_num()]")
			msg += span_info("Reward: [registered_account.bounty_value()]")
		if(registered_account.account_holder == user.real_name)
			msg += span_boldnotice("If you lose this ID card, you can reclaim your account by Alt-Clicking a blank ID card while holding it and entering your account ID number.")
	else
		msg += span_info("There is no registered account linked to this card. Alt-Click to add one.")

	return msg

/obj/item/card/id/GetAccess()
	return access.Copy()

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/RemoveID()
	return src

/// Called on COMSIG_ATOM_UPDATED_ICON. Updates the visuals of the wallet this card is in.
/obj/item/card/id/proc/update_in_wallet()
	SIGNAL_HANDLER

	if(istype(loc, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/powergaming = loc
		if(powergaming.front_id == src)
			powergaming.update_label()
			powergaming.update_appearance()

/// Updates the name based on the card's vars and state.
/obj/item/card/id/proc/update_label()
	var/name_string = registered_name ? "[registered_name]'s ID Card" : initial(name)
	var/assignment_string

	if(is_intern)
		if(assignment)
			assignment_string = (assignment in SSjob.head_of_staff_jobs) ? " ([assignment]-in-Training)" : " (Intern [assignment])"
		else
			assignment_string = " (Intern)"
	else
		assignment_string = " ([assignment])"

	name = "[name_string][assignment_string]"

/// Returns the trim assignment name.
/obj/item/card/id/proc/get_trim_assignment()
	return trim?.assignment || assignment

/obj/item/card/id/away
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	trim = /datum/id_trim/away
	icon_state = "retro"
	registered_age = null

/obj/item/card/id/away/hotel
	name = "Staff ID"
	desc = "A staff ID used to access the hotel's doors."
	trim = /datum/id_trim/away/hotel

/obj/item/card/id/away/hotel/security
	name = "Officer ID"
	trim = /datum/id_trim/away/hotel/security

/obj/item/card/id/away/old
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."

/obj/item/card/id/away/old/sec
	name = "Charlie Station Security Officer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Security Officer\"."
	trim = /datum/id_trim/away/old/sec

/obj/item/card/id/away/old/sci
	name = "Charlie Station Scientist's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Scientist\"."
	trim = /datum/id_trim/away/old/sci

/obj/item/card/id/away/old/eng
	name = "Charlie Station Engineer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Station Engineer\"."
	trim = /datum/id_trim/away/old/eng

/obj/item/card/id/away/old/apc
	name = "APC Access ID"
	desc = "A special ID card that allows access to APC terminals."
	trim = /datum/id_trim/away/old/apc

/obj/item/card/id/away/deep_storage //deepstorage.dmm space ruin
	name = "bunker access ID"

/obj/item/card/id/departmental_budget
	name = "departmental card (ERROR)"
	desc = "Provides access to the departmental budget."
	icon_state = "budgetcard"
	var/department_ID = ACCOUNT_CIV
	var/department_name = ACCOUNT_CIV_NAME
	registered_age = null

/obj/item/card/id/departmental_budget/Initialize(mapload)
	. = ..()
	var/datum/bank_account/B = SSeconomy.get_dep_account(department_ID)
	if(B)
		registered_account = B
		if(!B.bank_cards.Find(src))
			B.bank_cards += src
		name = "departmental card ([department_name])"
		desc = "Provides access to the [department_name]."
	SSeconomy.dep_cards += src

/obj/item/card/id/departmental_budget/Destroy()
	SSeconomy.dep_cards -= src
	return ..()

/obj/item/card/id/departmental_budget/update_label()
	return

/obj/item/card/id/departmental_budget/car
	department_ID = ACCOUNT_CAR
	department_name = ACCOUNT_CAR_NAME
	icon_state = "car_budget" //saving up for a new tesla

/obj/item/card/id/departmental_budget/AltClick(mob/living/user)
	registered_account.bank_card_talk(span_warning("Withdrawing is not compatible with this card design."), TRUE) //prevents the vault bank machine being useless and putting money from the budget to your card to go over personal crates

/obj/item/card/id/advanced
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station. Has an integrated digital display and advanced microchips."
	icon_state = "card_grey"
	worn_icon_state = "card_grey"

	wildcard_slots = WILDCARD_LIMIT_GREY

	/// An overlay icon state for when the card is assigned to a name. Usually manifests itself as a little scribble to the right of the job icon.
	var/assigned_icon_state = "assigned"

	/// If this is set, will manually override the icon file for the trim. Intended for admins to VV edit and chameleon ID cards.
	var/trim_icon_override
	/// If this is set, will manually override the icon state for the trim. Intended for admins to VV edit and chameleon ID cards.
	var/trim_state_override
	/// If this is set, will manually override the trim's assignmment for SecHUDs. Intended for admins to VV edit and chameleon ID cards.
	var/trim_assignment_override

/obj/item/card/id/advanced/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

/obj/item/card/id/advanced/Destroy()
	UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	return ..()

/obj/item/card/id/advanced/proc/update_intern_status(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!user?.client)
		return
	if(!CONFIG_GET(flag/use_exp_tracking))
		return
	if(!CONFIG_GET(flag/use_low_living_hour_intern))
		return
	if(!SSdbcore.Connect())
		return

	var/intern_threshold = (CONFIG_GET(number/use_low_living_hour_intern_hours) * 60) || (CONFIG_GET(number/use_exp_restrictions_heads_hours) * 60) || INTERN_THRESHOLD_FALLBACK_HOURS * 60
	var/playtime = user.client.get_exp_living(pure_numeric = TRUE)

	if((intern_threshold >= playtime) && (user.mind?.assigned_role.title in SSjob.station_jobs))
		is_intern = TRUE
		update_label()
		return

	if(!is_intern)
		return

	is_intern = FALSE
	update_label()

/obj/item/card/id/advanced/proc/remove_intern_status(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!is_intern)
		return

	is_intern = FALSE
	update_label()

/obj/item/card/id/advanced/proc/on_holding_card_slot_moved(obj/item/computer_hardware/card_slot/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(istype(old_loc, /obj/item/modular_computer/tablet))
		UnregisterSignal(old_loc, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	if(istype(source.loc, /obj/item/modular_computer/tablet))
		RegisterSignal(source.loc, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
		RegisterSignal(source.loc, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

/obj/item/card/id/advanced/Moved(atom/OldLoc, Dir)
	. = ..()

	if(istype(OldLoc, /obj/item/pda) || istype(OldLoc, /obj/item/storage/wallet))
		UnregisterSignal(OldLoc, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	if(istype(OldLoc, /obj/item/computer_hardware/card_slot))
		var/obj/item/computer_hardware/card_slot/slot = OldLoc

		UnregisterSignal(OldLoc, COMSIG_MOVABLE_MOVED)

		if(istype(slot.holder, /obj/item/modular_computer/tablet))
			var/obj/item/modular_computer/tablet/slot_holder = slot.holder
			UnregisterSignal(slot_holder, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	if(istype(loc, /obj/item/pda) || istype(loc, /obj/item/storage/wallet))
		RegisterSignal(loc, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
		RegisterSignal(loc, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

	if(istype(loc, /obj/item/computer_hardware/card_slot))
		var/obj/item/computer_hardware/card_slot/slot = loc

		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, .proc/on_holding_card_slot_moved)

		if(istype(slot.holder, /obj/item/modular_computer/tablet))
			var/obj/item/modular_computer/tablet/slot_holder = slot.holder
			RegisterSignal(slot_holder, COMSIG_ITEM_EQUIPPED, .proc/update_intern_status)
			RegisterSignal(slot_holder, COMSIG_ITEM_DROPPED, .proc/remove_intern_status)

/obj/item/card/id/advanced/update_overlays()
	. = ..()

	if(registered_name && registered_name != "Captain")
		. += mutable_appearance(icon, assigned_icon_state)

	var/trim_icon_file = trim_icon_override ? trim_icon_override : trim?.trim_icon
	var/trim_icon_state = trim_state_override ? trim_state_override : trim?.trim_state

	if(!trim_icon_file || !trim_icon_state)
		return

	. += mutable_appearance(trim_icon_file, trim_icon_state)

/obj/item/card/id/advanced/get_trim_assignment()
	if(trim_assignment_override)
		return trim_assignment_override
	else if(ispath(trim))
		var/datum/id_trim/trim_singleton = SSid_access.trim_singletons_by_path[trim]
		return trim_singleton.assignment

	return ..()

/obj/item/card/id/advanced/silver
	name = "silver identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "card_silver"
	worn_icon_state = "card_silver"
	inhand_icon_state = "silver_id"
	wildcard_slots = WILDCARD_LIMIT_SILVER

/datum/id_trim/maint_reaper
	access = list(ACCESS_MAINT_TUNNELS)
	trim_state = "trim_janitor"
	assignment = "Reaper"

/obj/item/card/id/advanced/silver/reaper
	name = "Thirteen's ID Card (Reaper)"
	trim = /datum/id_trim/maint_reaper
	registered_name = "Thirteen"

/obj/item/card/id/advanced/gold
	name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "card_gold"
	worn_icon_state = "card_gold"
	inhand_icon_state = "gold_id"
	wildcard_slots = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/gold/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	registered_name = "Captain"
	trim = /datum/id_trim/job/captain
	registered_age = null

/obj/item/card/id/advanced/gold/captains_spare/update_label() //so it doesn't change to Captain's ID card (Captain) on a sneeze
	if(registered_name == "Captain")
		name = "[initial(name)][(!assignment || assignment == "Captain") ? "" : " ([assignment])"]"
		update_appearance(UPDATE_ICON)
	else
		..()

/obj/item/card/id/advanced/centcom
	name = "\improper CentCom ID"
	desc = "An ID straight from Central Command."
	icon_state = "card_centcom"
	worn_icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	registered_name = "Central Command"
	registered_age = null
	trim = /datum/id_trim/centcom
	wildcard_slots = WILDCARD_LIMIT_CENTCOM

/obj/item/card/id/advanced/centcom/ert
	name = "\improper CentCom ID"
	desc = "An ERT ID card."
	registered_age = null
	registered_name = "Emergency Response Intern"
	trim = /datum/id_trim/centcom/ert

/obj/item/card/id/advanced/centcom/ert
	registered_name = "Emergency Response Team Commander"
	trim = /datum/id_trim/centcom/ert/commander

/obj/item/card/id/advanced/centcom/ert/security
	registered_name = "Security Response Officer"
	trim = /datum/id_trim/centcom/ert/security

/obj/item/card/id/advanced/centcom/ert/engineer
	registered_name = "Engineering Response Officer"
	trim = /datum/id_trim/centcom/ert/engineer

/obj/item/card/id/advanced/centcom/ert/medical
	registered_name = "Medical Response Officer"
	trim = /datum/id_trim/centcom/ert/medical

/obj/item/card/id/advanced/centcom/ert/chaplain
	registered_name = "Religious Response Officer"
	trim = /datum/id_trim/centcom/ert/chaplain

/obj/item/card/id/advanced/centcom/ert/janitor
	registered_name = "Janitorial Response Officer"
	trim = /datum/id_trim/centcom/ert/janitor

/obj/item/card/id/advanced/centcom/ert/clown
	registered_name = "Entertainment Response Officer"
	trim = /datum/id_trim/centcom/ert/clown

/obj/item/card/id/advanced/black
	name = "black identification card"
	desc = "This card is telling you one thing and one thing alone. The person holding this card is an utter badass."
	icon_state = "card_black"
	worn_icon_state = "card_black"
	assigned_icon_state = "assigned_syndicate"
	wildcard_slots = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/black/deathsquad
	name = "\improper Death Squad ID"
	desc = "A Death Squad ID card."
	registered_name = "Death Commando"
	trim = /datum/id_trim/centcom/deathsquad
	wildcard_slots = WILDCARD_LIMIT_DEATHSQUAD

/obj/item/card/id/advanced/black/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	registered_age = null
	trim = /datum/id_trim/syndicom
	wildcard_slots = WILDCARD_LIMIT_SYNDICATE

/obj/item/card/id/advanced/black/syndicate_command/crew_id
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	trim = /datum/id_trim/syndicom/crew

/obj/item/card/id/advanced/black/syndicate_command/captain_id
	name = "syndicate captain ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	trim = /datum/id_trim/syndicom/captain

/obj/item/card/id/advanced/debug
	name = "\improper Debug ID"
	desc = "A debug ID card. Has ALL the all access, you really shouldn't have this."
	icon_state = "card_centcom"
	worn_icon_state = "card_centcom"
	assigned_icon_state = "assigned_centcom"
	trim = /datum/id_trim/admin
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/obj/item/card/id/advanced/debug/Initialize(mapload)
	. = ..()
	registered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)

/obj/item/card/id/advanced/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "card_prisoner"
	worn_icon_state = "card_prisoner"
	inhand_icon_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = "Scum"
	registered_age = null
	trim = /datum/id_trim/job/prisoner

	wildcard_slots = WILDCARD_LIMIT_PRISONER

	/// Number of gulag points required to earn freedom.
	var/goal = 0
	/// Number of gulag points earned.
	var/points = 0
	/// If the card has a timer set on it for temporary stay.
	var/timed = FALSE
	/// Time to assign to the card when they pass through the security gate.
	var/time_to_assign
	/// Time left on a card till they can leave.
	var/time_left = 0

/obj/item/card/id/advanced/prisoner/attackby(obj/item/card/id/C, mob/user)
	..()
	var/list/id_access = C.GetAccess()
	if(ACCESS_BRIG in id_access)
		if(timed)
			timed = FALSE
			time_to_assign = initial(time_to_assign)
			registered_name = initial(registered_name)
			STOP_PROCESSING(SSobj, src)
			to_chat(user, "Restating prisoner ID to default parameters.")
			return
		time_to_assign = input(user,"Set sentence time in seconds.","Set sentence time in seconds.",0) as num|null
		if(isnull(time_to_assign) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
			return
		to_chat(user, "You set the sentence time to [time_to_assign] seconds.")
		timed = TRUE

/obj/item/card/id/advanced/prisoner/proc/start_timer()
	say("Sentence started, welcome to the corporate rehabilitation center!")
	START_PROCESSING(SSobj, src)

/obj/item/card/id/advanced/prisoner/examine(mob/user)
	. = ..()
	if(timed)
		if(time_left <= 0)
			. += span_notice("The digital timer on the card has zero seconds remaining. You leave a changed man, but a free man nonetheless.")
		else
			. += span_notice("The digital timer on the card has [time_left] seconds remaining. Don't do the crime if you can't do the time.")

/obj/item/card/id/advanced/prisoner/process(delta_time)
	if(!timed)
		return
	time_left -= delta_time
	if(time_left <= 0)
		say("Sentence time has been served. Thank you for your cooperation in our corporate rehabilitation program!")
		STOP_PROCESSING(SSobj, src)

/obj/item/card/id/advanced/prisoner/attack_self(mob/user)
	to_chat(usr, span_notice("You have accumulated [points] out of the [goal] points you need for freedom."))

/obj/item/card/id/advanced/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"
	trim = /datum/id_trim/job/prisoner/one

/obj/item/card/id/advanced/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"
	trim = /datum/id_trim/job/prisoner/two

/obj/item/card/id/advanced/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"
	trim = /datum/id_trim/job/prisoner/three

/obj/item/card/id/advanced/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"
	trim = /datum/id_trim/job/prisoner/four

/obj/item/card/id/advanced/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"
	trim = /datum/id_trim/job/prisoner/five

/obj/item/card/id/advanced/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"
	trim = /datum/id_trim/job/prisoner/six

/obj/item/card/id/advanced/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"
	trim = /datum/id_trim/job/prisoner/seven

/obj/item/card/id/advanced/mining
	name = "mining ID"
	trim = /datum/id_trim/job/shaft_miner/spare

/obj/item/card/id/advanced/highlander
	name = "highlander ID"
	registered_name = "Highlander"
	desc = "There can be only one!"
	icon_state = "card_black"
	worn_icon_state = "card_black"
	assigned_icon_state = "assigned_syndicate"
	trim = /datum/id_trim/highlander
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/obj/item/card/id/advanced/chameleon
	name = "agent card"
	desc = "A highly advanced chameleon ID card. Touch this card on another ID card or player to choose which accesses to copy. Has special magnetic properties which force it to the front of wallets."
	trim = /datum/id_trim/chameleon
	wildcard_slots = WILDCARD_LIMIT_CHAMELEON

	/// Have we set a custom name and job assignment, or will we use what we're given when we chameleon change?
	var/forged = FALSE
	/// Anti-metagaming protections. If TRUE, anyone can change the ID card's details. If FALSE, only syndicate agents can.
	var/anyone = FALSE
	/// Weak ref to the ID card we're currently attempting to steal access from.
	var/datum/weakref/theft_target

/obj/item/card/id/advanced/chameleon/Initialize(mapload)
	. = ..()

	var/datum/action/item_action/chameleon/change/id/chameleon_card_action = new(src)
	chameleon_card_action.chameleon_type = /obj/item/card/id/advanced
	chameleon_card_action.chameleon_name = "ID Card"
	chameleon_card_action.initialize_disguises()

/obj/item/card/id/advanced/chameleon/Destroy()
	theft_target = null
	. = ..()

/obj/item/card/id/advanced/chameleon/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/item/card/id))
		theft_target = WEAKREF(target)
		ui_interact(user)
		return

	return ..()

/obj/item/card/id/advanced/chameleon/pre_attack_secondary(atom/target, mob/living/user, params)
	// If we're attacking a human, we want it to be covert. We're not ATTACKING them, we're trying
	// to sneakily steal their accesses by swiping our agent ID card near them. As a result, we
	// return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN to cancel any part of the following the attack chain.
	if(istype(target, /mob/living/carbon/human))
		to_chat(user, "<span class='notice'>You covertly start to scan [target] with \the [src], hoping to pick up a wireless ID card signal...</span>")

		if(!do_mob(user, target, 2 SECONDS))
			to_chat(user, "<span class='notice'>The scan was interrupted.</span>")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/mob/living/carbon/human/human_target = target

		var/list/target_id_cards = human_target.get_all_contents_type(/obj/item/card/id)

		if(!length(target_id_cards))
			to_chat(user, "<span class='notice'>The scan failed to locate any ID cards.</span>")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/selected_id = pick(target_id_cards)
		to_chat(user, "<span class='notice'>You successfully sync your [src] with \the [selected_id].</span>")
		theft_target = WEAKREF(selected_id)
		ui_interact(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(istype(target, /obj/item))
		var/obj/item/target_item = target

		to_chat(user, "<span class='notice'>You covertly start to scan [target] with your [src], hoping to pick up a wireless ID card signal...</span>")

		var/list/target_id_cards = target_item.get_all_contents_type(/obj/item/card/id)

		var/target_item_id = target_item.GetID()

		if(target_item_id)
			target_id_cards |= target_item_id

		if(!length(target_id_cards))
			to_chat(user, "<span class='notice'>The scan failed to locate any ID cards.</span>")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/selected_id = pick(target_id_cards)
		to_chat(user, "<span class='notice'>You successfully sync your [src] with \the [selected_id].</span>")
		theft_target = WEAKREF(selected_id)
		ui_interact(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/item/card/id/advanced/chameleon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChameleonCard", name)
		ui.open()

/obj/item/card/id/advanced/chameleon/ui_static_data(mob/user)
	var/list/data = list()
	data["wildcardFlags"] = SSid_access.wildcard_flags_by_wildcard
	data["accessFlagNames"] = SSid_access.access_flag_string_by_flag
	data["accessFlags"] = SSid_access.flags_by_access
	return data

/obj/item/card/id/advanced/chameleon/ui_host(mob/user)
	// Hook our UI to the theft target ID card for UI state checks.
	return theft_target?.resolve()

/obj/item/card/id/advanced/chameleon/ui_state(mob/user)
	return GLOB.always_state

/obj/item/card/id/advanced/chameleon/ui_status(mob/user)
	var/target = theft_target?.resolve()

	if(!target)
		return UI_CLOSE

	var/status = min(
		ui_status_user_strictly_adjacent(user, target),
		ui_status_user_is_advanced_tool_user(user),
		max(
			ui_status_user_is_conscious_and_lying_down(user),
			ui_status_user_is_abled(user, target),
		),
	)

	if(status < UI_INTERACTIVE)
		return UI_CLOSE

	return status

/obj/item/card/id/advanced/chameleon/ui_data(mob/user)
	var/list/data = list()

	data["showBasic"] = FALSE

	var/list/regions = list()

	var/obj/item/card/id/target_card = theft_target.resolve()
	if(target_card)
		var/list/tgui_region_data = SSid_access.all_region_access_tgui
		for(var/region in SSid_access.station_regions)
			regions += tgui_region_data[region]

	data["accesses"] = regions
	data["ourAccess"] = access
	data["ourTrimAccess"] = trim ? trim.access : list()
	data["theftAccess"] = target_card.access.Copy()
	data["wildcardSlots"] = wildcard_slots
	data["selectedList"] = access
	data["trimAccess"] = list()

	return data

/obj/item/card/id/advanced/chameleon/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/obj/item/card/id/target_card = theft_target?.resolve()
	if(QDELETED(target_card))
		to_chat(usr, span_notice("The ID card you were attempting to scan is no longer in range."))
		target_card = null
		return TRUE

	// Wireless ID theft!
	var/turf/our_turf = get_turf(src)
	var/turf/target_turf = get_turf(target_card)
	if(!our_turf.Adjacent(target_turf))
		to_chat(usr, span_notice("The ID card you were attempting to scan is no longer in range."))
		target_card = null
		return TRUE

	switch(action)
		if("mod_access")
			var/access_type = params["access_target"]
			var/try_wildcard = params["access_wildcard"]
			if(access_type in access)
				remove_access(list(access_type))
				LOG_ID_ACCESS_CHANGE(usr, src, "removed [SSid_access.get_access_desc(access_type)]")
				return TRUE

			if(!(access_type in target_card.access))
				to_chat(usr, span_notice("ID error: ID card rejected your attempted access modification."))
				LOG_ID_ACCESS_CHANGE(usr, src, "failed to add [SSid_access.get_access_desc(access_type)][try_wildcard ? " with wildcard [try_wildcard]" : ""]")
				return TRUE

			if(!can_add_wildcards(list(access_type), try_wildcard))
				to_chat(usr, span_notice("ID error: ID card rejected your attempted access modification."))
				LOG_ID_ACCESS_CHANGE(usr, src, "failed to add [SSid_access.get_access_desc(access_type)][try_wildcard ? " with wildcard [try_wildcard]" : ""]")
				return TRUE

			if(!add_access(list(access_type), try_wildcard))
				to_chat(usr, span_notice("ID error: ID card rejected your attempted access modification."))
				LOG_ID_ACCESS_CHANGE(usr, src, "failed to add [SSid_access.get_access_desc(access_type)][try_wildcard ? " with wildcard [try_wildcard]" : ""]")
				return TRUE

			if(access_type in ACCESS_ALERT_ADMINS)
				message_admins("[ADMIN_LOOKUPFLW(usr)] just added [SSid_access.get_access_desc(access_type)] to an ID card [ADMIN_VV(src)] [(registered_name) ? "belonging to [registered_name]." : "with no registered name."]")
			LOG_ID_ACCESS_CHANGE(usr, src, "added [SSid_access.get_access_desc(access_type)]")
			return TRUE

/obj/item/card/id/advanced/chameleon/attack_self(mob/user)
	if(isliving(user) && user.mind)
		var/popup_input = tgui_alert(user, "Choose Action", "Agent ID", list("Show", "Forge/Reset", "Change Account ID"))
		if(user.incapacitated())
			return
		if(!user.is_holding(src))
			return
		if(popup_input == "Forge/Reset")
			if(!forged)
				var/input_name = stripped_input(user, "What name would you like to put on this card? Leave blank to randomise.", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name), MAX_NAME_LEN)
				input_name = sanitize_name(input_name)
				if(!input_name)
					// Invalid/blank names give a randomly generated one.
					if(user.gender == MALE)
						input_name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
					else if(user.gender == FEMALE)
						input_name = "[pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
					else
						input_name = "[pick(GLOB.first_names)] [pick(GLOB.last_names)]"

				registered_name = input_name

				var/change_trim = tgui_alert(user, "Adjust the appearance of your card's trim?", "Modify Trim", list("Yes", "No"))
				if(change_trim == "Yes")
					var/list/blacklist = typecacheof(type) + typecacheof(/obj/item/card/id/advanced/simple_bot)
					var/list/trim_list = list()
					for(var/trim_path in typesof(/datum/id_trim))
						if(blacklist[trim_path])
							continue

						var/datum/id_trim/trim = SSid_access.trim_singletons_by_path[trim_path]

						if(trim && trim.trim_state && trim.assignment)
							var/fake_trim_name = "[trim.assignment] ([trim.trim_state])"
							trim_list[fake_trim_name] = trim_path

					var/selected_trim_path
					selected_trim_path = input("Select trim to apply to your card.\nNote: This will not grant any trim accesses.", "Forge Trim", selected_trim_path) as null|anything in sort_list(trim_list, /proc/cmp_typepaths_asc)
					if(selected_trim_path)
						SSid_access.apply_trim_to_chameleon_card(src, trim_list[selected_trim_path])

				var/target_occupation = stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels.", "Agent card job assignment", assignment ? assignment : "Assistant", MAX_MESSAGE_LEN)
				if(target_occupation)
					assignment = target_occupation

				var/new_age = input(user, "Choose the ID's age:\n([AGE_MIN]-[AGE_MAX])", "Agent card age") as num|null
				if(new_age)
					registered_age = max(round(text2num(new_age)), 0)

				if(tgui_alert(user, "Activate wallet ID spoofing, allowing this card to force itself to occupy the visible ID slot in wallets?", "Wallet ID Spoofing", list("Yes", "No")) == "Yes")
					ADD_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)

				update_label()
				update_icon()
				forged = TRUE
				to_chat(user, span_notice("You successfully forge the ID card."))
				log_game("[key_name(user)] has forged \the [initial(name)] with name \"[registered_name]\", occupation \"[assignment]\" and trim \"[trim?.assignment]\".")

				if(!registered_account)
					if(ishuman(user))
						var/mob/living/carbon/human/accountowner = user

						var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[accountowner.account_id]"]
						if(account)
							account.bank_cards += src
							registered_account = account
							to_chat(user, span_notice("Your account number has been automatically assigned."))
				return
			if(forged)
				registered_name = initial(registered_name)
				assignment = initial(assignment)
				SSid_access.remove_trim_from_chameleon_card(src)
				REMOVE_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)
				log_game("[key_name(user)] has reset \the [initial(name)] named \"[src]\" to default.")
				update_label()
				update_icon()
				forged = FALSE
				to_chat(user, span_notice("You successfully reset the ID card."))
				return
		if (popup_input == "Change Account ID")
			set_new_account(user)
			return
	return ..()

/// A special variant of the classic chameleon ID card which accepts all access.
/obj/item/card/id/advanced/chameleon/black
	icon_state = "card_black"
	worn_icon_state = "card_black"
	assigned_icon_state = "assigned_syndicate"
	wildcard_slots = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/engioutpost
	registered_name = "George 'Plastic' Miller"
	desc = "A card used to provide ID and determine access across the station. There's blood dripping from the corner. Ew."
	trim = /datum/id_trim/engioutpost
	registered_age = 47

/obj/item/card/id/advanced/simple_bot
	name = "simple bot ID card"
	desc = "An internal ID card used by the station's non-sentient bots. You should report this to a coder if you're holding it."
	wildcard_slots = WILDCARD_LIMIT_ADMIN

/obj/item/card/id/red
	name = "Red Team identification card"
	desc = "A card used to identify members of the red team for CTF"
	icon_state = "ctf_red"

/obj/item/card/id/blue
	name = "Blue Team identification card"
	desc = "A card used to identify members of the blue team for CTF"
	icon_state = "ctf_blue"

/obj/item/card/id/yellow
	name = "Yellow Team identification card"
	desc = "A card used to identify members of the yellow team for CTF"
	icon_state = "ctf_yellow"

/obj/item/card/id/green
	name = "Green Team identification card"
	desc = "A card used to identify members of the green team for CTF"
	icon_state = "ctf_green"

#undef INTERN_THRESHOLD_FALLBACK_HOURS
#undef ID_ICON_BORDERS
