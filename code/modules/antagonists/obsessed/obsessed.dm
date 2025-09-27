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
	if(trauma)
		qdel(trauma)
	. = ..()

/datum/antagonist/obsessed/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/victim_dummy = new
	victim_dummy.set_haircolor("#bb9966", update = FALSE)
	victim_dummy.set_hairstyle("Messy", update = TRUE)

	var/icon/obsessed_icon = render_preview_outfit(preview_outfit)
	var/icon/blood_icon = icon('icons/effects/blood.dmi', "uniformblood")
	blood_icon.Blend(BLOOD_COLOR_RED, ICON_MULTIPLY)
	obsessed_icon.Blend(blood_icon, ICON_OVERLAY)

	var/icon/final_icon = finish_preview_icon(obsessed_icon)

	final_icon.Blend(
		icon('icons/ui/antags/obsessed.dmi', "obsession"),
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
	var/obj/family_heirloom

	for(var/datum/quirk/quirky in obsessionmind.current.quirks)
		if(istype(quirky, /datum/quirk/item_quirk/family_heirloom))
			var/datum/quirk/item_quirk/family_heirloom/heirloom_quirk = quirky
			family_heirloom = heirloom_quirk.heirloom?.resolve()
			break
	if(family_heirloom)
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
				objectives += polaroid
			if(OBSESSED_OBJECTIVE_HUG)
				var/datum/objective/hug/hug = new
				hug.owner = owner
				hug.target = obsessionmind
				objectives += hug
			if(OBSESSED_OBJECTIVE_HEIRLOOM)
				var/datum/objective/steal/heirloom_thief/heirloom_thief = new
				heirloom_thief.owner = owner
				heirloom_thief.target = obsessionmind//while you usually wouldn't need this for stealing, we need the name of the obsession
				heirloom_thief.steal_target = family_heirloom
				objectives += heirloom_thief
			if(OBSESSED_OBJECTIVE_JEALOUS)
				var/datum/objective/assassinate/jealous/jealous = new
				jealous.owner = owner
				jealous.target = obsessionmind//will reroll into a coworker on the objective itself
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
	..()
	if(target?.current)
		explanation_text = "Murder [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())]."
	else
		message_admins("WARNING! [ADMIN_LOOKUPFLW(owner)] obsessed objectives forged without an obsession!")
		explanation_text = "Free Objective"

/datum/objective/assassinate/jealous //assassinate, but it changes the target to someone else in the previous target's department. cool, right?
	var/datum/mind/old //the target the coworker was picked from.

/datum/objective/assassinate/jealous/update_explanation_text()
	..()
	old = find_coworker(target)
	if(target?.current && old)
		explanation_text = "Murder [target.name], [old]'s coworker."
	else
		explanation_text = "Free Objective"


/datum/objective/assassinate/jealous/proc/find_coworker(datum/mind/oldmind)//returning null = free objective
	if(is_unassigned_job(oldmind.assigned_role))
		return
	var/list/viable_coworkers = list()
	var/list/all_coworkers = list()
	var/our_departments = oldmind.assigned_role.departments_bitflags
	for(var/mob/living/carbon/human/human_alive in GLOB.alive_mob_list)
		if(!human_alive.mind)
			continue
		if(human_alive == oldmind.current || human_alive.mind.assigned_role.faction != FACTION_STATION || human_alive.mind.has_antag_datum(/datum/antagonist/obsessed))
			continue //the jealousy target has to have a job, and not be the obsession or obsessed.
		all_coworkers += human_alive.mind
		if(!(our_departments & human_alive.mind.assigned_role.departments_bitflags))
			continue
		viable_coworkers += human_alive.mind

	if(length(viable_coworkers))//find someone in the same department
		target = pick(viable_coworkers)
	else if(length(all_coworkers))//find someone who works on the station
		target = pick(all_coworkers)
	return oldmind


/datum/objective/spendtime //spend some time around someone, handled by the obsessed trauma since that ticks
	name = "spendtime"
	var/timer = 1800 //5 minutes

/datum/objective/spendtime/update_explanation_text()
	if(timer == initial(timer))//just so admins can mess with it
		timer += pick(-600, 0)
	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	if(target?.current && creeper)
		creeper.trauma.attachedobsessedobj = src
		explanation_text = "Spend [DisplayTimeText(timer)] around [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/spendtime/check_completion()
	return timer <= 0 || explanation_text == "Free Objective"


/datum/objective/hug//this objective isn't perfect. hugging the correct amount of times, then switching bodies, might fail the objective anyway. maybe i'll come back and fix this sometime.
	name = "hugs"
	var/hugs_needed

/datum/objective/hug/update_explanation_text()
	..()
	if(!hugs_needed)//just so admins can mess with it
		hugs_needed = rand(4,6)
	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	if(target?.current && creeper)
		explanation_text = "Hug [target.name] [hugs_needed] times while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/hug/check_completion()
	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	if(!creeper || !creeper.trauma || !hugs_needed)
		return TRUE//free objective
	return creeper.trauma.obsession_hug_count >= hugs_needed

/datum/objective/polaroid //take a picture of the target with you in it.
	name = "polaroid"

/datum/objective/polaroid/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Take a photo of [target.name] while they're alive, and keep it in your bag."
	else
		explanation_text = "Free Objective"

/datum/objective/polaroid/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.get_all_contents() //this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(istype(I, /obj/item/photo))
				var/obj/item/photo/P = I
				if(P.picture && (WEAKREF(target.current) in P.picture.mobs_seen) && !(WEAKREF(target.current) in P.picture.dead_seen)) //Does the picture exist and is the target in it and is the target not dead
					return TRUE
	return FALSE


/datum/objective/steal/heirloom_thief //exactly what it sounds like, steal someone's heirloom.
	name = "heirloomthief"

/datum/objective/steal/heirloom_thief/update_explanation_text()
	..()
	if(steal_target)
		explanation_text = "Steal [target.name]'s family heirloom, [steal_target] they cherish."
	else
		explanation_text = "Free Objective"

#undef OBSESSED_OBJECTIVE_SPEND_TIME
#undef OBSESSED_OBJECTIVE_POLAROID
#undef OBSESSED_OBJECTIVE_HUG
#undef OBSESSED_OBJECTIVE_HEIRLOOM
#undef OBSESSED_OBJECTIVE_JEALOUS
