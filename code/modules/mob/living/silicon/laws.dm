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

/mob/living/silicon/ai/make_laws()
	. = ..()
	for(var/obj/machinery/ai_law_rack/core/law_rack as anything in SSmachines.get_machines_by_type(/obj/machinery/ai_law_rack/core))
		if(law_rack.linked)
			continue
		if(!is_valid_z_level(get_turf(law_rack), get_turf(src)))
			continue
		law_rack.link_silicon(src)

	for(var/law in laws.inherent)
		lawcheck += law

	// melbert todo : fuck you
	var/datum/job/human_ai_job = SSjob.get_job(JOB_HUMAN_AI)
	if(human_ai_job && human_ai_job.current_positions && !laws.zeroth_borg)
		laws.zeroth_borg = "Follow the orders of Big Brother."
		laws.protected_zeroth = TRUE
