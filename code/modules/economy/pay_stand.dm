/obj/machinery/paystand
	name = "unregistered pay stand"
	desc = "See title."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	density = TRUE
	anchored = TRUE
	var/price = 0
	var/obj/item/card/id/my_card

/obj/machinery/paystand/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		if(!my_card)
			var/obj/item/card/id/assistant_mains_need_to_die = W
			if(assistant_mains_need_to_die.registered_account)
				var/msg = stripped_input(user, "Name of pay stand:", "Paystand Naming", "[user]'s Awesome Paystand")
				if(!msg)
					return
				var/price2 = input(user, "Enter price.", "Paystand Pricing", 25) as num
				if(!price2 || price2 < 0)
					return
				name = "[msg] ($[price2])"
				desc = "Owned by [assistant_mains_need_to_die.registered_account.account_holder]. Pays directly into [user.p_their()] account when swiped with an ID card."
				price = price2
				my_card = assistant_mains_need_to_die
				to_chat(user, "You link the stand to your account.")
				return
		var/obj/item/card/id/vbucks = W
		if(vbucks.registered_account)
			if(vbucks.registered_account.adjust_money(-price))
				my_card.registered_account.adjust_money(price)
				my_card.registered_account.bank_card_talk("Purchase made at your vendor by [vbucks.registered_account.account_holder] for $[price].")
				to_chat(user, "Thanks for purchasing! The vendor has been informed.")
				return
			else
				to_chat(user, "You trying to punk me, kid? Come back when you have the cash.")
				return
		else
			to_chat(user, "You're going to need an actual bank account for that one, buddy.")
			return
	if(istype(W, /obj/item/stack/spacecash))
		to_chat(user, "What is this, the 2000s? We only take card here.")
		return
	if(istype(W, /obj/item/coin))
		to_chat(user, "What is this, the 1800s? We only take card here.")
		return

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