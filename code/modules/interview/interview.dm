/**
 * Represents a new-player interview form
 *
 * Represents a new-player interview form, enabled by configuration to require
 * players with low playtime to request access to the server. To do so, they will
 * out a brief questionnaire, and are otherwise unable to do anything while they
 * wait for a response.
 */
/datum/interview
	/// Unique ID of the interview
	var/id
	/// Atomic ID for incrementing unique IDs
	var/static/atomic_id = 0
	/// The /client who owns this interview, the intiator
	var/client/owner
	/// The Ckey of the owner, used for when a client could disconnect
	var/owner_ckey
	/// The welcome message shown at the top of the interview panel
	var/welcome_message
	/// The questions to display on the questionnaire of the interview
	var/list/questions
	/// The stored responses, will be filled as the questionnaire is answered
	var/list/responses = list()
	/// Boolean operator controlling if the questionnaire's contents can be edited
	var/read_only = FALSE
	/// Integer that contains the current position in the interview queue, used for rendering
	var/pos_in_queue
	/// Contains the state of the form, used for rendering and sanity checking
	var/status = INTERVIEW_PENDING

/datum/interview/New(client/interviewee)
	if(!interviewee)
		qdel(src)
		return
	id = ++atomic_id
	owner = interviewee
	owner_ckey = owner.ckey
	questions = CONFIG_GET(str_list/interview_questions)
	responses.len = questions.len
	welcome_message = CONFIG_GET(string/interview_welcome_msg)

/**
 * Approves the interview, forces reconnect of owner if relevant.
 *
 * Approves the interview, and if relevant will force the owner to reconnect so that they have the proper
 * verbs returned to them.
 * Arguments:
 * * approved_by - The user who approved the interview, used for logging
 */
/datum/interview/proc/approve(client/approved_by)
	status = INTERVIEW_APPROVED
	read_only = TRUE
	GLOB.interviews.approved_ckeys |= owner_ckey
	GLOB.interviews.close_interview(src)
	log_admin_private("[key_name(approved_by)] has approved interview #[id] for [owner_ckey][!owner ? "(DC)": ""].")
	message_admins(span_adminnotice("[key_name(approved_by)] has approved [link_self()] for [owner_ckey][!owner ? "(DC)": ""]."))
	if (owner)
		SEND_SOUND(owner, sound('sound/effects/adminhelp.ogg'))
		to_chat(owner, "<font color='red' size='4'><b>-- Interview Update --</b></font>" \
			+ "\n[span_adminsay("Your interview was approved, you will now be reconnected in 5 seconds.")]", confidential = TRUE)
		addtimer(CALLBACK(src, PROC_REF(reconnect_owner)), 5 SECONDS)

/**
 * Denies the interview and adds the owner to the cooldown for new interviews.
 *
 * Arguments:
 * * denied_by - The user who denied the interview, used for logging
 */
/datum/interview/proc/deny(client/denied_by)
	status = INTERVIEW_DENIED
	read_only = TRUE
	GLOB.interviews.close_interview(src)
	GLOB.interviews.cooldown_ckeys |= owner_ckey
	log_admin_private("[key_name(denied_by)] has denied interview #[id] for [owner_ckey][!owner ? "(DC)": ""].")
	message_admins(span_adminnotice("[key_name(denied_by)] has denied [link_self()] for [owner_ckey][!owner ? "(DC)": ""]."))
	addtimer(CALLBACK(GLOB.interviews, TYPE_PROC_REF(/datum/interview_manager, release_from_cooldown), owner_ckey), 18 SECONDS)
	if (owner)
		SEND_SOUND(owner, sound('sound/effects/adminhelp.ogg'))
		to_chat(owner, "<font color='red' size='4'><b>-- Interview Update --</b></font>" \
			+ "\n<span class='adminsay'>Unfortunately your interview was denied. Please try submitting another questionnaire." \
			+ " You may do this in three minutes.</span>", confidential = TRUE)

/**
 * Forces client to reconnect, used in the callback from approval
 */
/datum/interview/proc/reconnect_owner()
	if (!owner)
		return
	winset(owner, null, "command=.reconnect")

/**
 * Verb for opening the existing interview, or if relevant creating a new interview if possible.
 */
/mob/dead/new_player/proc/open_interview()
	set name = "Open Interview"
	set category = "Interview"
	var/mob/dead/new_player/M = usr
	if (M?.client?.interviewee)
		var/datum/interview/I = GLOB.interviews.interview_for_client(M.client)
		if (I) // we can be returned nothing if the user is on cooldown
			I.ui_interact(M)
		else
			to_chat(usr, "<span class='adminsay'>You are on cooldown for interviews. Please" \
				+ " wait at least 3 minutes before starting a new questionnaire.</span>", confidential = TRUE)

/datum/interview/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Interview")
		ui.open()

/datum/interview/ui_state(mob/user)
	if(check_rights_for(user.client, R_ADMIN))
		return GLOB.always_state
	return GLOB.new_player_state

/datum/interview/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return
	switch(action)
		if ("update_answer")
			if (!read_only)
				responses[text2num(params["qidx"])] = copytext_char(params["answer"], 1, 501) // byond indexing moment
				. = TRUE
		if ("submit")
			if (!read_only)
				read_only = TRUE
				GLOB.interviews.enqueue(src)
				. = TRUE
		if ("approve")
			if (usr.client?.holder && status == INTERVIEW_PENDING)
				src.approve(usr)
				. = TRUE
		if ("deny")
			if (usr.client?.holder && status == INTERVIEW_PENDING)
				src.deny(usr)
				. = TRUE
		if ("adminpm")
			if (usr.client?.holder && owner)
				usr.client.cmd_admin_pm(owner, null)
		if("check_centcom")
			if(usr.client?.holder && owner)
				usr.client?.holder.open_centcom_bans(owner_ckey)

/datum/interview/ui_data(mob/user)
	. = list(
		"welcome_message" = welcome_message,
		"questions" = list(),
		"read_only" = read_only,
		"queue_pos" = pos_in_queue,
		"is_admin" = !!(user?.client && user.client.holder),
		"status" = status,
		"connected" = !!owner,
	)
	if(CONFIG_GET(string/centcom_ban_db))
		. += list(
			"centcom_connected" = TRUE,
			"has_permabans" = user.client.holder.check_centcom_permabans(owner_ckey),
		)
	else
		. += list(
			"centcom_connected" = FALSE,
			"has_permabans" = FALSE,
		)
	for (var/i in 1 to questions.len)
		var/list/data = list(
			"qidx" = i,
			"question" = questions[i],
			"response" = responses.len < i ? null : responses[i]
		)
		.["questions"] += list(data)

/**
 * Generates a clickable link to open this interview
 */
/datum/interview/proc/link_self()
	return "<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];interview=[REF(src)]'>Interview #[id]</a>"
