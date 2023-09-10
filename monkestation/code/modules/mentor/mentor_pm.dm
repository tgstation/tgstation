/// Takes input from /client/Topic and sends them a PM, fetching messages if needed. src is the sender and chosen_client is the target client
/client/proc/cmd_mentor_pm(whom, msg)
	var/client/chosen_client
	if(ismob(whom))
		var/mob/potential_mobs = whom
		chosen_client = potential_mobs.client
	else if(istext(whom))
		chosen_client = GLOB.directory[whom]
	else if(istype(whom, /client))
		chosen_client = whom
	if(chosen_client.prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<span class='danger'>Error: MentorPM: You are muted from Mentorhelps. (muted).</span>",
			confidential = TRUE)
		return
	if(!chosen_client)
		if(is_mentor())
			to_chat(src,
				type = MESSAGE_TYPE_MODCHAT,
				html = "<font color='red'>Error: Mentor-PM: Client not found.</font>",
				confidential = TRUE)
		else
			/// Mentor we are replying to left. Mentorhelp instead.
			mentorhelp(msg)
		return

	/// Get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message") as text|null

		if(!msg)
			return

		if(!chosen_client)
			if(is_mentor())
				to_chat(src,
					type = MESSAGE_TYPE_MODCHAT,
					html = "<font color='red'>Error: Mentor-PM: Client not found.</font>",
					confidential = TRUE)
			else
				/// Mentor we are replying to has vanished, Mentorhelp instead
				mentorhelp(msg)
				return

		/// Neither party is a mentor, they shouldn't be PMing!
		if(!chosen_client.is_mentor() && !is_mentor())
			return

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return

	log_mentor("Mentor PM: [key_name(src)]->[key_name(chosen_client)]: [msg]")

	msg = emoji_parse(msg)
	chosen_client << 'sound/items/bikehorn.ogg'
	if(chosen_client.is_mentor())
		if(is_mentor())
			/// Both are Mentors
			to_chat(chosen_client,
				type = MESSAGE_TYPE_MODCHAT,
				html = "<font color='purple'>Mentor PM from-<b>[key_name_mentor(src, chosen_client, TRUE, FALSE)]</b>: <span class='message linkify'>[msg]</span></font>",
				confidential = TRUE)
			to_chat(src,
				type = MESSAGE_TYPE_MODCHAT,
				html = "<font color='green'>Mentor PM to-<b>[key_name_mentor(chosen_client, chosen_client, TRUE, FALSE)]</b>: <span class='message linkify'>[msg]</span></font>",
				confidential = TRUE)
		else
			/// Sender is a Non-Mentor
			to_chat(chosen_client,
				type = MESSAGE_TYPE_MODCHAT,
				html = "<font color='purple'>Reply PM from-<b>[key_name_mentor(src, chosen_client, TRUE, FALSE)]</b>: <span class='message linkify'>[msg]</span></font>",
				confidential = TRUE)
			to_chat(src,
				type = MESSAGE_TYPE_MODCHAT,
				html = "<font color='green'>Mentor PM to-<b>[key_name_mentor(chosen_client, chosen_client, TRUE, FALSE)]</b>: <span class='message linkify'>[msg]</span></font>",
				confidential = TRUE)

	else
		if(is_mentor())
			/// Reciever is a Non-Mentor - Left unsorted so people that Mentorhelp with Mod chat off will still get it, otherwise they'll complain.
			to_chat(chosen_client, "<font color='purple'>Mentor PM from-<b>[key_name_mentor(src, chosen_client, TRUE, FALSE, FALSE)]</b>: [msg]</font>")
			to_chat(src,
				type = MESSAGE_TYPE_MODCHAT,
				html = "<font color='green'>Mentor PM to-<b>[key_name_mentor(chosen_client, chosen_client, TRUE, FALSE)]</b>: <span class='message linkify'>[msg]</span></font>",
				confidential = TRUE)

	/// We don't use message_Mentors here because the sender/receiver might get it too
	for(var/client/honked_clients in GLOB.mentors | GLOB.admins)
		/// Check client/honked_clients is an Mentor and isn't the Sender/Recipient
		if(honked_clients.key!=key && honked_clients.key!=chosen_client.key)
			to_chat(honked_clients,
				type = MESSAGE_TYPE_MODCHAT,
				html = "<B><font color='green'>Mentor PM: [key_name_mentor(src, honked_clients, FALSE, FALSE)]-&gt;[key_name_mentor(chosen_client, honked_clients, FALSE, FALSE)]:</B> <font color = #5c00e6> <span class='message linkify'>[msg]</span></font>",
				confidential = TRUE)
