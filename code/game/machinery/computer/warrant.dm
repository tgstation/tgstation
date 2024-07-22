/obj/machinery/computer/warrant
	name = "security citation console"
	desc = "Used to view outstanding citations and fines."
	icon_screen = "warrant"
	icon_keyboard = "id_key"
	circuit = /obj/item/circuitboard/computer/warrant
	light_color = COLOR_SOFT_RED
	/// The state of the printer
	var/printing = FALSE
	/// What is the source (PDA or src)
	var/source

/obj/machinery/computer/warrant/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PhysicalWarrantConsole", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/warrant/ui_data(mob/user)
	var/list/data = list()

	var/list/records = list()

	for(var/datum/record/crew/target in GLOB.manifest.general)
		if(!length(target.citations))
			continue

		var/list/citations = list()

		for(var/datum/crime/citation/warrant as anything in target.citations)
			if(!warrant.valid)
				continue

			var/list/entry = list(list(
				author = warrant.author,
				details = warrant.details,
				fine = warrant.fine,
				fine_name = warrant.name,
				fine_ref = REF(warrant),
				paid = warrant.paid,
				time = warrant.time,
			))

			citations += entry

		var/list/record = list(list(
			citations = citations,
			crew_name = target.name,
			crew_ref = REF(target),
			notes = target.security_note,
			rank = target.rank,
		))

		records += record
	data["records"] = records

	return data

/obj/machinery/computer/warrant/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE

	switch(action)
		if("pay")
			pay_fine(usr, params)
			return TRUE

		if("print")
			ui.close()
			print_ticket(usr, params)
			return TRUE

		if("refresh")
			return TRUE

	return FALSE

/// Pays towards a listed fine.
/obj/machinery/computer/warrant/proc/pay_fine(mob/user, list/params)
	var/internal_source
	if(source)
		internal_source = source
	else
		internal_source = get_turf(src)

	var/datum/record/crew/target = locate(params["crew_ref"]) in GLOB.manifest.general
	if(!target)
		return FALSE

	var/datum/crime/citation/warrant = locate(params["fine_ref"]) in target.citations
	if(!warrant)
		return FALSE

	if(!isliving(user) || issilicon(user))
		to_chat(user, span_warning("ACCESS DENIED"))
		playsound(internal_source, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/mob/living/player = user
	var/obj/item/card/id/auth = player.get_idcard(TRUE)
	if(!auth)
		to_chat(user, span_warning("ACCESS DENIED: No ID card detected."))
		playsound(internal_source, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/datum/bank_account/account = auth.registered_account
	if(!account?.account_holder || account.account_holder == "Unassigned")
		to_chat(user, span_warning("ACCESS DENIED: No account linked to ID."))
		playsound(internal_source, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/amount = params["amount"]
	if(!amount || !isnum(amount) || amount > warrant.fine || !account.adjust_money(-amount, "Paid fine for [target.name]"))
		to_chat(user, span_warning("ACCESS DENIED: Invalid amount."))
		playsound(internal_source, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	account.bank_card_talk("You have paid [amount]cr towards [target.name]'s fine of [warrant.fine]cr.")
	log_econ("[amount]cr was transferred from [user]'s transaction to [target.name]'s [warrant.fine]cr fine")
	SSblackbox.record_feedback("amount", "credits_transferred", amount)
	warrant.pay_fine(amount)

	if(amount >= 100 && target?.name != user)
		var/list/titles = list(
			"An anonymous benefactor",
			"A generous crew member",
			"A kind soul",
			"A good samaritan",
			"A friendly face",
			"A helpful stranger",
		)
		warrant.alert_owner(user, src, target.name, "[pick(titles)] has paid [amount]cr towards your fine.")

	var/datum/bank_account/sec_account = SSeconomy.get_dep_account(ACCOUNT_SEC)
	sec_account.adjust_money(amount)

	if(warrant.fine != 0 || target.name == user)
		return TRUE

	warrant.alert_owner(user, src, target.name, "One of your outstanding warrants has been completely paid.")
	return TRUE

/// Finishes printing, resets the printer.
/obj/machinery/computer/warrant/proc/print_finish(obj/item/paper/paperslip/ticket/ticket, internal_source)
	printing = FALSE
	playsound(internal_source, 'sound/machines/terminal_eject.ogg', 100, TRUE)
	ticket.forceMove(get_turf(internal_source))

	return TRUE

/// Prints a ticket for a listed fine.
/obj/machinery/computer/warrant/proc/print_ticket(mob/user, list/params)
	var/internal_source
	if(source)
		internal_source = source
	else
		internal_source = get_turf(src)

	if(printing)
		balloon_alert(internal_source, "printer busy")
		playsound(internal_source, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/datum/record/crew/target = locate(params["crew_ref"]) in GLOB.manifest.general
	if(!target)
		return FALSE

	var/datum/crime/citation/warrant = locate(params["fine_ref"]) in target.citations
	if(!warrant?.fine)
		return FALSE

	var/ticket_text = "<center><h1><b>Ticket to [target.name]</b><h1></center><BR>"
	ticket_text += "<center>Cited for [warrant.name]</h2></center><br><br>"
	ticket_text += "<b>Details:</b><br>[warrant.details]<br>"
	ticket_text += "<b>Issued by:</b><br>[warrant.author]<br>"
	ticket_text += "<b>Issued on:</b><br>[warrant.time]<br>"
	ticket_text += "<b>Comments:</b><br>[!target.security_note ? "None." : target.security_note]<br><br>"
	ticket_text += "<center><b>FINE:</b> [warrant.fine] credits</center><br>"
	ticket_text += "<i>Citations can be paid with the warrant console at the Brig entrance. \
		Not paying this citation may result in further prosecution from the Security department of [GLOB.station_name]. \
		If you have any problems with the citation reason - contact a Lawyer. <b>You've been warned.</b></i>"

	printing = TRUE
	balloon_alert(internal_source, "printing")
	playsound(internal_source, 'sound/machines/printer.ogg', 100, TRUE)

	var/obj/item/paper/paperslip/ticket/ticket = new(null)
	ticket.name = "ticket to [target.name]"
	ticket.desc = "A [warrant.fine]cr ticket for [target.name]."
	ticket.add_raw_text(ticket_text)
	ticket.update_icon()

	addtimer(CALLBACK(src, PROC_REF(print_finish), ticket, internal_source), 2 SECONDS)

	return TRUE
