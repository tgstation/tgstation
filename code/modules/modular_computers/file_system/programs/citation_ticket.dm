#define CITATION_DEFAULT_DEADLINE_MINUTES 15
#define CITATION_MAX_DEADLINE_MINUTES 60
#define CITATION_TICKET_NAME_LEN 24


/datum/crime/citation/timed_ticket
	/// Value at which the fine is considered overdue.
	var/pay_deadline = 0

/**
 * Shared issuance helper used by both the PDA program and the cyborg
 * citation pad. Validates the form, appends a citation to the target's
 * record, fires a PDA alert, and prints a carbon-copy ticket into the
 * issuer's free hand.
 *
 * Host-aware:
 * * if the host is a [/obj/item/modular_computer] the issuer name is
 *   sourced from the inserted ID and stored_paper is decremented; an
 *   empty paper tray refuses the issue.
 * * otherwise (cyborg pad) the issuer is the user's real_name and paper
 *   is treated as effectively unlimited.
 *
 * Returns TRUE on success, FALSE on any validation failure.
 */
/proc/issue_security_citation(atom/host, mob/user, list/params)
	if(QDELETED(host) || QDELETED(user))
		return FALSE

	var/input_name = strip_html_full(params["crime_name"], CITATION_TICKET_NAME_LEN)
	if(!input_name)
		host.balloon_alert(user, "no crime name!")
		return FALSE

	var/input_details
	if(params["details"])
		input_details = strip_html_full(params["details"], MAX_MESSAGE_LEN)

	var/fine = round(text2num(params["fine"]))
	if(!isnum(fine) || fine <= 0)
		host.balloon_alert(user, "fine must be > 0!")
		return FALSE

	var/max_fine = CONFIG_GET(number/maxfine)
	if(fine > max_fine)
		host.balloon_alert(user, "max fine is [max_fine]!")
		return FALSE

	var/deadline_minutes = round(text2num(params["deadline_minutes"]))
	if(!isnum(deadline_minutes) || deadline_minutes <= 0)
		deadline_minutes = CITATION_DEFAULT_DEADLINE_MINUTES
	if(deadline_minutes > CITATION_MAX_DEADLINE_MINUTES)
		deadline_minutes = CITATION_MAX_DEADLINE_MINUTES

	var/target_name = params["target_name"]
	if(!target_name)
		host.balloon_alert(user, "no target selected!")
		return FALSE

	var/datum/record/crew/target = find_record(target_name)
	if(!target)
		host.balloon_alert(user, "target not found in records!")
		return FALSE

	var/obj/item/modular_computer/host_computer
	if(istype(host, /obj/item/modular_computer))
		host_computer = host
		if(host_computer.stored_paper <= 0)
			host.balloon_alert(user, "out of paper!")
			return FALSE

	var/issuer_name = user.real_name
	if(host_computer)
		var/obj/item/card/id/issuer_id = host_computer.stored_id?.GetID()
		issuer_name = issuer_id?.registered_name || user.real_name

	var/datum/crime/citation/timed_ticket/new_citation = new(
		name = input_name,
		details = input_details,
		author = user,
		fine = fine,
	)
	new_citation.pay_deadline = STATION_TIME_PASSED() + (deadline_minutes MINUTES)
	target.citations += new_citation

	var/deadline_stamp = round_timestamp("hh:mm", new_citation.pay_deadline)

	new_citation.alert_owner(
		user,
		host,
		target.name,
		"You have been issued a [fine][MONEY_SYMBOL] citation for [input_name] by [issuer_name]. Payable at Security before [deadline_stamp] ([deadline_minutes] min).",
	)

	host.investigate_log("New Citation: <strong>[input_name]</strong> Fine: [fine] Deadline: [deadline_minutes]m | Added to [target.name] by [key_name(user)]", INVESTIGATE_RECORDS)
	SSblackbox.ReportCitation(REF(new_citation), user.ckey, user.real_name, target.name, input_name, input_details, fine)

	print_security_citation_ticket(host, user, target.name, target.rank, issuer_name, input_name, input_details, fine, deadline_stamp, deadline_minutes)
	if(host_computer)
		host_computer.stored_paper--

	playsound(host, 'sound/items/poster/poster_being_created.ogg', 30, TRUE)
	host.visible_message(span_notice("\The [host] prints a citation ticket."))
	host.balloon_alert(user, "ticket issued")
	return TRUE

