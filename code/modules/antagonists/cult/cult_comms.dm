// Contains cult communion, guide, and cult master abilities

/datum/action/innate/cult
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

/datum/action/innate/cult/IsAvailable(feedback = FALSE)
	if(!IS_CULTIST(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/comm
	name = "Communion"
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
	button_icon_state = "cult_comms"

/datum/action/innate/cult/comm/IsAvailable(feedback = FALSE)
	if(isshade(owner) && IS_CULTIST(owner))
		return TRUE
	return ..()

/datum/action/innate/cult/comm/Activate()
	var/input = tgui_input_text(usr, "Message to tell to the other acolytes", "Voice of Blood")
	if(!input || !IsAvailable(feedback = TRUE))
		return

	var/list/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(usr) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")
	cultist_commune(usr, input)

/datum/action/innate/cult/comm/proc/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	user.whisper("O bidai nabora se[pick("'","`")]sma!", language = /datum/language/common)
	user.whisper(html_decode(message), filterproof = TRUE)
	var/title = "Acolyte"
	var/span = "cult italic"
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/cult/master))
		span = "cultlarge"
		title = "Master"
	else if(!ishuman(user))
		title = "Construct"
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(IS_CULTIST(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="cult")

/datum/action/innate/cult/comm/spirit
	name = "Spiritual Communion"
	desc = "Conveys a message from the spirit realm that all cultists can hear."

/datum/action/innate/cult/comm/spirit/IsAvailable(feedback = FALSE)
	if(IS_CULTIST(owner.mind.current))
		return TRUE
	return ..()

/datum/action/innate/cult/comm/spirit/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	my_message = span_cultboldtalic("The [user.name]: [message]")
	for(var/mob/player_list as anything in GLOB.player_list)
		if(IS_CULTIST(player_list))
			to_chat(player_list, my_message)
		else if(player_list in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(player_list, user)
			to_chat(player_list, "[link] [my_message]")

/datum/action/innate/cult/mastervote
	name = "Assert Leadership"
	button_icon_state = "cultvote"

/datum/action/innate/cult/mastervote/IsAvailable(feedback = FALSE)
	var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C || C.cult_team.cult_vote_called || !ishuman(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/mastervote/Activate()
	var/choice = tgui_alert(owner, "The mantle of leadership is heavy. Success in this role requires an expert level of communication and experience. Are you sure?",, list("Yes", "No"))
	if(choice == "Yes" && IsAvailable())
		var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
		pollCultists(owner,C.cult_team)

/proc/pollCultists(mob/living/Nominee,datum/team/cult/team) //Cult Master Poll
	if(world.time < CULT_POLL_WAIT)
		to_chat(Nominee, "It would be premature to select a leader while everyone is still settling in, try again in [DisplayTimeText(CULT_POLL_WAIT-world.time)].")
		return
	team.cult_vote_called = TRUE //somebody's trying to be a master, make sure we don't let anyone else try
	for(var/datum/mind/B in team.members)
		if(B.current)
			B.current.update_mob_action_buttons()
			if(!B.current.incapacitated())
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, span_cultlarge("Acolyte [Nominee] has asserted that [Nominee.p_theyre()] worthy of leading the cult. A vote will be called shortly."))
	sleep(10 SECONDS)
	var/list/asked_cultists = list()
	for(var/datum/mind/B in team.members)
		if(B.current && B.current != Nominee && !B.current.incapacitated())
			SEND_SOUND(B.current, 'sound/magic/exit_blood.ogg')
			asked_cultists += B.current
	var/list/yes_voters = poll_candidates("[Nominee] seeks to lead your cult, do you support [Nominee.p_them()]?", poll_time = 300, group = asked_cultists)
	if(QDELETED(Nominee) || Nominee.incapacitated())
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_mob_action_buttons()
				if(!B.current.incapacitated())
					to_chat(B.current,span_cultlarge("[Nominee] has died in the process of attempting to win the cult's support!"))
		return FALSE
	if(!Nominee.mind)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_mob_action_buttons()
				if(!B.current.incapacitated())
					to_chat(B.current,span_cultlarge("[Nominee] has gone catatonic in the process of attempting to win the cult's support!"))
		return FALSE
	if(LAZYLEN(yes_voters) <= LAZYLEN(asked_cultists) * 0.5)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_mob_action_buttons()
				if(!B.current.incapacitated())
					to_chat(B.current, span_cultlarge("[Nominee] could not win the cult's support and shall continue to serve as an acolyte."))
		return FALSE
	team.cult_master = Nominee
	var/datum/antagonist/cult/cultist = Nominee.mind.has_antag_datum(/datum/antagonist/cult)
	if (cultist)
		cultist.silent = TRUE
		cultist.on_removal()
	Nominee.mind.add_antag_datum(/datum/antagonist/cult/master)
	for(var/datum/mind/B in team.members)
		if(B.current)
			for(var/datum/action/innate/cult/mastervote/vote in B.current.actions)
				vote.Remove(B.current)
			if(!B.current.incapacitated())
				to_chat(B.current,span_cultlarge("[Nominee] has won the cult's support and is now their master. Follow [Nominee.p_their()] orders to the best of your ability!"))
	return TRUE

/datum/action/innate/cult/master/IsAvailable(feedback = FALSE)
	if(!owner.mind || !owner.mind.has_antag_datum(/datum/antagonist/cult/master) || GLOB.cult_narsie)
		return FALSE
	return ..()

/datum/action/innate/cult/master/finalreck
	name = "Final Reckoning"
	desc = "A single-use spell that brings the entire cult to the master's location."
	button_icon_state = "sintouch"

/datum/action/innate/cult/master/finalreck/Activate()
	var/datum/antagonist/cult/antag = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!antag)
		return
	var/place = get_area(owner)
	var/datum/objective/eldergod/summon_objective = locate() in antag.cult_team.objectives
	if(place in summon_objective.summon_spots)//cant do final reckoning in the summon area to prevent abuse, you'll need to get everyone to stand on the circle!
		to_chat(owner, span_cultlarge("The veil is too weak here! Move to an area where it is strong enough to support this magic."))
		return
	for(var/i in 1 to 4)
		chant(i)
		var/list/destinations = list()
		for(var/turf/T in orange(1, owner))
			if(!T.is_blocked_turf(TRUE))
				destinations += T
		if(!LAZYLEN(destinations))
			to_chat(owner, span_warning("You need more space to summon your cult!"))
			return
		if(do_after(owner, 30, target = owner))
			for(var/datum/mind/B in antag.cult_team.members)
				if(B.current && B.current.stat != DEAD)
					var/turf/mobloc = get_turf(B.current)
					switch(i)
						if(1)
							new /obj/effect/temp_visual/cult/sparks(mobloc, B.current.dir)
							playsound(mobloc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
						if(2)
							new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, B.current.dir)
							playsound(mobloc, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
						if(3)
							new /obj/effect/temp_visual/dir_setting/cult/phase(mobloc, B.current.dir)
							playsound(mobloc, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
						if(4)
							playsound(mobloc, 'sound/magic/exit_blood.ogg', 100, TRUE)
							if(B.current != owner)
								var/turf/final = pick(destinations)
								if(istype(B.current.loc, /obj/item/soulstone))
									var/obj/item/soulstone/S = B.current.loc
									S.release_shades(owner)
								B.current.setDir(SOUTH)
								new /obj/effect/temp_visual/cult/blood(final)
								addtimer(CALLBACK(B.current, TYPE_PROC_REF(/mob/, reckon), final), 10)
		else
			return
	antag.cult_team.reckoning_complete = TRUE
	Remove(owner)

/mob/proc/reckon(turf/final)
	new /obj/effect/temp_visual/cult/blood/out(get_turf(src))
	forceMove(final)

/datum/action/innate/cult/master/finalreck/proc/chant(chant_number)
	switch(chant_number)
		if(1)
			owner.say("C'arta forbici!", language = /datum/language/common, forced = "cult invocation")
		if(2)
			owner.say("Pleggh e'ntrath!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 50, TRUE)
		if(3)
			owner.say("Barhah hra zar'garis!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 75, TRUE)
		if(4)
			owner.say("N'ath reth sh'yro eth d'rekkathnor!!!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 100, TRUE)

/datum/action/innate/cult/master/cultmark
	name = "Mark Target"
	desc = "Marks a target for the cult."
	button_icon_state = "cult_mark"
	click_action = TRUE
	enable_text = span_cult("You prepare to mark a target for your cult. <b>Click a target to mark them!</b>")
	disable_text = span_cult("You cease the marking ritual.")
	/// The duration of the mark itself
	var/cult_mark_duration = 90 SECONDS
	/// The duration of the cooldown for cult marks
	var/cult_mark_cooldown_duration = 2 MINUTES
	/// The actual cooldown tracked of the action
	COOLDOWN_DECLARE(cult_mark_cooldown)

/datum/action/innate/cult/master/cultmark/IsAvailable(feedback = FALSE)
	return ..() && COOLDOWN_FINISHED(src, cult_mark_cooldown)

/datum/action/innate/cult/master/cultmark/InterceptClickOn(mob/caller, params, atom/clicked_on)
	var/turf/caller_turf = get_turf(caller)
	if(!isturf(caller_turf))
		return FALSE

	if(!(clicked_on in view(7, caller_turf)))
		return FALSE

	return ..()

/datum/action/innate/cult/master/cultmark/do_ability(mob/living/caller, atom/clicked_on)
	var/datum/antagonist/cult/cultist = caller.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
	if(!cultist)
		CRASH("[type] was casted by someone without a cult antag datum.")

	var/datum/team/cult/cult_team = cultist.get_team()
	if(!cult_team)
		CRASH("[type] was casted by a cultist without a cult team datum.")

	if(cult_team.blood_target)
		to_chat(caller, span_cult("The cult has already designated a target!"))
		return FALSE

	if(cult_team.set_blood_target(clicked_on, caller, cult_mark_duration))
		unset_ranged_ability(caller, span_cult("The marking rite is complete! It will last for [DisplayTimeText(cult_mark_duration)] seconds."))
		COOLDOWN_START(src, cult_mark_cooldown, cult_mark_cooldown_duration)
		build_all_button_icons()
		addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), cult_mark_cooldown_duration + 1)
		return TRUE

	unset_ranged_ability(caller, span_cult("The marking rite failed!"))
	return TRUE

/datum/action/innate/cult/ghostmark //Ghost version
	name = "Blood Mark your Target"
	desc = "Marks whatever you are orbiting for the entire cult to track."
	button_icon_state = "cult_mark"
	check_flags = NONE
	/// The duration of the mark on the target
	var/cult_mark_duration = 60 SECONDS
	/// The cooldown between marks - the ability can be used in between cooldowns, but can't mark (only clear)
	var/cult_mark_cooldown_duration = 60 SECONDS
	/// The actual cooldown tracked of the action
	COOLDOWN_DECLARE(cult_mark_cooldown)

/datum/action/innate/cult/ghostmark/IsAvailable(feedback = FALSE)
	return ..() && isobserver(owner)

/datum/action/innate/cult/ghostmark/Activate()
	var/datum/antagonist/cult/cultist = owner.mind?.has_antag_datum(/datum/antagonist/cult, TRUE)
	if(!cultist)
		CRASH("[type] was casted by someone without a cult antag datum.")

	var/datum/team/cult/cult_team = cultist.get_team()
	if(!cult_team)
		CRASH("[type] was casted by a cultist without a cult team datum.")

	if(cult_team.blood_target)
		if(!COOLDOWN_FINISHED(src, cult_mark_cooldown))
			cult_team.unset_blood_target_and_timer()
			to_chat(owner, span_cultbold("You have cleared the cult's blood target!"))
			return TRUE

		to_chat(owner, span_cultbold("The cult has already designated a target!"))
		return FALSE

	if(!COOLDOWN_FINISHED(src, cult_mark_cooldown))
		to_chat(owner, span_cultbold("You aren't ready to place another blood mark yet!"))
		return FALSE

	var/atom/mark_target = owner.orbiting?.parent || get_turf(owner)
	if(!mark_target)
		return FALSE

	if(cult_team.set_blood_target(mark_target, owner, 60 SECONDS))
		to_chat(owner, span_cultbold("You have marked [mark_target] for the cult! It will last for [DisplayTimeText(cult_mark_duration)]."))
		COOLDOWN_START(src, cult_mark_cooldown, cult_mark_cooldown_duration)
		build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)
		addtimer(CALLBACK(src, PROC_REF(reset_button)), cult_mark_cooldown_duration + 1)
		return TRUE

	to_chat(owner, span_cult("The marking failed!"))
	return FALSE

/datum/action/innate/cult/ghostmark/update_button_name(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(COOLDOWN_FINISHED(src, cult_mark_duration))
		name = initial(name)
		desc = initial(desc)
	else
		name = "Clear the Blood Mark"
		desc = "Remove the Blood Mark you previously set."

	return ..()

/datum/action/innate/cult/ghostmark/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(COOLDOWN_FINISHED(src, cult_mark_duration))
		button_icon_state = initial(button_icon_state)
	else
		button_icon_state = "emp"

	return ..()

/datum/action/innate/cult/ghostmark/proc/reset_button()
	if(QDELETED(owner) || QDELETED(src))
		return

	SEND_SOUND(owner, 'sound/magic/enter_blood.ogg')
	to_chat(owner, span_cultbold("Your previous mark is gone - you are now ready to create a new blood mark."))
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

//////// ELDRITCH PULSE /////////

/datum/action/innate/cult/master/pulse
	name = "Eldritch Pulse"
	desc = "Seize upon a fellow cultist or cult structure and teleport it to a nearby location."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "arcane_barrage"
	click_action = TRUE
	enable_text = span_cult("You prepare to tear through the fabric of reality... <b>Click a target to sieze them!</b>")
	disable_text = span_cult("You cease your preparations.")
	/// Weakref to whoever we're currently about to toss
	var/datum/weakref/throwee_ref
	/// Cooldown of the ability
	var/pulse_cooldown_duration = 15 SECONDS
	/// The actual cooldown tracked of the action
	COOLDOWN_DECLARE(pulse_cooldown)

/datum/action/innate/cult/master/pulse/IsAvailable(feedback = FALSE)
	return ..() && COOLDOWN_FINISHED(src, pulse_cooldown)

/datum/action/innate/cult/master/pulse/InterceptClickOn(mob/living/caller, params, atom/clicked_on)
	var/turf/caller_turf = get_turf(caller)
	if(!isturf(caller_turf))
		return FALSE

	if(!(clicked_on in view(7, caller_turf)))
		return FALSE

	if(clicked_on == caller)
		return FALSE

	return ..()

/datum/action/innate/cult/master/pulse/do_ability(mob/living/caller, atom/clicked_on)
	var/atom/throwee = throwee_ref?.resolve()

	if(QDELETED(throwee))
		to_chat(caller, span_cult("You lost your target!"))
		throwee = null
		throwee_ref = null
		return FALSE

	if(throwee)
		if(get_dist(throwee, clicked_on) >= 16)
			to_chat(caller, span_cult("You can't teleport [clicked_on.p_them()] that far!"))
			return FALSE

		var/turf/throwee_turf = get_turf(throwee)

		playsound(throwee_turf, 'sound/magic/exit_blood.ogg')
		new /obj/effect/temp_visual/cult/sparks(throwee_turf, caller.dir)
		throwee.visible_message(
			span_warning("A pulse of magic whisks [throwee] away!"),
			span_cult("A pulse of blood magic whisks you away..."),
		)

		if(!do_teleport(throwee, clicked_on, channel = TELEPORT_CHANNEL_CULT))
			to_chat(caller, span_cult("The teleport fails!"))
			throwee.visible_message(
				span_warning("...Except they don't go very far"),
				span_cult("...Except you don't appear to have moved very far."),
			)
			return FALSE

		throwee_turf.Beam(clicked_on, icon_state = "sendbeam", time = 0.4 SECONDS)
		new /obj/effect/temp_visual/cult/sparks(get_turf(clicked_on), caller.dir)
		throwee.visible_message(
			span_warning("[throwee] appears suddenly in a pulse of magic!"),
			span_cult("...And you appear elsewhere."),
		)

		COOLDOWN_START(src, pulse_cooldown, pulse_cooldown_duration)
		to_chat(caller, span_cult("A pulse of blood magic surges through you as you shift [throwee] through time and space."))
		caller.click_intercept = null
		throwee_ref = null
		build_all_button_icons()
		addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), pulse_cooldown_duration + 1)

		return TRUE

	else
		if(isliving(clicked_on))
			var/mob/living/living_clicked = clicked_on
			if(!IS_CULTIST(living_clicked))
				return FALSE
			SEND_SOUND(caller, sound('sound/weapons/thudswoosh.ogg'))
			to_chat(caller, span_cultbold("You reach through the veil with your mind's eye and seize [clicked_on]! <b>Click anywhere nearby to teleport [clicked_on.p_them()]!</b>"))
			throwee_ref = WEAKREF(clicked_on)
			return TRUE

		if(istype(clicked_on, /obj/structure/destructible/cult))
			to_chat(caller, span_cultbold("You reach through the veil with your mind's eye and lift [clicked_on]! <b>Click anywhere nearby to teleport it!</b>"))
			throwee_ref = WEAKREF(clicked_on)
			return TRUE

	return FALSE
