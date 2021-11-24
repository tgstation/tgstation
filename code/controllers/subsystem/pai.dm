SUBSYSTEM_DEF(pai)
	name = "pAI"

	flags = SS_NO_INIT|SS_NO_FIRE

	var/list/candidates = list()
	var/ghost_spam = FALSE
	var/spam_delay = 100
	var/list/pai_card_list = list()

/datum/pai_candidate
	var/name
	var/key
	var/description
	var/comments
	var/ready = FALSE

/datum/controller/subsystem/pai/proc/findPAI(/obj/item/pai_card/pai, mob/user)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Due to growing incidents of SELF corrupted independent artificial intelligences, freeform personality devices have been temporarily banned in this sector."))
		return
	if(!ghost_spam)
		ghost_spam = TRUE
		for(var/mob/dead/observer/ghost in GLOB.player_list)
			if(!ghost.key)
				continue
			if(!(ROLE_PAI in ghost.client.prefs.be_special))
				continue
			to_chat(ghost, span_ghostalert("[user] is requesting a pAI personality! Use the pAI button to submit yourself as one."))
		addtimer(CALLBACK(src, .proc/spam_again), spam_delay)
	var/list/available = list()
	for(var/datum/pai_candidate/checked_candidate in SSpai.candidates)
		available.Add(check_ready(checked_candidate))

/datum/controller/subsystem/pai/proc/recruitWindow(mob/user)
	var/datum/pai_candidate/candidate
	for(var/datum/pai_candidate/checked_candidate in candidates)
		if(checked_candidate.key == user.key)
			candidate = checked_candidate
	if(!candidate)
		candidate = new /datum/pai_candidate()
		candidate.key = user.key
		candidates.Add(candidate)
	ui_interact()

/datum/controller/subsystem/pai/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiSubmit", name)
		ui.open()

/datum/controller/subsystem/pai/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("submit")
			var/datum/pai_candidate/candidate = locate(params["candidate"]) in candidates
			if(candidate)
				candidate.name = params["name"]
				candidate.key = usr.ckey
				candidate.description = params["description"]
				candidate.ready = TRUE
				for(var/obj/item/paicard/paicard in pai_card_list)
					if(!paicard.pai)
						paicard.alertUpdate()
	return

/datum/controller/subsystem/pai/proc/spam_again()
	ghost_spam = FALSE

/datum/controller/subsystem/pai/proc/check_ready(datum/pai_candidate/C)
	if(!C.ready)
		return FALSE
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.key == C.key)
			return C
	return FALSE