/// Prints a single sheet of carbon paper containing the citation and places it in the issuer's free hand.
/proc/print_security_citation_ticket(atom/host, mob/user, target_name, target_rank, issuer_name, crime_name, details, fine, deadline_stamp, deadline_minutes)
	var/details_block = details ? "<p><b>Details:</b><br>[details]</p>" : ""
	var/contents = {"<h3>Nanotrasen Security Citation</h3>
<hr>
<p><b>Issued to:</b> [target_name] ([target_rank])</p>
<p><b>Issued by:</b> [issuer_name]</p>
<p><b>Issued at:</b> [round_timestamp("hh:mm")]</p>
<hr>
<p><b>Offense:</b> [crime_name]</p>
[details_block]
<hr>
<p><b>Fine:</b> [fine][MONEY_SYMBOL]</p>
<p><b>Pay before:</b> [deadline_stamp] Station Time (within [deadline_minutes] minute\s of issue)</p>
<hr>
<p><i>Fines are payable at the Security Office. Failure to pay before the listed deadline may escalate enforcement.</i></p>"}

	var/obj/item/paper/carbon/ticket = new(host.drop_location())
	ticket.name = "citation - [target_name]"
	ticket.add_raw_text(contents)
	ticket.update_appearance()
	if(!isnull(user))
		user.put_in_hands(ticket)
	return ticket

/// Builds the TGUI data dict shared by the PDA program and the cyborg pad.
/proc/build_citation_ui_data(paper_left)
	var/list/data = list()

	var/list/crew = list()
	for(var/datum/record/crew/entry as anything in GLOB.manifest.general)
		if(entry.name == "Unknown")
			continue
		crew += list(list(
			"name" = entry.name,
			"rank" = entry.rank,
		))
	data["crew"] = crew

	data["max_fine"] = CONFIG_GET(number/maxfine)
	data["money_symbol"] = MONEY_SYMBOL
	data["max_crime_name_len"] = CITATION_TICKET_NAME_LEN
	data["max_details_len"] = MAX_MESSAGE_LEN
	data["default_deadline_minutes"] = CITATION_DEFAULT_DEADLINE_MINUTES
	data["max_deadline_minutes"] = CITATION_MAX_DEADLINE_MINUTES
	data["paper_left"] = paper_left
	return data

/datum/computer_file/program/citation_ticket
	filename = "secticket"
	filedesc = "Security Citation Issuer"
	downloader_category = PROGRAM_CATEGORY_SECURITY
	program_open_overlay = "citation"
	extended_desc = "Issue citations against crew records and print carbon-copy enforcement tickets. Restricted to security personnel."
	program_flags = PROGRAM_ON_NTNET_STORE
	can_run_on_flags = PROGRAM_ALL
	download_access = list(ACCESS_SECURITY)
	run_access = list(ACCESS_SECURITY)
	size = 4
	tgui_id = "NtosCitation"
	program_icon = "gavel"
	alert_able = TRUE

/datum/computer_file/program/citation_ticket/ui_data(mob/user)
	return build_citation_ui_data(computer?.stored_paper)

/datum/computer_file/program/citation_ticket/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("issue_citation")
			if(!computer)
				return FALSE
			return issue_security_citation(computer, ui.user, params)

/// An integrated borg version of the citation issuer.
/obj/item/borg/citation_pad
	name = "citation issuer"
	desc = "An on-board terminal for issuing security citations and printing carbon-copy enforcement tickets on the spot."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "labeler0"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/borg/citation_pad/attack_self(mob/user)
	ui_interact(user)

/obj/item/borg/citation_pad/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/borg/citation_pad/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosCitation")
		ui.open()

/obj/item/borg/citation_pad/ui_data(mob/user)
	return build_citation_ui_data(/* paper_left = */ 999)

/obj/item/borg/citation_pad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("issue_citation")
			return issue_security_citation(src, ui.user, params)

#undef CITATION_DEFAULT_DEADLINE_MINUTES
#undef CITATION_MAX_DEADLINE_MINUTES
#undef CITATION_TICKET_NAME_LEN
