/datum/game_mode
	var/list/datum/mind/sintouched = list()
	var/list/datum/mind/demons = list()
	var/demon_ascended = 0 // Number of arch demons on station

/datum/game_mode/proc/auto_declare_completion_sintouched()
	var/text = ""
	if(sintouched.len)
		text += "<br><span class='big'><b>The sintouched were:</b></span>"
		var/list/sintouchedUnique = uniqueList(sintouched)
		for(var/datum/mind/sintouched_mind in sintouchedUnique)
			text += printplayer(sintouched_mind)
			text += printobjectives(sintouched_mind)
		text += "<br>"
	text += "<br>"
	world << text

/datum/game_mode/proc/auto_declare_completion_demons()
	/var/text = ""
	if(demons.len)
		text += "<br><span class='big'><b>The demons were:</b></span>"
		for(var/datum/mind/demon in demons)
			text += printplayer(demon)
			text += printdemoninfo(demon)
			text += printobjectives(demon)
		text += "<br>"
	world << text

/datum/game_mode/demon


/datum/game_mode/proc/finalize_demon(datum/mind/demon_mind)
	var/mob/living/carbon/human/S = demon_mind.current
	demon_mind.demoninfo.give_base_spells(1)
	var/trueName= randomDemonName()
	var/datum/objective/demon/soulquantity/soulquant = new
	soulquant.owner = demon_mind
	var/datum/objective/demon/soulquality/soulqual = new
	soulqual.owner = demon_mind
	demon_mind.objectives += soulqual
	demon_mind.objectives += soulquant
	demon_mind.demoninfo = demonInfo(trueName, 1)
	demon_mind.store_memory("Your demonic true name is [demon_mind.demoninfo.truename]<br>[demon_mind.demoninfo.banlaw()]<br>[demon_mind.demoninfo.banelaw()]<br>[demon_mind.demoninfo.obligationlaw()]<br>")
	demon_mind.demoninfo.owner = demon_mind
	spawn(10)
		if(demon_mind.assigned_role == "Clown")
			S << "<span class='notice'>Your infernal nature has allowed you to overcome your clownishness.</span>"
			S.dna.remove_mutation(CLOWNMUT)

/datum/mind/proc/announceDemonLaws()
	if(!demoninfo)
		return
	current << "<span class='warning'><b>You remember your link to the infernal.  You are [src.demoninfo.truename], an agent of hell, a demon.  And you were sent to the plane of 		creation for a reason.  A greater  \
		purpose.  Convince the crew to sin, and embroiden Hell's grasp. \
		</b></span>"
	current << "<span class='warning'><b>However, your infernal form is not without weaknesses.</b></span>"
	current << src.demoninfo.banelaw()
	current << src.demoninfo.banlaw()
	current << src.demoninfo.obligationlaw()
	current << "<br/><br/> <span class='warning'>Remember, the crew can research your weaknesses if they find out your demon name.</span><br>"
	var/obj_count = 1
	current << "<span class='notice'>Your current objectives:</span>"
	for(var/datum/objective/objective in objectives)
		current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
