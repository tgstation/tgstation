#define MONKEYS_ESCAPED		1
#define MONKEYS_LIVED		2
#define MONKEYS_DIED		3
#define DISEASE_LIVED		4

/datum/antagonist/monkey
	name = "Monkey"
	job_rank = ROLE_MONKEY
	roundend_category = "monkeys"
	panel_category = "monkey"
	var/datum/team/monkey/monkey_team

/datum/antagonist/monkey/on_gain()
	. = ..()
	SSticker.mode.ape_infectees += owner
	owner.special_role = "Infected Monkey"

	var/datum/disease/D = new /datum/disease/transformation/jungle_fever/monkeymode
	if(!owner.current.HasDisease(D))
		owner.current.AddDisease(D)
	else
		QDEL_NULL(D)

/datum/antagonist/monkey/greet()
	to_chat(owner, "<b>You are a monkey now!</b>")
	to_chat(owner, "<b>Bite humans to infect them, follow the orders of the monkey leaders, and help fellow monkeys!</b>")
	to_chat(owner, "<b>Ensure at least one infected monkey escapes on the Emergency Shuttle!</b>")
	to_chat(owner, "<b><i>As an intelligent monkey, you know how to use technology and how to ventcrawl while wearing things.</i></b>")
	to_chat(owner, "<b>You can use :k to talk to fellow monkeys!</b>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/monkey.ogg'))

/datum/antagonist/monkey/on_removal()
	. = ..()
	owner.special_role = null
	SSticker.mode.ape_infectees -= owner

	var/datum/disease/D = (/datum/disease/transformation/jungle_fever in owner.current.viruses)
	if(D)
		D.cure()

/datum/antagonist/monkey/create_team(datum/team/monkey/new_team)
	if(!new_team)
		for(var/datum/antagonist/monkey/N in get_antagonists(/datum/antagonist/monkey, TRUE))
			if(N.monkey_team)
				monkey_team = N.monkey_team
				return
		monkey_team = new /datum/team/monkey
		monkey_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	monkey_team = new_team

/datum/antagonist/monkey/proc/forge_objectives()
	if(monkey_team)
		owner.objectives |= monkey_team.objectives

/datum/antagonist/monkey/leader
	name = "Monkey Leader"

/datum/antagonist/monkey/leader/on_gain()
	. = ..()
	var/obj/item/organ/heart/freedom/F = new
	F.Insert(owner.current, drop_if_replaced = FALSE)
	SSticker.mode.ape_leaders += owner
	owner.special_role = "Monkey Leader"

/datum/antagonist/monkey/leader/on_removal()
	. = ..()
	SSticker.mode.ape_leaders -= owner
	var/obj/item/organ/heart/H = new
	H.Insert(owner.current, drop_if_replaced = FALSE) //replace freedom heart with normal heart

/datum/antagonist/monkey/leader/greet()
	to_chat(owner, "<B><span class='notice'>You are the Jungle Fever patient zero!!</B></span>")
	to_chat(owner, "<b>You have been planted onto this station by the Animal Rights Consortium.</b>")
	to_chat(owner, "<b>Soon the disease will transform you into an ape. Afterwards, you will be able spread the infection to others with a bite.</b>")
	to_chat(owner, "<b>While your infection strain is undetectable by scanners, any other infectees will show up on medical equipment.</b>")
	to_chat(owner, "<b>Your mission will be deemed a success if any of the live infected monkeys reach CentCom.</b>")
	to_chat(owner, "<b>As an initial infectee, you will be considered a 'leader' by your fellow monkeys.</b>")
	to_chat(owner, "<b>You can use :k to talk to fellow monkeys!</b>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/monkey.ogg'))


/datum/antagonist/monkey/antag_panel_section(datum/mind/mind, mob/current)
	var/text = "monkey"
	if (SSticker.mode.config_tag == "monkey")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(ishuman(current))
		if(is_monkey_leader(mind))
			text += "<a href='?src=[REF(mind)];monkey=healthy'>healthy</a> | <a href='?src=[REF(mind)];monkey=infected'>infected</a> <b>LEADER</b> | <a href='?src=[REF(mind)];monkey=human'>human</a> | other"
		else
			text += "<a href='?src=[REF(mind)];monkey=healthy'>healthy</a> | <a href='?src=[REF(mind)];monkey=infected'>infected</a> | <a href='?src=[REF(mind)];monkey=leader'>leader</a> | <b>HUMAN</b> | other"
	else if(ismonkey(current))
		var/found = FALSE
		for(var/datum/disease/transformation/jungle_fever/JF in current.viruses)
			found = TRUE
			break

		var/isLeader = is_monkey_leader(mind)
		if(isLeader)
			text += "<a href='?src=[REF(mind)];monkey=healthy'>healthy</a> | <a href='?src=[REF(mind)];monkey=infected'>infected</a> <b>LEADER</b> | <a href='?src=[REF(mind)];monkey=human'>human</a> | other"
		else if(found)
			text += "<a href='?src=[REF(mind)];monkey=healthy'>healthy</a> | <b>INFECTED</b> | <a href='?src=[REF(mind)];monkey=leader'>leader</a> | <a href='?src=[REF(mind)];monkey=human'>human</a> | other"
		else
			text += "<b>HEALTHY</b> | <a href='?src=[REF(mind)];monkey=infected'>infected</a> | <a href='?src=[REF(mind)];monkey=leader'>leader</a> | <a href='?src=[REF(mind)];monkey=human'>human</a> | other"
	else
		text += "healthy | infected | leader | human | <b>OTHER</b>"

	if(current && current.client && (ROLE_MONKEY in current.client.prefs.be_special))
		text += " | Enabled in Prefs"
	else
		text += " | Disabled in Prefs"
	return text

/datum/antagonist/monkey/antag_panel_href(href, datum/mind/mind, mob/current)
	var/mob/living/L = current
	if (L.notransform)
		return
	switch(href)
		if("healthy")
			if (check_rights(R_ADMIN))
				var/mob/living/carbon/human/H = current
				var/mob/living/carbon/monkey/M = current
				if (istype(H))
					log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
					message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]</span>")
					mind = null
					M = H.monkeyize()
					mind = M.mind
				else if (istype(M) && length(M.viruses))
					for(var/thing in M.viruses)
						var/datum/disease/D = thing
						D.cure(FALSE)
		if("leader")
			if(check_rights(R_ADMIN, 0))
				add_monkey_leader(mind)
				log_admin("[key_name(usr)] made [key_name(current)] a monkey leader!")
				message_admins("[key_name_admin(usr)] made [key_name_admin(current)] a monkey leader!")
		if("infected")
			if(check_rights(R_ADMIN, 0))
				var/mob/living/carbon/human/H = current
				var/mob/living/carbon/monkey/M = current
				add_monkey(mind)
				if (istype(H))
					log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
					message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]</span>")
					mind = null
					M = H.monkeyize()
					mind = M.mind
					current.ForceContractDisease(new /datum/disease/transformation/jungle_fever)
				else if (istype(M))
					current.ForceContractDisease(new /datum/disease/transformation/jungle_fever)
		if("human")
			if (check_rights(R_ADMIN, 0))
				var/mob/living/carbon/human/H = current
				var/mob/living/carbon/monkey/M = current
				if (istype(M))
					for(var/datum/disease/transformation/jungle_fever/JF in M.viruses)
						JF.cure(0)
						stoplag() //because deleting of virus is doing throught spawn(0) //What
					remove_monkey(src)
					log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
					message_admins("<span class='notice'>[key_name_admin(usr)] attempting to humanize [key_name_admin(current)]</span>")
					H = M.humanize(TR_KEEPITEMS  |  TR_KEEPIMPLANTS  |  TR_KEEPORGANS  |  TR_KEEPDAMAGE  |  TR_KEEPVIRUS  |  TR_DEFAULTMSG)
					if(H)
						mind = H.mind

