/datum/game_mode
	var/list/marked_objective = list()

/datum/game_mode/traitor/marked
	name = "marked"
	config_tag = "marked"
	required_players = 15
	var/number_of_marks = 1

	announce_span = "danger"
	announce_text = "There are Syndicate agents on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: A crew member has been marked by the syndicate cartels. Protect this crew member at all costs!"

/datum/game_mode/traitor/marked/pre_setup()
	var/numlobbys = 0
	for(var/mob/dead/new_player/N in GLOB.player_list)
		if(N.client && N.ready == PLAYER_READY_TO_PLAY)
			numlobbys++
	if(antag_candidates.len >= numlobbys)
		if(antag_candidates.len >= 2)
			antag_candidates -= pick_n_take(antag_candidates)
		else
			return 0
	. = ..()

/datum/game_mode/traitor/marked/post_setup()
	var/list/potential_marked = list()
	for(var/mob/living/carbon/human/L in GLOB.player_list)
		if(!L.mind)
			continue
		if(L.mind in pre_traitors)
			continue
		if(check_perseus(L))
			continue
		potential_marked += L.mind
	if(potential_marked.len)
		for(var/i=1,i<=number_of_marks,i++)
			if(!potential_marked.len)
				break
			marked_objective += pick_n_take(potential_marked)
		for(var/datum/mind/marked_mind in marked_objective)
			if(istype(marked_mind.current,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = marked_mind.current
				var/obj/item/folder/folder = create_certificate(H)
				H.equip_to_slot_or_del(folder, slot_in_backpack)
				to_chat(marked_mind.current,"<span class='big bold'><font color='red'>You have been marked for death!</font><span>")
				to_chat(marked_mind.current,"<B>Various Syndicate cartels have put a bounty on your head. There are agents onboard the station who are here to assassinate you. You have been given a folder that contains proof of this fact, we suggest you show this security so they can offer you the necessary protection.</B>")
				log_game("[H.key] (ckey) has been selected as a Marked witness")
	return ..()

/datum/game_mode/traitor/marked/special_report()
	if(marked_objective.len)
		var/result = "<div class='panel greenborder'>"
		result += "<span class='header'>The marked players were:</span><br>"
		var/count = 1
		for(var/datum/mind/marked_mind in marked_objective)
			result += printplayer(marked_mind)
			if(count < marked_objective.len)
				result += "<br>"
			count++
		result += "</div>"
		return result
	return ..()

/datum/game_mode/traitor/marked/proc/create_certificate(mob/living/L)
	var/obj/item/folder/blue/folder = new()
	folder.name = "Central Command Witness Protection Documentation"
	var/obj/item/paper/P = new(folder)
	P.name = "Central Command Witness Protection Certificate"
	var/the_name = L.real_name
	var/marked_gender = L.gender
	var/heshe = "he"
	if(marked_gender == "female")
		heshe = "she"
	var/marked_job = ""
	if(L.mind)
		var/datum/job/J = SSjob.GetJob(L.mind.assigned_role)
		if(J)
			marked_job = " the [J.title]"
	P.info = "<B>[P.name]</B><br>This document is to notify [L.real_name][marked_job] that [heshe] has been marked for death by various Syndicate Cartels. There is at least one if not multiple agents onboard your station that seek to assassinate [the_name]."
	P.stamps += "<img src=large_stamp-cent.png>"
	var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_stamp-cent")
	stampoverlay.pixel_x = rand(-2, 2)
	stampoverlay.pixel_y = rand(-3, 2)
	LAZYADD(P.stamped, "stamp-cent")
	P.add_overlay(stampoverlay)
	P.update_icon()
	folder.update_icon()
	return folder

/datum/antagonist/proc/assign_marked_objective()
	var/list/new_objectives = list()
	if(SSticker.mode.marked_objective.len && (!(owner in SSticker.mode.marked_objective)))
		for(var/datum/mind/mind in SSticker.mode.marked_objective)
			if(mind.current && mind.current.stat != DEAD)
				var/list/all_objectives = objectives+owner.objectives
				var/target_already_exists = 0
				for(var/datum/objective/assassinate/A in all_objectives)
					if(A.target == mind)
						target_already_exists = 1
						break
				if(!target_already_exists)
					var/datum/objective/assassinate/kill_objective = new
					kill_objective.owner = owner
					kill_objective.target = mind
					kill_objective.update_explanation_text()
					new_objectives += kill_objective
			else
	if(new_objectives.len)
		return new_objectives
	return null

/datum/admins/proc/list_marked_players()
	. = ""
	if(SSticker && SSticker.mode && SSticker.mode.marked_objective.len)
		. += "<B>Marked Players</B><br>"
		. += "<table cellspacing=5>"
		for(var/datum/mind/mind in SSticker.mode.marked_objective)
			var/list/parts = list()
			if(mind.current)
				parts += "<a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(mind.current)]'>[mind.current.real_name]</a> "
			else
				parts += "<a href='?_src_=vars;[HrefToken()];Vars=[REF(mind)]'>[mind.name]</a> "
			if(!mind.current)
				parts += "<font color=red>(Body destroyed)</font>"
			else
				if(mind.current.stat == DEAD)
					parts += "<font color=red>(DEAD)</font>"
				else if(!mind.current.client)
					parts += "(No client)"
			parts += "<a href='?priv_msg=[ckey(mind.key)]'>PM</a>"
			if(mind.current)
				parts += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(mind.current)]'>FLW</a>"
			. += "<tr><td>[parts.Join("</td><td>")]</td></tr>"
		. += "</table>"