// Recruitment controller.
/datum/recruiter
	var/atom/subject
	var/list/currently_querying // Used to avoid asking the same ghost repeatedly.
	var/searching = 0			// Are we currently looking for a ghost?

	var/display_name
	var/role // ROLE_*
	var/list/jobban_roles = list()
	var/reject_antag_hud = 1
	var/alien_whitelist_id = null // "Diona"
	var/recruitment_timeout = 600

	// Called when a volunteer has been added.
	// Args:
	//  player = /mob/dead/observer
	//  controls = /string
	var/event/player_volunteering = new()

	// Same, but only called when player has disabled the role.
	var/event/player_not_volunteering = new()

	// Args: player = /mob/dead/observer or null
	var/event/recruited = new()

/datum/recruiter/New(var/atom/_subject)
	subject=_subject

/datum/recruiter/proc/recruiting_player(var/mob/dead/observer/O)
	INVOKE_EVENT(player_volunteering, list("player"=O, "controls"="<a href='?src=\ref[O];jump=\ref[subject]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Retract</a>"))

/datum/recruiter/proc/nonrecruiting_player(var/mob/dead/observer/O)
	INVOKE_EVENT(player_not_volunteering, list("player"=O, "controls"="<a href='?src=\ref[O];jump=\ref[subject]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign up</a>"))

/datum/recruiter/proc/request_player()
	currently_querying = list()

	searching = 1

	var/list/active_candidates = get_active_candidates(role)

	for(var/mob/dead/observer/O in active_candidates)
		if(!check_observer(O))
			continue

		currently_querying |= O
		recruiting_player(O)
		//to_chat(O, "<span class='recruit'>Someone is harvesting [display_name]. You have been added to the list of potential ghosts. (<a href='?src=\ref[O];jump=\ref[subject]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Retract</a>)</span>")

	for(var/mob/dead/observer/O in dead_mob_list - active_candidates)
		if(!check_observer(O))
			continue
		nonrecruiting_player(O)
		//to_chat(O, "<span class='recruit'>Someone is harvesting [display_name]. (<a href='?src=\ref[O];jump=\ref[subject]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign up</a>)</span>")

	spawn(recruitment_timeout)
		if(!currently_querying || currently_querying.len==0)
			INVOKE_EVENT(recruited, list("player"=null))
			return

		var/mob/dead/observer/O

		O = pick(currently_querying)
		while(currently_querying.len && !check_observer(O)) //While we the list has something and
			currently_querying -= O				//Remove them from the list if they don't get checked properly
			O = pick(currently_querying)

		if(!check_observer(O))
			INVOKE_EVENT(recruited, list("player"=null))
		else
			INVOKE_EVENT(recruited, list("player"=O))

/datum/recruiter/Topic(var/href, var/list/href_list)
	if(href_list["signup"])
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O)
			return

		volunteer(O)

/datum/recruiter/proc/volunteer(var/mob/dead/observer/O)
	if(!searching || !istype(O))
		return

	if(!check_observer(O))
		to_chat(O, "<span class='warning'>You cannot be [display_name].</span>")//Jobbanned or something.

		return

	if(O in currently_querying)
		to_chat(O, "<span class='notice'>Removed from registration list.</span>")
		currently_querying -= O
	else
		to_chat(O, "<span class='notice'>Added to registration list.</span>")
		currently_querying += O

/datum/recruiter/proc/check_observer(var/mob/dead/observer/O)
	if(reject_antag_hud && O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 0

	if(jobban_roles.len > 0)
		for(var/jbrole in jobban_roles)
			if(jobban_isbanned(O, jbrole))
				return 0

	if(alien_whitelist_id && !is_alien_whitelisted(src, alien_whitelist_id) && config.usealienwhitelist)
		return 0

	return O.client

/datum/recruiter/Destroy()
	subject = null
	currently_querying = null
	player_volunteering = null
	player_not_volunteering = null
	..()
