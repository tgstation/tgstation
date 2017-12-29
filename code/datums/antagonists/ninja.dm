/datum/antagonist/ninja
	name = "Ninja"
	panel_category = "ninja"
	job_rank = ROLE_NINJA
	var/helping_station = 0
	var/give_objectives = TRUE

/datum/antagonist/ninja/friendly
	helping_station = 1

/datum/antagonist/ninja/friendly/noobjective
	give_objectives = FALSE

/datum/antagonist/ninja/New(datum/mind/new_owner)
	if(new_owner && !ishuman(new_owner.current))//It's fine if we aren't passed a mind, but if we are, they have to be human.
		throw EXCEPTION("Only humans and/or humanoids may be ninja'ed")
	..(new_owner)

/datum/antagonist/ninja/randomAllegiance/New(datum/mind/new_owner)
	..(new_owner)
	helping_station = rand(0,1)

/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/H = owner.current)
	return H.equipOutfit(/datum/outfit/ninja)

/datum/antagonist/ninja/proc/addMemories()
	owner.store_memory("I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	owner.store_memory("Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	owner.store_memory("Officially, [helping_station?"Nanotrasen":"The Syndicate"] are my employer.")

/datum/antagonist/ninja/proc/addObjectives(quantity = 6)
	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				if(M.special_role)
					possible_targets[M] = 0						//bad-guy
				else if(M.assigned_role in GLOB.command_positions)
					possible_targets[M] = 1						//good-guy

	var/list/possible_objectives = list(1,2,3,4)

	while(objectives.len < quantity)
		switch(pick_n_take(possible_objectives))
			if(1)	//research
				var/datum/objective/download/O = new /datum/objective/download()
				O.owner = owner
				O.gen_amount_goal()
				objectives += O

			if(2)	//steal
				var/datum/objective/steal/special/O = new /datum/objective/steal/special()
				O.owner = owner
				objectives += O

			if(3)	//protect/kill
				if(!possible_targets.len)	continue
				var/index = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[index]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(index,index+1)

				if(is_bad_guy ^ helping_station)			//kill (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/assassinate/O = new /datum/objective/assassinate()
					O.owner = owner
					O.target = M
					O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
					objectives += O
				else										//protect
					var/datum/objective/protect/O = new /datum/objective/protect()
					O.owner = owner
					O.target = M
					O.explanation_text = "Protect \the [M.current.real_name], the [M.assigned_role], from harm."
					objectives += O
			if(4)	//debrain/capture
				if(!possible_targets.len)	continue
				var/selected = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[selected]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(selected,selected+1)

				if(is_bad_guy ^ helping_station)			//debrain (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/debrain/O = new /datum/objective/debrain()
					O.owner = owner
					O.target = M
					O.explanation_text = "Steal the brain of [M.current.real_name]."
					objectives += O
				else										//capture
					var/datum/objective/capture/O = new /datum/objective/capture()
					O.owner = owner
					O.gen_amount_goal()
					objectives += O
			else
				break
	var/datum/objective/O = new /datum/objective/survive()
	O.owner = owner
	owner.objectives |= objectives


/proc/remove_ninja(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/datum = L.mind.has_antag_datum(ANTAG_DATUM_NINJA)
	datum.on_removal()
	return TRUE

/proc/add_ninja(mob/living/carbon/human/H, type = ANTAG_DATUM_NINJA_RANDOM)
	if(!H || !H.mind)
		return FALSE
	return H.mind.add_antag_datum(type)

/proc/is_ninja(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_NINJA)


/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/effects/ninja_greeting.ogg'))
	to_chat(owner.current, "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	to_chat(owner.current, "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	to_chat(owner.current, "Officially, [helping_station?"Nanotrasen":"The Syndicate"] are my employer.")
	return

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		addObjectives()
	addMemories()

/datum/antagonist/ninja/antag_panel_section(datum/mind/mind, mob/current)
	if(!ishuman(current))
		return FALSE
	var/text = "ninja"
	if(SSticker.mode.config_tag == "ninja")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	var/datum/antagonist/ninja/ninjainfo = mind.has_antag_datum(ANTAG_DATUM_NINJA)
	if(ninjainfo)
		if(ninjainfo.helping_station)
			text += "<a href='?src=[REF(mind)];ninja=clear'>employee</a>  |  syndicate  |  <b>NANOTRASEN</b>  |  <b><a href='?src=[REF(mind)];ninja=equip'>EQUIP</a></b>"
		else
			text += "<a href='?src=[REF(mind)];ninja=clear'>employee</a>  |  <b>SYNDICATE</b>  |  nanotrasen  |  <b><a href='?src=[REF(mind)];ninja=equip'>EQUIP</a></b>"
	else
		text += "<b>EMPLOYEE</b>  |  <a href='?src=[REF(mind)];ninja=syndicate'>syndicate</a>  |  <a href='?src=[REF(mind)];ninja=nanotrasen'>nanotrasen</a>  |  <a href='?src=[REF(mind)];ninja=random'>random allegiance</a>"
	if(current && current.client && (ROLE_NINJA in current.client.prefs.be_special))
		text += "  |  Enabled in Prefs"
	else
		text += "  |  Disabled in Prefs"
	return text

/datum/antagonist/ninja/antag_panel_href(href, datum/mind/mind, mob/current)
	var/datum/antagonist/ninja/ninjainfo = mind.has_antag_datum(ANTAG_DATUM_NINJA)
	switch(href)
		if("clear")
			remove_ninja(current)
			message_admins("[key_name_admin(usr)] has de-ninja'ed [current].")
			log_admin("[key_name(usr)] has de-ninja'ed [current].")
		if("equip")
			ninjainfo.equip_space_ninja()
			return
		if("nanotrasen")
			add_ninja(current, ANTAG_DATUM_NINJA_FRIENDLY)
			message_admins("[key_name_admin(usr)] has friendly ninja'ed [current].")
			log_admin("[key_name(usr)] has friendly ninja'ed [current].")
		if("syndicate")
			add_ninja(current, ANTAG_DATUM_NINJA)
			message_admins("[key_name_admin(usr)] has syndie ninja'ed [current].")
			log_admin("[key_name(usr)] has syndie ninja'ed [current].")
		if("random")
			add_ninja(current)
			message_admins("[key_name_admin(usr)] has random ninja'ed [current].")
			log_admin("[key_name(usr)] has random ninja'ed [current].")