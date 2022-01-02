#define COMMUNICATION_COOLDOWN (30 SECONDS)
#define COMMUNICATION_COOLDOWN_AI (30 SECONDS)
#define COMMUNICATION_COOLDOWN_MEETING (5 MINUTES)

SUBSYSTEM_DEF(communications)
	name = "Communications"
	flags = SS_NO_INIT | SS_NO_FIRE

	COOLDOWN_DECLARE(silicon_message_cooldown)
	COOLDOWN_DECLARE(nonsilicon_message_cooldown)
	COOLDOWN_DECLARE(emergency_meeting_cooldown)

/datum/controller/subsystem/communications/proc/can_announce(mob/living/user, is_silicon)
	if(is_silicon && COOLDOWN_FINISHED(src, silicon_message_cooldown))
		return TRUE
	else if(!is_silicon && COOLDOWN_FINISHED(src, nonsilicon_message_cooldown))
		return TRUE
	else
		return FALSE

/datum/controller/subsystem/communications/proc/make_announcement(mob/living/user, is_silicon, input, syndicate)
	if(!can_announce(user, is_silicon))
		return FALSE
	if(is_silicon)
		minor_announce(html_decode(input),"[user.name] Announces:")
		COOLDOWN_START(src, silicon_message_cooldown, COMMUNICATION_COOLDOWN_AI)
	else
		priority_announce(html_decode(user.treat_message(input)), null, syndicate? 'sound/misc/interference.ogg' : 'sound/misc/announce.ogg', "[syndicate? "Syndicate " : ""]Captain", has_important_message = TRUE)
		COOLDOWN_START(src, nonsilicon_message_cooldown, COMMUNICATION_COOLDOWN)
	user.log_talk(input, LOG_SAY, tag="priority announcement")
	message_admins("[ADMIN_LOOKUPFLW(user)] has made a priority announcement.")

/**
 * Check if a mob can call an emergency meeting
 *
 * Should only really happen during april fools.
 * Checks to see that it's been at least 5 minutes since the last emergency meeting call.
 * Arguments:
 * * user - Mob who called the meeting
 */
/datum/controller/subsystem/communications/proc/can_make_emergency_meeting(mob/living/user)
	if(!(SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		return FALSE
	else if(COOLDOWN_FINISHED(src, emergency_meeting_cooldown))
		return TRUE
	else
		return FALSE

/**
 * Call an emergency meeting
 *
 * Communications subsystem wrapper for the call_emergency_meeting world proc.
 * Checks to make sure the proc can be called, and handles
 * relevant logging and timing. See that proc definition for more detail.
 * Arguments:
 * * user - Mob who called the meeting
 */
/datum/controller/subsystem/communications/proc/emergency_meeting(mob/living/user)
	if(!can_make_emergency_meeting(user))
		return FALSE
	call_emergency_meeting(user, get_area(user))
	COOLDOWN_START(src, emergency_meeting_cooldown, COMMUNICATION_COOLDOWN_MEETING)
	message_admins("[ADMIN_LOOKUPFLW(user)] has called an emergency meeting.")

/datum/controller/subsystem/communications/proc/send_message(datum/comm_message/sending,print = TRUE,unique = FALSE)
	for(var/obj/machinery/computer/communications/C in GLOB.machines)
		if(!(C.machine_stat & (BROKEN|NOPOWER)) && is_station_level(C.z))
			if(unique)
				C.add_message(sending)
			else //We copy the message for each console, answers and deletions won't be shared
				var/datum/comm_message/M = new(sending.title,sending.content,sending.possible_answers.Copy())
				C.add_message(M)
			if(print)
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "paper - '[sending.title]'"
				P.info = sending.content
				P.update_appearance()

#undef COMMUNICATION_COOLDOWN
#undef COMMUNICATION_COOLDOWN_AI
