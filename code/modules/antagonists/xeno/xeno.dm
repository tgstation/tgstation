/datum/team/xeno
	name = "Aliens"

//Simply lists them.
/datum/team/xeno/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The [name] were:</span>"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/xeno
	name = "Xenomorph"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	var/datum/team/xeno/xeno_team

/datum/antagonist/xeno/create_team(datum/team/xeno/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/X in GLOB.antagonists)
			if(!X.owner || !X.xeno_team)
				continue
			xeno_team = X.xeno_team
			return
		xeno_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		xeno_team = new_team

/datum/antagonist/xeno/get_team()
	return xeno_team

/mob/living/carbon/alien/humanoid/royal/queen/Login()
	..()
	SSshuttle.registerHostileEnvironment(src)

/mob/living/carbon/alien/humanoid/royal/queen/Logout()
	..()
	addtimer(CALLBACK(src, .proc/logoutcheck), 40 SECONDS)//when logging out, we don't want to spam announcements with leaving and reconnecting.
	SSshuttle.clearHostileEnvironment(src)
	neutralized = TRUE

/mob/living/carbon/alien/humanoid/royal/queen/death()
	..()
	SSshuttle.clearHostileEnvironment(src)
	neutralized = TRUE

/mob/living/carbon/alien/humanoid/royal/queen/proc/logoutcheck()
	if(!client)
		SSshuttle.clearHostileEnvironment(src) //the queen has officially gone braindead, so we can allow the shuttle to leave

/mob/living/carbon/alien/humanoid/royal/queen/Life()
	..()
	if(!client)
		return
	if(life_ticks_to_wait)
		life_ticks_to_wait--
		return
	life_ticks_to_wait = initial(life_ticks_to_wait)
	var/living_humans = 0
	var/total_humans = length(GLOB.human_list)
	for(var/H in GLOB.human_list)
		var/mob/living/carbon/human/human = H
		if(!human.client || human.stat == DEAD )
			continue
		living_humans++
	if(living_humans < total_humans/10 && !nuking && !neutralized)
		INVOKE_ASYNC(src, .proc/nuke_it_from_orbit)

/mob/living/carbon/alien/humanoid/royal/queen/proc/nuke_it_from_orbit()
    nuking = TRUE
    addtimer(CALLBACK(GLOBAL_PROC, .proc/priority_announce, "Hostile Lifeforms Identified. Extreme Biohazard Alert. Determining Containment Solutions","Central Command Update", 'sound/misc/notice1.ogg'), 50)
    addtimer(CALLBACK(GLOBAL_PROC, .proc/priority_announce, "Containment Solution Identified. Initiating Station Self Destruct Protocol.","Central Command Update", 'sound/misc/notice1.ogg'), 450)
    addtimer(CALLBACK(src, .proc/blow_nuke), 500)

/mob/living/carbon/alien/humanoid/royal/queen/proc/blow_nuke()
    var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
    nuke.safety = FALSE
    nuke.explode()

var/nuking = FALSE

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	if(!mind.has_antag_datum(/datum/antagonist/xeno))
		mind.add_antag_datum(/datum/antagonist/xeno)
