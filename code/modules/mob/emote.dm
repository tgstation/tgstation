//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null)
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + 1, length(act) + 1)
		act = copytext(act, 1, custom_param)

	var/datum/emote/E
	E = E.emote_list[act]
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
		return
	E.run_emote(src, param, m_type)

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/flip/run_emote(mob/user, params)
	. = ..()
	if(.)
		user.SpinAnimation(7,1)

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/spin/run_emote(mob/user)
	. = ..()
	if(.)
		user.spin(20, 1)

		if(iscyborg(user) && user.has_buckled_mobs())
			var/mob/living/silicon/robot/R = user
			GET_COMPONENT_FROM(riding_datum, /datum/component/riding, R)
			if(riding_datum)
				for(var/mob/M in R.buckled_mobs)
					riding_datum.force_dismount(M)
			else
				R.unbuckle_all_mobs()

/datum/emote/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	muzzle_ignore = TRUE
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon/human, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/clap/run_emote(mob/user, params)
	. = ..()
	if (.)
		var/clap = pick('sound/misc/clap1.ogg',
				        'sound/misc/clap2.ogg',
				        'sound/misc/clap3.ogg',
				        'sound/misc/clap4.ogg')
		if (ishuman(user))
			// Need hands to clap
			var/mob/living/carbon/human/H = user
			if (!H.get_bodypart("l_arm") || !H.get_bodypart("r_arm"))
				return
			playsound(H, clap, 50, 1, -1)
		else if (isobserver(user))
			playsound(user, clap, 50, 1, -1, 0, null, 0, FALSE, TRUE, TRUE)