/datum/antagonist/cult
	var/datum/action/innate/cultcomm/communion = new

/datum/antagonist/cult/Destroy()
	qdel(communion)
	return ..()

/datum/antagonist/cultist/proc/add_objectives()
	var/list/target_candidates = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !is_convertable_to_cult(player) && !owner && isliving(player))
			target_candidates += player.mind
	if(target_candidates.len == 0)
		message_admins("Cult Sacrifice: Could not find unconvertable target, checking for convertable target.")
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && (player != owner) && isliving(player))
				target_candidates += player.mind
	if(target_candidates.len > 0)
		GLOB.sac_mind = pick(target_candidates)
		if(!GLOB.sac_mind)
			message_admins("Cult Sacrifice: ERROR -  Null target chosen!")
		else
			var/datum/job/sacjob = SSjob.GetJob(GLOB.sac_mind.assigned_role)
			var/icon/reshape = get_flat_human_icon(null, sacjob, GLOB.sac_mind.current.client.prefs)
			reshape.Shift(SOUTH, 4)
			reshape.Shift(EAST, 1)
			reshape.Crop(7,4,26,31)
			reshape.Crop(-5,-3,26,30)
			GLOB.sac_image = reshape
	else
		message_admins("Cult Sacrifice: Could not find unconvertable or convertable target. WELP!")
		GLOB.sac_complete = TRUE
	SSticker.mode.cult_objectives += "sacrifice"
	SSticker.mode.cult_objectives += "eldergod"
	on_gain()

/datum/antagonist/cult/on_gain()
	. = ..()
	if(SSticker.mode.cult_objectives.len == 0)
		add_objectives()
		return
	if(!owner)
		return
	if(jobban_isbanned(owner.current, ROLE_CULTIST))
		addtimer(CALLBACK(SSticker.mode, /datum/game_mode.proc/replace_jobbaned_player, owner, ROLE_CULTIST, ROLE_CULTIST), 0)
	owner.current.log_message("<font color=#960000>Has been converted to the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/cultist/apply_innate_effects()
	owner.faction |= "cult"
	owner.verbs += /mob/living/proc/cult_help
	if(!GLOB.cult_mastered)
		owner.verbs += /mob/living/proc/cult_master
	communion.Grant(owner)
	owner.throw_alert("bloodsense", /obj/screen/alert/bloodsense)
	..()

/datum/antagonist/cultist/remove_innate_effects()
	owner.faction -= "cult"
	owner.verbs -= /mob/living/proc/cult_help
	owner.verbs -= /mob/living/proc/cult_master
	for(var/datum/action/innate/cultmast/H in owner.actions)
		qdel(H)
	owner.clear_alert("bloodsense")
	..()

/datum/antagonist/cult/on_removal()
	. = ..()
	to_chat(owner, "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Dark One and all your memories as its servant.</span>")
	owner.current.log_message("<font color=#960000>Has renounced the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)
	if(!silent)
		owner.current.visible_message("<span class='big'>[owner] looks like [owner.current.p_they()] just reverted to their old faith!</span>")
