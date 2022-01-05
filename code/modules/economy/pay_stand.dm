/obj/machinery/paystand
	name = "unregistered pay stand"
	desc = "See title."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	density = TRUE
	anchored = TRUE
	var/locked = FALSE
	var/obj/item/card/id/my_card
	var/obj/item/assembly/signaler/signaler //attached signaler, let people attach signalers that get activated if the user's transaction limit is achieved.
	var/signaler_threshold = 0 //signaler threshold amount
	var/amount_deposited = 0 //keep track of the amount deposited over time so you can pay multiple times to reach the signaler threshold
	var/force_fee = 0 //replaces the "pay whatever" functionality with a set amount when non-zero.

/obj/machinery/paystand/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		if(W == my_card)
			var/list/items = list(
			"Rename" = image(icon = 'icons/obj/economy.dmi', icon_state = "name"),
			"Set the fee" = image(icon = 'icons/obj/economy.dmi', icon_state = "fee")
			)
			var/choice = show_radial_menu(user, src, items, null, require_near = TRUE, tooltips = TRUE)
			if(choice == "Rename")
				var/rename_msg = tgui_input_text(user, "Rename the Paystand", "Paystand Name", name)
				if(!rename_msg || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				name = rename_msg
				return
			else if(choice == "Set the fee")
				var/force_fee_input = tgui_input_number(user, "Set the fee", "Fee", max_value = 10000)
				if(isnull(force_fee_input) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				force_fee = round(force_fee_input)
				return
			locked = !locked
			to_chat(user, span_notice("You [src.locked ? "lock" : "unlock"] the paystand, protecting the bolts from [anchored ? "loosening" : "tightening"]."))
			return
		if(!my_card)
			var/obj/item/card/id/new_card = W
			if(!new_card.registered_account)
				return
			var/msg = tgui_input_text(user, "Name of pay stand", "Paystand Naming", "Paystand (owned by [new_card.registered_account.account_holder])")
			if(!msg)
				return
			name = msg
			desc = "Owned by [new_card.registered_account.account_holder], pays directly into [user.p_their()] account."
			my_card = new_card
			to_chat(user, "You link the stand to your account.")
			return
		var/obj/item/card/id/pay_card = W
		if(pay_card.registered_account)
			if(!pay_card.registered_account.account_job)//Departmental budget cards like cargo's fall under this
				to_chat(user, span_warning("ERROR: Personal use of department budgets is not authorized."))
				return
			var/credit_amount = 0
			if(!force_fee)
				credit_amount = tgui_input_number(user, "How much would you like to deposit?", "Money Deposit")
				if(isnull(credit_amount))
					return
				credit_amount = round(credit_amount)
			else
				credit_amount = force_fee
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(credit_amount < 1)
				to_chat(user, span_warning("ERROR: Invalid amount designated."))
				return
			if(pay_card.registered_account.adjust_money(-credit_amount))
				purchase(pay_card.registered_account.account_holder, credit_amount)
				say("Thank you for your patronage, [pay_card.registered_account.account_holder]!")
				playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)
				return
			else
				to_chat(user, span_warning("ERROR: Account has insufficient funds to make transaction."))
				return
		else
			to_chat(user, span_warning("ERROR: No bank account assigned to identification card."))
			return
	if(istype(W, /obj/item/holochip))
		var/obj/item/holochip/H = W
		var/cashmoney = round(tgui_input_number(user, "How much would you like to deposit?", "Money Deposit"))
		if(isnull(cashmoney))
			return
		cashmoney = round(cashmoney)
		if(H.spend(cashmoney, FALSE))
			purchase(user, cashmoney)
			to_chat(user, "Thanks for purchasing! The vendor has been informed.")
			return
		else
			to_chat(user, span_warning("ERROR: Insufficient funds to make transaction."))
			return
	if(istype(W, /obj/item/stack/spacecash))
		to_chat(user, "What is this, the 2000s? We only take card here.")
		return
	if(istype(W, /obj/item/coin))
		to_chat(user, "What is this, the 1800s? We only take card here.")
		return
	if(istype(W, /obj/item/assembly/signaler))
		var/obj/item/assembly/signaler/S = W
		if(S.secured)
			to_chat(user, span_warning("The signaler needs to be in attachable mode to add it to the paystand!"))
			return
		if(!my_card)
			to_chat(user, span_warning("ERROR: No identification card has been assigned to this paystand yet!"))
			return
		if(!isnull(signaler))
			to_chat(user, span_warning("A signaler is already attached to this unit!"))
			return
		var/cash_limit = tgui_input_number(user, "Enter the minimum amount of cash needed to deposit before the signaler is activated.", "Signaler Activation Threshold", 1, min_value = 1)
		if(isnull(cash_limit))
			return
		cash_limit = round(cash_limit)
		S.forceMove(src)
		signaler = S
		signaler_threshold = cash_limit
		to_chat(user, "You attach the signaler to the paystand.")
		desc += " A signaler appears to be attached to the scanner."

	if(default_deconstruction_screwdriver(user, "card_scanner", "card_scanner", W))
		return

	else if(default_pry_open(W))
		return

	else if(default_unfasten_wrench(user, W))
		return

	else if(default_deconstruction_crowbar(W))
		return
	else
		return ..()

/obj/machinery/paystand/proc/purchase(buyer, price)
	my_card.registered_account.adjust_money(price)
	my_card.registered_account.bank_card_talk("Purchase made at your vendor by [buyer] for [price] credits.")
	amount_deposited = amount_deposited + price
	if(signaler && amount_deposited >= signaler_threshold)
		signaler.signal()
		amount_deposited = 0

/obj/machinery/paystand/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	if(locked)
		to_chat(user, span_warning("The bolts on this paystand are currently covered!"))
		return FALSE
	. = ..()

/obj/machinery/paystand/examine(mob/user)
	. = ..()
	if(force_fee)
		. += span_warning("This paystand forces a payment of <b>[force_fee]</b> credit\s per swipe instead of a variable amount.")
	if(user.get_active_held_item() == my_card)
		. += span_notice("Paystands can be edited through swiping your card.")
