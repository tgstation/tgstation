#define COMMUNICATION_COOLDOWN (30 SECONDS)
#define COMMUNICATION_COOLDOWN_AI (30 SECONDS)
#define COMMUNICATION_COOLDOWN_MEETING (5 MINUTES)
#define STATION_REPORT_TEMPLATE_PATH "modular_bandastation/paperwork/templates/station_report.md" /// BANDASTATION ADDITION - UPDATED INTERCEPT TEMPLATE

GLOBAL_DATUM_INIT(communications_controller, /datum/communciations_controller, new)

/datum/communciations_controller
	COOLDOWN_DECLARE(silicon_message_cooldown)
	COOLDOWN_DECLARE(nonsilicon_message_cooldown)

	/// Are we trying to send a cross-station message that contains soft-filtered words? If so, flip to TRUE to extend the time admins have to cancel the message.
	var/soft_filtering = FALSE

	/// The main content of the roundstart report
	/// If nothing is set, it will pick a random flavor report
	var/command_report_main_content = ""
	/// A list of footnote datums, to be added to the bottom of the roundstart command report.
	var/list/command_report_footnotes = list()
	/// A counter of conditions that are blocking the command report from printing. Counter incremements up for every blocking condition, and de-incrememnts when it is complete.
	var/block_command_report = 0
	/// Has a special xenomorph egg been delivered?
	var/xenomorph_egg_delivered = FALSE
	/// The location where the special xenomorph egg was planted
	var/area/captivity_area

	/// What is the lower bound of when the roundstart announcement is sent out?
	var/waittime_l = 1 SECONDS /// BANDASTATION EDIT
	/// What is the higher bound of when the roundstart announcement is sent out?
	var/waittime_h = 5 SECONDS /// BANDASTATION EDIT

	/// Tracks if we have announced greenshift at the start of the round or not
	var/announced_greenshift = FALSE

/datum/communciations_controller/proc/can_announce(mob/living/user, is_silicon)
	if(is_silicon && COOLDOWN_FINISHED(src, silicon_message_cooldown))
		return TRUE
	else if(!is_silicon && COOLDOWN_FINISHED(src, nonsilicon_message_cooldown))
		return TRUE
	else
		return FALSE

/datum/communciations_controller/proc/make_announcement(mob/living/user, is_silicon, input, syndicate, list/players)
	if(!can_announce(user, is_silicon))
		return FALSE
	if(is_silicon)
		minor_announce(html_decode(input),"[user.name] объявляет", players = players)
		COOLDOWN_START(src, silicon_message_cooldown, COMMUNICATION_COOLDOWN_AI)
	else
		var/list/message_data = user.treat_message(input)
		if(syndicate)
			priority_announce(html_decode(message_data["message"]), null, 'sound/announcer/announcement/announce_syndi.ogg', ANNOUNCEMENT_TYPE_SYNDICATE, has_important_message = TRUE, players = players, color_override = "red", tts_override = user.GetComponent(/datum/component/tts_component)) // Bandastation Addition: "tts_override = user.GetComponent(/datum/component/tts_component)"
		else
			priority_announce(html_decode(message_data["message"]), null, 'sound/announcer/announcement/announce.ogg', ANNOUNCEMENT_TYPE_CAPTAIN, has_important_message = TRUE, players = players, tts_override = user.GetComponent(/datum/component/tts_component)) // Bandastation Addition: "tts_override = user.GetComponent(/datum/component/tts_component)"
		COOLDOWN_START(src, nonsilicon_message_cooldown, COMMUNICATION_COOLDOWN)
	user.log_talk(input, LOG_SAY, tag="priority announcement")
	message_admins("[ADMIN_LOOKUPFLW(user)] has made a priority announcement.")

/datum/communciations_controller/proc/send_message(datum/comm_message/sending,print = TRUE,unique = FALSE, contains_advanced_html = FALSE)
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.machine_stat & (BROKEN|NOPOWER)) && is_station_level(C.z))
			if(unique)
				C.add_message(sending)
			else //We copy the message for each console, answers and deletions won't be shared
				var/datum/comm_message/M = new(sending.title,sending.content,sending.possible_answers.Copy())
				C.add_message(M)
			if(print)
				var/obj/item/paper/printed_paper = new /obj/item/paper(C.loc)
				printed_paper.name = "paper - '[sending.title]'"
				printed_paper.add_raw_text("</center>[sending.content]", advanced_html = contains_advanced_html)
				printed_paper.color = "#deebff"
				printed_paper.update_appearance()

