#define SUMMON_POSSIBILITIES 3

/datum/antagonist/cult
	var/datum/action/innate/cult/comm/communion = new
	var/datum/action/innate/cult/mastervote/vote = new

/datum/antagonist/cult/Destroy()
	QDEL_NULL(communion)
	QDEL_NULL(vote)
	return ..()

/datum/antagonist/cult/proc/add_objectives()
	var/list/target_candidates = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !player.mind.has_antag_datum(ANTAG_DATUM_CULT) && !is_convertable_to_cult(player) && (player != owner) && player.stat != DEAD)
			target_candidates += player.mind
	if(target_candidates.len == 0)
		message_admins("Cult Sacrifice: Could not find unconvertable target, checking for convertable target.")
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !player.mind.has_antag_datum(ANTAG_DATUM_CULT) && (player != owner) && player.stat != DEAD)
				target_candidates += player.mind
	listclearnulls(target_candidates)
	if(LAZYLEN(target_candidates))
		GLOB.sac_mind = pick(target_candidates)
		if(!GLOB.sac_mind)
			message_admins("Cult Sacrifice: ERROR -  Null target chosen!")
		else
			var/datum/job/sacjob = SSjob.GetJob(GLOB.sac_mind.assigned_role)
			var/datum/preferences/sacface = GLOB.sac_mind.current.client.prefs
			var/icon/reshape = get_flat_human_icon(null, sacjob, sacface)
			reshape.Shift(SOUTH, 4)
			reshape.Shift(EAST, 1)
			reshape.Crop(7,4,26,31)
			reshape.Crop(-5,-3,26,30)
			GLOB.sac_image = reshape
	else
		message_admins("Cult Sacrifice: Could not find unconvertable or convertable target. WELP!")
		GLOB.sac_complete = TRUE
	SSticker.mode.cult_objectives += "sacrifice"
	if(!GLOB.summon_spots.len)
		while(GLOB.summon_spots.len < SUMMON_POSSIBILITIES)
			var/area/summon = pick(GLOB.sortedAreas - GLOB.summon_spots)
			if(summon && (summon.z in GLOB.station_z_levels) && summon.valid_territory)
				GLOB.summon_spots += summon
	SSticker.mode.cult_objectives += "eldergod"

/datum/antagonist/cult/proc/cult_memorization(datum/mind/cult_mind)
	var/mob/living/current = cult_mind.current
	for(var/obj_count = 1,obj_count <= SSticker.mode.cult_objectives.len,obj_count++)
		var/explanation
		switch(SSticker.mode.cult_objectives[obj_count])
			if("sacrifice")
				if(GLOB.sac_mind)
					explanation = "Sacrifice [GLOB.sac_mind], the [GLOB.sac_mind.assigned_role] via invoking a Sacrifice rune with them on it and three acolytes around it."
				else
					explanation = "The veil has already been weakened here, proceed to the final objective."
					GLOB.sac_complete = TRUE
			if("eldergod")
				explanation = "Summon Nar-Sie by invoking the rune 'Summon Nar-Sie'. <b>The summoning can only be accomplished in [english_list(GLOB.summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"
		if(!silent)
			to_chat(current, "<B>Objective #[obj_count]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_cult(new_owner.current)

/datum/antagonist/cult/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	if(!LAZYLEN(SSticker.mode.cult_objectives))
		add_objectives()
	SSticker.mode.cult += owner // Only add after they've been given objectives
	cult_memorization(owner)
	if(jobban_isbanned(current, ROLE_CULTIST))
		addtimer(CALLBACK(SSticker.mode, /datum/game_mode.proc/replace_jobbaned_player, current, ROLE_CULTIST, ROLE_CULTIST), 0)
	SSticker.mode.update_cult_icons_added(owner)
	current.log_message("<font color=#960000>Has been converted to the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)
	if(GLOB.blood_target && GLOB.blood_target_image && current.client)
		current.client.images += GLOB.blood_target_image

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction |= "cult"
	current.grant_language(/datum/language/narsie)
	current.verbs += /mob/living/proc/cult_help
	if(!GLOB.cult_mastered)
		vote.Grant(current)
	communion.Grant(current)
	current.throw_alert("bloodsense", /obj/screen/alert/bloodsense)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction -= "cult"
	current.remove_language(/datum/language/narsie)
	current.verbs -= /mob/living/proc/cult_help
	vote.Remove(current)
	communion.Remove(current)
	current.clear_alert("bloodsense")

/datum/antagonist/cult/on_removal()
	owner.wipe_memory()
	SSticker.mode.cult -= owner
	SSticker.mode.update_cult_icons_removed(owner)
	if(!silent)
		owner.current.visible_message("<span class='big'>[owner.current] looks like [owner.current.p_they()] just reverted to their old faith!</span>", ignored_mob = owner.current)
		to_chat(owner.current, "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant.</span>")
		owner.current.log_message("<font color=#960000>Has renounced the cult of Nar'Sie!</font>", INDIVIDUAL_ATTACK_LOG)
	if(GLOB.blood_target && GLOB.blood_target_image && owner.current.client)
		owner.current.client.images -= GLOB.blood_target_image
	. = ..()

/datum/antagonist/cult/master
	var/datum/action/innate/cult/master/finalreck/reckoning = new
	var/datum/action/innate/cult/master/cultmark/bloodmark = new
	var/datum/action/innate/cult/master/pulse/throwing = new

/datum/antagonist/cult/master/Destroy()
	QDEL_NULL(reckoning)
	QDEL_NULL(bloodmark)
	QDEL_NULL(throwing)
	return ..()

/datum/antagonist/cult/master/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	SSticker.mode.set_antag_hud(current, "cultmaster")

/datum/antagonist/cult/master/greet()
	to_chat(owner.current, "<span class='cultlarge'>You are the cult's Master</span>. As the cult's Master, you have a unique title and loud voice when communicating, are capable of marking \
	targets, such as a location or a noncultist, to direct the cult to them, and, finally, you are capable of summoning the entire living cult to your location <b><i>once</i></b>.")
	to_chat(owner.current, "Use these abilities to direct the cult to victory at any cost.")

/datum/antagonist/cult/master/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	if(!GLOB.reckoning_complete)
		reckoning.Grant(current)
	bloodmark.Grant(current)
	throwing.Grant(current)
	current.update_action_buttons_icon()
	current.apply_status_effect(/datum/status_effect/cult_master)

/datum/antagonist/cult/master/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	reckoning.Remove(current)
	bloodmark.Remove(current)
	throwing.Remove(current)
	current.update_action_buttons_icon()
	current.remove_status_effect(/datum/status_effect/cult_master)
