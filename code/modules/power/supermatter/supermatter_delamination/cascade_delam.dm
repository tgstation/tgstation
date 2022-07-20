/datum/sm_delam_strat/cascade

/datum/sm_delam_strat/cascade/can_select(obj/machinery/power/supermatter_crystal/sm)
	var/total_moles = sm.absorbed_gasmix.total_moles()
	if(total_moles < MOLE_PENALTY_THRESHOLD / sm.absorption_ratio)
		return FALSE
	for (var/gas_path in list(/datum/gas/antinoblium, /datum/gas/hypernoblium))
		var/percent = sm.absorbed_gasmix.gases[gas_path] / total_moles
		if(!percent || percent < 0.4)
			return FALSE
	return TRUE
	
/datum/sm_delam_strat/cascade/delam_progress(obj/machinery/power/supermatter_crystal/sm)	
	. = ..()
	if(!.)
		return FALSE
	sm.radio.talk_into(
		sm,
		"DANGER: HYPERSTRUCTURE OSCILLATION FREQUENCY OUT OF BOUNDS.", 
		sm.damage > sm.emergency_point
	)
	var/list/messages = list(
		"Space seems to be shifting around you...",
		"You hear a high-pitched ringing sound.",
		"You feel tingling going down your back.",
		"Something feels very off.",
		"A drowning sense of dread washes over you.",
	)
	for(var/mob/victim as anything in GLOB.player_list)
		to_chat(victim, span_danger(pick(messages)))

/datum/sm_delam_strat/cascade/on_select(obj/machinery/power/supermatter_crystal/sm)
	log_game("[sm] has begun a cascade.")
	message_admins("[sm] has begun a cascade. [ADMIN_JMP(sm)]")
	sm.investigate_log("has begun a cascade.", INVESTIGATE_ENGINE)

	sm.warp = new(sm)
	sm.vis_contents += sm.warp
	animate(sm.warp, time = 1, transform = matrix().Scale(0.5,0.5))
	animate(time = 9, transform = matrix())

	addtimer(CALLBACK(src, .proc/announce_cascade, sm), 2 MINUTES)

/datum/sm_delam_strat/cascade/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	log_game("[sm] has stopped its cascade.")
	message_admins("[sm] has stopped its cascade. [ADMIN_JMP(sm)]")
	sm.investigate_log("has stopped its cascade.", INVESTIGATE_ENGINE)

	sm.vis_contents -= sm.warp
	QDEL_NULL(sm.warp)

	addtimer(CALLBACK(src, .proc/announce_cascade, sm), 2 MINUTES)

/datum/sm_delam_strat/count_down(obj/machinery/power/supermatter_crystal/sm)
	set waitfor = FALSE

	var/obj/item/radio/radio = sm.radio

	if(sm.final_countdown) // We're already doing it go away
		stack_trace("SM [sm] told to delaminate again while it's already delaminating.")
		return
	sm.final_countdown = TRUE
	sm.update_appearance()

	radio.talk_into(
		sm,
		"CRYSTAL DELAMINATION IMMINENT. The supermatter has reached critical integrity failure. Harmonic frequency limits exceeded. Causality destabilization field could not be engaged.", 
		sm.emergency_channel
	)

	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		var/message
		var/healed = FALSE
		
		if(sm.damage < sm.explosion_point) // Cutting it a bit close there engineers
			message = "Crystalline hyperstructure returning to safe operating parameters. Harmonic frequency restored within emergency bounds. Anti-resonance filter initiated."
			healed = TRUE
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(1 SECONDS)
			continue
		else if(i > 50)
			message = "[DisplayTimeText(i, TRUE)] remain before resonance-induced stabilization."
		else
			message = "[i*0.1]..."

		radio.talk_into(sm, message, sm.emergency_channel)
		
		if(healed)
			sm.final_countdown = FALSE
			sm.update_appearance()
			return // delam averted
		sleep(1 SECONDS)

	delaminate(sm)

/datum/sm_delam_strat/cascade/proc/delaminate(obj/machinery/power/supermatter_crystal/sm)
	effect_explosion(sm)
	effect_emergency_state()
	effect_cascade_demoralize()
	priority_announce("A Type-C resonance shift event has occurred in your sector. Scans indicate local oscillation flux affecting spatial and gravitational substructure. \
		Multiple resonance hotspots have formed. Please standby.", "Nanotrasen Star Observation Association", ANNOUNCER_SPANOMALIES)
	sleep(2 SECONDS)
	effect_strand_shuttle()
	sleep(5 SECONDS)
	var/obj/cascade_portal/rift = effect_evac_rift()
	effect_crystal_mass(sm, rift)
	priority_announce("We have been hit by a sector-wide electromagnetic pulse. All of our systems are heavily damaged, including those \
		required for shuttle navigation. We can only reasonably conclude that a supermatter cascade is occurring on or near your station.\n\n\
		Evacuation is no longer possible by conventional means; however, we managed to open a rift near the [get_area_name(rift)]. \
		All personnel are hereby required to enter the rift by any means available.\n\n\
		[Gibberish("Retrieval of survivors will be conducted upon recovery of necessary facilities.", FALSE, 5)] \
		[Gibberish("Good luck--", FALSE, 25)]")

/datum/sm_delam_strat/cascade/proc/announce_cascade(obj/machinery/power/supermatter_crystal/sm)
	if(!can_select(sm))
		return FALSE
	priority_announce("Attention: Long range anomaly scans indicate abnormal quantities of harmonic flux originating from \
	a subject within [station_name()], a resonance collapse may occur.",
	"Nanotrasen Star Observation Association")
	return TRUE

/*
	message_admins("Exit rift at [rift_area] deleted. [ADMIN_JMP(rift_location)]")
	log_game("Bluespace Exit Rift at [rift_area] was deleted.")
	rift.investigate_log("was deleted.", INVESTIGATE_ENGINE)
	priority_announce("[Gibberish("The rift has been destroyed, we can no longer help you.", FALSE, 5)]")
	qdel(rift)

	sleep(25 SECONDS)

	priority_announce("Reports indicate formation of crystalline seeds following resonance shift event. \
		Rapid expansion of crystal mass proportional to rising gravitational force. \
		Matter collapse due to gravitational pull foreseeable.",
		"Nanotrasen Star Observation Association")
	
	sleep(25 SECONDS)

	priority_announce("[Gibberish("All attempts at evacuation have now ceased, and all assets have been retrieved from your sector.\n \
		To the remaining survivors of [station_name()], farewell.", FALSE, 5)]")

	if(SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		// special message for hijacks
		var/shuttle_msg = "Navigation protocol set to [SSshuttle.emergency.is_hijacked() ? "\[ERROR\]" : "backup route"]. \
			Reorienting bluespace vessel to exit vector. ETA 15 seconds."
		// garble the special message
		if(SSshuttle.emergency.is_hijacked())
			shuttle_msg = Gibberish(shuttle_msg, TRUE, 15)
		minor_announce(shuttle_msg, "Emergency Shuttle", TRUE)
		SSshuttle.emergency.setTimer(15 SECONDS)
	if(SSshuttle.emergency.mode != SHUTTLE_ESCAPE) // if the shuttle is enroute to centcom, we let the shuttle end the round
		addtimer(CALLBACK(src, .proc/the_end), 1 MINUTES)
*/