// Called AFTER everyone is equipped with their job
/datum/communciations_controller/proc/queue_roundstart_report()
	addtimer(CALLBACK(src, PROC_REF(send_roundstart_report)), rand(waittime_l, waittime_h))

// BANDASTATION EDIT START - Updated intercept template
/datum/communciations_controller/proc/send_roundstart_report(greenshift)
	if(block_command_report) //If we don't want the report to be printed just yet, we put it off until it's ready
		addtimer(CALLBACK(src, PROC_REF(send_roundstart_report), greenshift), 10 SECONDS)
		return

	// Ensure NT logo asset is registered before we reference it in the report HTML
	get_asset_datum(/datum/asset/simple/logos)

	SSstation.generate_station_goals(CONFIG_GET(number/station_goal_budget))

	var/station_report_template = file2text(STATION_REPORT_TEMPLATE_PATH)

	var/station_goals_section = ""
	var/list/station_goal_strings = list()
	for(var/datum/station_goal/station_goal as anything in SSstation.get_station_goals())
		station_goal.on_report()
		station_goal_strings += station_goal.get_report()

	if(length(station_goal_strings))
		station_goals_section = list(
			"# === Цели на смену ===\n\n",
			station_goal_strings.Join("\n\n---\n\n"),
		).Join()

	station_report_template = replacetext(station_report_template, "%STATION_GOALS", station_goals_section)

	var/trait_reports_section = ""
	var/list/trait_reports = list()
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		trait_reports += "- [station_trait.get_report()]"

	if(length(trait_reports))
		trait_reports_section = list(
			"\n\n---\n\n",
			"# === Обнаруженные отклонения ===\n\n",
			trait_reports.Join("\n")
		).Join()

	station_report_template = replacetext(station_report_template, "%TRAIT_REPORTS", trait_reports_section)

	var/footnote_section = ""
	if(length(command_report_footnotes))
		var/list/footnotes = list()
		for(var/datum/command_footnote/footnote in command_report_footnotes)
			footnotes += "**[footnote.message]**\n\n"
			footnotes += "*[footnote.signature]*\n\n"

		footnote_section = list(
			"\n\n---\n\n",
			"# === Дополнительная информация ===\n\n",
			footnotes.Join()
		).Join()

	station_report_template = replacetext(station_report_template, "%FOOTNOTES", footnote_section)

	var/signing_officer = generate_random_name_species_based(
		gender = pick(list(MALE, FEMALE)),
		unique = TRUE,
		species_type = /datum/species/human
	)
	station_report_template = replacetext(station_report_template, "%SIGNING_OFFICER", signing_officer)

#ifndef MAP_TEST
	station_report_template = replace_text_keys(station_report_template, null)
	print_command_report(station_report_template, "[command_name()]. Отчет об обстановке", announce = FALSE, contains_advanced_html = FALSE)
	if(CONFIG_GET(flag/roundstart_blue_alert))
		if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_BLUE)
			SSsecurity_level.set_level(SEC_LEVEL_BLUE, announce = FALSE)
		priority_announce(
			"[SSsecurity_level.current_security_level.elevating_to_announcement]\n\n\
				Отчет был скопирован и распечатан на всех консолях связи.",
			"Уровень угрозы повышен.",
			ANNOUNCER_INTERCEPT,
			color_override = SSsecurity_level.current_security_level.announcement_color,
		)
	else
		priority_announce(
			"Отчет был скопирован и распечатан на всех консолях связи.",
			"Отчет об обстановке",
			SSstation.announcer.get_rand_report_sound(),
		)

#endif
// BANDASTATION EDIT END

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
#undef COMMUNICATION_COOLDOWN_MEETING

/// BANDASTATION ADDITION - UPDATED INTERCEPT TEMPLATE
#undef STATION_REPORT_TEMPLATE_PATH
