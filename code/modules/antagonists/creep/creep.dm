/datum/antagonist/creep
	name = "Creep"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	job_rank = ROLE_CREEP
	show_name_in_check_antagonists = TRUE
	roundend_category = "creeps"
	silent = TRUE //not actually silent, because greet will be called by the trauma anyway.
	var/datum/brain_trauma/special/creep/trauma

/datum/antagonist/creep/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to at least be a carbon!")
		return
	if(!C.getorgan(/obj/item/organ/brain)) // If only I had a brain
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to HAVE A BRAIN.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	//PRESTO FUCKIN MAJESTO
	C.gain_trauma(/datum/brain_trauma/special/creep)//ZAP

/datum/antagonist/creep/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/creepalert.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner, "<span class='boldannounce'>You are the Creep!</span>")
	to_chat(owner, "<B>They would call it an obsession. They would call you crazy, because they don't understand your unrequited love.<br>All you know is that you love [trauma.obsession]. And you. will. show them.</B>")
	to_chat(owner, "<B>I will surely go insane if I don't spend enough time around [trauma.obsession], but when i'm near them too long it gets too difficult to speak properly, making me look like a CREEP!</B>")
	owner.announce_objectives()

/datum/antagonist/creep/Destroy()
	if(trauma)
		qdel(trauma)
	. = ..()

/datum/antagonist/creep/proc/forge_objectives(var/datum/mind/obsessionmind)

	var/datum/objective/assassinate/creep/kill = new
	kill.owner = owner
	kill.target = obsessionmind

	var/list/objectives_left = list("spendtime", "polaroid", "hug")
	for(var/i in 1 to 2)//set to 3 when hugs gets in, after that sit
		var/chosen_objective = pick(objectives_left)
		objectives_left.Remove(chosen_objective)
		switch(chosen_objective)
			if("spendtime")
				var/datum/objective/spendtime/spendtime = new
				spendtime.owner = owner
				spendtime.target = obsessionmind
				objectives += spendtime
			if("polaroid")
				var/datum/objective/polaroid/polaroid = new
				polaroid.owner = owner
				polaroid.target = obsessionmind
				objectives += polaroid
			if("hug")
				var/datum/objective/hug/hug = new
				hug.owner = owner
				hug.target = obsessionmind
				objectives += hug

	objectives += kill//finally add the assassinate last, because you'd have to complete it last to greentext.
	for(var/datum/objective/O in objectives)
		O.update_explanation_text()

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
	if(trauma)
		if(trauma.total_time_creeping > 0)
			report += "<span class='greentext'>The [name] spent a total of [DisplayTimeText(trauma.total_time_creeping)] being near [trauma.obsession]!</span>"
		else
			report += "<span class='redtext'>The [name] did not go near their obsession the entire round! That's extremely impressive, but you are a shit [name]!</span>"
	else
		report += "<span class='greentext'>The [name] had no trauma attached to their antagonist ways! Either it bugged out or an admin incorrectly gave this good samaritan antag and it broke! You might as well show yourself!!</span>"

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//////////////////////////////////////////////////
///CREEPY objectives (few chosen per obsession)///
//////////////////////////////////////////////////

/datum/objective/assassinate/creep //just a creepy version of assassinate

/datum/objective/assassinate/creep/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Murder [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/spendtime //spend some time around someone, handled by the creep trauma since that ticks
	name = "spendtime"
	var/timer = 3000 //5 minutes

/datum/objective/spendtime/update_explanation_text()
	if(timer == 1800)//just so admins can mess with it
		timer += pick(-600, 0)
	var/datum/antagonist/creep/creeper = owner.has_antag_datum(/datum/antagonist/creep)
	if(target && target.current && creeper)
		creeper.trauma.attachedcreepobj = src
		explanation_text = "Spend [DisplayTimeText(timer)] around [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/spendtime/check_completion()
	return timer <= 0 || explanation_text == "Free Objective"


/datum/objective/hug
	name = "hugs"
	var/hugs_needed

/datum/objective/hug/update_explanation_text()
	..()
	if(!hugs_needed)//just so admins can mess with it
		hugs_needed = rand(4,6)
	if(target && target.current)
		var/datum/component/hugcounter/hugcounter = owner.current.AddComponent(/datum/component/hugcounter)
		hugcounter.target = target
		explanation_text = "Hug [target.name] [hugs_needed] times while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/hug/check_completion()
	GET_COMPONENT(hugcounter, /datum/component/hugcounter)
	if(!hugcounter || !hugs_needed)
		return TRUE//free objective
	return hugcounter.hugnumber >= hugs_needed

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



