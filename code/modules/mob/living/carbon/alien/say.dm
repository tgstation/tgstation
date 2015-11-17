/mob/living/carbon/alien/say(var/message)
	. = ..(message, "A")
	if(.)
		playsound(loc, "hiss", 25, 1, 1) //erp just isn't the same without sound feedback

/mob/living/proc/alien_talk(message, shown_name = name)
	log_say("[key_name(src)] : [message]")
	message = trim(message)

	if (!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<i><span class='alien'>Hivemind, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
	for(var/mob/S in player_list)
		if((!S.stat && S.hivecheck()))
			S << rendered
	for (var/mob/M in dead_mob_list)
		if(!istype(M,/mob/new_player) && !istype(M,/mob/living/carbon/brain)) //No meta-evesdropping
			rendered = "<i><span class='alien'>Hivemind, <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a><span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
			M << rendered

/mob/living/carbon/alien/humanoid/queen/alien_talk(message, shown_name = name)
	shown_name = "<FONT size = 3>[shown_name]</FONT>"
	..(message, shown_name)

/mob/living/carbon/hivecheck()
	var/datum/organ/internal/alien/hivenode/HN = get_organ("hivenode")
	return (HN && HN.exists())