/datum/objective/monkey
	explanation_text = "Ensure that infected monkeys escape on the emergency shuttle!"
	martyr_compatible = TRUE
	var/monkeys_to_win = 1
	var/escaped_monkeys = 0

/datum/objective/monkey/check_completion()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if (M.HasDisease(D) && (M.onCentCom() || M.onSyndieBase()))
			escaped_monkeys++
	if(escaped_monkeys >= monkeys_to_win)
		return TRUE
	return FALSE

/datum/team/monkey
	name = "Monkeys"

/datum/team/monkey/proc/update_objectives()
	objectives = list()
	var/datum/objective/monkey/O = new /datum/objective/monkey()
	O.team = src
	objectives += O
	return

/datum/team/monkey/proc/infected_monkeys_alive()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if(M.HasDisease(D))
			return TRUE
	return FALSE

/datum/team/monkey/proc/infected_monkeys_escaped()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if(M.HasDisease(D) && (M.onCentCom() || M.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/monkey/proc/infected_humans_escaped()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/human/M in GLOB.alive_mob_list)
		if(M.HasDisease(D) && (M.onCentCom() || M.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/monkey/proc/infected_humans_alive()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/human/M in GLOB.alive_mob_list)
		if(M.HasDisease(D))
			return TRUE
	return FALSE

/datum/team/monkey/proc/get_result()
	if(infected_monkeys_escaped())
		return MONKEYS_ESCAPED
	if(infected_monkeys_alive())
		return MONKEYS_LIVED
	if(infected_humans_alive() || infected_humans_escaped())
		return DISEASE_LIVED
	return MONKEYS_DIED

/datum/team/monkey/roundend_report()
	var/list/parts = list()
	switch(get_result())
		if(MONKEYS_ESCAPED)
			parts += "<span class='greentext big'><B>Monkey Major Victory!</B></span>"
			parts += "<span class='greentext'><B>Central Command and [station_name()] were taken over by the monkeys! Ook ook!</B></span>"
		if(MONKEYS_LIVED)
			parts += "<FONT size = 3><B>Monkey Minor Victory!</B></FONT>"
			parts += "<span class='greentext'><B>[station_name()] was taken over by the monkeys! Ook ook!</B></span>"
		if(DISEASE_LIVED)
			parts += "<span class='redtext big'><B>Monkey Minor Defeat!</B></span>"
			parts += "<span class='redtext'><B>All the monkeys died, but the disease lives on! The future is uncertain.</B></span>"
		if(MONKEYS_DIED)
			parts += "<span class='redtext big'><B>Monkey Major Defeat!</B></span>"
			parts += "<span class='redtext'><B>All the monkeys died, and Jungle Fever was wiped out!</B></span>"
	var/list/leaders = get_antagonists(/datum/antagonist/monkey/leader, TRUE)
	var/list/monkeys = get_antagonists(/datum/antagonist/monkey, TRUE)

	if(LAZYLEN(leaders))
		parts += "<span class='header'>The monkey leaders were:</span>"
		parts += printplayerlist(SSticker.mode.ape_leaders)
	if(LAZYLEN(monkeys))
		parts += "<span class='header'>The monkeys were:</span>"
		parts += printplayerlist(SSticker.mode.ape_infectees)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"