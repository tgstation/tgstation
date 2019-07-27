//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + 1, length(act) + 1)
		act = copytext(act, 1, custom_param)

<<<<<<< HEAD

	var/list/key_emotes = GLOB.emote_list[act]

	if(!length(key_emotes))
		if(intentional)
			to_chat(src, "<span class='notice'>'[act]' emote does not exist. Say *help for a list.</span>")
		return
	for(var/datum/emote/P in key_emotes)
		if(P.run_emote(src, param, m_type, intentional))
			return
	if(intentional)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
=======
	var/datum/emote/E
	E = E.emote_list[act]
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
		return
	E.run_emote(src, param, m_type, intentional)
>>>>>>> Updated this old code to fork

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

<<<<<<< HEAD
/datum/emote/flip/run_emote(mob/user, params , type_override, intentional)
=======
/datum/emote/flip/run_emote(mob/user, params)
>>>>>>> Updated this old code to fork
	. = ..()
	if(.)
		user.SpinAnimation(7,1)

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

<<<<<<< HEAD
/datum/emote/spin/run_emote(mob/user, params ,  type_override, intentional)
=======
/datum/emote/spin/run_emote(mob/user)
>>>>>>> Updated this old code to fork
	. = ..()
	if(.)
		user.spin(20, 1)

		if(iscyborg(user) && user.has_buckled_mobs())
			var/mob/living/silicon/robot/R = user
<<<<<<< HEAD
			var/datum/component/riding/riding_datum = R.GetComponent(/datum/component/riding)
=======
			GET_COMPONENT_FROM(riding_datum, /datum/component/riding, R)
>>>>>>> Updated this old code to fork
			if(riding_datum)
				for(var/mob/M in R.buckled_mobs)
					riding_datum.force_dismount(M)
			else
				R.unbuckle_all_mobs()
