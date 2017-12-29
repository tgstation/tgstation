/datum/antagonist/shadowling
	name = "Shadowling"
	job_rank = ROLE_SHADOWLING
	roundend_category = "shadowlings"
	var/list/objectives_given = list()

/datum/antagonist/shadowling/on_gain()
	. = ..()
	SSticker.mode.update_shadow_icons_added(owner)
	SSticker.mode.shadows += owner
	owner.special_role = "thrall"
	message_admins("[key_name_admin(owner.current)] was made into a shadowling!")
	log_game("[key_name(owner.current)] was made into a shadowling!")

	var/mob/living/carbon/human/S = owner.current
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_hatch(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_hivemind(null))

	if(owner.assigned_role == "Clown")
		to_chat(S, "<span class='notice'>Your alien nature has allowed you to overcome your clownishness.</span>")
		S.dna.remove_mutation(CLOWNMUT)

	var/datum/objective/ascend/O = new
	O.update_explanation_text()
	owner.objectives += O
	objectives_given += O
	owner.announce_objectives()

/datum/antagonist/shadowling/on_removal()
	for(var/O in objectives_given)
		owner.objectives -= O
	SSticker.mode.update_shadow_icons_removed(owner)
	SSticker.mode.shadows.Remove(owner)
	message_admins("[key_name_admin(owner.current)] was de-shadowlinged!")
	log_game("[key_name(owner.current)] was de-shadowlinged!")
	owner.special_role = null
	for(var/obj/effect/proc_holder/spell/S in owner.spell_list)
		owner.RemoveSpell(S)
	var/mob/living/M = owner.current
	if(issilicon(M))
		M.audible_message("<span class='notice'>[M] lets out a short blip.</span>", \
						  "<span class='userdanger'>You have been turned into a robot! You are no longer a shadowling! Though you try, you cannot remember anything about your time as one...</span>")
	else if(is_species(M, /datum/species/shadow/ling)) //a non antag full-powered shadowling is REALLY REALLY BAD for balance reasons
		M.visible_message("<span class='big'>[M] screams and contorts!</span>", \
						  "<span class='userdanger'>THE LIGHT-- YOUR MIND-- <i>BURNS--</i></span>")
		addtimer(CALLBACK(src, .proc/explodify), 30)


/datum/antagonist/shadowling/proc/explodify()
	if(!M || QDELETED(M))
		return
	M.visible_message("<span class='warning'>[M] suddenly bloats and explodes!</span>", \
					  "<span class='warning'><b>AAAAAAAAA<font size=3>AAAAAAAAAAAAA</font><font size=4>AAAAAAAAAAAA----</font></span>")
	playsound(M, 'sound/magic/Disintegrate.ogg', 100, 1)
	M.gib()

/datum/antagonist/shadowling/greet()
	to_chat(owner, "<br> <span class='shadowling'><b><font size=3>You are a shadowling!</font></b></span>")
	to_chat(owner, "<b>Currently, you are disguised as an employee aboard [station_name()]].</b>")
	to_chat(owner, "<b>In your limited state, you have three abilities: Enthrall, Hatch, and Hivemind Commune.</b>")
	to_chat(owner, "<b>Any other shadowlings are your allies. You must assist them as they shall assist you.</b>")
	to_chat(owner, "<b>If you are new to shadowling, or want to read about abilities, check the wiki page at https://wiki.hippiestation.com/index.php?title=Shadowling</b><br>")
	to_chat(owner, "<b>You require [SSticker.mode.required_thralls || 15] thralls to ascend.</b><br>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/sling.ogg'))

/datum/antagonist/shadowling/proc/check_shadow_death()
	for(var/datum/mind/shadow_mind in get_antagonists(/datum/antagonist/shadowling))
		var/turf/T = get_turf(shadow_mind.current)
		if((shadow_mind) && (shadow_mind.current) && (shadow_mind.current.stat != DEAD) && T && (T.z in GLOB.station_z_levels) && ishuman(shadow_mind.current))
			return FALSE
	return TRUE

/datum/antagonist/shadowling/roundend_report()
	var/list/parts = list()

	if(SSticker.mode.shadowling_ascended) //Doesn't end instantly - this is hacky and I don't know of a better way ~X
		parts += "<span class='greentext big'>The shadowlings have ascended and taken over the station!</span>"
	else if(!SSticker.mode.shadowling_ascended && check_shadow_death()) //If the shadowlings have ascended, they can not lose the round
		parts += "<span class='redtext big'>The shadowlings have been killed by the crew!</span>"
	else if(!SSticker.mode.shadowling_ascended && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		parts += "<span class='redtext big'>The crew escaped the station before the shadowlings could ascend!</span>"
	else
		parts += "<span class='redtext big'>The shadowlings have failed!</span>"

	if(objectives.len)
		parts += "<b>The shadowlings' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
			count++

	if(LAZYLEN(SSticker.mode.shadows))
		parts += printplayerlist(SSticker.mode.shadows)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"


/datum/objective/ascend
	explanation_text = "Ascend to your true form by use of the Ascendance ability. This may only be used with 15 or more collective thralls, while hatched, and is unlocked with the Collective Mind ability."

/datum/objective/ascend/check_completion()
	if(SSticker && SSticker.mode && SSticker.mode.shadowling_ascended)
		return TRUE
	return FALSE

/datum/objective/ascend/update_explanation_text()
	explanation_text = "Ascend to your true form by use of the Ascendance ability. This may only be used with [SSticker.mode.required_thralls] or more collective thralls, while hatched, and is unlocked with the Collective Mind ability."
