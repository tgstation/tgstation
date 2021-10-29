/mob/living/carbon/examine_more(mob/user)
	var/msg = list("<span class='notice'><i>You examine [src] closer, and note the following...</i></span>")
	var/t_His = p_their(TRUE)
	var/t_He = p_they(TRUE)
	var/t_Has = p_have()

	var/any_bodypart_damage = FALSE
	for(var/X in bodyparts)
		var/obj/item/bodypart/LB = X
		if(LB.is_pseudopart)
			continue
		var/limb_max_damage = LB.max_damage
		var/status = ""
		var/brutedamage = round(LB.brute_dam/limb_max_damage*100)
		var/burndamage = round(LB.burn_dam/limb_max_damage*100)
		switch(brutedamage)
			if(20 to 50)
				status = LB.light_brute_msg
			if(51 to 75)
				status = LB.medium_brute_msg
			if(76 to 100)
				status += LB.heavy_brute_msg

		if(burndamage >= 20 && status)
			status += " and "
		switch(burndamage)
			if(20 to 50)
				status += LB.light_burn_msg
			if(51 to 75)
				status += LB.medium_burn_msg
			if(76 to 100)
				status += LB.heavy_burn_msg

		if(status)
			any_bodypart_damage = TRUE
			msg += "\t<span class='warning'>[t_His] [LB.name] is [status].</span>"

		for(var/thing in LB.wounds)
			any_bodypart_damage = TRUE
			var/datum/wound/W = thing
			switch(W.severity)
				if(WOUND_SEVERITY_TRIVIAL)
					msg += "\t<span class='warning'>[t_His] [LB.name] is suffering [W.a_or_from] [W.get_topic_name(user)].</span>"
				if(WOUND_SEVERITY_MODERATE)
					msg += "\t<span class='warning'>[t_His] [LB.name] is suffering [W.a_or_from] [W.get_topic_name(user)]!</span>"
				if(WOUND_SEVERITY_SEVERE)
					msg += "\t<span class='warning'><b>[t_His] [LB.name] is suffering [W.a_or_from] [W.get_topic_name(user)]!</b></span>"
				if(WOUND_SEVERITY_CRITICAL)
					msg += "\t<span class='warning'><b>[t_His] [LB.name] is suffering [W.a_or_from] [W.get_topic_name(user)]!!</b></span>"
		if(LB.current_gauze)
			var/datum/bodypart_aid/current_gauze = LB.current_gauze
			msg += "\t<span class='notice'><i>[t_His] [LB.name] is [current_gauze.desc_prefix] with <a href='?src=[REF(current_gauze)];remove=1'>[current_gauze.get_description()]</a>.</i></span>"
		if(LB.current_splint)
			var/datum/bodypart_aid/current_splint = LB.current_splint
			msg += "\t<span class='notice'><i>[t_His] [LB.name] is [current_splint.desc_prefix] with <a href='?src=[REF(current_splint)];remove=1'>[current_splint.get_description()]</a>.</i></span>"

	if(!any_bodypart_damage)
		msg += "\t<span class='smallnotice'><i>[t_He] [t_Has] no significantly damaged bodyparts.</i></span>"

	var/list/visible_scars
	if(all_scars)
		for(var/i in all_scars)
			var/datum/scar/S = i
			if(S.is_visible(user))
				LAZYADD(visible_scars, S)

	if(!visible_scars)
		msg |= "\t<span class='smallnotice'><i>[t_He] [t_Has] no visible scars.</i></span>"
	else
		for(var/i in visible_scars)
			var/datum/scar/S = i
			var/scar_text = S.get_examine_description(user)
			if(scar_text)
				msg += "[scar_text]"

	return msg
