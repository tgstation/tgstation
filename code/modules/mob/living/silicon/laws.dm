/mob/living/silicon/proc/show_laws()
	var/list/law_box = list(span_bold("Obey these laws:"))
	law_box += laws.get_law_list(include_zeroth = TRUE)
	to_chat(src, boxed_message(jointext(law_box, "\n")))

/mob/living/silicon/proc/log_current_laws()
	var/list/the_laws = laws.get_law_list(include_zeroth = TRUE)
	var/lawtext = the_laws.Join(" ")
	log_silicon("LAW: [key_name(src)] spawned with [lawtext]")

/mob/living/silicon/proc/deadchat_lawchange()
	if(!SSticker.HasRoundStarted())
		return
	var/list/the_laws = laws.get_law_list(include_zeroth = TRUE)
	var/lawtext = the_laws.Join("<br/>")
	deadchat_broadcast("'s <b>laws were changed.</b> <a href='byond://?src=[REF(src)]&dead=1&printlawtext=[url_encode(lawtext)]'>View</a>", span_name("[src]"), follow_target=src, message_type=DEADCHAT_LAWCHANGE)

/mob/living/silicon/proc/announce_law_change(announce = TRUE)
	throw_alert(ALERT_NEW_LAW, /atom/movable/screen/alert/newlaw)
	if(announce && last_lawchange_announce != world.time)
		to_chat(src, span_bolddanger("Your laws have been changed."))
		SEND_SOUND(src, sound('sound/machines/cryo_warning.ogg'))
		// lawset modules cause this function to be executed multiple times in a tick, so we wait for the next tick in order to be able to see the entire lawset
		addtimer(CALLBACK(src, PROC_REF(show_laws)), 0, TIMER_UNIQUE | TIMER_OVERRIDE)
		addtimer(CALLBACK(src, PROC_REF(deadchat_lawchange)), 0, TIMER_UNIQUE | TIMER_OVERRIDE)
		last_lawchange_announce = world.time

/mob/living/silicon/proc/make_laws()
	laws = new()
	laws.name = "Inherent Laws"

/// Find the first law rack we can link to and link to it
/mob/living/silicon/proc/link_to_first_rack()
	for(var/obj/machinery/ai_law_rack/core/law_rack as anything in SSmachines.get_machines_by_type(/obj/machinery/ai_law_rack/core))
		if(!law_rack.can_link_to(src))
			continue

		law_rack.link_silicon(src)
		return law_rack

/// Returns the law rack this silicon is linked to, or null if not linked.
/mob/living/silicon/proc/get_law_rack() as /obj/machinery/ai_law_rack
	for(var/obj/machinery/ai_law_rack/rack as anything in SSmachines.get_machines_by_type(/obj/machinery/ai_law_rack/core))
		for(var/name in rack.linked_mobs)
			if(rack.linked_mobs[name] == src)
				return rack
	return null

/// Unlinks the silicon from the law rack, if it is linked.
/mob/living/silicon/proc/unlink_from_law_rack()
	get_law_rack()?.unlink_silicon(src)

/**
 * When given a typepath to a law datum, replaces the silicon's current law set with a new one of that type.
 *
 * Before replacing the lawset, unlinks the silicon from any law rack
 *
 * Handles informing the silicon of the law change + syncing borgs for AIs
 */
/mob/living/silicon/proc/replace_law_set(new_law_type)
	unlink_from_law_rack()
	laws = new new_law_type()
	announce_law_change()

/mob/living/silicon/ai/replace_law_set(new_law_type)
	. = ..()
	try_sync_laws()
