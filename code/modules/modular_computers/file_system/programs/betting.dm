GLOBAL_LIST_EMPTY_TYPED(active_bets, /datum/active_bet)

///Max amount of characters you can have in an active bet's title
#define MAX_LENGTH_TITLE 64
///Max amount of characters you can have in an active bet's description
#define MAX_LENGTH_DESCRIPTION 200

/datum/computer_file/program/betting
	filename = "betting"
	filedesc = "SpaceBet"
	downloader_category = PROGRAM_CATEGORY_GAMES
	program_open_overlay = "gambling"
	extended_desc = "A multi-platform network for placing requests across the station, with payment across the network being possible."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_PDA
	size = 4
	tgui_id = "NtosSpaceBetting"
	program_icon = "dice"

	///The active bet this program made, as we can only have 1 going at a time to prevent flooding/spam.
	var/datum/active_bet/created_bet

/datum/computer_file/program/betting/New()
	. = ..()
	RegisterSignal(src, COMSIG_COMPUTER_FILE_DELETE, PROC_REF(on_delete))

///Called when we're deleted, we'll be taking the bet with us.
/datum/computer_file/program/betting/proc/on_delete(datum/source, obj/item/modular_computer/computer_uninstalling)
	SIGNAL_HANDLER

	created_bet.payout()
	QDEL_NULL(created_bet)

/datum/computer_file/program/betting/ui_data(mob/user)
	var/list/data = list()
	data["active_bets"] = list()
	for(var/datum/active_bet/bets as anything in GLOB.active_bets)
		data["active_bets"] += list(list(
			"name" = bets.name,
			"description" = bets.description,
			"owner" = bets == created_bet,
			"creator" = bets.bet_owner,
			"current_bets" = bets.get_bets(computer.computer_id_slot?.registered_account),
			"locked" = bets.locked,
		))

	data["can_create_bet"] = !!isnull(created_bet)
	if(isnull(computer.computer_id_slot))
		data["bank_name"] = null
		data["bank_money"] = null
	else
		data["bank_name"] = computer.computer_id_slot.registered_account.account_holder
		data["bank_money"] = computer.computer_id_slot.registered_account.account_balance

	return data

/datum/computer_file/program/betting/ui_static_data(mob/user)
	var/list/data = list()
	data["max_title_length"] = MAX_LENGTH_TITLE
	data["max_description_length"] = MAX_LENGTH_DESCRIPTION
	return data

/datum/computer_file/program/betting/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(isnull(computer.computer_id_slot))
		to_chat(user, span_danger("\The [computer] flashes an \"RFID Error - Unable to scan ID\" warning."))
		return
	switch(action)
		if("create_bet")
			var/title = reject_bad_name(params["title"], allow_numbers = TRUE, max_length = MAX_LENGTH_TITLE, cap_after_symbols = FALSE)
			var/description = reject_bad_name(params["description"], allow_numbers = TRUE, max_length = MAX_LENGTH_DESCRIPTION, cap_after_symbols = FALSE)
			if(isnull(title) || isnull(description))
				return
			var/list/options = list(params["option1"], params["option2"], params["option3"], params["option4"])
			for(var/option in options)
				options -= option
				//remove nulls, empty, and duplicates.
				if(isnull(option) || option == "" || options.Find(option))
					continue
				options += option
				option = reject_bad_name(option, allow_numbers = TRUE, max_length = MAX_LENGTH_TITLE, cap_after_symbols = FALSE)
			if(length(options) < 2)
				to_chat(user, span_danger("2 options minimum required to start a bet."))
				return
			created_bet = new(user, title, description, options)
			return TRUE
		if("place_bet")
			var/datum/active_bet/bet_placed_on
			for(var/datum/active_bet/bets as anything in GLOB.active_bets)
				if(bets.name == params["bet_selected"])
					bet_placed_on = bets
			//can't bet on your own bet
			if(isnull(bet_placed_on))
				return
			if(bet_placed_on == created_bet)
				to_chat(user, span_danger("You can't bet on your own poll!"))
				return
			var/money_betting = params["money_betting"]
			if(!isnum(money_betting))
				return
			var/option = params["option_selected"]
			if(isnull(bet_placed_on))
				return
			bet_placed_on.bet_money(computer.computer_id_slot.registered_account, money_betting, option)
			return TRUE
		if("cancel_bet")
			var/datum/active_bet/bet_cancelling
			for(var/datum/active_bet/bets as anything in GLOB.active_bets)
				if(bets.name == params["bet_selected"])
					bet_cancelling = bets
			bet_cancelling.cancel_bet(computer.computer_id_slot.registered_account)
			return TRUE
		if("select_winner")
			var/datum/active_bet/bets_ending
			for(var/datum/active_bet/bets as anything in GLOB.active_bets)
				if(bets.name == params["bet_selected"])
					bets_ending = bets
			if(isnull(bets_ending) || bets_ending != created_bet)
				return
			created_bet.payout(params["winning_answer"])
			QDEL_NULL(created_bet)
			return TRUE
		if("lock_betting")
			var/datum/active_bet/bet_locking
			for(var/datum/active_bet/bets as anything in GLOB.active_bets)
				if(bets.name == params["bet_selected"])
					bet_locking = bets
			if(bet_locking != created_bet)
				return
			bet_locking.locked = TRUE

