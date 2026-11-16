#define OBSESSED_OBJECTIVE_SPEND_TIME "spend_time"
#define OBSESSED_OBJECTIVE_POLAROID "polaroid"
#define OBSESSED_OBJECTIVE_HUG "hug"
#define OBSESSED_OBJECTIVE_HEIRLOOM "heirloom"
#define OBSESSED_OBJECTIVE_JEALOUS "jealous"

/datum/antagonist/obsessed
	name = "Obsessed"
	show_in_antagpanel = TRUE
	antagpanel_category = ANTAG_GROUP_CREW
	pref_flag = ROLE_OBSESSED
	show_to_ghosts = TRUE
	antag_hud_name = "obsessed"
	show_name_in_check_antagonists = TRUE
	roundend_category = "obsessed"
	antag_flags = ANTAG_SKIP_GLOBAL_LIST
	silent = TRUE //not actually silent, because greet will be called by the trauma anyway.
	suicide_cry = "FOR MY LOVE!!"
	preview_outfit = /datum/outfit/obsessed
	hardcore_random_bonus = TRUE
	stinger_sound = 'sound/music/antag/creepalert.ogg'
	/// How many objectives should be generated
	var/objectives_to_generate = 3
	/// Brain trauma that causes the obsession
	var/datum/brain_trauma/special/obsessed/trauma

/datum/antagonist/obsessed/can_be_owned(datum/mind/new_owner)
	return ..() && new_owner.current?.get_organ_by_type(/obj/item/organ/brain) // gotta have a brain to be obsessed!

/// Dummy antag datum that will show the cured obsessed to admins
/datum/antagonist/former_obsessed
	name = "Former Obsessed"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	antagpanel_category = ANTAG_GROUP_CREW
	show_in_roundend = FALSE
	antag_flags = ANTAG_FAKE|ANTAG_SKIP_GLOBAL_LIST
	silent = TRUE
	can_elimination_hijack = ELIMINATION_PREVENT
	ui_name = null

/datum/antagonist/obsessed/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to at least be a carbon!")
		return
	if(!C.get_organ_by_type(/obj/item/organ/brain)) // If only I had a brain
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to HAVE A BRAIN.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	//PRESTO FUCKIN MAJESTO
	C.gain_trauma(/datum/brain_trauma/special/obsessed)//ZAP

/datum/antagonist/obsessed/greet()
	play_stinger()
	owner.announce_objectives()

/datum/antagonist/obsessed/Destroy()
	QDEL_NULL(trauma)
	return ..()

/datum/antagonist/obsessed/get_preview_icon()
	var/datum/universal_icon/obsessed_icon = render_preview_outfit(preview_outfit)
	var/datum/universal_icon/blood_icon = uni_icon('icons/effects/blood.dmi', "uniformblood")
	blood_icon.blend_color(BLOOD_COLOR_RED, ICON_MULTIPLY)
	obsessed_icon.blend_icon(blood_icon, ICON_OVERLAY)

	var/datum/universal_icon/final_icon = finish_preview_icon(obsessed_icon)

	final_icon.blend_icon(
		uni_icon('icons/ui/antags/obsessed.dmi', "obsession"),
		ICON_OVERLAY,
		ANTAGONIST_PREVIEW_ICON_SIZE - 30,
		20,
	)

	return final_icon

/datum/outfit/obsessed
	name = "Obsessed (Preview only)"

	uniform = /obj/item/clothing/under/misc/overalls
	gloves = /obj/item/clothing/gloves/latex
	mask = /obj/item/clothing/mask/surgical
	neck = /obj/item/camera
	suit = /obj/item/clothing/suit/apron
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/outfit/obsessed/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(INCLUDE_POCKETS | INCLUDE_ACCESSORIES))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	H.regenerate_icons()

