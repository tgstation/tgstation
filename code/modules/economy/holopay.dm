/// Max range at which the hologram can be projected before it deletes
#define MAX_HOLO_RANGE 3
/// Minimum forced fee for holopay stations. Registers as "pay what you want."
#define MIN_FEE 0
/// Maximum forced fee. It's unlikely for a user to encounter this type of money, much less pay it willingly.
#define MAX_FEE 5000

/obj/machinery/holopay
	name = "holographic pay stand"
	desc = "an unregistered pay stand"
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	alpha = 150
	anchored = TRUE
	layer = FLY_LAYER
	/// Owner of the holopay
	var/mob/living/owner
	/// ID linked to the holopay
	var/obj/item/card/id/linked_card
	/// Owner's linked account to the holopay
	var/datum/bank_account/linked_account
	/// Replaces the "pay whatever" functionality with a set amount when non-zero.
	var/force_fee = 0
	/// List of logos available for customization - via font awesome 5
	var/static/list/available_logos = list("angry", "ankh", "band-aid", "cannabis", "cat", "cocktail", "coins", "comments-dollar",
	"cross", "cut", "donate", "dna", "flask", "glass-cheers", "glass-martini-alt", "hand-holding-usd", "heart", "heart-broken",
	"hamburger", "hat-cowboy-side", "money-check-alt", "music", "pizza-slice", "prescription-bottle-alt", "radiation", "robot", "smile",
	"tram", "trash")
	/// The brand icon chosen by the user
	var/shop_logo = "donate"

/obj/machinery/holopay/New(turf/location, mob/living/user, obj/item/card/id/card, datum/bank_account/account)
	loc = location
	owner = user
	linked_card = card
	linked_account = account
	desc = "Pays directly into [owner]'s bank account."
	add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	set_light(2)
	visible_message(span_notice("A holographic pay stand appears."))
	/// Start checking if the owner has left or died
	RegisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_STATUS_UNCONSCIOUS), .proc/check_operation)
	return ..()

/**
 * A periodic check to see if the owner has left the area, died, or is afk.
 * Deletes the holopay if any condition is true.
 */
/obj/machinery/holopay/proc/check_operation()
	SIGNAL_HANDLER
	if(!owner || !owner.client || !isliving(owner) || !IN_GIVEN_RANGE(src, owner, MAX_HOLO_RANGE))
		QDEL_NULL(linked_card?.my_store)
		qdel(src)

/obj/machinery/holopay/Destroy()
	playsound(loc, "sound/effects/empulse.ogg", 40, TRUE)
	visible_message(span_notice("The pay stand vanishes."))
	return ..()

/obj/machinery/holopay/examine(mob/user)
	. = ..()
	if(force_fee)
		. += span_boldnotice("This holopay forces a payment of <b>[force_fee]</b> credit\s per swipe instead of a variable amount.")

/obj/machinery/holopay/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!linked_account)
		balloon_alert(user, "no registered owner")
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HoloPay")
		ui.open()

