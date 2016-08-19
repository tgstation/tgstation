/mob/living/carbon/alien/say(message)
	. = ..(message, "A")
	if(.)
		playsound(loc, "hiss", 25, 1, 1) //erp just isn't the same without sound feedback

/mob/living/proc/alien_talk(message, shown_name = name)
	log_say("[key_name(src)] : [message]")
	message = trim(message)
	if(!message) return

	var/message_a = say_quote(message, get_spans())
	var/rendered = "<i><span class='alien'>Hivemind, <span class='name'>[shown_name]</span> <span class='message'>[message_a]</span></span></i>"
	for(var/mob/S in player_list)
		if((!S.stat && S.hivecheck()) || (S in dead_mob_list))
			S << rendered

/mob/living/carbon/alien/humanoid/queen/alien_talk(message, shown_name = name)
	shown_name = "<FONT size = 3>[shown_name]</FONT>"
	..(message, shown_name)

/mob/living/carbon/hivecheck()
	return getorgan(/obj/item/organ/internal/alien/hivenode)
