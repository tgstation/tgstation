//print an error message to world.log
/proc/error(msg)
	world.log << "## ERROR: [msg]"

/*
 * print a warning message to world.log
 */
/* see setup.dm
#define WARNING(MSG) to_chat(world, "##WARNING: [MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
#define warning(msg) world.log << "## WARNING: [msg]"
#define testing(msg) world.log << "## TESTING: [msg]"
#define log_game(text) diary << html_decode("\[[time_stamp()]]GAME: [text]")

#define log_vote(text) diary << html_decode("\[[time_stamp()]]VOTE: [text]")

#define log_access(text) diary << html_decode("\[[time_stamp()]]ACCESS: [text]")

#define log_say(text) diary << html_decode("\[[time_stamp()]]SAY: [text]")

#define log_ooc(text) diary << html_decode("\[[time_stamp()]]OOC: [text]")

#define log_whisper(text) diary << html_decode("\[[time_stamp()]]WHISPER: [text]")

#define log_cultspeak(text) diary << html_decode("\[[time_stamp()]]CULT: [text]")

#define log_narspeak(text) diary << html_decode("\[[time_stamp()]]NARSIE: [text]")

#define log_emote(text) diary << html_decode("\[[time_stamp()]]EMOTE: [text]")

#define log_attack(text) diaryofmeanpeople << html_decode("\[[time_stamp()]]ATTACK: [text]")

#define log_adminsay(text) diary << html_decode("\[[time_stamp()]]ADMINSAY: [text]")

#define log_adminwarn(text) diary << html_decode("\[[time_stamp()]]ADMINWARN: [text]")
#define log_pda(text) diary << html_decode("\[[time_stamp()]]PDA: [text]")
*/

/proc/log_admin(raw_text)
	var/text_to_log = "\[[time_stamp()]]ADMIN: [raw_text]"

	admin_log.Add(text_to_log)

	if(config.log_admin)
		diary << html_decode(text_to_log)

	if(config.log_admin_only)
		admin_diary << html_decode(text_to_log)

/proc/log_debug(text)
	if (config.log_debug)
		diary << html_decode("\[[time_stamp()]]DEBUG: [text]")

	for(var/client/C in admins)
		if(C.prefs.toggles & CHAT_DEBUGLOGS)
			to_chat(C, "DEBUG: [text]")




/proc/log_adminghost(text)
	if (config.log_adminghost)
		diary << html_decode("\[[time_stamp()]]ADMINGHOST: [text]")
		message_admins("\[ADMINGHOST\] [text]")

/proc/log_ghost(text)
	if (config.log_adminghost)
		diary << html_decode("\[[time_stamp()]]GHOST: [text]")
		message_admins("\[GHOST\] [text]")


/**
 * Helper proc to log attacks or similar events between two mobs.
 */
/proc/add_attacklogs(var/mob/user, var/mob/target, var/what_done, var/object = null, var/addition = null, var/admin_warn = TRUE)
	var/user_txt = (user ? "[user][user.ckey ? " ([user.ckey])" : ""]" : "\<NULL USER\>")
	var/target_txt = (target ? "[target][target.ckey ? " ([target.ckey])" : ""]" : "\<NULL TARGET\>")
	var/object_txt = (object ? " with \the [object]" : "")
	var/intent_txt = (user ? " (INTENT: [uppertext(user.a_intent)])" : "")
	var/addition_txt = (addition ? " ([addition])" : "")

	if (ismob(user))
		user.attack_log += text("\[[time_stamp()]\] <span class='danger'>Has [what_done] [target_txt][object_txt].[intent_txt][addition_txt]</span>")

	if (ismob(target))
		target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [what_done] by [user_txt][object_txt].[intent_txt][addition_txt]</font>")
		target.LAssailant = (iscarbon(user) ? user : null)

	var/log_msg = "<span class='danger'>[user_txt] [what_done] [target_txt][object_txt][intent_txt].</span>[addition_txt] ([formatJumpTo(user, "JMP")])"
	log_attack(log_msg)
	if (admin_warn)
		msg_admin_attack(log_msg)

/**
 * Helper proc to log detailed game events easier.
 *
 * @param user Subject of the action
 * @param what_done Description of the action that user has done (e.g. "toggled the PA to 3")
 * @param admin Whether to message the admins about this
 * @param tp_link Whether to add a jump link to the position of the action (i.e. user.loc)
 * @param tp_link_short Whether to make the jump link display 'JMP' instead of the area and coordinates
 * @param span_class What CSS class to use for the message.
 */
/proc/add_gamelogs(var/mob/user, var/what_done, var/admin = 1, var/tp_link = FALSE, var/tp_link_short = TRUE, var/span_class = "notice")
	var/user_text = (ismob(user) ? "[user] ([user.ckey])" : "<NULL USER>")
	var/link = (tp_link ? " ([formatJumpTo(user, (tp_link_short ? "JMP" : ""))])" : "")

	var/msg = "<span class='[span_class]'>[user_text] has [what_done].</span>[link]"
	log_game(msg)
	if (admin)
		message_admins(msg)

/**
 * Helper function to log reagent transfers, usually 'bad' ones.
 *
 * @param user The user that performed the transfer
 * @param source The item from which the reagents are transferred.
 * @param target The destination of the transfer
 * @param amount The amount of units transferred
 * @param reagent_names List of reagent names to log
 */
/proc/log_reagents(var/mob/user, var/source, var/target, var/amount, var/list/reagent_names)
	if (amount == 0)
		return

	if (reagent_names && reagent_names.len > 0)
		var/reagent_text = "<span class='danger'>[english_list(reagent_names)]</span>"
		add_gamelogs(user, "added [amount]u (inc. [reagent_text]) to \a [target] with \the [source]", admin = TRUE, tp_link = TRUE)
	else
		add_gamelogs(user, "added [amount]u to \a [target] with \the [source]", admin = TRUE, tp_link = FALSE)


/**
 * Standardized method for tracking startup times.
 */
/proc/log_startup_progress(var/message)
	to_chat(world, "<span class='danger'>[message]</span>")
	world.log << message