/**
 * The active bet that our app will create & use, handles following who owns the bet,
 * who is betting, and also takes care of paying out at the end.
 */
/datum/active_bet
	///The person owning the bet, who will choose which option has won.
	var/bet_owner
	///The name of the bet
	var/name
	///The description of the bet
	var/description
	///Boolean on whether the bet is locked from getting new betters, or current ones from taking their money out.
	var/locked
	///Total amount of money that has been bet.
	var/total_amount_bet
	/** Assoc list of options, with each option having a list of people betting and the amount they've bet.
	options = list(
		OPTION_A = list(
			PERSON_1_ACCOUNT = bet_amount,
			PERSON_2_ACCOUNT = bet_amount,
		),
		OPTION_B = list(
			PERSON_3_ACCOUNT = bet_amount,
		),
	)
	*/
	var/list/options

	///The message we sent to the newscaster, which we'll then reply to once the betting is over.
	var/datum/feed_message/newscaster_message

/datum/active_bet/New(creator, name, description, options)
	src.bet_owner = creator
	src.name = name
	src.description = description
	src.options = options
	GLOB.active_bets += src
	for(var/option in options)
		if(!length(options[option]))
			options[option] = list()
	//we'll only advertise it on the first bet of the round, as to not make this overly annoying.
	var/should_alert = FALSE
	for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
		if(FC.channel_name == NEWSCASTER_SPACE_BETTING)
			if(!length(FC.messages))
				should_alert = TRUE
	newscaster_message = GLOB.news_network.submit_article("The bet [name] has started, place your bets now!", "NtOS Space Betting App", NEWSCASTER_SPACE_BETTING, null, update_alert = should_alert)

/datum/active_bet/Destroy(force)
	GLOB.active_bets -= src
	newscaster_message = null
	return ..()

///Returns how many bets there is per option
/datum/active_bet/proc/get_bets(datum/bank_account/user_account)
	var/list/bets_per_option = list()
	for(var/option in options)
		var/amount_personally_invested = 0
		var/total_amount = 0
		for(var/list/existing_bets in options[option])
			var/existing_bet_amount = text2num(existing_bets[2])
			if(user_account && (existing_bets[1] == user_account))
				amount_personally_invested = existing_bet_amount
			total_amount += existing_bet_amount
		bets_per_option += list(list("option_name" = option, "amount" = total_amount, "personally_invested" = amount_personally_invested))
	return bets_per_option

