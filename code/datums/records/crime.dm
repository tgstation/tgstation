/**
 * Crime data. Used to store information about crimes.
 */
/datum/crime
	/// Name of the crime
	var/name
	/// Details about the crime
	var/details
	/// Player that wrote the crime
	var/author
	/// Time of the crime
	var/time

/datum/crime/New(name = "Crime", details = "No details provided.", author = "Anonymous", time = world.time)
	src.author = author
	src.details = details
	src.name = name
	src.time = time

/datum/crime/citation
	/// Fine for the crime
	var/fine
	/// Amount of money paid for the crime
	var/paid

/datum/crime/citation/New(name = "Citation", details = "No details provided.", author = "Anonymous", time = world.time, fine = 0, paid = 0)
	. = ..()
	src.fine = fine
	src.paid = paid

/// Pays off a citation. Messages the user if its paid or a large amount was deposited.
/datum/crime/citation/proc/pay_fine(mob/user, amount, target_name)
	paid += amount
	if(paid > fine)
		paid = fine

	fine -= amount
	if(fine < 0)
		fine = 0

	if(amount >= 100 && target_name && target_name != user)
		var/list/titles = list(
			"An anonymous benefactor",
			"A generous citizen",
			"A kind soul",
			"A good samaritan",
			"A friendly face",
			"A helpful stranger",
		)

		for(var/obj/item/modular_computer/tablet in GLOB.TabletMessengers)
			if(tablet.saved_identification != target_name)
				continue
			var/message = "[pick(titles)] has paid [amount]cr towards your fine."
			var/datum/signal/subspace/messaging/tablet_msg/signal = new(src, list(
				"name" = "Security Citation",
				"job" = "Citation Server",
				"message" = message,
				"targets" = list(tablet),
				"automated" = TRUE
			))
			signal.send_to_receivers()
			user.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)

	var/datum/bank_account/sec_account = SSeconomy.get_dep_account(ACCOUNT_SEC)
	sec_account.adjust_money(amount)

	if(fine != 0 && target_name)
		return TRUE

	for(var/obj/item/modular_computer/tablet in GLOB.TabletMessengers)
		if(tablet.saved_identification != target_name)
			continue
		var/message = "One of your outstanding warrants has been completely paid."
		var/datum/signal/subspace/messaging/tablet_msg/signal = new(src, list(
			"name" = "Security Citation",
			"job" = "Citation Server",
			"message" = message,
			"targets" = list(tablet),
			"automated" = TRUE
		))
		signal.send_to_receivers()
		user.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)
