
ADMIN_VERB(dsay, "Dsay", "Speaks to deadchat, using your stealth ckey if applicable", NONE, VERB_CATEGORY_GAME, message as text)
	if(!length(message))
		return

	if(user.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, span_danger("You cannot send DSAY messages (muted)."))
		return

	if(user.handle_spam_prevention(message, MUTE_DEADCHAT))
		return

	message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	user.mob.log_talk(message, LOG_DSAY)

	var/rank_name = user.holder.rank_names()
	var/admin_name = user.ckey
	if(user.holder.fakekey)
		rank_name = pick(strings("admin_nicknames.json", "ranks", "config"))
		admin_name = pick(strings("admin_nicknames.json", "names", "config"))

	var/name_and_rank = "[span_tooltip(rank_name, "STAFF")] ([admin_name])"
	deadchat_broadcast("[span_prefix("DEAD:")] [name_and_rank] says, <span class='message'>\"[emoji_parse(message)]\"</span>")

/client/proc/get_dead_say()
	var/msg = input(src, null, "dsay \"text\"") as text|null

	if (isnull(msg))
		return

	SSadmin_verbs.dynamic_invoke_verb(src, /datum/admin_verb_holder/dsay, msg)
