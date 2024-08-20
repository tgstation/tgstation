/datum/action/bb/gear
	name = "Choose Gear"
	desc = "Choose a piece of gear of your choice. You can only pick one, and all teammates must agree."
	button_icon_state = "weapons"
	check_flags = AB_CHECK_CONSCIOUS
	var/static/list/choices

/datum/action/bb/gear/IsAvailable(feedback, post_choice = FALSE)
	. = ..()
	if(!.)
		return
	if(team.summoned_gear)
		if(feedback)
			owner.balloon_alert(owner, "already summoned gear!")
		return FALSE
	if(team.choosing_gear && !post_choice)
		if(feedback)
			owner.balloon_alert(owner, "someone is already trying to choose gear!")
		return FALSE
	if(!team.fully_recruited())
		if(feedback)
			owner.balloon_alert(owner, "need to fully recruit team!")
		return FALSE

/datum/action/bb/gear/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	if(team.chosen_gear)
		INVOKE_ASYNC(team, TYPE_PROC_REF(/datum/team/brother_team, summon_gear), owner)
	else
		team.choosing_gear = TRUE
		INVOKE_ASYNC(src, PROC_REF(choose_gear))

/datum/action/bb/gear/proc/choose_gear()
	team.update_action_icons()
	if(!choices)
		for(var/name in GLOB.bb_gear)
			var/datum/bb_gear/gear = GLOB.bb_gear[name]
			var/datum/radial_menu_choice/option = new
			option.name = gear.name
			option.info = gear.desc
			option.image = gear.preview()
			LAZYSET(choices, name, option)
	var/chosen = show_radial_menu(owner, owner, choices, uniqueid = "bb_gear_[REF(team)]", tooltips = TRUE)
	if(!chosen || !IsAvailable(feedback = TRUE, post_choice = TRUE))
		team.choosing_gear = FALSE
		team.update_action_icons()
		return
	var/datum/bb_gear/chosen_gear = GLOB.bb_gear[chosen]
	var/list/to_poll = list()
	for(var/datum/mind/member as anything in team.members)
		if(member == owner.mind || QDELETED(member.current) || QDELETED(member.current.client) || member.current.stat == DEAD)
			continue
		to_poll += member.current
	var/list/agreed = SSpolling.poll_candidates(
		"[owner.mind.name || owner.real_name] wishes to choose [chosen_gear.name] as your team's gear. Do you agree?",
		group = to_poll,
		alert_pic = chosen_gear.preview(),
		role_name_text = "Blood Brother Gear",
		custom_response_messages = list(
			POLL_RESPONSE_SIGNUP = "You have agreed to choose [chosen_gear.name] as your team's gear.",
			POLL_RESPONSE_ALREADY_SIGNED = "You have already voted on your choice of gear!",
			POLL_RESPONSE_NOT_SIGNED = "You aren't signed up for this!",
			POLL_RESPONSE_TOO_LATE_TO_UNREGISTER = "It's too late to take back your vote now!",
			POLL_RESPONSE_UNREGISTERED = "You have taken back your vote for [chosen_gear.name]. You can re-vote again before the poll ends.",
		)
	)
	team.choosing_gear = FALSE
	if(length(agreed) != length(to_poll))
		SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
		to_chat(owner, span_warning("Your team didn't agree on the summoning [chosen_gear.name]!"), type = MESSAGE_TYPE_INFO)
		team.update_action_icons()
		return
	team.chosen_gear = chosen_gear
	team.update_action_icons()
	for(var/datum/mind/brother as anything in team.members)
		to_chat(brother.current, span_boldnotice("[owner.mind.name || owner.real_name] has chosen [chosen_gear.name] as your team's gear! You may drop-pod it in at any time using the Summon Gear action!"), type = MESSAGE_TYPE_INFO, avoid_highlighting = (brother == owner.mind))

/datum/action/bb/gear/update_button_name(atom/movable/screen/movable/action_button/button, force)
	if(team.chosen_gear)
		name = "Summon Gear"
		desc = "Summon a drop pod at your current location containing your chosen piece of gear, [team.chosen_gear.name]."
	else
		name = initial(name)
		desc = initial(desc)
	return ..()
