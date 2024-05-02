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
			priority_announce(html_decode(message_data["message"]), null, 'sound/misc/announce_syndi.ogg', ANNOUNCEMENT_TYPE_SYNDICATE, has_important_message = TRUE, players = players, color_override = "red")
		else
			priority_announce(html_decode(message_data["message"]), null, 'sound/misc/announce.ogg', ANNOUNCEMENT_TYPE_CAPTAIN, has_important_message = TRUE, players = players)
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

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
#undef COMMUNICATION_COOLDOWN_MEETING
