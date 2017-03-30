/mob/living/proc/alien_talk(message, shown_name = name)
	log_say("[key_name(src)] : [message]")
	message = trim(message)
	if(!message) return

	var/message_a = say_quote(message, get_spans())
	var/rendered = "<i><span class='alien'>Hivemind, <span class='name'>[shown_name]</span> <span class='message'>[message_a]</span></span></i>"
	for(var/mob/S in player_list)
		if(!S.stat && S.hivecheck())
			to_chat(S, rendered)
		if(S in dead_mob_list)
			var/link = FOLLOW_LINK(S, src)
			to_chat(S, "[link] [rendered]")

/mob/living/carbon/alien/humanoid/royal/queen/alien_talk(message, shown_name = name)
	shown_name = "<FONT size = 3>[shown_name]</FONT>"
	..(message, shown_name)

/mob/living/carbon/hivecheck()
	var/obj/item/organ/alien/hivenode/N = getorgan(/obj/item/organ/alien/hivenode)
	if(N && !N.recent_queen_death) //Mob has alien hive node and is not under the dead queen special effect.
		return N