/datum/antagonist/obsessed/forge_objectives(datum/mind/obsessionmind)
	var/list/objectives_left = list(OBSESSED_OBJECTIVE_SPEND_TIME, OBSESSED_OBJECTIVE_POLAROID, OBSESSED_OBJECTIVE_HUG)
	var/datum/objective/assassinate/obsessed/kill = new
	kill.owner = owner
	kill.target = obsessionmind

	if(obsessionmind.current?.has_quirk(/datum/quirk/item_quirk/family_heirloom))
		objectives_left += OBSESSED_OBJECTIVE_HEIRLOOM

	// If they have no coworkers, jealousy will pick someone else on the station. This will never be a free objective.
	if(!is_captain_job(obsessionmind.assigned_role))
		objectives_left += OBSESSED_OBJECTIVE_JEALOUS

	for(var/i in 1 to objectives_to_generate)
		var/chosen_objective = pick_n_take(objectives_left)
		switch(chosen_objective)
			if(OBSESSED_OBJECTIVE_SPEND_TIME)
				var/datum/objective/spendtime/spendtime = new
				spendtime.owner = owner
				spendtime.target = obsessionmind
				objectives += spendtime
			if(OBSESSED_OBJECTIVE_POLAROID)
				var/datum/objective/polaroid/polaroid = new
				polaroid.owner = owner
				polaroid.target = obsessionmind
				polaroid.obsession_weakref = WEAKREF(obsessionmind.current)
				objectives += polaroid
			if(OBSESSED_OBJECTIVE_HUG)
				var/datum/objective/hug/hug = new
				hug.owner = owner
				hug.target = obsessionmind
				objectives += hug
			if(OBSESSED_OBJECTIVE_HEIRLOOM)
				var/datum/objective/steal/heirloom_thief/heirloom_thief = new
				heirloom_thief.owner = owner
				heirloom_thief.target = obsessionmind
				heirloom_thief.find_target()
				objectives += heirloom_thief
			if(OBSESSED_OBJECTIVE_JEALOUS)
				var/datum/objective/assassinate/jealous/jealous = new
				jealous.owner = owner
				jealous.obsessed_target = obsessionmind
				jealous.find_target()
				objectives += jealous

	objectives += kill//finally add the assassinate last, because you'd have to complete it last to greentext.

	for(var/datum/objective/O in objectives)
		O.update_explanation_text()

/datum/antagonist/obsessed/roundend_report_header()
	return span_header("Someone became obsessed!<br>")

/datum/antagonist/obsessed/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(trauma)
		if(trauma.total_time_creeping > 0)
			report += span_greentext("The [name] spent a total of [DisplayTimeText(trauma.total_time_creeping)] being near [trauma.obsession]!")
		else
			report += span_redtext("The [name] did not go near their obsession the entire round! That's extremely impressive!")
	else
		report += span_redtext("The [name] had no trauma attached to their antagonist ways! Either it bugged out or an admin incorrectly gave this good samaritan antag and it broke! You might as well show yourself!!")

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//////////////////////////////////////////////////
///CREEPY objectives (few chosen per obsession)///
//////////////////////////////////////////////////

/datum/objective/assassinate/obsessed //just a creepy version of assassinate

/datum/objective/assassinate/obsessed/update_explanation_text()
	if(target?.current)
		explanation_text = "Murder [target.name], the [target_role_type ? english_list(target.get_special_roles()) : target.assigned_role.title]."
	else
		message_admins("WARNING! [ADMIN_LOOKUPFLW(owner)] obsessed objectives forged without an obsession!")
		explanation_text = "Free Objective"
		completed = TRUE

/datum/objective/assassinate/jealous //assassinate, but it changes the target to someone else in the previous target's department. cool, right?
	var/datum/mind/obsessed_target

/datum/objective/assassinate/jealous/update_explanation_text()
	if(target?.current && obsessed_target)
		explanation_text = "Murder [target.name], [obsessed_target]'s coworker."
	else
		explanation_text = "Free Objective"
		completed = TRUE

