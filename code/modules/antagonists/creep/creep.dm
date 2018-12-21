/datum/antagonist/creep
	name = "Creep"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	roundend_category = "creeps"
	var/datum/mind/obsession
	var/datum/status_effect/creep/creep_status


/datum/antagonist/creep/on_gain()
	owner.current.apply_status_effect(STATUS_EFFECT_CREEP, owner)
	creep_status = owner.current.has_status_effect(STATUS_EFFECT_CREEP)
	forge_objectives()
	creep_status.obsession = src.obsession
	. = ..()

/datum/antagonist/creep/greet()
	to_chat(owner, "<span class='boldannounce'>You are the Creep!</span>")
	to_chat(owner, "<B>Defend your obsessions from demons and evildoers of the station! Until, of course, the voices want them gone, that is.</B>")
	to_chat(owner, "<B>Check your status tab to see how long you have to defend your current obsession.</B>")
	owner.announce_objectives()

/datum/antagonist/creep/proc/forge_objectives()

	var/datum/objective/assassinate/creep/realtarget = new
	realtarget.owner = owner

	var/datum/objective/polaroid/polaroid = new
	polaroid.owner = owner
	polaroid.target = realtarget.target
	objectives += polaroid

	objectives += realtarget//finally add the assassinate last
	owner.current.apply_status_effect(STATUS_EFFECT_INLOVE, realtarget.target.current)
	obsession = realtarget.target

/datum/antagonist/creep/roundend_report_header()
	return 	"<span class='header'>Someone became a creep!</span><br>"

/datum/antagonist/creep/roundend_report()
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
	if(creep_status)
		report += "<span class='greentext big'>The [name] spent a total of [creep_status.total_time_creeping] being near [creep_status.obsession]!</span>"

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

///creep creepy objectives (few chosen per obsession)///


/datum/objective/spendtime //spend some time around someone, handled by the creep status effect since it also looks for the target
	var/timer = 3000 //5 minutes

/datum/objective/spendtime/New()
	var/datum/antagonist/creep/creeper = owner.has_antag_datum(/datum/antagonist/creep)
	if(!creeper)
		return
	if(creeper.creep_status)
		creeper.creep_status.attachedcreepobj = src

/datum/objective/spendtime/update_explanation_text()
	if(timer == 3000)//just so admins can mess with it
		timer += pick(-1200, -600, 600, 1200)
	explanation_text = "Spend [timer / 600] minutes around [target.name] while they are alive."

/datum/objective/spendtime/check_completion()
	return timer <= 0

/datum/objective/assassinate/creep //just a creepy version of assassinate

/datum/objective/assassinate/creep/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Murder [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
/*
/datum/objective/hug
	name = "hugs"
	var/hugs_needed
	var/hugs_counted = 0

/datum/objective/hug/update_explanation_text()
	..()
	if(!hugs_needed)//just so admins can mess with it
		hugs_needed = rand(4,6)
	if(target && target.current)
		explanation_text = "Hug [target.name] [hugs_needed] times!"
	else
		explanation_text = "Free Objective"

/datum/objective/hug/check_completion()
	return hugs_counted >= hugs_needed
*/
/datum/objective/polaroid //take a picture of the target with you in it.
	name = "polaroid"

/datum/objective/polaroid/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Take a photo with [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/polaroid/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(istype(I, /obj/item/photo))
				var/obj/item/photo/P = I
				if(P.picture.mobs_seen.Find(owner) && P.picture.mobs_seen.Find(target) && !P.picture.dead_seen.Find(target))//you are in the picture, they are but they are not dead.
					return TRUE
	return FALSE