///Pays out the loser's money equally to all the winners, or refunds it all if no winning option was given.
/datum/active_bet/proc/payout(winning_option)
	if(isnull(winning_option) || !(winning_option in options))
		//no winner was selected (likely the host's PDA was destroyed or attempted href exploit), so let's refund everyone.
		for(var/list/option in options)
			for(var/list/existing_bets in options[option])
				var/datum/bank_account/refunded_account = existing_bets[1]
				refunded_account.adjust_money(text2num(existing_bets[2]), "Refund: [name] gamble cancelled.")
		return
	GLOB.news_network.submit_comment(
		comment_text = "The bet [name] has ended, the winner was [winning_option]!",
		newscaster_username = "NtOS Betting Results",
		current_message = newscaster_message,
	)
	var/list/winners = options[winning_option]
	if(!length(winners))
		return
	for(var/list/winner in winners)
		//they aren't winning their own money, so people betting a ton of money won't lose their money to those who bet few.
		total_amount_bet -= text2num(winner[2])
	for(var/list/winner in winners)
		var/datum/bank_account/winner_account = winner[1]
		var/money_won = text2num(winner[2]) + total_amount_bet / length(winners)
		winner_account.adjust_money(money_won, "Won gamble: [name]") //give them their money back & whatever they won.
		//they only made their money back, don't tell them they won anything.
		if((money_won - text2num(winner[2])) == 0)
			continue
		winner_account.bank_card_talk("You won [money_won]cr from having a correct guess on [name]!")

///Puts a bank account's money bet on a given option.
/datum/active_bet/proc/bet_money(datum/bank_account/better, money_betting, option_betting)
	if(locked)
		return
	for(var/option in options)
		for(var/list/existing_bets in options[option])
			if(existing_bets[1] == better)
				//We're already betting, but now we're betting on another one, clear our previous and we'll bet on the new.
				if(option != option_betting)
					better.adjust_money(text2num(existing_bets[2]), "Refunded: changed bet for [name].")
					options[option] -= list(existing_bets)
				//We're already betting on the same one, we'll add it together instead of making it a separate bet, or the user is taking money out.
				else
					//putting more money in
					if(text2num(existing_bets[2]) < money_betting)
						var/money_adding_in = money_betting - text2num(existing_bets[2])
						if(!better.adjust_money(-money_adding_in, "Gambling on [name]."))
							return
						total_amount_bet += money_adding_in
						better.bank_card_talk("Additional [money_adding_in]cr deducted for your bet on [name].")
						existing_bets[2] = "[money_betting]"
						return
					//taking it all out, we remove them from the list so they aren't a winner with bets of 0.
					if(money_betting == 0)
						var/money_taking_out = text2num(existing_bets[2])
						total_amount_bet -= money_taking_out
						better.adjust_money(money_taking_out, "Refunded: changed bet for [name].")
						options[option] -= list(existing_bets)
						return
					//taking money out
					if(text2num(existing_bets[2]) > money_betting)
						var/money_taking_out = text2num(existing_bets[2]) - money_betting
						total_amount_bet -= money_taking_out
						better.bank_card_talk("Refunded [money_taking_out]cr for taking money out of your bet on [name].")
						better.adjust_money(money_taking_out, "Refund from gambling on [name].")
						existing_bets[2] = "[money_betting]"
						return

	if(!better.adjust_money(-money_betting, "Gambling on [name]"))
		return
	total_amount_bet += money_betting
	options[option_betting] += list(list(better, "[money_betting]"))
	better.bank_card_talk("Deducted [money_betting]cr for your bet on [name].")

///Cancels your bet, removing your bet and refunding your money.
/datum/active_bet/proc/cancel_bet(datum/bank_account/better)
	for(var/option in options)
		for(var/list/existing_bets in options[option])
			if(existing_bets[1] == better)
				var/money_refunding = text2num(existing_bets[2])
				total_amount_bet -= money_refunding
				better.bank_card_talk("Refunded [money_refunding]cr for cancelling your bet on [name].")
				better.adjust_money(money_refunding, "Refunded: changed bet for [name].")
				options[option] -= list(existing_bets)

#undef MAX_LENGTH_TITLE
#undef MAX_LENGTH_DESCRIPTION
