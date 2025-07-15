#define COMMUNICATION_COOLDOWN (30 SECONDS)
#define COMMUNICATION_COOLDOWN_AI (30 SECONDS)
#define COMMUNICATION_COOLDOWN_MEETING (5 MINUTES)

GLOBAL_DATUM_INIT(communications_controller, /datum/communciations_controller, new)

/datum/communciations_controller
	COOLDOWN_DECLARE(silicon_message_cooldown)
	COOLDOWN_DECLARE(nonsilicon_message_cooldown)

	/// Are we trying to send a cross-station message that contains soft-filtered words? If so, flip to TRUE to extend the time admins have to cancel the message.
	var/soft_filtering = FALSE

	/// A list of footnote datums, to be added to the bottom of the roundstart command report.
	var/list/command_report_footnotes = list()
	/// A counter of conditions that are blocking the command report from printing. Counter incremements up for every blocking condition, and de-incrememnts when it is complete.
	var/block_command_report = 0
	/// Has a special xenomorph egg been delivered?
	var/xenomorph_egg_delivered = FALSE
	/// The location where the special xenomorph egg was planted
	var/area/captivity_area

	/// What is the lower bound of when the roundstart announcement is sent out?
	var/waittime_l = 60 SECONDS
	/// What is the higher bound of when the roundstart announcement is sent out?
	var/waittime_h = 180 SECONDS

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
		minor_announce(html_decode(input),"[user.name] announces:", players = players)
		COOLDOWN_START(src, silicon_message_cooldown, COMMUNICATION_COOLDOWN_AI)
	else
		var/list/message_data = user.treat_message(input)
		if(syndicate)
			priority_announce(html_decode(message_data["message"]), null, 'sound/announcer/announcement/announce_syndi.ogg', ANNOUNCEMENT_TYPE_SYNDICATE, has_important_message = TRUE, players = players, color_override = "red")
		else
			priority_announce(html_decode(message_data["message"]), null, 'sound/announcer/announcement/announce.ogg', ANNOUNCEMENT_TYPE_CAPTAIN, has_important_message = TRUE, players = players)
		COOLDOWN_START(src, nonsilicon_message_cooldown, COMMUNICATION_COOLDOWN)
	user.log_talk(input, LOG_SAY, tag="priority announcement")
	message_admins("[ADMIN_LOOKUPFLW(user)] has made a priority announcement.")

/datum/communciations_controller/proc/send_message(datum/comm_message/sending,print = TRUE,unique = FALSE)
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
				printed_paper.add_raw_text(sending.content)
				printed_paper.update_appearance()

// Called AFTER everyone is equipped with their job
/datum/communciations_controller/proc/queue_roundstart_report()
	addtimer(CALLBACK(src, PROC_REF(send_roundstart_report)), rand(waittime_l, waittime_h))

/datum/communciations_controller/proc/send_roundstart_report(greenshift)
	if(block_command_report) //If we don't want the report to be printed just yet, we put it off until it's ready
		addtimer(CALLBACK(src, PROC_REF(send_roundstart_report), greenshift), 10 SECONDS)
		return

	var/dynamic_report = SSdynamic.get_advisory_report()
	if(isnull(greenshift)) // if we're not forced to be greenshift or not - check if we are an actual greenshift
		greenshift = SSdynamic.current_tier.tier == 0 && dynamic_report == /datum/dynamic_tier/greenshift::advisory_report

	. = "<b><i>Nanotrasen Department of Intelligence Threat Advisory, Spinward Sector, TCD [time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR]:</i></b><hr>"
	. += dynamic_report

	SSstation.generate_station_goals(greenshift ? INFINITY : CONFIG_GET(number/station_goal_budget))

	var/list/datum/station_goal/goals = SSstation.get_station_goals()
	if(length(goals))
		var/list/texts = list("<hr><b>Special Orders for [station_name()]:</b><br>")
		for(var/datum/station_goal/station_goal as anything in goals)
			station_goal.on_report()
			texts += station_goal.get_report()
		. += texts.Join("<hr>")

	var/list/trait_list_strings = list()
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		trait_list_strings += "[station_trait.get_report()]<BR>"
	if(trait_list_strings.len > 0)
		. += "<hr><b>Identified shift divergencies:</b><BR>" + trait_list_strings.Join()

	if(length(command_report_footnotes))
		var/footnote_pile = ""

		for(var/datum/command_footnote/footnote as anything in command_report_footnotes)
			footnote_pile += "[footnote.message]<BR>"
			footnote_pile += "<i>[footnote.signature]</i><BR>"
			footnote_pile += "<BR>"

		. += "<hr><b>Additional Notes: </b><BR><BR>" + footnote_pile

#ifndef MAP_TEST
	print_command_report(., "[command_name()] Status Summary", announce=FALSE)
	if(greenshift)
		priority_announce(
			"Thanks to the tireless efforts of our security and intelligence divisions, \
				there are currently no credible threats to [station_name()]. \
				All station construction projects have been authorized. Have a secure shift!",
			"Security Report",
			SSstation.announcer.get_rand_report_sound(),
			color_override = "green",
		)
	else if(CONFIG_GET(flag/roundstart_blue_alert))
		if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_BLUE)
			SSsecurity_level.set_level(SEC_LEVEL_BLUE, announce = FALSE)
		priority_announce(
			"[SSsecurity_level.current_security_level.elevating_to_announcement]\n\n\
				A summary has been copied and printed to all communications consoles.",
			"Security level elevated.",
			ANNOUNCER_INTERCEPT,
			color_override = SSsecurity_level.current_security_level.announcement_color,
		)
	else
		priority_announce(
			"A summary of the station's situation has been copied and printed to all communications consoles.",
			"Security Report",
			SSstation.announcer.get_rand_report_sound(),
		)

#endif

	return .

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
#undef COMMUNICATION_COOLDOWN_MEETING