/datum/objective/assassinate/jealous/find_target(dupe_search_range, list/blacklist)
	if(is_unassigned_job(obsessed_target.assigned_role))
		return ..()

	var/list/viable_coworkers = list()
	var/list/all_coworkers = list()
	var/our_departments = obsessed_target.assigned_role.departments_bitflags
	for(var/datum/mind/crewmember as anything in get_crewmember_minds())
		if(crewmember == obsessed_target || crewmember.has_antag_datum(/datum/antagonist/obsessed))
			continue // the jealousy target has to have a job, and not be the obsession or obsessed.

		if(our_departments & crewmember.assigned_role.departments_bitflags)
			viable_coworkers += crewmember
		all_coworkers += crewmember

	if(length(viable_coworkers)) // find someone in the same department
		target = pick(viable_coworkers)
	else if(length(all_coworkers)) // find someone who works on the station
		target = pick(all_coworkers)
	update_explanation_text()
	return target

/datum/objective/spendtime //spend some time around someone, handled by the obsessed trauma since that ticks
	name = "spendtime"
	var/timer = 0

/datum/objective/spendtime/update_explanation_text()
	if(!timer)
		timer = 5 MINUTES + pick(-60 SECONDS, 0)

	if(target?.current)
		explanation_text = "Spend [DisplayTimeText(timer)] around [target.name] while they're alive."
	else
		explanation_text = "Free Objective"
		completed = TRUE

/datum/objective/spendtime/check_completion()
	return timer <= 0 || completed

/datum/objective/hug//this objective isn't perfect. hugging the correct amount of times, then switching bodies, might fail the objective anyway. maybe i'll come back and fix this sometime.
	name = "hugs"
	var/hugs_needed = 0

/datum/objective/hug/update_explanation_text()
	if(!hugs_needed)
		hugs_needed = rand(4,6)

	if(target?.current)
		explanation_text = "Hug [target.name] [hugs_needed] times while they're alive."

	else
		explanation_text = "Free Objective"
		completed = TRUE

/datum/objective/hug/check_completion()
	return hugs_needed <= 0 || completed

/datum/objective/polaroid //take a picture of the target with you in it.
	name = "polaroid"
	/// Weakref to our obsession's original mob
	var/datum/weakref/obsession_weakref

/datum/objective/polaroid/update_explanation_text()
	if(target?.current)
		explanation_text = "Take a photo of [target.name] while they're alive, and keep it in your bag."
	else
		explanation_text = "Free Objective"
		completed = TRUE

/datum/objective/polaroid/check_completion()
	for(var/obj/item/photo/photo in owner.current?.get_all_contents())
		if((obsession_weakref in photo.picture?.mobs_seen) && !(obsession_weakref in photo.picture?.dead_seen))
			return TRUE
	return FALSE


/datum/objective/steal/heirloom_thief //exactly what it sounds like, steal someone's heirloom.
	name = "heirloomthief"

/datum/objective/steal/heirloom_thief/update_explanation_text()
	if(steal_target)
		explanation_text = "Steal [target]'s family heirloom, [steal_target] they cherish."
	else
		explanation_text = "Free Objective"
		completed = TRUE

/datum/objective/steal/heirloom_thief/find_target(dupe_search_range, list/blacklist)
	for(var/datum/quirk/item_quirk/family_heirloom/quirky in target?.current?.quirks)
		steal_target = quirky.heirloom?.resolve()
		RegisterSignal(steal_target, COMSIG_QDELETING, PROC_REF(steal_target_deleted))
		break

	update_explanation_text()
	return steal_target

/datum/objective/steal/heirloom_thief/check_completion()
	return (!isnull(steal_target) && (steal_target in owner.current?.get_all_contents())) || completed

/datum/objective/steal/heirloom_thief/proc/steal_target_deleted()
	SIGNAL_HANDLER
	steal_target = null // it's gone, and so are our hopes and dreams

#undef OBSESSED_OBJECTIVE_SPEND_TIME
#undef OBSESSED_OBJECTIVE_POLAROID
#undef OBSESSED_OBJECTIVE_HUG
#undef OBSESSED_OBJECTIVE_HEIRLOOM
#undef OBSESSED_OBJECTIVE_JEALOUS