/obj/machinery/holopay/ui_status(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE

/obj/machinery/holopay/ui_static_data(mob/user)
	. = list()
	.["available_logos"] = available_logos
	.["description"] = desc
	.["force_fee"] = force_fee
	.["max_fee"] = MAX_FEE
	.["name"] = name
	.["owner"] = linked_account?.account_holder || null
	.["shop_logo"] = shop_logo

/obj/machinery/holopay/ui_data(mob/user)
	. = list()
	var/obj/item/card/id/id_card
	if(isliving(user))
		var/mob/living/card_holder = user
		id_card = card_holder.get_idcard(TRUE)
	if(id_card?.registered_account)
		.["user"] = list()
		.["user"]["name"] = id_card.registered_account.account_holder
		.["user"]["balance"] = id_card.registered_account.account_balance

/obj/machinery/holopay/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE
	switch(action)
		if("done")
			ui.send_full_update()
			return TRUE
		if("fee")
			var/choice = params["amount"]
			if(!isnum(choice))
				stack_trace("User input a non number into the holopay fee field.")
				return FALSE
			if(choice < MIN_FEE || choice > MAX_FEE)
				stack_trace("User input a number outside of the valid range into the holopay fee field.")
				return FALSE
			/// If the fee is valid, apply it
			force_fee = params["amount"]
			return TRUE
		if("logo")
			shop_logo = params["logo"]
			return TRUE
		if("pay")
			ui.close()
			return process_payment(usr)
		if("rename")
			/// The stand name must be within the length limit
			if(length(params["name"]) < 3 || length(params["name"]) > MAX_NAME_LEN)
				to_chat(usr, span_warning("Must be between 3 - 42 characters."))
				return FALSE
			name = html_encode(trim(params["name"], MAX_NAME_LEN))
			return TRUE
	return FALSE

/obj/machinery/holopay/attackby(obj/item/held_item, mob/user, params)
	/// Users can pay with an ID to skip the UI
	if(istype(held_item, /obj/item/card/id))
		var/obj/item/card/id/pay_card = held_item
		if(!pay_card.registered_account || !pay_card.registered_account.account_job)
			balloon_alert(user, "invalid account")
			return FALSE

		/// Delete the holopay if the master swipes on it
		if(pay_card.registered_account == linked_account)
			qdel(src)
			return TRUE
		process_payment(user)
		return TRUE

	/// Users can also pay by holochip
	if(istype(held_item, /obj/item/holochip))
		var/obj/item/holochip/chip = held_item
		if(!chip.credits)
			balloon_alert(user, "holochip is empty")
			to_chat(user, span_warning("There doesn't seem to be any credits here."))
			return FALSE
		var/cash_deposit = tgui_input_number(user, "How much? (Max: [chip.credits])", "Patronage", 1, chip.credits, 1)
		if(isnull(cash_deposit))
			return TRUE
		if(cash_deposit <= 0 || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
			return FALSE
		cash_deposit = round(cash_deposit)
		if(chip.spend(cash_deposit, FALSE))
			alert_buyer(user, cash_deposit)
			return TRUE
		else
			balloon_alert(user, "insufficient funds")
			to_chat(user, span_warning("You don't have enough credits to pay for this."))
			return FALSE

	/// Throws errors if they try to use space cash
	if(istype(held_item, /obj/item/stack/spacecash))
		to_chat(user, "What is this, the 2000s? We only take card here.")
		return TRUE
	if(istype(held_item, /obj/item/coin))
		to_chat(user, "What is this, the 1800s? We only take card here.")
		return TRUE
	return ..()

/**
 * Initiates a transaction between accounts.
 *
 * Parameters:
 * * user - The user who initiated the transaction.
 * Returns:
 * * TRUE if the transaction was successful, FALSE otherwise.
 */
/obj/machinery/holopay/proc/process_payment(mob/living/user)
	// Preliminary sanity checks
	if(!isliving(user) || issilicon(user))
		return FALSE

	/// Account checks
	var/obj/item/card/id/id_card
	id_card = user.get_idcard(TRUE)
	if(!id_card || !id_card.registered_account || !id_card.registered_account.account_job)
		balloon_alert(user, "invalid account")
		to_chat(user, span_warning("You don't have a valid account."))
		return FALSE
	var/datum/bank_account/payee = id_card.registered_account
	if(payee == linked_account)
		balloon_alert(user, "invalid transaction")
		to_chat(user, span_warning("You can't pay yourself."))
		return FALSE
	var/minimum = force_fee || 1
	if(!payee.has_money(minimum))
		balloon_alert(user, "insufficient credits")
		to_chat(user, span_warning("You don't have the money to pay for this."))
		return FALSE

	/// If the user has enough money, ask them the amount or charge the force fee
	var/amount
	if(force_fee)
		amount = force_fee
	else
		amount = tgui_input_number(user, "How much? (Max: [payee.account_balance])", "Patronage", max_value = payee.account_balance)

	/// Exit checks in case the user cancelled or entered an invalid amount
	if(!amount || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return FALSE
	if(!payee.adjust_money(-amount))
		balloon_alert(user, "insufficient credits")
		to_chat(user, span_warning("You don't have the money to pay for this."))
		return FALSE

	/// Success: Alert the buyer
	alert_buyer(user, amount)
	return TRUE

/**
 * Alerts the owner of the transaction.
 *
 * Parameters:
 * * user - The user who initiated the transaction.
 * * amount - The amount of money that was paid.
 * Returns:
 * * TRUE if the alert was successful.
 */
/obj/machinery/holopay/proc/alert_buyer(payee, amount)
	/// Alert the owner
	linked_account.adjust_money(amount)
	linked_account.bank_card_talk("[payee] has deposited [amount] cr at your holographic pay stand.")
	say("Thank you for your patronage, [payee]!")
	playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)

	/// Log the event
	log_econ("[amount] credits were transferred from [payee]'s transaction to [linked_account.account_holder]")
	SSblackbox.record_feedback("amount", "credits_transferred", amount)
	return TRUE

#undef MAX_HOLO_RANGE
#undef MIN_FEE
#undef MAX_FEE
